//// Build-time maintenance of the root `website-manifest.json`.
////
//// The production build records each default-language post's last-update
//// date, keyed by slug. Entries are written newest first and `latest_post`
//// names the newest one explicitly, so readers do not have to depend on JSON
//// object ordering after another tool rewrites the manifest.

import gleam/json
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import simplifile

pub type Error {
  CouldNotListBlog(path: String, reason: simplifile.FileError)
  CouldNotRead(path: String, reason: simplifile.FileError)
  CouldNotWrite(path: String, reason: simplifile.FileError)
  MissingDate(path: String)
  MissingSlug(path: String)
  InvalidDate(path: String, raw: String)
  MissingManifestSection(name: String)
}

type PostDate {
  PostDate(slug: String, date: String)
}

/// Recompute the post-date sections from the djot sources and write them back
/// to the manifest without disturbing its image hashes or FTP cache.
pub fn update_post_dates(
  blog_directory: String,
  manifest_path: String,
) -> Result(Int, Error) {
  use entries <- result.try(
    simplifile.read_directory(blog_directory)
    |> result.map_error(fn(reason) { CouldNotListBlog(blog_directory, reason) }),
  )
  use original <- result.try(
    simplifile.read(manifest_path)
    |> result.map_error(fn(reason) { CouldNotRead(manifest_path, reason) }),
  )
  use posts <- result.try(collect_post_dates(blog_directory, entries))
  let newest_first = list.sort(posts, newest_first)
  let updated =
    original
    |> upsert_section("posts", render_posts_section(newest_first))
    |> result.try(fn(content) {
      case newest_first {
        [] -> Ok(content)
        [latest, ..] ->
          upsert_section(content, "latest_post", render_latest_section(latest))
      }
    })

  use content <- result.try(updated)
  use Nil <- result.try(
    simplifile.write(manifest_path, content)
    |> result.map_error(fn(reason) { CouldNotWrite(manifest_path, reason) }),
  )
  Ok(list.length(posts))
}

pub fn describe_error(error: Error) -> String {
  case error {
    CouldNotListBlog(path, reason) ->
      "could not list " <> path <> ": " <> simplifile.describe_error(reason)
    CouldNotRead(path, reason) ->
      "could not read " <> path <> ": " <> simplifile.describe_error(reason)
    CouldNotWrite(path, reason) ->
      "could not write " <> path <> ": " <> simplifile.describe_error(reason)
    MissingDate(path) -> path <> " has no date in its frontmatter"
    MissingSlug(path) -> path <> " has no slug in its frontmatter"
    InvalidDate(path, raw) -> path <> " has an invalid date: " <> raw
    MissingManifestSection(name) ->
      "website-manifest.json has no " <> name <> " section"
  }
}

fn collect_post_dates(
  blog_directory: String,
  entries: List(String),
) -> Result(List(PostDate), Error) {
  list.try_fold(entries, [], fn(acc, entry) {
    let directory = blog_directory <> "/" <> entry
    use is_directory <- result.try(
      simplifile.is_directory(directory)
      |> result.map_error(fn(reason) { CouldNotRead(directory, reason) }),
    )
    case is_directory {
      False -> Ok(acc)
      True -> read_post_date(directory, acc)
    }
  })
}

fn read_post_date(
  directory: String,
  acc: List(PostDate),
) -> Result(List(PostDate), Error) {
  let path = directory <> "/index.djot"
  use is_source <- result.try(
    simplifile.is_file(path)
    |> result.map_error(fn(reason) { CouldNotRead(path, reason) }),
  )
  case is_source {
    False -> Ok(acc)
    True -> {
      use source <- result.try(
        simplifile.read(path)
        |> result.map_error(fn(reason) { CouldNotRead(path, reason) }),
      )
      let fields = frontmatter(source)
      use raw_slug <- result.try(
        field(fields, "slug")
        |> result.replace_error(MissingSlug(path)),
      )
      use raw_date <- result.try(
        field(fields, "date")
        |> result.replace_error(MissingDate(path)),
      )
      use date <- result.try(
        normalize_date(raw_date)
        |> result.replace_error(InvalidDate(path, raw_date)),
      )
      Ok([PostDate(slug: raw_slug, date: date), ..acc])
    }
  }
}

fn frontmatter(source: String) -> List(String) {
  source
  |> string.split("\n")
  |> list.drop(1)
  |> list.take_while(fn(line) { string.trim(line) != "---" })
}

fn field(lines: List(String), name: String) -> Result(String, Nil) {
  let prefix = name <> ":"
  list.find_map(lines, fn(line) {
    let trimmed = string.trim(line)
    case string.starts_with(trimmed, prefix) {
      True ->
        Ok(
          strip_quotes(
            string.trim(string.drop_start(trimmed, string.length(prefix))),
          ),
        )
      False -> Error(Nil)
    }
  })
}

fn strip_quotes(value: String) -> String {
  case string.first(value), string.last(value) {
    Ok("\""), Ok("\"") ->
      value
      |> string.drop_start(1)
      |> string.drop_end(1)
    Ok("'"), Ok("'") -> value |> string.drop_start(1) |> string.drop_end(1)
    _, _ -> value
  }
}

