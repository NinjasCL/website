//// Build-time cache for GitHub repository embed images.
////
//// The old site fetched each repository page once, cached the HTML under
//// `.opengraph/{md5}.html.cache`, and reused it. This module keeps that
//// cache key and also stores the social-card image next to the HTML, then
//// copies it into the generated site so the visitor's browser never has
//// to ask GitHub for a card image. Every failure falls back to GitHub's
//// deterministic `/1/owner/repo` URL rather than breaking the build.

import gleam/bit_array
import gleam/crypto
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/result
import gleam/string
import simplifile

const cache_directory = ".opengraph"

const output_directory = "./dist/opengraph"

const user_agent = "Mozilla/5.0 (compatible; ninjas.cl build)"

/// The site-local URL a repository's cached social-card image is served
/// from. Pure so the embed renderer can use it without touching the cache.
pub fn local_image_path(repo: String) -> String {
  "/opengraph/" <> cache_key(repo) <> ".png"
}

/// The cache-aware image source used by production builds. On a warm
/// cache it only copies the existing image into the site; on a miss it
/// fetches and caches the repository page and image first.
pub fn image_source(repo: String) -> String {
  image_source_in(
    repo,
    cache_directory,
    output_directory,
    fetch_html,
    fetch_image,
  )
}

/// The same behavior as `image_source` with explicit directories and
/// fetchers, so tests can exercise caching without network access or
/// touching the real build output.
pub fn image_source_in(
  repo: String,
  cache: String,
  output: String,
  fetch_html: fn(String) -> Result(String, Nil),
  fetch_image: fn(String) -> Result(BitArray, Nil),
) -> String {
  let repo = strip_trailing_slash(repo)
  let key = cache_key(repo)
  let local = local_image_path(repo)
  let fallback = social_image_url(repo)
  let cached_file = cache <> "/" <> key <> ".png"

  case simplifile.is_file(cached_file) {
    Ok(True) -> publish(cached_file, output, key, local, fallback)
    _ ->
      warm_cache(
        repo,
        key,
        cache,
        cached_file,
        output,
        local,
        fallback,
        fetch_html,
        fetch_image,
      )
  }
}

fn warm_cache(
  repo: String,
  key: String,
  cache: String,
  cached_file: String,
  output: String,
  local: String,
  fallback: String,
  fetch_html: fn(String) -> Result(String, Nil),
  fetch_image: fn(String) -> Result(BitArray, Nil),
) -> String {
  let html_file = cache <> "/" <> key <> ".html.cache"
  let html =
    cached_or_fetched_html(html_file, repository_url(repo), cache, fetch_html)
  let image_url = case html {
    Ok(page) -> result.unwrap(og_image(page), or: fallback)
    Error(Nil) -> fallback
  }

  case fetch_image_bytes(image_url, fallback, fetch_image) {
    Ok(image) ->
      case write_bits(cache, cached_file, image) {
        Ok(Nil) -> publish(cached_file, output, key, local, fallback)
        Error(Nil) -> fallback
      }
    Error(Nil) -> fallback
  }
}

fn cached_or_fetched_html(
  html_file: String,
  url: String,
  cache: String,
  fetch_html: fn(String) -> Result(String, Nil),
) -> Result(String, Nil) {
  case simplifile.read(html_file) {
    Ok(html) -> Ok(html)
    Error(_) ->
      case fetch_html(url) {
        Ok(html) -> {
          let _ = write_text(cache, html_file, html)
          Ok(html)
        }
        Error(Nil) -> Error(Nil)
      }
  }
}

fn fetch_image_bytes(
  url: String,
  fallback: String,
  fetch_image: fn(String) -> Result(BitArray, Nil),
) -> Result(BitArray, Nil) {
  case result.try(fetch_image(url), non_empty) {
    Ok(image) -> Ok(image)
    Error(Nil) ->
      case url == fallback {
        True -> Error(Nil)
        False -> result.try(fetch_image(fallback), non_empty)
      }
  }
}

fn non_empty(bits: BitArray) -> Result(BitArray, Nil) {
  case bit_array.byte_size(bits) {
    0 -> Error(Nil)
    _ -> Ok(bits)
  }
}

fn publish(
  cached_file: String,
  output: String,
  key: String,
  local: String,
  fallback: String,
) -> String {
  let output_file = output <> "/" <> key <> ".png"
  case create_directory(output) {
    Error(Nil) -> fallback
    Ok(Nil) ->
      case simplifile.copy_file(cached_file, output_file) {
        Ok(Nil) -> local
        Error(_) -> fallback
      }
  }
}

fn create_directory(path: String) -> Result(Nil, Nil) {
  simplifile.create_directory_all(path) |> result.map_error(fn(_) { Nil })
}

fn write_text(dir: String, path: String, content: String) -> Result(Nil, Nil) {
  use Nil <- result.try(create_directory(dir))
  simplifile.write(path, content) |> result.map_error(fn(_) { Nil })
}

fn write_bits(
  dir: String,
  path: String,
  content: BitArray,
) -> Result(Nil, Nil) {
  use Nil <- result.try(create_directory(dir))
  simplifile.write_bits(path, content) |> result.map_error(fn(_) { Nil })
}

/// The social-card image URL from a GitHub page's OpenGraph or Twitter
/// metadata, preferring the OpenGraph value.
fn og_image(html: String) -> Result(String, Nil) {
  case meta_content(html, "property", "og:image") {
    Ok(url) -> Ok(url)
    Error(Nil) -> meta_content(html, "name", "twitter:image")
  }
}

fn meta_content(
  html: String,
  attribute: String,
  value: String,
) -> Result(String, Nil) {
  let marker = attribute <> "=\"" <> value <> "\""
  use #(_, after_tag) <- result.try(string.split_once(html, marker))
  use #(_, after_content) <- result.try(string.split_once(
    after_tag,
    "content=\"",
  ))
  use #(content, _) <- result.try(string.split_once(after_content, "\""))
  case content {
    "" -> Error(Nil)
    content -> Ok(content)
  }
}

fn cache_key(repo: String) -> String {
  repo
  |> repository_url
  |> bit_array.from_string
  |> crypto.hash(crypto.Md5, _)
  |> bit_array.base16_encode
  |> string.lowercase
}

fn repository_url(repo: String) -> String {
  "https://github.com/" <> repo
}

fn social_image_url(repo: String) -> String {
  "https://opengraph.githubassets.com/1/" <> repo
}

fn strip_trailing_slash(value: String) -> String {
  case string.ends_with(value, "/") {
    True -> string.drop_end(value, 1)
    False -> value
  }
}

fn client() -> httpc.Configuration {
  httpc.configure() |> httpc.follow_redirects(True)
}

fn get_bits(url: String) -> Result(response.Response(BitArray), Nil) {
  case request.to(url) {
    Error(Nil) -> Error(Nil)
    Ok(request) -> {
      let request =
        request
        |> request.set_header("user-agent", user_agent)
        |> request.map(bit_array.from_string)
      httpc.dispatch_bits(client(), request) |> result.map_error(fn(_) { Nil })
    }
  }
}

fn fetch_html(url: String) -> Result(String, Nil) {
  case get_bits(url) {
    Ok(response) if response.status == 200 ->
      bit_array.to_string(response.body) |> result.map_error(fn(_) { Nil })
    _ -> Error(Nil)
  }
}

fn fetch_image(url: String) -> Result(BitArray, Nil) {
  case get_bits(url) {
    Ok(response) if response.status == 200 -> non_empty(response.body)
    _ -> Error(Nil)
  }
}