/// Blogatto writes `YYYY-MM-DD HH:MM:SS +HH:MM`; RFC 3339 in UTC makes the
/// recorded values directly comparable regardless of the source offset.
fn normalize_date(raw: String) -> Result(String, Nil) {
  let input = case string.split_once(raw, " ") {
    Ok(#(date, time_and_zone)) ->
      case string.split_once(time_and_zone, " ") {
        Ok(#(time, offset)) -> date <> "T" <> time <> offset
        Error(Nil) -> date <> "T" <> time_and_zone <> "+00:00"
      }
    Error(Nil) -> raw
  }
  case timestamp.parse_rfc3339(input) {
    Ok(parsed) -> Ok(timestamp.to_rfc3339(parsed, calendar.utc_offset))
    Error(_) -> Error(Nil)
  }
}

fn newest_first(left: PostDate, right: PostDate) -> order.Order {
  case string.compare(right.date, left.date) {
    order.Eq -> string.compare(left.slug, right.slug)
    other -> other
  }
}

fn quoted(value: String) -> String {
  value |> json.string |> json.to_string
}

fn render_posts_section(posts: List(PostDate)) -> String {
  case posts {
    [] -> "  \"posts\": {}"
    _ -> {
      let entries =
        list.map(posts, fn(post) {
          "    " <> quoted(post.slug) <> ": " <> quoted(post.date)
        })
      "  \"posts\": {\n" <> string.join(entries, ",\n") <> "\n  }"
    }
  }
}

fn render_latest_section(post: PostDate) -> String {
  "  \"latest_post\": {\n"
  <> "    \"slug\": "
  <> quoted(post.slug)
  <> ",\n"
  <> "    \"date\": "
  <> quoted(post.date)
  <> "\n"
  <> "  }"
}

/// Replace an existing top-level section, or insert a new one just before the
/// FTP cache. The surrounding manifest text is left byte-for-byte intact.
fn upsert_section(
  manifest: String,
  name: String,
  section: String,
) -> Result(String, Error) {
  let lines = string.split(manifest, "\n")
  case find_index(lines, section_start(name)) {
    Ok(start) -> {
      let suffix = list.drop(lines, start + 1)
      use relative_end <- result.try(
        find_index(suffix, is_section_end)
        |> result.replace_error(MissingManifestSection(name)),
      )
      let end = start + 1 + relative_end
      let comma = closing_line_has_comma(lines, end)
      Ok(string.join(
        list.append(
          list.take(lines, start),
          list.append(
            string.split(with_comma(section, comma), "\n"),
            list.drop(lines, end + 1),
          ),
        ),
        "\n",
      ))
    }
    Error(Nil) ->
      case find_index(lines, fn(line) { line == "  \"ftp\": {" }) {
        Ok(index) ->
          Ok(string.join(
            list.append(
              list.take(lines, index),
              list.append(
                string.split(with_comma(section, True), "\n"),
                list.drop(lines, index),
              ),
            ),
            "\n",
          ))
        Error(Nil) -> insert_before_last_brace(lines, section)
      }
  }
}

fn insert_before_last_brace(
  lines: List(String),
  section: String,
) -> Result(String, Error) {
  let reversed = list.reverse(lines)
  use reversed_index <- result.try(
    find_index(reversed, fn(line) { line == "}" })
    |> result.replace_error(MissingManifestSection("closing brace")),
  )
  let index = list.length(lines) - reversed_index - 1
  Ok(string.join(
    list.append(
      ensure_trailing_comma(list.take(lines, index)),
      list.append(string.split(section, "\n"), list.drop(lines, index)),
    ),
    "\n",
  ))
}

fn ensure_trailing_comma(lines: List(String)) -> List(String) {
  case list.reverse(lines) {
    [last, ..rest] ->
      case has_content(last) && !string.ends_with(last, ",") {
        True -> list.reverse([last <> ",", ..rest])
        False -> lines
      }
    [] -> lines
  }
}

fn has_content(line: String) -> Bool {
  string.trim(line) != ""
}

fn closing_line_has_comma(lines: List(String), index: Int) -> Bool {
  case list.take(list.drop(lines, index), 1) {
    [line, ..] -> line == "  },"
    [] -> False
  }
}

fn with_comma(section: String, comma: Bool) -> String {
  case comma {
    True -> section <> ","
    False -> section
  }
}

fn section_start(name: String) -> fn(String) -> Bool {
  fn(line) {
    line == "  \"" <> name <> "\": {" || line == "  \"" <> name <> "\": {}"
  }
}

fn is_section_end(line: String) -> Bool {
  line == "  }," || line == "  }"
}

fn find_index(
  lines: List(String),
  predicate: fn(String) -> Bool,
) -> Result(Int, Nil) {
  do_find_index(lines, predicate, 0)
}

fn do_find_index(
  lines: List(String),
  predicate: fn(String) -> Bool,
  index: Int,
) -> Result(Int, Nil) {
  case lines {
    [] -> Error(Nil)
    [line, ..rest] ->
      case predicate(line) {
        True -> Ok(index)
        False -> do_find_index(rest, predicate, index + 1)
      }
  }
}
