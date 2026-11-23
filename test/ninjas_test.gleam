import blogatto/config.{type Config}
import blogatto/config/feed
import blogatto/config/feed/atom.{type AtomFeed}
import blogatto/post
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import gleeunit
import lustre/element
import ninjas/blog
import ninjas/github_opengraph
import ninjas/highlight
import ninjas/home
import simplifile
import site

pub fn main() -> Nil {
  gleeunit.main()
}

fn find_atom_feed(config: Config(Nil), output: String) -> AtomFeed(Nil) {
  let assert Ok(feed) =
    list.find(config.atom_feeds, fn(feed) { feed.output == output })
  feed
}

fn atom_feed_metadata(post: post.Post(Nil)) -> feed.FeedMetadata(Nil) {
  feed.FeedMetadata(path: post.url, post: post, url: post.url)
}

pub fn production_blog_config_test() {
  let config = blog.new(site.production_url)

  assert config.site_url == "https://ninjas.cl/"
  assert config.output_dir == "./dist"
  assert config.static_dir == option.Some("./static")

  let assert option.Some(post_config) = config.post_config
  assert post_config.paths == ["./blog"]
  assert post_config.route_prefix == option.Some("blog")

  // The syndication and crawler configs ride along in every build. Each
  // site language gets its own Atom feed at its own output path.
  assert list.length(config.atom_feeds) == 4
  let atom_outputs = list.map(config.atom_feeds, fn(feed) { feed.output })
  list.each(
    ["/atom.xml", "/en/atom.xml", "/ja/atom.xml", "/pt/atom.xml"],
    fn(output) {
      assert list.contains(atom_outputs, output)
    },
  )
  let assert [rss_feed] = config.rss_feeds
  assert rss_feed.output == "/rss.xml"
  let assert option.Some(sitemap_config) = config.sitemap
  assert sitemap_config.path == "/sitemap.xml"
  let assert option.Some(robots_config) = config.robots
  assert robots_config.sitemap_url == "https://ninjas.cl/sitemap.xml"
  let assert [robot] = robots_config.robots
  assert robot.user_agent == "*"
  assert robot.allowed_routes == ["/"]

  // The blog index routes regenerate from the catalog on every build: one
  // list page per 25-post page plus the /blog redirect.
  let assert Ok(entries) = simplifile.read_directory("./blog")
  let post_directories =
    list.filter(entries, fn(entry) {
      case simplifile.is_directory("./blog/" <> entry) {
        Ok(True) -> True
        _ -> False
      }
    })
  let expected_pages =
    int.max(
      { list.length(post_directories) + site.blog_page_size - 1 }
        / site.blog_page_size,
      1,
    )
  let routes = dict.keys(config.routes)
  int.range(from: 1, to: expected_pages + 1, with: Nil, run: fn(_, n) {
    let route = "/blog/page/" <> int.to_string(n)
    let assert True = list.contains(routes, route)
    Nil
  })
  let assert True = list.contains(routes, "/blog")

  // The home page ships in the site's four languages: the Spanish
  // default at the root, the translated homes at their language routes.
  list.each(["/en", "/ja", "/pt"], fn(route) {
    let assert True = list.contains(routes, route)
  })

  // The sitemap excludes the /blog redirect route (its absolute URL form)
  // and keeps the index page routes.
  let assert option.Some(filter) = sitemap_config.filter
  let assert False = filter(site.production_url <> "blog")
  let assert True = filter(site.production_url <> "blog/page/1")
}

pub fn atom_feeds_identify_their_languages_test() {
  // Each feed's id and self link point at the URL it is served from, and
  // its hreflang names the language whose variants it carries.
  let config = blog.new(site.production_url)
  let cases = [
    #("/atom.xml", site.site_language),
    #("/en/atom.xml", "en"),
    #("/ja/atom.xml", "ja"),
    #("/pt/atom.xml", "pt"),
  ]

  list.each(cases, fn(entry) {
    let #(output, hreflang) = entry
    let feed = find_atom_feed(config, output)
    let url =
      site.production_url <> string.slice(output, 1, string.length(output) - 1)
    assert feed.id == url
    assert feed.title == atom.PlainText(site.site_title)
    assert feed.subtitle == option.Some(site.site_description)
    assert list.length(feed.authors) == 1
    let assert option.Some(link) = feed.link
    assert link.href == url
    assert link.rel == option.Some("self")
    assert link.content_type == option.Some("application/atom+xml")
    assert link.hreflang == option.Some(hreflang)
  })
}

pub fn atom_feeds_filter_by_language_test() {
  // Each feed accepts exactly one of a post's four language variants: the
  // root feed takes the default variant, whose language is `None`.
  let config = blog.new(site.production_url)
  let variants = [
    index_test_post(10),
    index_test_variant(10, "en"),
    index_test_variant(10, "ja"),
    index_test_variant(10, "pt"),
  ]
  let cases = [
    #("/atom.xml", option.None),
    #("/en/atom.xml", option.Some("en")),
    #("/ja/atom.xml", option.Some("ja")),
    #("/pt/atom.xml", option.Some("pt")),
  ]

  list.each(cases, fn(entry) {
    let #(output, expected_language) = entry
    let feed_config = find_atom_feed(config, output)
    let assert option.Some(filter) = feed_config.filter
    let included =
      list.filter(variants, fn(post) { filter(atom_feed_metadata(post)) })
    assert list.length(included) == 1
    let assert [included_post] = included
    assert included_post.language == expected_language
  })
}

pub fn dev_blog_config_test() {
  let config = blog.new(site.dev_url)

  assert config.site_url == "http://127.0.0.1:3000/"
  assert config.output_dir == "./dist"
  assert config.static_dir == option.Some("./static")
}

pub fn blog_sources_are_djot_test() {
  // The content syntax is djot: the shipped post is a .djot source with
  // djot strong, and no markdown source remains under blog/.
  let assert Ok(post_source) =
    simplifile.read("./blog/bienvenidos-a-ninjas-cl/index.djot")
  assert post_source |> string.contains("*Ninjas.cl*")
  assert string.contains(post_source, "**") == False
  let assert Ok(False) =
    simplifile.is_file("./blog/bienvenidos-a-ninjas-cl/index.md")
  // The English and Japanese variants are djot sources too — same slug so
  // the post page groups them as language options, djot strong, no
  // markdown sources.
  list.each(["index-en.djot", "index-ja.djot", "index-pt.djot"], fn(file) {
    let assert Ok(variant) =
      simplifile.read("./blog/bienvenidos-a-ninjas-cl/" <> file)
    assert variant |> string.contains("slug: bienvenidos-a-ninjas-cl")
    assert variant |> string.contains("*Ninjas.cl*")
    assert string.contains(variant, "**") == False
    let assert Ok(False) =
      simplifile.is_file(
        "./blog/bienvenidos-a-ninjas-cl/"
        <> string.replace(file, ".djot", ".md"),
      )
  })
}

pub fn advent_post_migration_test() {
  // The migrated old post ships flat: both djot sources beside the copied
  // cover, input, and solution files, sharing one slug so they group as
  // the post's language variants.
  let dir = "./blog/advent-of-code-in-onyx-day-01"
  list.each(
    ["index.djot", "index-en.djot", "cover.jpg", "input.txt", "main.onyx"],
    fn(file) {
      let assert Ok(True) = simplifile.is_file(dir <> "/" <> file)
    },
  )

  // Both sources carry the shared slug, the preserved original date, and
  // the copied cover as the featured image — with djot conventions intact.
  list.each(["index.djot", "index-en.djot"], fn(file) {
    let assert Ok(source) = simplifile.read(dir <> "/" <> file)
    assert source |> string.contains("slug: advent-of-code-in-onyx-day-01")
    assert source
      |> string.contains("date: 2024-12-04 15:14:22 +00:00")
    assert source
      |> string.contains(
        "featured_image: /blog/advent-of-code-in-onyx-day-01/cover.jpg",
      )
    assert string.contains(source, "**") == False
    // The solution toggles ship as summary-carrying fences — the raw =html
    // form breaks under blogatto's per-block div wrapper — and the old
    // markdown's empty-link artifact is gone.
    assert string.contains(source, "``` =html") == False
    assert string.contains(source, "<details>") == False
    assert string.contains(source, "]()") == False
  })

  // The Spanish default is the translation; the English original ships as
  // the en variant.
  let assert Ok(spanish) = simplifile.read(dir <> "/index.djot")
  assert spanish
    |> string.contains("title: Advent of Code — Solución del Día 01")
  assert spanish |> string.contains("Día 1: Histeria de los historiadores")
  assert spanish |> string.contains("Mostrar solución")
  assert spanish |> string.contains("```go {summary=\"Mostrar solución\"}")
  assert spanish
    |> string.contains("```elixir {summary=\"Mostrar solución\"}")
  assert string.contains(spanish, "Day 1: Historian Hysteria") == False

  let assert Ok(english) = simplifile.read(dir <> "/index-en.djot")
  assert english |> string.contains("title: Advent of Code - Day 01 Solution")
  assert english |> string.contains("Day 1: Historian Hysteria")
  assert english |> string.contains("Show Solution")
  assert english |> string.contains("```go {summary=\"Show Solution\"}")
  assert english
    |> string.contains("```elixir {summary=\"Show Solution\"}")
}

pub fn post_typography_ships_test() {
  // The post typography presentation lives in the static asset: the
  // 16px ladder step for post bodies and JetBrains Mono for post code.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-body {")
  assert css |> string.contains("font-size: var(--rs-font-size-3);")
  assert css |> string.contains(".post-body pre,")
  assert css |> string.contains("'JetBrains Mono', var(--rs-font-mono);")
}

pub fn site_font_floor_ships_test() {
  // The site-wide 16px floor lives in the static asset: the cosmic
  // theme's 13px body shrink is overridden back to the ladder's size-3
  // step, and every rendered element that styled itself smaller lifts
  // to the same step.
  let assert Ok(css) = simplifile.read("./static/style.css")
  // The base restore: one variable, every inheriting element follows.
  assert css
    |> string.contains("html[data-rs-theme=\"cosmic\"] {")
  assert css
    |> string.contains("--rs-font-size-body: var(--rs-font-size-3);")
  // The chrome bumps: navbar links, the hero note, figure captions, the
  // back-to-top link, and the post list's date fine print.
  assert css |> string.contains(".rs-navbar a {")
  assert css |> string.contains(".rs-note {")
  assert css |> string.contains(".rs-figure__caption {")
  assert css |> string.contains(".rs-top {")
  assert css |> string.contains(".rs-list small {")
  // The language options row joins the floor.
  assert css |> string.contains(".post-languages {")
  // Nothing above the floor shrank: the section titles keep their
  // enlarged step and the post body keeps its own.
  assert css
    |> string.contains("font-size: var(--rs-font-size-5);")
  assert string.contains(css, "font-size: var(--rs-font-size-2);") == False
  assert string.contains(css, "font-size: var(--rs-font-size-1);") == False
}

pub fn highlight_code_component_test() {
  // The site's code component tokenizes tagged djot blocks at build time
  // — Go and Elixir among smalto's default grammars — keeping the
  // language class beside class-based token spans.
  let component = highlight.code_component(highlight.syntax_config())

  let go =
    component(dict.new(), option.Some("go"), [
      element.text(
        "package main\nimport \"fmt\"\nfunc main() {\n  var message = \"The part 1 solution\"\n}",
      ),
    ])
    |> element.to_string
  assert go |> string.contains("language-go")
  assert go |> string.contains("smalto-keyword")
  assert go |> string.contains("smalto-string")

  let elixir =
    component(dict.new(), option.Some("elixir"), [
      element.text(
        "defmodule AdventOfCode2024Day1 do\n  def parse(input) do\n    \"\"\n  end\nend",
      ),
    ])
    |> element.to_string
  assert elixir |> string.contains("language-elixir")
  assert elixir |> string.contains("smalto-keyword")

  // Untagged blocks and unknown language tags stay plain — the fallback
  // carries no token spans. ("onyx" is not among the default grammars.)
  let plain =
    component(dict.new(), option.None, [element.text("3   4")])
    |> element.to_string
  assert plain |> string.contains("<code>3   4</code>")
  assert string.contains(plain, "smalto-") == False

  let unknown =
    component(dict.new(), option.Some("onyx"), [element.text("use core")])
    |> element.to_string
  assert string.contains(unknown, "smalto-") == False

  // Entities survive the extraction round-trip: the source is unescaped
  // before tokenizing and Lustre re-escapes the tokens on render.
  let entities =
    component(dict.new(), option.Some("bash"), [
      element.text("echo \"a & b < c\""),
    ])
    |> element.to_string
  assert entities |> string.contains("a &amp; b")
  assert entities |> string.contains("smalto-string")

  // A fence's summary attribute wraps the highlighted block in a real
  // details/summary toggle — the code inside the details, the bare
  // language token in the class.
  let solution =
    component(dict.new(), option.Some("go {summary=\"Mostrar solución\"}"), [
      element.text("package main\nimport \"fmt\"\nfunc main() {}\n"),
    ])
    |> element.to_string
  assert solution
    |> string.contains(
      "<details><summary>Mostrar solución</summary><pre><code class=\"language-go\">",
    )
  assert solution |> string.contains("smalto-keyword")
  assert solution |> string.contains("</details>")

  // An unknown language with a summary still toggles, wrapping the plain
  // fallback code.
  let unknown_solution =
    component(dict.new(), option.Some("onyx {summary=\"Mostrar solución\"}"), [
      element.text("use core"),
    ])
    |> element.to_string
  assert unknown_solution
    |> string.contains(
      "<details><summary>Mostrar solución</summary><pre><code>use core</code></pre></details>",
    )

  // Blocks without the attribute carry no toggle.
  assert string.contains(go, "<details>") == False
}

pub fn inline_code_stays_a_bare_span_test() {
  // A single-backtick span reaches the code component with no language
  // and no `pre` call. It must stay a bare `code` so it flows with the
  // surrounding sentence instead of breaking onto its own line.
  let component = highlight.code_component(highlight.syntax_config())
  let inline =
    component(dict.new(), option.None, [element.text("~/.config/emacs")])
    |> element.to_string

  assert inline == "<code>~/.config/emacs</code>"
  assert string.contains(inline, "<pre>") == False
}

pub fn pre_component_wraps_only_untagged_blocks_test() {
  // blogatto calls `pre` for every fenced djot block, handing it whatever
  // the code component returned. The untagged fence is the case that
  // arrives as a bare `code`; tagged panels, summary toggles and embeds
  // already own their structure and must not be wrapped again.
  let component = highlight.code_component(highlight.syntax_config())
  let pre = highlight.pre_component

  let untagged =
    component(dict.new(), option.None, [element.text("3   4")])
    |> fn(child) { pre(dict.new(), [child]) }
    |> element.to_string
  assert untagged |> string.contains("<pre><code>3   4</code></pre>")

  let tagged =
    component(dict.new(), option.Some("go"), [element.text("package main")])
    |> fn(child) { pre(dict.new(), [child]) }
    |> element.to_string
  assert tagged |> string.contains("<pre><code class=\"language-go\">")
  assert string.split(tagged, "<pre>") |> list.length == 2

  let toggle =
    component(dict.new(), option.Some("go {summary=\"Mostrar solución\"}"), [
      element.text("package main"),
    ])
    |> fn(child) { pre(dict.new(), [child]) }
    |> element.to_string
  assert toggle |> string.contains("<details><summary>")
  assert string.split(toggle, "<pre>") |> list.length == 2

  let embed =
    component(dict.new(), option.Some("youtube"), [
      element.text("dQw4w9WgXcQ"),
    ])
    |> fn(child) { pre(dict.new(), [child]) }
    |> element.to_string
  assert embed |> string.contains("class=\"embed-video\"")
  assert string.contains(embed, "<pre>") == False
}

pub fn embed_components_render_test() {
  // The content-block component's embed languages: github repositories,
  // youtube players, ninjas.cl blog posts, and external websites — each
  // a full OpenGraph card (or a full-width player) from its fence.
  let component = highlight.code_component(highlight.syntax_config())

  // A GitHub repository card: the repo's link, title, description,
  // site name, and the site-local cached social card image.
  let github =
    component(dict.new(), option.Some("github"), [
      element.text(
        "NinjasCL/chileanbirds-dataset | Dataset con las aves de Chile",
      ),
    ])
    |> element.to_string
  assert github
    |> string.contains(
      "class=\"embed-full\" href=\"https://github.com/NinjasCL/chileanbirds-dataset\"",
    )
  assert github |> string.contains("embed-full__site\">GitHub<")
  assert github |> string.contains("NinjasCL/chileanbirds-dataset")
  assert github |> string.contains("Dataset con las aves de Chile")
  assert github
    |> string.contains(
      "src=\"/opengraph/ac6455248f3b7270da27facfe87ead1a.png\"",
    )

  // A bare repo fence still renders a valid card, description omitted.
  let github_short =
    component(dict.new(), option.Some("github"), [
      element.text("NinjasCL/wren-baron"),
    ])
    |> element.to_string
  assert github_short
    |> string.contains(
      "class=\"embed-full\" href=\"https://github.com/NinjasCL/wren-baron\"",
    )
  assert github_short |> string.contains("embed-full__description") == False

  // The three YouTube forms all parse to the full-width player.
  let watch =
    component(dict.new(), option.Some("youtube"), [
      element.text("https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
    ])
    |> element.to_string
  assert watch |> string.contains("class=\"embed-video\"")
  assert watch |> string.contains("width=\"100%\"")
  assert watch
    |> string.contains("https://www.youtube.com/embed/dQw4w9WgXcQ")
  assert watch
    |> string.contains(
      "allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\"",
    )
  let short =
    component(dict.new(), option.Some("youtube"), [
      element.text("https://youtu.be/dQw4w9WgXcQ"),
    ])
    |> element.to_string
  assert short
    |> string.contains("https://www.youtube.com/embed/dQw4w9WgXcQ")
  let bare =
    component(dict.new(), option.Some("youtube"), [
      element.text("dQw4w9WgXcQ"),
    ])
    |> element.to_string
  assert bare
    |> string.contains("https://www.youtube.com/embed/dQw4w9WgXcQ")

  // A ninjas blog post card: the site's own post, with its title,
  // description, and cover.
  let ninjas =
    component(dict.new(), option.Some("ninjas"), [
      element.text(
        "la-revista-club-nintendo | La Revista Club Nintendo | Mis recuerdos con la revista y como comencé en la informática | /blog/la-revista-club-nintendo/cover.png",
      ),
    ])
    |> element.to_string
  assert ninjas
    |> string.contains(
      "class=\"embed-full\" href=\"https://ninjas.cl/blog/la-revista-club-nintendo/\"",
    )
  assert ninjas |> string.contains("embed-full__site\">Ninjas.cl<")
  assert ninjas |> string.contains("La Revista Club Nintendo")
  assert ninjas
    |> string.contains(
      "Mis recuerdos con la revista y como comencé en la informática",
    )
  assert ninjas
    |> string.contains("src=\"/blog/la-revista-club-nintendo/cover.png\"")

  // An external website card: the old `{% embed %}` — link, host-derived
  // site name, and the carried title, description, and image.
  let website =
    component(dict.new(), option.Some("embed"), [
      element.text(
        "https://gleam.run | Gleam | Un lenguaje tipado seguro y amigable | https://gleam.run/images/lp/hero.png",
      ),
    ])
    |> element.to_string
  assert website
    |> string.contains("class=\"embed-full\" href=\"https://gleam.run\"")
  assert website |> string.contains("embed-full__site\">gleam.run<")
  assert website |> string.contains("Gleam")
  assert website
    |> string.contains("Un lenguaje tipado seguro y amigable")
  assert website
    |> string.contains("src=\"https://gleam.run/images/lp/hero.png\"")
}

fn reset_opengraph_test_dirs(cache: String, output: String) -> Nil {
  let _ = simplifile.delete(cache)
  let _ = simplifile.delete(output)
  let assert Ok(Nil) = simplifile.create_directory_all(cache)
  let assert Ok(Nil) = simplifile.create_directory_all(output)
  Nil
}

fn opengraph_cache_basename(repo: String) -> String {
  string.drop_start(
    github_opengraph.local_image_path(repo),
    string.length("/opengraph/"),
  )
}

fn opengraph_html_cache_name(repo: String) -> String {
  string.replace(opengraph_cache_basename(repo), ".png", ".html.cache")
}

fn panic_fetch_html(_url: String) -> Result(String, Nil) {
  panic as "HTML fetch should not run when the cache is warm"
}

fn panic_fetch_image(_url: String) -> Result(BitArray, Nil) {
  panic as "image fetch should not run when the cache is warm"
}

pub fn github_opengraph_paths_are_md5_keyed_test() {
  // The key matches the old site's lowercase MD5 of the repository URL.
  assert github_opengraph.local_image_path("NinjasCL/chileanbirds-dataset")
    == "/opengraph/ac6455248f3b7270da27facfe87ead1a.png"
}

pub fn github_opengraph_reuses_cached_image_test() {
  let cache = "./build/opengraph-test-cache"
  let output = "./build/opengraph-test-output"
  reset_opengraph_test_dirs(cache, output)
  let repo = "cache-test/cached"
  let image_file = cache <> "/" <> opengraph_cache_basename(repo)

  let assert Ok(Nil) = simplifile.write_bits(image_file, <<7, 8, 9>>)
  let source =
    github_opengraph.image_source_in(
      repo,
      cache,
      output,
      panic_fetch_html,
      panic_fetch_image,
    )

  assert source == github_opengraph.local_image_path(repo)
  let assert Ok(published) =
    simplifile.read_bits(output <> "/" <> opengraph_cache_basename(repo))
  assert published == <<7, 8, 9>>
}

pub fn github_opengraph_warms_cache_from_og_image_test() {
  let cache = "./build/opengraph-test-cache"
  let output = "./build/opengraph-test-output"
  reset_opengraph_test_dirs(cache, output)
  let repo = "cache-test/miss"
  let html =
    "<meta property=\"og:image\" content=\"https://images.example/card.png\" />"
  let fetch_html = fn(_url: String) -> Result(String, Nil) { Ok(html) }
  let fetch_image = fn(url: String) -> Result(BitArray, Nil) {
    case url {
      "https://images.example/card.png" -> Ok(<<1, 2, 3>>)
      _ -> Error(Nil)
    }
  }

  let source =
    github_opengraph.image_source_in(
      repo,
      cache,
      output,
      fetch_html,
      fetch_image,
    )

  assert source == github_opengraph.local_image_path(repo)
  let assert Ok(cached_html) =
    simplifile.read(cache <> "/" <> opengraph_html_cache_name(repo))
  assert cached_html == html
  let assert Ok(cached_image) =
    simplifile.read_bits(cache <> "/" <> opengraph_cache_basename(repo))
  assert cached_image == <<1, 2, 3>>
  let assert Ok(published) =
    simplifile.read_bits(output <> "/" <> opengraph_cache_basename(repo))
  assert published == <<1, 2, 3>>

  // A later build with the HTML cached but the image missing reuses the
  // HTML without fetching it again.
  let assert Ok(Nil) =
    simplifile.delete(cache <> "/" <> opengraph_cache_basename(repo))
  let reused =
    github_opengraph.image_source_in(
      repo,
      cache,
      output,
      panic_fetch_html,
      fetch_image,
    )
  assert reused == github_opengraph.local_image_path(repo)
  let assert Ok(refetched) =
    simplifile.read_bits(cache <> "/" <> opengraph_cache_basename(repo))
  assert refetched == <<1, 2, 3>>
}

pub fn github_opengraph_falls_back_when_image_is_blocked_test() {
  let cache = "./build/opengraph-test-cache"
  let output = "./build/opengraph-test-output"
  reset_opengraph_test_dirs(cache, output)
  let repo = "cache-test/blocked"
  let fallback = "https://opengraph.githubassets.com/1/" <> repo
  let marker = output <> "/fallback-requested"
  let fetch_html = fn(_url: String) -> Result(String, Nil) {
    Ok(
      "<meta name=\"twitter:image\" content=\"https://images.example/blocked.png\" />",
    )
  }
  let fetch_image = fn(url: String) -> Result(BitArray, Nil) {
    case url == fallback {
      True -> {
        let _ = simplifile.write(marker, "yes")
        Ok(<<4, 5>>)
      }
      False -> Error(Nil)
    }
  }

  let source =
    github_opengraph.image_source_in(
      repo,
      cache,
      output,
      fetch_html,
      fetch_image,
    )

  assert source == github_opengraph.local_image_path(repo)
  let assert Ok("yes") = simplifile.read(marker)
  let assert Ok(cached_image) =
    simplifile.read_bits(cache <> "/" <> opengraph_cache_basename(repo))
  assert cached_image == <<4, 5>>
}

pub fn github_opengraph_falls_back_when_fetches_fail_test() {
  let cache = "./build/opengraph-test-cache"
  let output = "./build/opengraph-test-output"
  reset_opengraph_test_dirs(cache, output)
  let repo = "cache-test/offline"
  let fetch_html = fn(_url: String) -> Result(String, Nil) { Error(Nil) }
  let fetch_image = fn(_url: String) -> Result(BitArray, Nil) { Error(Nil) }

  let source =
    github_opengraph.image_source_in(
      repo,
      cache,
      output,
      fetch_html,
      fetch_image,
    )

  assert source == "https://opengraph.githubassets.com/1/" <> repo
  let assert Ok(False) =
    simplifile.is_file(cache <> "/" <> opengraph_cache_basename(repo))
}

pub fn night_owl_code_theme_ships_test() {
  // The code-block presentation lives in the static asset: post code
  // blocks sit in the Night Owl panel — the editor background darker
  // than the page, the theme's contrast border — and the smalto token
  // classes carry the Night Owl palette.
  let assert Ok(css) = simplifile.read("./static/style.css")
  // The panel.
  assert css |> string.contains(".post-body pre {")
  assert css |> string.contains("background: #011627;")
  assert css |> string.contains("color: #d6deeb;")
  assert css |> string.contains("border: 2px solid #122d42;")
  // The palette: keyword, string, number, comment, and function colors
  // straight from the Night Owl theme.
  assert css |> string.contains(".smalto-keyword {")
  assert css |> string.contains("color: #c792ea;")
  assert css |> string.contains(".smalto-string {")
  assert css |> string.contains("color: #ecc48d;")
  assert css |> string.contains(".smalto-number {")
  assert css |> string.contains("color: #f78c6c;")
  assert css |> string.contains(".smalto-comment {")
  assert css |> string.contains("color: #637777;")
  assert css |> string.contains(".smalto-function {")
  assert css |> string.contains("color: #82aaff;")
}

pub fn inline_code_highlight_ships_test() {
  // Inline spans keep the post's mono face but get the site's violet
  // highlight — light text on #7540bd — instead of a block code panel.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-body :not(pre) > code {")
  let assert Ok(#(_, after_rule)) =
    string.split_once(css, ".post-body :not(pre) > code {")
  let assert Ok(#(rule, _)) = string.split_once(after_rule, "}")
  assert rule
    |> string.contains("font-family: 'JetBrains Mono', var(--rs-font-mono);")
  assert rule |> string.contains("color: #fafafa;")
  assert rule |> string.contains("background-color: #7540bd;")
}

/// The default source's `icon` frontmatter value, when it declares one —
/// read inside the frontmatter block so a body mention of "icon:" never
/// counts.
fn frontmatter_icon(source: String) -> option.Option(String) {
  case string.split_once(source, "\n---") {
    Error(Nil) -> option.None
    Ok(#(frontmatter, _)) ->
      case string.split_once(frontmatter, "\nicon: ") {
        Error(Nil) -> option.None
        Ok(#(_, rest)) ->
          case string.split_once(rest, "\n") {
            Ok(#(value, _)) -> option.Some(string.trim(value))
            Error(Nil) -> option.Some(string.trim(rest))
          }
      }
  }
}

pub fn every_post_ships_all_languages_test() {
  // The owner's full-coverage mandate: every post directory under blog/
  // ships all four sources — the default Spanish beside the English,
  // Japanese, and Portuguese machine translations — sharing one slug so
  // each post page's options row offers the full set, and repeating the
  // default's `icon` when it declares one so every language page leads
  // its title with it.
  let assert Ok(entries) = simplifile.read_directory("./blog")
  let posts =
    list.filter(entries, fn(entry) {
      case simplifile.is_directory("./blog/" <> entry) {
        Ok(True) -> True
        _ -> False
      }
    })
  assert list.length(posts) >= 1

  list.each(posts, fn(post) {
    let dir = "./blog/" <> post

    // All four variants exist.
    list.each(
      ["index.djot", "index-en.djot", "index-ja.djot", "index-pt.djot"],
      fn(file) {
        let assert Ok(True) = simplifile.is_file(dir <> "/" <> file)
      },
    )

    // And they group as one post: every variant repeats the default's slug.
    let assert Ok(default) = simplifile.read(dir <> "/index.djot")
    let assert Ok(#(_, slug_rest)) = string.split_once(default, "slug: ")
    let assert Ok(#(default_slug, _)) = string.split_once(slug_rest, "\n")
    list.each(["index-en.djot", "index-ja.djot", "index-pt.djot"], fn(file) {
      let assert Ok(variant) = simplifile.read(dir <> "/" <> file)
      assert variant |> string.contains("slug: " <> default_slug)
    })

    // A declared title icon travels like the slug: every variant repeats
    // the default's value.
    case frontmatter_icon(default) {
      option.None -> Nil
      option.Some(icon) ->
        list.each(["index-en.djot", "index-ja.djot", "index-pt.djot"], fn(file) {
          let assert Ok(variant) = simplifile.read(dir <> "/" <> file)
          assert variant |> string.contains("icon: " <> icon)
        })
    }
  })
}

pub fn format_date_test() {
  let date =
    timestamp.from_calendar(
      date: calendar.Date(2026, calendar.November, 16),
      time: calendar.TimeOfDay(0, 0, 0, 0),
      offset: calendar.utc_offset,
    )

  assert site.format_date(date) == "2026-11-16"
}

pub fn format_date_pads_month_and_day_test() {
  let date =
    timestamp.from_calendar(
      date: calendar.Date(2026, calendar.January, 5),
      time: calendar.TimeOfDay(0, 0, 0, 0),
      offset: calendar.utc_offset,
    )

  assert site.format_date(date) == "2026-01-05"
}

pub fn home_view_renders_homepage_sections_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  assert html |> string.contains("rs-navbar")
  // The hero title carries the Chilean tricolor through the same banded
  // gradient technique as retrostrap's rs-rainbow: one span clipped to
  // the text, hard bands in the 🇨🇱 emoji's blue/white/red.
  assert html |> string.contains("cl-rainbow")
  assert html |> string.contains("忍者 開発者 Ninjas.cl")
  assert html |> string.contains("rs-rainbow") == False
  assert html |> string.contains("Entradas del blog")
  assert html |> string.contains("Todavía no hay entradas publicadas.")
  assert html |> string.contains("Proyectos")
  assert html |> string.contains("Libros")
  assert html |> string.contains("Juegos")
  assert html |> string.contains("rs-footer")
  assert html |> string.contains("/background.js")
  // The site description renders in its original places — the hero's
  // note and the page's meta description — and also feeds the mirrored
  // og/twitter/JSON-LD fields of the head suite.
  assert html
    |> string.contains("rs-note\">Ninjas es un grupo desarrollador")
  assert html
    |> string.contains("content=\"Ninjas es un grupo desarrollador")
  assert html |> string.contains("por @CLSource")
  assert html |> string.contains("¡11 años programando ❤️!")
  // On the home page the navbar uses in-page section anchors and marks
  // "Inicio" as the current page.
  assert html |> string.contains("href=\"#projects\"")
  assert html |> string.contains("aria-current=\"page\"")
}

pub fn home_view_renders_about_row_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // The about row wraps the portrait and the text in one grid.
  assert html |> string.contains("about__cols")
  // The portrait is present and no longer pinned to a fixed 250x250 box.
  assert html |> string.contains("/img/camilo.jpg")
  assert string.contains(html, "width=\"250\"") == False
  assert string.contains(html, "height=\"250\"") == False
  // The caption survives, crediting the site owner's handle; the former
  // personal-name caption is gone.
  assert html |> string.contains("@CLSource — Software Engineer")
  assert string.contains(html, "Camilo Castro — Software Engineer") == False
  // Within the about row the portrait comes first: the section title
  // precedes it and the section text follows it, speaking in the site's
  // own first-person voice.
  let assert Ok(#(before_portrait, after_portrait)) =
    string.split_once(html, "camilo.jpg")
  assert before_portrait |> string.contains("Sobre nosotros")
  assert after_portrait
    |> string.contains(
      "Ninjas es un grupo experimental de desarrollo de software de Chile 🇨🇱 fundado por @CLSource. Participamos en proyectos de videojuegos, software y otras actividades relacionadas.",
    )
  assert string.contains(html, "Ninja Systems es un grupo") == False
  // The values line and the closing find-us link follow in the same
  // column, linking GitHub to the ninjascl organization.
  assert after_portrait
    |> string.contains(
      "Nos gusta crear artefactos hermosos y pensados en las personas. Valoramos lo humano en los proyectos tecnológicos.",
    )
  assert after_portrait |> string.contains("Ninjas.cl nació el 2015")
  assert after_portrait
    |> string.contains(
      "Puedes encontrarnos en <a href=\"https://github.com/ninjascl\"",
    )
}

pub fn home_view_renders_five_section_headers_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // Splitting on the class name leaves one piece per occurrence plus one:
  // exactly five section headers — the banner panel at #contact carries no
  // title, so the untitled wall adds none — with no leak into other
  // headings (showcase card h3s, hero, footer).
  let pieces = string.split(html, "rs-panel__title")
  assert list.length(pieces) == 6
}

// Fixtures for the blog index tests: numbered posts with two-digit
// numbers (no title is a substring of another) whose dates rise with the
// number, so `Entrada 39` is the newest of the set.
fn index_test_date(number: Int) -> timestamp.Timestamp {
  timestamp.from_calendar(
    date: calendar.Date(2000 + number, calendar.January, 1),
    time: calendar.TimeOfDay(0, 0, 0, 0),
    offset: calendar.utc_offset,
  )
}

fn index_test_post(number: Int) -> post.Post(Nil) {
  post.Post(
    title: "Entrada " <> int.to_string(number),
    slug: "entrada-" <> int.to_string(number),
    url: site.production_url <> "blog/entrada-" <> int.to_string(number) <> "/",
    date: index_test_date(number),
    description: "Descripción de la entrada " <> int.to_string(number),
    excerpt: "",
    language: option.None,
    featured_image: option.Some(
      "/blog/entrada-" <> int.to_string(number) <> "/cover.jpg",
    ),
    contents: [],
    extras: dict.from_list([#("tags", "uno, dos")]),
  )
}

fn index_test_variant(number: Int, language: String) -> post.Post(Nil) {
  post.Post(
    title: "Entry " <> int.to_string(number),
    slug: "entrada-" <> int.to_string(number),
    url: site.production_url
      <> "blog/"
      <> language
      <> "/entrada-"
      <> int.to_string(number)
      <> "/",
    date: index_test_date(number),
    description: "Description " <> int.to_string(number),
    excerpt: "",
    language: option.Some(language),
    featured_image: option.Some(
      "/blog/entrada-" <> int.to_string(number) <> "/cover.jpg",
    ),
    contents: [],
    extras: dict.new(),
  )
}

fn index_test_posts() -> List(post.Post(Nil)) {
  int.range(from: 10, to: 40, with: [], run: fn(acc, n) {
    [index_test_post(n), ..acc]
  })
}

pub fn blog_index_first_page_test() {
  // Thirty default posts plus an English variant of the newest: page 1
  // lists the 25 newest default entries, newest first, and never lists a
  // translated variant as an entry of its own.
  let posts = index_test_posts() |> list.append([index_test_variant(39, "en")])
  let html = site.blog_index_view(1)(posts) |> element.to_string

  // Newest first: the newest entry precedes the second newest.
  let assert Ok(#(_, after_newest)) = string.split_once(html, "Entrada 39")
  assert string.contains(after_newest, "Entrada 38")
  // The 25 newest make page 1: the 25th (15) is in, the 26th (14) is out.
  assert string.contains(html, "Entrada 15")
  assert string.contains(html, "Entrada 14") == False
  // The variant is an option on the newest entry's card, not an entry.
  assert string.contains(html, "Entry 39") == False

  // Each card carries the post's cover, description, formatted date, and
  // tags — and the link to its translation, resolved by slug.
  assert string.contains(html, "src=\"/blog/entrada-39/cover.jpg\"")
  assert string.contains(html, "Descripción de la entrada 39")
  assert string.contains(html, "2039-01-01")
  assert string.contains(html, "post-tag")
  assert string.contains(html, "uno")
  assert string.contains(html, "dos")
  assert string.contains(html, "href=\"https://ninjas.cl/blog/en/entrada-39/\"")
}

pub fn blog_index_second_page_test() {
  // The remainder page: the five oldest entries, continuing the same
  // newest-first order, with its own page counter.
  let html = site.blog_index_view(2)(index_test_posts()) |> element.to_string

  let assert Ok(#(_, after_first)) = string.split_once(html, "Entrada 14")
  assert string.contains(after_first, "Entrada 13")
  assert string.contains(html, "Entrada 10")
  assert string.contains(html, "Entrada 15") == False
  assert string.contains(html, "2 / 2")
}

pub fn blog_index_cover_fallback_test() {
  // A post without a featured image falls back to the site image.
  let posts = [
    post.Post(..index_test_post(10), featured_image: option.None),
  ]
  let html = site.blog_index_view(1)(posts) |> element.to_string

  assert string.contains(html, "src=\"/img/Ninjas.png\"")
}

pub fn blog_index_cards_lead_titles_with_the_posts_icon_test() {
  // The entry card's title leads with the post's own icon; an iconless
  // entry keeps the newspaper icon the post's own page title falls back
  // to.
  let iconed =
    post.Post(
      ..index_test_post(10),
      extras: dict.from_list([#("icon", "Earth_32x32_4.png")]),
    )
  let plain = index_test_post(11)
  let html = site.blog_index_view(1)([iconed, plain]) |> element.to_string

  let assert Ok(#(before_earth, after_earth)) =
    string.split_once(html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert before_earth |> string.contains("embed-full__title")
  assert after_earth |> string.contains("Entrada 10")
  let assert Ok(#(_, after_news)) =
    string.split_once(html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert after_news |> string.contains("Entrada 11")
}

pub fn blog_index_pagination_nav_test() {
  // The first page links only the next page, the last only the previous
  // one, and a single-page catalog links neither — the counter always
  // rides along between the buttons.
  let first = site.blog_index_view(1)(index_test_posts()) |> element.to_string
  assert string.contains(first, "Página siguiente")
  assert string.contains(first, "href=\"/blog/page/2/\"")
  assert string.contains(first, "Página anterior") == False
  assert string.contains(first, "1 / 2")

  let last = site.blog_index_view(2)(index_test_posts()) |> element.to_string
  assert string.contains(last, "Página anterior")
  assert string.contains(last, "href=\"/blog/page/1/\"")
  assert string.contains(last, "Página siguiente") == False

  let single =
    site.blog_index_view(1)([index_test_post(10)])
    |> element.to_string
  assert string.contains(single, "1 / 1")
  assert string.contains(single, "Página siguiente") == False
  assert string.contains(single, "Página anterior") == False
}

pub fn blog_redirect_view_test() {
  // The /blog URL is the old site's redirect: a meta-refresh straight to
  // the first index page, with a plain link for clients that skip it.
  let html = site.blog_redirect_view() |> element.to_string

  assert string.contains(html, "http-equiv=\"Refresh\"")
  assert string.contains(html, "0; url=/blog/page/1/")
  assert string.contains(html, "href=\"/blog/page/1/\"")
}

pub fn blog_index_chrome_and_feed_test() {
  // The index page carries the full site chrome — the navigation menu,
  // the masthead header, the footer — and its title section links the
  // Atom feed through the old site's feed icon.
  let html =
    site.blog_index_view(1)([index_test_post(10)])
    |> element.to_string

  assert string.contains(html, "rs-navbar")
  assert string.contains(html, "id=\"masthead\"")
  assert string.contains(html, "rs-footer")
  assert string.contains(html, "href=\"/atom.xml\"")
  assert string.contains(html, "src=\"/img/feed.svg\"")
}

pub fn atom_feed_paths_test() {
  // The default language owns the root feed, each translation owns its
  // nested feed, and unsupported codes keep the default feed.
  assert site.atom_feed_path("es") == "/atom.xml"
  assert site.atom_feed_path("en") == "/en/atom.xml"
  assert site.atom_feed_path("ja") == "/ja/atom.xml"
  assert site.atom_feed_path("pt") == "/pt/atom.xml"
  assert site.atom_feed_path("fr") == "/atom.xml"
}

pub fn language_feed_links_test() {
  // Each language's blog index and home posts header link that language's
  // own Atom feed with the same icon and alt text.
  let cases = [
    #("es", home.spanish_text, site.blog_index_view(1)),
    #("en", home.english_text, site.language_blog_index_view("en", 1)),
    #("ja", home.japanese_text, site.language_blog_index_view("ja", 1)),
    #("pt", home.portuguese_text, site.language_blog_index_view("pt", 1)),
  ]

  list.each(cases, fn(entry) {
    let #(code, home_text, blog_index_view) = entry
    let expected = "href=\"" <> site.atom_feed_path(code) <> "\""
    let index_html = blog_index_view([]) |> element.to_string
    let home_html = home.view(home_text, []) |> element.to_string

    assert string.contains(index_html, expected)
    assert string.contains(home_html, expected)
    assert string.contains(index_html, "src=\"/img/feed.svg\"")
    assert string.contains(home_html, "src=\"/img/feed.svg\"")
    assert string.contains(index_html, "alt=\"Feed Atom RSS\"")
    assert string.contains(home_html, "alt=\"Feed Atom RSS\"")
  })
}

pub fn blog_index_language_version_lists_its_language_test() {
  // The English index at /blog/en/page/1/ lists the English variants,
  // newest first — never a default-language post, never another
  // language's variant — on its own page count.
  let posts =
    index_test_posts()
    |> list.append([
      index_test_variant(39, "en"),
      index_test_variant(38, "en"),
      index_test_variant(10, "en"),
      index_test_variant(37, "ja"),
    ])
  let html = site.language_blog_index_view("en", 1)(posts) |> element.to_string

  // Newest first: the newest English entry precedes the next one.
  let assert Ok(#(_, after_newest)) = string.split_once(html, "Entry 39")
  assert string.contains(after_newest, "Entry 38")
  assert string.contains(after_newest, "Entry 10")
  // Three English variants: one page holds them all.
  assert string.contains(html, "1 / 1")
  // No default-language entry appears, and no other-language variant
  // leaks in — not even as a card's translation link, since the
  // Japanese variant belongs to a slug the English index never lists.
  assert string.contains(html, "Entrada 39") == False
  assert string.contains(html, "https://ninjas.cl/blog/ja/entrada-37/") == False
}

pub fn blog_index_language_page_speaks_its_language_test() {
  // A language index declares its language and speaks it: the Japanese
  // page carries the ja lang value and locale, the Japanese title
  // template and panel heading, the intro, and the Japanese pagination
  // buttons linking its own pages. The default page keeps its exact
  // Spanish presentation.
  let ja_posts =
    int.range(from: 10, to: 40, with: [], run: fn(acc, n) {
      [index_test_variant(n, "ja"), ..acc]
    })
  let ja = site.language_blog_index_view("ja", 1)(ja_posts) |> element.to_string

  assert string.contains(ja, "lang=\"ja\"")
  assert string.contains(ja, "ja_JP")
  assert string.contains(ja, "ブログ、ページ1 — Ninjas.cl")
  assert string.contains(ja, ">ブログ")
  assert string.contains(ja, "ブログ記事をすべて、新しいものから順に。各カードは記事とその翻訳にリンクします。")
  assert string.contains(ja, "次のページ")
  assert string.contains(ja, "href=\"/blog/ja/page/2/\"")
  assert string.contains(ja, "前のページ") == False
  assert string.contains(ja, "Página siguiente") == False

  // The default page: unchanged Spanish presentation.
  let es = site.blog_index_view(1)(index_test_posts()) |> element.to_string
  assert string.contains(es, "lang=\"es-CL\"")
  assert string.contains(es, "Blog, página 1 — Ninjas.cl")
  assert string.contains(
    es,
    "Todas las entradas del blog, las más recientes primero. Cada tarjeta enlaza la entrada y sus traducciones.",
  )
  assert string.contains(es, "Página siguiente")
  assert string.contains(es, "href=\"/blog/page/2/\"")
  assert string.contains(es, "ブログ") == False
}

/// The masthead's shared navigation menu, isolated from the rest of the
/// page so a label's appearing in a heading or a card cannot satisfy the
/// language checks by accident.
fn navbar_html(html: String) -> String {
  let assert Ok(#(_, after)) = string.split_once(html, "<nav")
  let assert Ok(#(nav, _)) = string.split_once(after, "</nav>")
  nav
}

pub fn blog_index_navbar_speaks_its_language_test() {
  // Each language index translates the shared navigation menu just like
  // the translated homes — the six labels and the region's aria-label —
  // instead of riding along with the default Spanish chrome.
  let es = site.blog_index_view(1)(index_test_posts()) |> element.to_string
  let es_nav = navbar_html(es)
  assert es_nav |> string.contains("aria-label=\"Navegación principal\"")
  assert es_nav |> string.contains("Inicio")
  assert es_nav |> string.contains("Nosotros")

  let en = site.language_blog_index_view("en", 1)([]) |> element.to_string
  let en_nav = navbar_html(en)
  assert en_nav |> string.contains("aria-label=\"Main navigation\"")
  assert en_nav |> string.contains("Home")
  assert en_nav |> string.contains("About us")
  assert en_nav |> string.contains("Projects")
  assert en_nav |> string.contains("Books")
  assert en_nav |> string.contains("Games")
  assert en_nav |> string.contains("Inicio") == False
  assert en_nav |> string.contains("Nosotros") == False

  let ja = site.language_blog_index_view("ja", 1)([]) |> element.to_string
  let ja_nav = navbar_html(ja)
  assert ja_nav |> string.contains("aria-label=\"メインナビゲーション\"")
  assert ja_nav |> string.contains("ホーム")
  assert ja_nav |> string.contains("私たちについて")
  assert ja_nav |> string.contains("プロジェクト")
  assert ja_nav |> string.contains("書籍")
  assert ja_nav |> string.contains("ゲーム")
  assert ja_nav |> string.contains("Inicio") == False

  let pt = site.language_blog_index_view("pt", 1)([]) |> element.to_string
  let pt_nav = navbar_html(pt)
  assert pt_nav |> string.contains("aria-label=\"Navegação principal\"")
  assert pt_nav |> string.contains("Início")
  assert pt_nav |> string.contains("Sobre nós")
  assert pt_nav |> string.contains("Projetos")
  assert pt_nav |> string.contains("Livros")
  assert pt_nav |> string.contains("Jogos")
  assert pt_nav |> string.contains("Nosotros") == False
}

pub fn blog_index_pagination_uses_post_navigation_hands_test() {
  // The pagination buttons point with the same Win95 hand as the post
  // navigation buttons, rotated the same quarter turns: left for the
  // previous page, right for the next — never the old arrow sprites.
  let posts = index_test_posts()
  let first = site.blog_index_view(1)(posts) |> element.to_string
  assert string.contains(first, "ArrowLeft_32x32_4.png") == False
  assert string.contains(first, "ArrowRight_32x32_4.png") == False
  assert string.contains(first, "post-nav__hand--left") == False
  let assert Ok(#(before_next, _)) =
    string.split_once(first, "Página siguiente")
  assert before_next
    |> string.contains("src=\"/icons/win95/Msow10_32x32_4.png\"")
  assert before_next |> string.contains("post-nav__hand--right")

  let many =
    int.range(from: 10, to: 69, with: [], run: fn(acc, n) {
      [index_test_post(n), ..acc]
    })
  let middle = site.blog_index_view(2)(many) |> element.to_string
  let hand = "src=\"/icons/win95/Msow10_32x32_4.png\""
  assert list.length(string.split(middle, hand)) == 3
  let assert Ok(#(before, after)) = string.split_once(middle, "2 / 3")
  assert before |> string.contains("post-nav__hand--left")
  assert before |> string.contains("post-nav__hand--right") == False
  assert after |> string.contains("post-nav__hand--right")
  assert after |> string.contains("post-nav__hand--left") == False

  let last = site.blog_index_view(2)(posts) |> element.to_string
  assert string.contains(last, "post-nav__hand--right") == False
  let assert Ok(#(before_prev, _)) = string.split_once(last, "Página anterior")
  assert before_prev
    |> string.contains("src=\"/icons/win95/Msow10_32x32_4.png\"")
  assert before_prev |> string.contains("post-nav__hand--left")
}

pub fn blog_index_language_options_row_test() {
  // Every index page links its sibling languages' same-numbered page:
  // the default page links the three language indexes with Español
  // marked as the current page; a language page links back to the
  // default's same page with its own language current — and never
  // links its own page.
  let es = site.blog_index_view(1)(index_test_posts()) |> element.to_string

  assert string.contains(es, "Idiomas:")
  assert string.contains(es, "Español</span>")
  assert string.contains(es, "href=\"/blog/en/page/1/\"")
  assert string.contains(es, "href=\"/blog/ja/page/1/\"")
  assert string.contains(es, "href=\"/blog/pt/page/1/\"")
  assert string.contains(es, "href=\"/blog/page/1/\"") == False

  let en_posts =
    int.range(from: 10, to: 40, with: [], run: fn(acc, n) {
      [index_test_variant(n, "en"), ..acc]
    })
  let en = site.language_blog_index_view("en", 2)(en_posts) |> element.to_string

  assert string.contains(en, "Languages:")
  assert string.contains(en, "English</span>")
  assert string.contains(en, "href=\"/blog/page/2/\"")
  assert string.contains(en, "href=\"/blog/ja/page/2/\"")
  assert string.contains(en, "href=\"/blog/pt/page/2/\"")
  assert string.contains(en, "href=\"/blog/en/page/2/\"") == False
}

pub fn blog_index_language_card_links_test() {
  // A translated index card links the Spanish original beside the other
  // translations — its own language never, the card itself links it.
  // The default index keeps linking exactly the translated variants.
  let posts =
    index_test_posts()
    |> list.append([
      index_test_variant(39, "en"),
      index_test_variant(39, "ja"),
      index_test_variant(39, "pt"),
    ])

  let en = site.language_blog_index_view("en", 1)(posts) |> element.to_string
  assert string.contains(en, "href=\"https://ninjas.cl/blog/entrada-39/\"")
  assert string.contains(en, "href=\"https://ninjas.cl/blog/ja/entrada-39/\"")
  assert string.contains(en, "href=\"https://ninjas.cl/blog/pt/entrada-39/\"")
  // Each own-language URL appears exactly once — the card's own link.
  let en_own = string.split(en, "https://ninjas.cl/blog/en/entrada-39/")
  assert list.length(en_own) == 2
  let en_original = string.split(en, "https://ninjas.cl/blog/entrada-39/")
  assert list.length(en_original) == 2

  let es = site.blog_index_view(1)(posts) |> element.to_string
  assert string.contains(es, "href=\"https://ninjas.cl/blog/en/entrada-39/\"")
  assert string.contains(es, "href=\"https://ninjas.cl/blog/ja/entrada-39/\"")
  assert string.contains(es, "href=\"https://ninjas.cl/blog/pt/entrada-39/\"")
  // The Spanish original's URL appears exactly once: the card's own link.
  let es_own = string.split(es, "https://ninjas.cl/blog/entrada-39/")
  assert list.length(es_own) == 2
}

pub fn banner_wall_renders_every_shipped_banner_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // The wall renders one plain img per shipped banner, served from the
  // site's own /banners assets: every shipped .gif appears, and the
  // rendered count matches the shipped file count.
  let assert Ok(files) = simplifile.read_directory("./static/banners")
  let shipped = list.filter(files, fn(file) { string.ends_with(file, ".gif") })
  list.each(shipped, fn(file) {
    assert html |> string.contains("src=\"/banners/" <> file <> "\"")
  })
  let pieces = string.split(html, "src=\"/banners/")
  assert list.length(pieces) == list.length(shipped) + 1
}

pub fn banner_panel_strips_contacto_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // The untitled panel keeps its #contact anchor for external deep links,
  // but the Contacto identity is gone: no title, no navbar button, no link
  // targeting the panel, and none of the former copy.
  assert html |> string.contains("id=\"contact\"")
  assert string.contains(html, "Contacto") == False
  assert string.contains(html, "href=\"#contact\"") == False
  assert string.contains(html, "¿Construimos algo juntos?") == False
  assert string.contains(html, "Escríbenos") == False
  // The wall is the panel's entire body: from the panel's opening to its
  // closing section tag there is no anchor at all, so no banner is linked
  // and none of the removed Contacto controls (GitHub link, mailto button)
  // can appear there. The exact href is checked in the panel scope because
  // the projects section's Ninjas.cl card keeps its own
  // https://github.com/ninjascl code link.
  let assert Ok(#(_, after_id)) = string.split_once(html, "id=\"contact\"")
  let assert Ok(#(panel, _)) = string.split_once(after_id, "</section>")
  assert string.contains(panel, "<a") == False
  assert string.contains(panel, "mailto:") == False
  assert string.contains(panel, "https://github.com/ninjascl") == False
}

pub fn navbar_keeps_no_contacto_link_test() {
  // The navbar is shared, so the Contacto link is gone from every page:
  // in-page anchors on the home page, home-prefixed fragments on posts.
  let home_html = home.view(home.spanish_text, []) |> element.to_string
  assert string.contains(home_html, "href=\"#contact\"") == False

  let post_html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string
  assert string.contains(post_html, "href=\"/#contact\"") == False
}

pub fn banner_wall_presentation_ships_test() {
  // The wall presentation lives in a static asset, not rendered markup.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".banner-wall {")
  assert css |> string.contains("display: flex")
  assert css |> string.contains("flex-wrap: wrap")
  assert css |> string.contains("justify-content: center")
  assert css |> string.contains(".banner-wall img")
  assert css |> string.contains("image-rendering: pixelated")
  // The img rule only sets crisp rendering: no width or height forcing, so
  // the odd-sized banners (iframsuc, ubuntu-88x31, netbsd2) keep their
  // intrinsic proportions.
  let assert Ok(#(_, after_img)) = string.split_once(css, ".banner-wall img {")
  let assert Ok(#(img_rule, _)) = string.split_once(after_img, "}")
  assert string.contains(img_rule, "width") == False
  assert string.contains(img_rule, "height") == False
}

pub fn footer_trims_decorative_blocks_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // The trimmed footer keeps its element, the copyright line — ending in
  // the build's current year, read through the same clock the footer
  // uses — and the back-to-top link targeting the masthead anchor.
  let #(copyright_date, _time) =
    timestamp.to_calendar(timestamp.system_time(), calendar.utc_offset)
  let copyright =
    "Copyright 🥷🏽 Ninjas.cl © 2015–"
    <> int.to_string(copyright_date.year)
    <> " · Todos los derechos e izquierdos preservados"
  assert html |> string.contains("rs-footer")
  assert html |> string.contains(copyright)
  assert html |> string.contains("href=\"#masthead\"")
  assert html |> string.contains("^ volver arriba ^")
  // The former decorative blocks are gone from the home page entirely.
  assert string.contains(html, "Chile WebRing") == False
  assert string.contains(html, "Ir a un sitio aleatorio") == False
  assert string.contains(html, "webri.ng") == False
  assert string.contains(html, "rs-webring-bar") == False
  assert string.contains(html, "Hecho a mano en Chile") == False
  assert string.contains(html, "source code") == False
  assert string.contains(html, "written by human") == False
  assert string.contains(html, "rs-button88") == False
  // The post page closes with the same site footer — copyright line and
  // back-to-top link — and its former minimal line is gone.
  let post_html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string
  assert post_html |> string.contains("rs-footer")
  assert post_html |> string.contains(copyright)
  assert post_html |> string.contains("href=\"#masthead\"")
  assert post_html |> string.contains("^ volver arriba ^")
  assert post_html |> string.contains("Ninjas.cl — Desde 2015") == False
}

pub fn copyright_line_leads_with_the_authorship_icon_test() {
  // The shared footer leads its copyright line with the Win95
  // document-and-pencil icon — decorative, empty alt — ahead of the
  // verbatim text, on every page the footer renders.
  let icon_src = "src=\"/icons/win95/FilePencil_32x32_4.png\""
  let label = "Copyright 🥷🏽"

  // The home page.
  let home_html = home.view(home.spanish_text, []) |> element.to_string
  let assert Ok(#(before_home, after_home)) =
    string.split_once(home_html, icon_src)
  assert before_home |> string.contains("rs-footer")
  assert after_home |> string.contains(label)

  // A post page.
  let post_html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string
  let assert Ok(#(before_post, after_post)) =
    string.split_once(post_html, icon_src)
  assert before_post |> string.contains("rs-footer")
  assert after_post |> string.contains(label)

  // The blog index page.
  let index_html =
    site.blog_index_view(1)(index_test_posts()) |> element.to_string
  let assert Ok(#(before_index, after_index)) =
    string.split_once(index_html, icon_src)
  assert before_index |> string.contains("rs-footer")
  assert after_index |> string.contains(label)
}

pub fn style_css_enlarges_section_headers_test() {
  // The size contract lives in a static asset, not in rendered markup.
  let assert Ok(css) = simplifile.read("./static/style.css")

  // Section headers get --rs-font-size-5 (1.5rem, ≈1.85× the 0.8125rem
  // panel-title default), tuned down from the initial --rs-font-size-6.
  assert css |> string.contains(".rs-panel__title")
  assert css |> string.contains("font-size: var(--rs-font-size-5)")
}

pub fn style_css_home_section_clearance_test() {
  // The clearance contract lives in a static asset, like the section-header
  // sizes: every home section panel — about, posts, projects, books,
  // games, and the banner wall at #contact — keeps a 32px top margin
  // (--rs-space-5, double retrostrap's 16px panel default), mirroring
  // the #blog clearance rule.
  let assert Ok(css) = simplifile.read("./static/style.css")

  assert css
    |> string.contains(
      "#about,\n#posts,\n#projects,\n#books,\n#games,\n#contact {\n  margin-top: var(--rs-space-5);",
    )
}

pub fn style_css_chilean_title_rainbow_test() {
  // The title contract lives in a static asset, like the section-header
  // sizes: retrostrap's rs-rainbow technique — hard bands clipped to
  // the text — carrying the 🇨🇱 emoji's flag palette, running top to
  // bottom in the flag's own band order.
  let assert Ok(css) = simplifile.read("./static/style.css")

  assert css |> string.contains(".cl-rainbow")
  assert css |> string.contains("linear-gradient(180deg")
  assert css
    |> string.contains("#1f429b 0 33%, #eee 33% 66%, #d42d27 66% 100%")
  assert css |> string.contains("background-clip: text")
  assert css |> string.contains("color: transparent")
}

pub fn home_view_serves_showcase_images_from_img_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // Projects and books showcase images load from the site's own assets.
  assert html |> string.contains("/img/elixircl.png")
  assert html |> string.contains("/img/jasonelle.png")
  assert html |> string.contains("/img/joyofpw.png")
  assert html |> string.contains("/img/chaucha.png")
  // The hero also references Ninjas.png via its absolute production URL, so
  // assert on the rendered src to pin the showcase card's local path.
  assert html |> string.contains("src=\"/img/Ninjas.png\"")
  assert html |> string.contains("/img/superclubnet.jpg")
  assert html |> string.contains("/img/elixir-fullstack.jpg")
  assert html |> string.contains("/img/wren-libro.jpg")
  assert html |> string.contains("/img/emilipothese-FTfjMijq-Ws-unsplash.jpg")
  assert html |> string.contains("/img/niklas-konig-1cTFuvI14J4-unsplash.jpg")
  assert html |> string.contains("/img/quirquincho.jpg")
  assert html |> string.contains("/img/rolplay-manual.png")
  assert html |> string.contains("/img/rossa.gif")
  assert html |> string.contains("/img/quechaucha.jpg")
  assert html |> string.contains("/img/munstajump.gif")
  // Alts survive the switch.
  assert html |> string.contains("Logo de Elixir Chile")
  assert html |> string.contains("Logo de Jasonelle")
  assert html |> string.contains("Foto de Emilipothèse en Unsplash")
  assert html |> string.contains("Foto de Niklas König en Unsplash")
  assert html |> string.contains("Portada de Super Club Net")
  // Every showcase section serves from /img: no remote image host remains
  // anywhere in the markup.
  assert string.contains(html, "avatars.githubusercontent.com") == False
  assert string.contains(html, "raw.githubusercontent.com") == False
  assert string.contains(html, "ninjas.cl/covers") == False
  assert string.contains(html, "ninjas.cl/blog") == False
  // Only the hero logo keeps its absolute production URL.
  assert html |> string.contains("https://ninjas.cl/img/Ninjas.png")
}

pub fn books_card_for_operating_systems_concepts_test() {
  // The new book ships as a regular showcase card: its cover, alt text,
  // July 2025 caption, both links, and the two-sentence summary in every
  // site language.
  let spanish = home.view(home.spanish_text, []) |> element.to_string
  assert spanish |> string.contains("Conceptos de Sistemas Operativos")
  assert spanish
    |> string.contains("src=\"/img/niklas-konig-1cTFuvI14J4-unsplash.jpg\"")
  assert spanish |> string.contains("Foto de Niklas König en Unsplash")
  assert spanish |> string.contains("Desde Julio 2025")
  assert spanish
    |> string.contains(
      "href=\"https://ninjascl.github.io/sistemas-operativos/\"",
    )
  assert spanish
    |> string.contains(
      "href=\"https://github.com/NinjasCL/sistemas-operativos\"",
    )
  assert spanish
    |> string.contains(
      "Un recorrido práctico por los conceptos de sistemas operativos",
    )

  let english = home.view(home.english_text, []) |> element.to_string
  assert english
    |> string.contains("A hands-on tour of operating system concepts")
  assert english |> string.contains("Since July 2025")

  let japanese = home.view(home.japanese_text, []) |> element.to_string
  assert japanese |> string.contains("オペレーティングシステムの概念を実践的に解説")
  assert japanese |> string.contains("2025年7月から")

  let portuguese = home.view(home.portuguese_text, []) |> element.to_string
  assert portuguese
    |> string.contains(
      "Um percurso prático pelos conceitos de sistemas operacionais",
    )
  assert portuguese |> string.contains("Desde Julho 2025")
}

pub fn home_covers_old_catalog_items_test() {
  // Every showcase item carried over from the legacy catalog ships on the
  // new home page — Jasonelle included, restored from projects.json with
  // its logo served from the site's own /img and its texts in Spanish.
  let html = home.view(home.spanish_text, []) |> element.to_string

  list.each(
    [
      // projects.json
      "https://elixircl.github.io",
      "https://jasonelle.com",
      "https://joyofpw.github.io/",
      "https://chaucha.cl/",
      // books.json, plus the newer Robótica con Elixir and Conceptos de
      // Sistemas Operativos
      "https://elixircl.github.io/elixir-robotics/",
      "https://ninjascl.github.io/sistemas-operativos/",
      "https://ninjas.cl/books/superclubnet/",
      "https://ninjas.cl/books/elixir-fullstack/",
      "https://ninjas.cl/books/wren-libro/",
      "https://archive.org/details/quirquincho",
      // games.json
      "https://ninjascl.github.io/rolplus/",
      "https://www.lexaloffle.com/bbs/?tid=28945",
      "https://proyecto-chaucha.github.io/quechaucha/",
      "https://clsource.itch.io/munsta-jump",
    ],
    fn(url) {
      assert html |> string.contains("href=\"" <> url <> "\"")
    },
  )

  // The restored Jasonelle card: local logo, Spanish date, and the code
  // repository beside the site link.
  assert html |> string.contains("src=\"/img/jasonelle.png\"")
  assert html |> string.contains("Logo de Jasonelle")
  assert html |> string.contains("Desde Noviembre 2018")
  assert html |> string.contains("https://github.com/jasonelle/")
}

pub fn showcase_cards_follow_about_row_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // Fifteen card rows: five in proyectos, six in libros, four in juegos.
  let pieces = string.split(html, "showcase__cols")
  assert list.length(pieces) == 16
  // Each row card puts its figure before its text: the Elixir Chile alt
  // precedes its card title, and the Profesor Rossa alt precedes its
  // juegos card title the same way.
  let assert Ok(#(before_alt, after_alt)) =
    string.split_once(html, "Logo de Elixir Chile")
  assert before_alt |> string.contains("showcase__cols")
  assert after_alt |> string.contains("Elixir Chile 🇨🇱")
  let assert Ok(#(before_rossa, after_rossa)) =
    string.split_once(html, "Captura del juego Profesor Rossa")
  assert before_rossa |> string.contains("showcase__cols")
  assert after_rossa |> string.contains("Profesor Rossa")
  // Captions survive under the images.
  assert html |> string.contains("Desde Marzo 2022")
  // The card row grid and the grouped figure-fill rules ship in style.css.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".showcase__cols")
  assert css |> string.contains(".showcase__cols .rs-figure")
}

pub fn games_cards_lead_titles_with_the_games_icon_test() {
  // Every games card leads its title with the Media Player icon from the
  // win95 pack — decorative, empty alt — the same inline presentation the
  // projects and books card titles use.
  let html = home.view(home.spanish_text, []) |> element.to_string
  let icon_src = "src=\"/icons/win95/Mmsys108_32x32_4.png\""
  let assert [_, rolplay, rossa, chaucha, munsta] = string.split(html, icon_src)

  assert rolplay |> string.contains("Rolplay Manual")
  assert rossa |> string.contains("Profesor Rossa")
  assert chaucha |> string.contains("¡Qué Chaucha!")
  assert munsta |> string.contains("Munsta Jump!")
}

pub fn showcase_image_boxes_share_height_test() {
  // Showcase card image boxes share the Super Club Net height (that
  // cover's 1050×1600 ratio) and letterbox undistorted; the about
  // portrait and the featured post's figures keep the separate
  // natural-proportions rule.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".showcase__cols .rs-figure img")
  assert css |> string.contains("aspect-ratio: 1050 / 1600")
  assert css |> string.contains("object-fit: contain")
  // The about and featured-post img rules share the natural-proportions
  // rule, and the about img rule stays out of the showcase ratio box.
  assert css |> string.contains("#about .rs-figure img,")
  assert css |> string.contains(".post__cols .rs-figure img {")
  assert string.contains(
      css,
      "#about .rs-figure img,\n.showcase__cols .rs-figure img",
    )
    == False
}

pub fn showcase_buttons_carry_icons_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // Thirty icon buttons: the single-word view and code labels on all
  // fifteen showcase cards, and no small variant left anywhere.
  let pieces = string.split(html, "rs-btn--icon")
  assert list.length(pieces) == 31
  assert string.contains(html, "rs-btn--small") == False
  // Each button leads with its matching icon beside its label — one
  // word per language, never the former bilingual form.
  let assert Ok(#(_, after_view)) =
    string.split_once(html, "src=\"/icons/win95/Shdocvw257_32x32_8.png\"")
  assert after_view |> string.contains("Ver</a>")
  let assert Ok(#(_, after_code)) =
    string.split_once(html, "src=\"/icons/win95/Wscript100_32x32_4.png\"")
  assert after_code |> string.contains("Código</a>")
  assert string.contains(html, "Ver / View") == False
  assert string.contains(html, "Código / Code") == False
}

pub fn showcase_buttons_are_enlarged_test() {
  let html = home.view(home.spanish_text, []) |> element.to_string

  // Every showcase button carries retrostrap's large variant (the custom
  // size override is gone, so the native :active press applies), and the
  // pixelated icon box rule ships in style.css.
  let pieces = string.split(html, "rs-btn--large")
  assert list.length(pieces) == 31
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert string.contains(css, ".showcase__cols .rs-btn {") == False
  assert css |> string.contains(".showcase__cols .rs-btn img")
  assert css |> string.contains("image-rendering: pixelated")
}

pub fn emojis_render_as_static_icons_test() {
  // The featured-post heading (with its star icon) only renders when a
  // post exists, so the home view is exercised with a one-post fixture.
  let fixture =
    post.Post(
      title: "Bienvenidos a Ninjas.cl",
      slug: "bienvenidos-a-ninjas-cl",
      url: "https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/",
      date: timestamp.from_calendar(
        date: calendar.Date(2026, calendar.November, 16),
        time: calendar.TimeOfDay(0, 0, 0, 0),
        offset: calendar.utc_offset,
      ),
      description: "El sitio vuelve a estar en línea.",
      excerpt: "",
      language: option.None,
      featured_image: option.None,
      contents: [],
      extras: dict.new(),
    )

  let html = home.view(home.spanish_text, [fixture]) |> element.to_string

  // The navbar leads with its icons; the flower precedes Sobre nosotros.
  let assert Ok(#(_, after_desktop)) =
    string.split_once(html, "src=\"/icons/win95/Desktop_32x32_4.png\"")
  assert after_desktop |> string.contains("Inicio")
  let assert Ok(#(_, after_flower)) =
    string.split_once(html, "src=\"/icons/win95/D3FlowerBox100_32x32_4.png\"")
  assert after_flower |> string.contains("Sobre nosotros")
  // The wizard icon precedes the Elixir Chile title, whose flag stays.
  let assert Ok(#(_, after_wizard)) =
    string.split_once(html, "src=\"/icons/win95/Regwiz117_32x32_4.png\"")
  assert after_wizard |> string.contains("Elixir Chile 🇨🇱")
  // The star precedes the featured-post heading.
  let assert Ok(#(_, after_star)) =
    string.split_once(html, "src=\"/icons/win95/Star_32x32_4.png\"")
  assert after_star |> string.contains("Entrada destacada")
  // Every mapping icon renders somewhere on the page.
  assert html |> string.contains("/icons/win95/Notepad_32x32_4.png")
  assert html |> string.contains("/icons/win95/Bulb_32x32_4.png")
  assert html |> string.contains("/icons/win95/HelpBook_32x32_4.png")
  assert html |> string.contains("/icons/win95/Winmine1_32x32_4.png")
  assert html |> string.contains("/icons/win95/Fastboot101_32x32_4.png")
  assert html |> string.contains("/icons/win95/Quartz100_32x32_4.png")
  assert html |> string.contains("/icons/win95/Star_32x32_4.png")
  // The removed Contacto controls leave no Globe or Mail icon anywhere.
  assert string.contains(html, "/icons/win95/Globe_32x32_4.png") == False
  assert string.contains(html, "/icons/win95/Mail_32x32_4.png") == False
  // None of the replaced emojis remains in the markup.
  assert string.contains(html, "🏠") == False
  assert string.contains(html, "📖") == False
  assert string.contains(html, "🌸") == False
  assert string.contains(html, "🔮") == False
  assert string.contains(html, "📚") == False
  assert string.contains(html, "🎮") == False
  assert string.contains(html, "🧙") == False
  assert string.contains(html, "🚀") == False
  assert string.contains(html, "🪙") == False
  assert string.contains(html, "⭐") == False
  // The kept emojis remain — the Spanish home's tagline among them.
  assert html |> string.contains("Software de 🇨🇱 con ❤️")
  assert html |> string.contains("🥷 Ninjas.cl")
  assert html |> string.contains("🛸 Jasonelle")
  assert html |> string.contains("Copyright 🥷🏽")
  // The shared inline presentation ships in style.css.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".site-icon {")
  assert css |> string.contains("image-rendering: pixelated")
}

pub fn icon_manifest_documents_matches_test() {
  // The manifest in the static icon directory names every icon the
  // markup uses, and records the kept emojis with reasons.
  let assert Ok(manifest) =
    simplifile.read("./static/icons/win95/emoji-matches.json")
  assert manifest |> string.contains("Desktop_32x32_4.png")
  assert manifest |> string.contains("Notepad_32x32_4.png")
  assert manifest |> string.contains("D3FlowerBox100_32x32_4.png")
  assert manifest |> string.contains("Bulb_32x32_4.png")
  assert manifest |> string.contains("HelpBook_32x32_4.png")
  assert manifest |> string.contains("Winmine1_32x32_4.png")
  assert manifest |> string.contains("Regwiz117_32x32_4.png")
  assert manifest |> string.contains("Fastboot101_32x32_4.png")
  assert manifest |> string.contains("Quartz100_32x32_4.png")
  assert manifest |> string.contains("Star_32x32_4.png")
  // The post warnings' icon joins the documented matches.
  assert manifest |> string.contains("Warning_32x32_4.png")
  // The post navigation buttons' pointing hand replaces the arrows.
  assert manifest |> string.contains("Msow10_32x32_4.png")
  assert string.contains(manifest, "Hand_32x32_4.png") == False
  assert string.contains(manifest, "ArrowLeft_32x32_4.png") == False
  assert string.contains(manifest, "ArrowRight_32x32_4.png") == False
  // The tags row's icon joins the documented matches.
  assert manifest |> string.contains("Bookmark_32x32_4.png")
  // The removed Contacto controls took their matches with them: no Mail or
  // Globe icons and no envelope or octopus emojis remain.
  assert string.contains(manifest, "Mail_32x32_4.png") == False
  assert string.contains(manifest, "Globe_32x32_4.png") == False
  assert string.contains(manifest, "✉️") == False
  assert string.contains(manifest, "🐙") == False
  assert manifest |> string.contains("🇨🇱")
  assert manifest |> string.contains("❤️")
  assert manifest |> string.contains("🥷")
  assert manifest |> string.contains("🛸")
}

fn featured_post_fixture(image: option.Option(String)) -> post.Post(Nil) {
  post.Post(
    title: "Bienvenidos a Ninjas.cl",
    slug: "bienvenidos-a-ninjas-cl",
    url: "https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/",
    date: timestamp.from_calendar(
      date: calendar.Date(2026, calendar.November, 16),
      time: calendar.TimeOfDay(0, 0, 0, 0),
      offset: calendar.utc_offset,
    ),
    description: "El sitio vuelve a estar en línea.",
    excerpt: "",
    language: option.None,
    featured_image: image,
    contents: [],
    extras: dict.new(),
  )
}

pub fn featured_post_follows_about_row_test() {
  // With its own featured image, the featured post renders the row: the
  // figure leads before the title, and the button is a large icon one.
  let html =
    home.view(home.spanish_text, [
      featured_post_fixture(option.Some("/img/superclubnet.jpg")),
    ])
    |> element.to_string

  assert html |> string.contains("post__cols")
  let assert Ok(#(before_image, after_image)) =
    string.split_once(html, "src=\"/img/superclubnet.jpg\"")
  assert before_image |> string.contains("post__cols")
  assert after_image |> string.contains("Bienvenidos a Ninjas.cl")
  assert html |> string.contains("rs-btn rs-btn--icon rs-btn--large")
  let assert Ok(#(_, after_reader)) =
    string.split_once(html, "src=\"/icons/win95/Progman25_32x32_4.png\"")
  assert after_reader |> string.contains("Leer entrada")
  // Without a featured image, the Ninjas placeholder keeps the row.
  let bare =
    home.view(home.spanish_text, [featured_post_fixture(option.None)])
    |> element.to_string
  assert bare |> string.contains("post__cols")
  assert bare |> string.contains("src=\"/img/Ninjas.png\"")
  // The styles: the post grid mirrors the about values and joins the
  // natural-proportions figure treatment.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post__cols {")
  assert css |> string.contains(".post__cols .rs-figure img")
  // The title link leads with the newspaper icon and the date with the
  // calendar icon.
  let assert Ok(#(_, after_news)) =
    string.split_once(html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert after_news |> string.contains("Bienvenidos a Ninjas.cl")
  let assert Ok(#(before_cal, after_cal)) =
    string.split_once(html, "src=\"/icons/win95/Timedate_32x32_4.png\"")
  assert before_cal |> string.contains("Bienvenidos a Ninjas.cl")
  assert after_cal |> string.contains("2026-11-16")
  // The current post's frontmatter pins its featured image.
  let assert Ok(post_djot) =
    simplifile.read("./blog/bienvenidos-a-ninjas-cl/index.djot")
  assert post_djot |> string.contains("featured_image: /img/Ninjas.png")
}

pub fn featured_post_title_leads_with_the_posts_icon_test() {
  // The home page's featured row leads its linked title with the
  // post's own icon — the newspaper fallback staying covered by the
  // about-row test above.
  let iconed = icon_fixture(option.Some("Earth_32x32_4.png"))
  let html = home.view(home.spanish_text, [iconed]) |> element.to_string

  let assert Ok(#(_, after_earth)) =
    string.split_once(html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert after_earth |> string.contains("Bienvenidos a Ninjas.cl")
  assert string.contains(html, "Mailnews8_32x32_4.png") == False
}

pub fn post_template_title_and_date_lead_with_icons_test() {
  let html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string

  // The article title leads with the newspaper icon and the post-meta
  // date with the calendar icon, matching the featured post's row.
  let assert Ok(#(_, after_news)) =
    string.split_once(html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert after_news |> string.contains("Bienvenidos a Ninjas.cl")
  let assert Ok(#(before_cal, after_cal)) =
    string.split_once(html, "src=\"/icons/win95/Timedate_32x32_4.png\"")
  assert before_cal |> string.contains("Bienvenidos a Ninjas.cl")
  assert after_cal |> string.contains("2026-11-16")
}

/// A post fixture carrying an `icon` frontmatter value (or none), for
/// the title-icon tests.
fn icon_fixture(icon: option.Option(String)) -> post.Post(Nil) {
  post.Post(..featured_post_fixture(option.None), extras: case icon {
    option.None -> dict.new()
    option.Some(value) -> dict.from_list([#("icon", value)])
  })
}

pub fn post_icon_url_resolves_static_icons_test() {
  // The `icon` frontmatter value resolves against the static packs: a
  // bare filename searches the win95 pack and then the macos9 pack, a
  // qualified name resolves as given, and a leading /icons/ is
  // tolerated — every form reaching the same rendered path.
  assert site.post_icon_url(icon_fixture(option.Some("Bulb_32x32_4.png")))
    == "/icons/win95/Bulb_32x32_4.png"
  assert site.post_icon_url(icon_fixture(option.Some("1.png")))
    == "/icons/macos9/1.png"
  assert site.post_icon_url(icon_fixture(option.Some("win95/Star_32x32_4.png")))
    == "/icons/win95/Star_32x32_4.png"
  assert site.post_icon_url(icon_fixture(option.Some("/icons/macos9/5.png")))
    == "/icons/macos9/5.png"
}

pub fn post_icon_falls_back_to_the_newspaper_test() {
  // The newspaper icon leads every title without a resolvable icon: no
  // key, an empty value, an unknown filename, or a path outside the
  // packs — a mistyped name never renders a broken image.
  let newspaper = "/icons/win95/Mailnews8_32x32_4.png"
  assert site.post_icon_url(icon_fixture(option.None)) == newspaper
  assert site.post_icon_url(icon_fixture(option.Some(""))) == newspaper
  assert site.post_icon_url(icon_fixture(option.Some("NoSuchIcon_32x32_4.png")))
    == newspaper
  assert site.post_icon_url(icon_fixture(option.Some("../style.css")))
    == newspaper
  assert site.post_icon_url(icon_fixture(option.Some("/img/Ninjas.png")))
    == newspaper
}

pub fn post_page_title_leads_with_the_posts_icon_test() {
  // A post with an `icon` renders it beside its title on the post page's
  // h1 — the newspaper icon never reaching the page. The fallback stays
  // covered by the template's own title test above.
  let iconed = icon_fixture(option.Some("Earth_32x32_4.png"))
  let html = site.post_template(iconed, [iconed]) |> element.to_string

  let assert Ok(#(before_earth, after_earth)) =
    string.split_once(html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert before_earth |> string.contains("<h1>")
  assert after_earth |> string.contains("Bienvenidos a Ninjas.cl")
  assert string.contains(html, "Mailnews8_32x32_4.png") == False
}

/// A post whose description carries a bare URL with trailing prose
/// punctuation, for the description-link tests.
fn url_description_fixture() -> post.Post(Nil) {
  post.Post(
    title: "Wren Playground",
    slug: "wren-playground",
    url: "https://ninjas.cl/blog/wren-playground/",
    date: timestamp.from_calendar(
      date: calendar.Date(2026, calendar.November, 16),
      time: calendar.TimeOfDay(0, 0, 0, 0),
      offset: calendar.utc_offset,
    ),
    description: "Una pequeña alternativa a https://runjs.app/, hecha para Wren.",
    excerpt: "",
    language: option.None,
    featured_image: option.None,
    contents: [],
    extras: dict.new(),
  )
}

pub fn post_page_description_links_urls_test() {
  // The description paragraph links the bare URL inline in the prose,
  // the trailing comma staying outside the anchor.
  let html =
    site.post_template(url_description_fixture(), [])
    |> element.to_string

  assert html
    |> string.contains(
      "Una pequeña alternativa a <a href=\"https://runjs.app/\">https://runjs.app/</a>, hecha para Wren.",
    )
}

pub fn featured_row_description_links_urls_test() {
  // The home page's featured row renders its description the same way:
  // the bare URL as an anchor, the trailing comma outside.
  let html =
    home.view(home.spanish_text, [url_description_fixture()])
    |> element.to_string

  assert html
    |> string.contains(
      "<a href=\"https://runjs.app/\">https://runjs.app/</a>, hecha para Wren.",
    )
}

pub fn raw_description_consumers_stay_raw_test() {
  // The blog index entry card is one link, so its description stays
  // plain text — no anchor to the URL anywhere on the index page.
  let index_html =
    site.blog_index_view(1)([url_description_fixture()])
    |> element.to_string
  assert string.contains(index_html, "<a href=\"https://runjs.app/\">") == False
  assert index_html |> string.contains("https://runjs.app/, hecha para Wren.")

  // The post page's meta description carries the raw frontmatter text.
  let post_html =
    site.post_template(url_description_fixture(), [])
    |> element.to_string
  assert post_html
    |> string.contains(
      "content=\"Una pequeña alternativa a https://runjs.app/, hecha para Wren.\"",
    )
}

pub fn not_found_view_renders_chrome_and_message_test() {
  let html = site.not_found_view() |> element.to_string

  // The shared navbar renders with non-home semantics: home-prefixed
  // section links and no current-page marker.
  assert html |> string.contains("rs-navbar")
  assert html |> string.contains("href=\"/#projects\"")
  assert string.contains(html, "aria-current") == False
  // The footer keeps its trim: the copyright line and back-to-top link.
  assert html |> string.contains("rs-footer")
  assert html |> string.contains("href=\"#masthead\"")
  // The Sad Mac leads the message, the page's single main heading.
  assert html |> string.contains("src=\"/img/sad_mac.png\"")
  let pieces = string.split(html, "<h1")
  assert list.length(pieces) == 2
  assert html
    |> string.contains("La página que buscabas está en otro castillo")
  // The page titles itself 404.
  assert html |> string.contains("<title>404 — Ninjas.cl</title>")
  // The masthead renders the navbar alone — no hero element at all.
  assert string.contains(html, "hero") == False
}

pub fn head_meta_suite_renders_on_every_page_test() {
  let home_html = home.view(home.spanish_text, []) |> element.to_string
  let post_html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string
  let not_found = site.not_found_view() |> element.to_string

  // The identity chrome and the structured-data block ship on every
  // page, with the fixed og/twitter fields beside them.
  list.each([home_html, post_html, not_found], fn(html) {
    assert html |> string.contains("name=\"generator\"")
    assert html |> string.contains("https://github.com/veeso/blogatto")
    assert html |> string.contains("href=\"/humans.txt\"")
    assert html |> string.contains("apple-touch-icon")
    assert html |> string.contains("/favicon-32x32.png")
    assert html |> string.contains("/favicon-16x16.png")
    assert html |> string.contains("href=\"/site.webmanifest\"")
    assert html
      |> string.contains("content=\"index,follow\" name=\"robots\"")
    assert html
      |> string.contains("content=\"CC-BY-NC-ND\" name=\"usage-rights\"")
    assert html |> string.contains("content=\"ninjas, ninja")
    assert html
      |> string.contains("content=\"website\" property=\"og:type\"")
    assert html
      |> string.contains(
        "content=\"https://ninjas.cl/logo_og.png\" property=\"og:image\"",
      )
    // The Open Graph locale mirrors the page's language: the site's es_CL
    // on every default page.
    assert html
      |> string.contains("content=\"es_CL\" property=\"og:locale\"")
    assert html
      |> string.contains(
        "content=\"summary_large_image\" name=\"twitter:card\"",
      )
    // The structured-data block ships unescaped with the Spanish
    // description inside.
    assert html |> string.contains("application/ld+json")
    assert html
      |> string.contains("\"headline\": \"Ninjas Chile (Ninjas.cl)\"")
    assert html |> string.contains("\"datePublished\": \"2026-11-21\"")
    assert html |> string.contains("por @CLSource.")
    // The JetBrains Mono font ships from Google Fonts on every page: the
    // two preconnects and the stylesheet, before the site CSS.
    assert html
      |> string.contains(
        "href=\"https://fonts.googleapis.com\" rel=\"preconnect\"",
      )
    assert html
      |> string.contains(
        "crossorigin href=\"https://fonts.gstatic.com\" rel=\"preconnect\"",
      )
    assert html
      |> string.contains(
        "href=\"https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&amp;display=swap\" rel=\"stylesheet\"",
      )
  })

  // The mirrored fields: the home carries the site identity, the post
  // its own title and URL, and the not-found page its 404 title.
  assert home_html
    |> string.contains("content=\"Ninjas.cl\" property=\"og:title\"")
  assert home_html
    |> string.contains("content=\"https://ninjas.cl/\" property=\"og:url\"")
  assert post_html
    |> string.contains(
      "content=\"Bienvenidos a Ninjas.cl — Ninjas.cl\" property=\"og:title\"",
    )
  assert post_html
    |> string.contains(
      "content=\"https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/\" property=\"og:url\"",
    )
  assert not_found
    |> string.contains("content=\"404 — Ninjas.cl\" property=\"og:title\"")
  assert not_found
    |> string.contains(
      "content=\"https://ninjas.cl/404.html\" property=\"og:url\"",
    )
  // The per-page meta description stays the only one.
  let pieces = string.split(home_html, "name=\"description\"")
  assert list.length(pieces) == 2
}

pub fn page_container_violet_wash_test() {
  // The main container carries the old ninjas.cl scheme's full
  // .violet-frame recipe — the wash at about 5% transparency plus the
  // dashed #7540bd border — and only that: no theme token or text
  // color changes ride along.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css
    |> string.contains("html[data-rs-theme=\"cosmic\"] .rs-page {")
  assert css |> string.contains("background: rgba(33, 4, 49, 0.945);")
  assert css |> string.contains("border-style: dashed;")
  assert css |> string.contains("border-color: #7540bd;")
  assert string.contains(css, "--rs-bg-content:") == False
  assert string.contains(css, "--rs-text:") == False
}

pub fn background_patterns_match_shipped_files_test() {
  let assert Ok(js) = simplifile.read("./static/background.js")

  // The offered list is the array literal in background.js: the entries
  // between [ and ], trimmed of quotes and whitespace.
  let assert Ok(#(_, after_bracket)) = string.split_once(js, "[")
  let assert Ok(#(list_string, _)) = string.split_once(after_bracket, "]")
  let offered =
    list_string
    |> string.split(",")
    |> list.map(fn(entry) { entry |> string.trim |> string.replace("\"", "") })
    |> list.filter(fn(entry) { entry != "" })

  // The shipped tiles: every .png under the three pattern sets — the
  // numbered macOS set, the named Windows 3.1 set, and the custom set
  // for owner-added tiles — prefixed with its set's subdirectory.
  let assert Ok(macos9_files) =
    simplifile.read_directory("./static/patterns/macos9")
  let assert Ok(win_files) =
    simplifile.read_directory("./static/patterns/win3.1")
  let assert Ok(custom_files) =
    simplifile.read_directory("./static/patterns/custom")
  let shipped =
    [
      list.map(macos9_files, fn(file) { "macos9/" <> file }),
      list.map(win_files, fn(file) { "win3.1/" <> file }),
      list.map(custom_files, fn(file) { "custom/" <> file }),
    ]
    |> list.flatten
    |> list.filter(fn(file) { string.ends_with(file, ".png") })

  // No duplicates, and the offered list matches the shipped PNGs exactly:
  // every offered tile exists, every shipped PNG is offered, and the
  // sets' non-image files (like the macos9 LICENSE) are not offered.
  assert list.length(offered) == list.length(list.unique(offered))
  let sorted_offered = list.sort(offered, string.compare)
  let sorted_shipped = list.sort(shipped, string.compare)
  assert sorted_offered == sorted_shipped
}

pub fn background_pattern_fallback_test() {
  // Without JavaScript the stylesheet's fallback tile must resolve at the
  // reorganized pattern path.
  let assert Ok(css) = simplifile.read("./static/style.css")
  let fallback = "--random-pattern: url(\"/patterns/macos9/128.png\")"
  assert css |> string.contains(fallback)
}

pub fn cursor_pack_ships_in_stylesheet_test() {
  // The retro cursor pack: the arrow points by default and the hand
  // points on interactive controls, both served from the site's /cursors
  // assets; disabled controls fall back to the custom arrow.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains("cursor: url(\"/cursors/arrow.cur\"), auto;")
  assert css |> string.contains("cursor: url(\"/cursors/hand.cur\"), pointer;")
  assert css
    |> string.contains("cursor: url(\"/cursors/arrow.cur\"), default;")
}

pub fn post_template_renders_masthead_test() {
  // Without a featured image, the cover defaults to the Ninjas logo.
  let html =
    site.post_template(featured_post_fixture(option.None), [])
    |> element.to_string

  assert html |> string.contains("rs-navbar")
  assert html |> string.contains("id=\"masthead\"")
  assert html |> string.contains("href=\"/#projects\"")
  assert html |> string.contains("Bienvenidos a Ninjas.cl")
  // The cover fills the masthead: the cover class plus the inline
  // background image — the default Ninjas logo without a featured image.
  assert html |> string.contains("masthead masthead--cover")
  assert html |> string.contains("background-image:url(/img/Ninjas.png);")
  // Only the navbar rides the cover: no hero logo, no "忍者 開発者" site
  // title, no marquee — and no current-page marker off the home page.
  assert string.contains(html, "hero__logo") == False
  assert string.contains(html, "忍者 開発者") == False
  assert string.contains(html, "site-header") == False
  assert string.contains(html, "rs-marquee") == False
  assert string.contains(html, "aria-current") == False

  // With a featured image, the cover is that image.
  let covered =
    site.post_template(
      featured_post_fixture(option.Some("/img/superclubnet.jpg")),
      [],
    )
    |> element.to_string
  assert covered
    |> string.contains("background-image:url(/img/superclubnet.jpg);")

  // The cover presentation lives in the static asset, like the banner
  // wall's: cover sizing, centered, no repeat, and the banner min-height.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".masthead--cover {")
  assert css |> string.contains("background-size: cover")
  assert css |> string.contains("background-position: center")
  assert css |> string.contains("background-repeat: no-repeat")
  assert css |> string.contains("min-height: 240px")
}

/// A post variant fixture: the same slug for every language so the
/// variants group as one post's language options, with the variant URL
/// blogatto derives from the language code.
fn post_variant_fixture(language: option.Option(String)) -> post.Post(Nil) {
  let url = case language {
    option.None -> "https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/"
    option.Some(code) ->
      "https://ninjas.cl/blog/" <> code <> "/bienvenidos-a-ninjas-cl/"
  }
  post.Post(
    title: "Bienvenidos a Ninjas.cl",
    slug: "bienvenidos-a-ninjas-cl",
    url: url,
    date: timestamp.from_calendar(
      date: calendar.Date(2026, calendar.November, 16),
      time: calendar.TimeOfDay(0, 0, 0, 0),
      offset: calendar.utc_offset,
    ),
    description: "El sitio vuelve a estar en línea.",
    excerpt: "",
    language: language,
    featured_image: option.None,
    contents: [],
    extras: dict.new(),
  )
}

/// A post fixture with an arbitrary date and language, for staleness
/// checks in any variant.
fn dated_post_fixture(
  language: option.Option(String),
  date: timestamp.Timestamp,
) -> post.Post(Nil) {
  post.Post(
    title: "Bienvenidos a Ninjas.cl",
    slug: "bienvenidos-a-ninjas-cl",
    url: "https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/",
    date: date,
    description: "El sitio vuelve a estar en línea.",
    excerpt: "",
    language: language,
    featured_image: option.None,
    contents: [],
    extras: dict.new(),
  )
}

pub fn post_language_options_render_per_variant_test() {
  let default = post_variant_fixture(option.None)
  let english = post_variant_fixture(option.Some("en"))
  let japanese = post_variant_fixture(option.Some("ja"))
  let portuguese = post_variant_fixture(option.Some("pt"))
  let all_posts = [default, english, japanese, portuguese]

  // The default page's row: all four variants in the declared order, the
  // current Spanish entry plain text marked as the current page, the
  // others linking to their variant URLs, separated by " · ".
  let html = site.post_template(default, all_posts) |> element.to_string
  assert html
    |> string.contains(
      "Idiomas: <span aria-current=\"page\">Español</span> · <a href=\"https://ninjas.cl/blog/en/bienvenidos-a-ninjas-cl/\">English</a> · <a href=\"https://ninjas.cl/blog/ja/bienvenidos-a-ninjas-cl/\">日本語</a> · <a href=\"https://ninjas.cl/blog/pt/bienvenidos-a-ninjas-cl/\">Português</a>",
    )

  // The translated pages keep the row with their own current entry, the
  // default variant linked back — and the row's label follows the page's
  // language: "Languages" on English, "言語" on Japanese, "Idiomas" on
  // Spanish and Portuguese, with the Spanish label absent from the en/ja
  // pages.
  let en_html = site.post_template(english, all_posts) |> element.to_string
  assert en_html |> string.contains("Languages: ")
  assert en_html |> string.contains("aria-current=\"page\">English")
  assert en_html
    |> string.contains(
      "href=\"https://ninjas.cl/blog/bienvenidos-a-ninjas-cl/\"",
    )
  assert string.contains(en_html, "Idiomas: ") == False

  let ja_html = site.post_template(japanese, all_posts) |> element.to_string
  assert ja_html |> string.contains("言語: ")
  assert string.contains(ja_html, "Idiomas: ") == False

  let pt_html = site.post_template(portuguese, all_posts) |> element.to_string
  assert pt_html |> string.contains("Idiomas: ")

  // A post with a single variant renders no options row.
  let single = site.post_template(default, [default]) |> element.to_string
  assert string.contains(single, "Idiomas: ") == False
  assert string.contains(single, "post-languages") == False

  // The row's presentation ships in style.css.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-languages {")
  assert css |> string.contains(".post-languages span[aria-current=\"page\"]")
}

pub fn language_options_rows_lead_with_their_icon_test() {
  // The three language options rows — the post page's, the blog index's,
  // and the home page's — lead their label with the Win95 Regional
  // Settings icon, the era's own languages indicator: the icon precedes
  // the "Idiomas: " label on every page that renders the row.
  let default = post_variant_fixture(option.None)
  let english = post_variant_fixture(option.Some("en"))
  let all = [default, english]
  let icon_src = "src=\"/icons/win95/Intl101_32x32_4.png\""

  // The post page.
  let post_html = site.post_template(default, all) |> element.to_string
  let assert Ok(#(_, after_icon)) = string.split_once(post_html, icon_src)
  assert after_icon |> string.contains("Idiomas: ")

  // The blog index.
  let index_html =
    site.blog_index_view(1)(index_test_posts()) |> element.to_string
  let assert Ok(#(_, index_after_icon)) =
    string.split_once(index_html, icon_src)
  assert index_after_icon |> string.contains("Idiomas: ")

  // The home page.
  let home_html = home.view(home.spanish_text, []) |> element.to_string
  let assert Ok(#(_, home_after_icon)) = string.split_once(home_html, icon_src)
  assert home_after_icon |> string.contains("Idiomas: ")
}

pub fn translated_variants_warn_machine_translation_test() {
  let default = post_variant_fixture(option.None)
  let english = post_variant_fixture(option.Some("en"))
  let japanese = post_variant_fixture(option.Some("ja"))
  let portuguese = post_variant_fixture(option.Some("pt"))
  let all_posts = [default, english, japanese, portuguese]

  // The translated variants carry the machine-translated warning in their
  // own language, led by the warning icon.
  let en_html = site.post_template(english, all_posts) |> element.to_string
  assert en_html |> string.contains("post-warning")
  assert en_html
    |> string.contains("machine translation of the original Spanish post")
  assert en_html |> string.contains("Warning_32x32_4.png")

  let ja_html = site.post_template(japanese, all_posts) |> element.to_string
  assert ja_html |> string.contains("機械翻訳したもので")

  let pt_html = site.post_template(portuguese, all_posts) |> element.to_string
  assert pt_html
    |> string.contains("tradução automática da publicação original em espanhol")

  // The default variant carries no translation warning.
  let es_html = site.post_template(default, all_posts) |> element.to_string
  assert string.contains(es_html, "machine translation") == False
  assert string.contains(es_html, "機械翻訳") == False
  assert string.contains(es_html, "tradução automática") == False

  // The warning presentation ships in style.css.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-warning {")
}

pub fn stale_post_warns_with_day_count_test() {
  // Dates relative to the build's current day, so the test never rots: a
  // 400-day-old post is stale, a 30-day-old one is fresh.
  let now = timestamp.system_time()
  let stale =
    dated_post_fixture(
      option.None,
      timestamp.add(now, duration.seconds(-400 * 86_400)),
    )
  let fresh =
    dated_post_fixture(
      option.None,
      timestamp.add(now, duration.seconds(-30 * 86_400)),
    )

  // The stale post renders the pinned warning wording…
  let stale_html = site.post_template(stale, [stale]) |> element.to_string
  assert stale_html
    |> string.contains(
      "Este contenido puede estar desactualizado ya que han pasado más de ",
    )
  // …with the elapsed day count spliced in, a real number past the
  // one-year threshold.
  let assert Ok(#(_, after_days)) =
    string.split_once(stale_html, "han pasado más de ")
  let assert Ok(#(days_text, _)) =
    string.split_once(after_days, " días desde su publicación")
  let assert Ok(days) = int.parse(days_text)
  assert days > 365

  // The fresh post carries no staleness warning.
  let fresh_html = site.post_template(fresh, [fresh]) |> element.to_string
  assert string.contains(fresh_html, "desactualizado") == False
}

pub fn stale_warning_follows_variant_language_test() {
  // A stale post's warning follows the rendered page's language: each
  // variant words it in its own language, the elapsed days spliced in
  // place of the template's {days} placeholder.
  let now = timestamp.system_time()
  let date = timestamp.add(now, duration.seconds(-400 * 86_400))
  let spanish = dated_post_fixture(option.None, date)
  let english = dated_post_fixture(option.Some("en"), date)
  let japanese = dated_post_fixture(option.Some("ja"), date)
  let portuguese = dated_post_fixture(option.Some("pt"), date)

  // The English page warns in English, with the day count spliced in…
  let en_html = site.post_template(english, [english]) |> element.to_string
  assert en_html |> string.contains("This content may be outdated")
  let assert Ok(#(_, en_after_days)) =
    string.split_once(en_html, "as more than ")
  let assert Ok(#(en_days_text, _)) =
    string.split_once(en_after_days, " days have passed since its publication")
  let assert Ok(en_days) = int.parse(en_days_text)
  assert en_days > 365

  // …the Japanese and Portuguese pages in their own wordings…
  let ja_html = site.post_template(japanese, [japanese]) |> element.to_string
  assert ja_html |> string.contains("このコンテンツは公開から")
  assert ja_html
    |> string.contains("日以上が経過しているため、最新ではない可能性があります")

  let pt_html =
    site.post_template(portuguese, [portuguese]) |> element.to_string
  assert pt_html
    |> string.contains("Este conteúdo pode estar desatualizado, já que")

  // …with no Spanish wording leaking into the translated pages, and the
  // default page keeping its Spanish wording.
  assert en_html |> string.contains("desactualizado") == False
  assert ja_html |> string.contains("desactualizado") == False
  assert pt_html |> string.contains("desactualizado") == False
  let es_html = site.post_template(spanish, [spanish]) |> element.to_string
  assert es_html
    |> string.contains("Este contenido puede estar desactualizado")
}

pub fn post_page_language_follows_variant_test() {
  // Translated variants declare their own language code; the default and
  // every other page keep the site's es-CL.
  let japanese = post_variant_fixture(option.Some("ja"))
  let ja_html = site.post_template(japanese, [japanese]) |> element.to_string
  assert ja_html |> string.contains("lang=\"ja\"")

  let english = post_variant_fixture(option.Some("en"))
  let en_html = site.post_template(english, [english]) |> element.to_string
  assert en_html |> string.contains("lang=\"en\"")

  let portuguese = post_variant_fixture(option.Some("pt"))
  let pt_html =
    site.post_template(portuguese, [portuguese]) |> element.to_string
  assert pt_html |> string.contains("lang=\"pt\"")

  let default = post_variant_fixture(option.None)
  let es_html = site.post_template(default, [default]) |> element.to_string
  assert es_html |> string.contains("lang=\"es-CL\"")
  assert home.view(home.spanish_text, [])
    |> element.to_string
    |> string.contains("lang=\"es-CL\"")
  assert site.not_found_view()
    |> element.to_string
    |> string.contains("lang=\"es-CL\"")
}

pub fn home_lists_default_language_posts_test() {
  let default = post_variant_fixture(option.None)
  let english = post_variant_fixture(option.Some("en"))

  let html =
    home.view(home.spanish_text, [english, default]) |> element.to_string

  // The home list carries the default-language entry once, and the
  // translated variant is not a second entry: its variant URL appears
  // nowhere on the page.
  let pieces = string.split(html, "Leer entrada")
  assert list.length(pieces) == 2
  assert string.contains(html, "blog/en/bienvenidos-a-ninjas-cl") == False
}

pub fn og_locale_follows_page_language_test() {
  // og:locale mirrors the page's language: the site's es_CL on default
  // pages, the variant's own locale on translated pages — from the
  // language configuration.
  let english = post_variant_fixture(option.Some("en"))
  let en_html = site.post_template(english, [english]) |> element.to_string
  assert en_html
    |> string.contains("content=\"en_US\" property=\"og:locale\"")

  let japanese = post_variant_fixture(option.Some("ja"))
  let ja_html = site.post_template(japanese, [japanese]) |> element.to_string
  assert ja_html
    |> string.contains("content=\"ja_JP\" property=\"og:locale\"")

  let portuguese = post_variant_fixture(option.Some("pt"))
  let pt_html =
    site.post_template(portuguese, [portuguese]) |> element.to_string
  assert pt_html
    |> string.contains("content=\"pt_BR\" property=\"og:locale\"")

  let default = post_variant_fixture(option.None)
  let es_html = site.post_template(default, [default]) |> element.to_string
  assert es_html
    |> string.contains("content=\"es_CL\" property=\"og:locale\"")
}

/// A navigation fixture: a default-language post with the given slug,
/// dated the given days ago.
fn nav_fixture(slug: String, days_ago: Int) -> post.Post(Nil) {
  post.Post(
    title: "Entrada " <> slug,
    slug: slug,
    url: "https://ninjas.cl/blog/" <> slug <> "/",
    date: timestamp.add(
      timestamp.system_time(),
      duration.seconds(days_ago * -86_400),
    ),
    description: "d",
    excerpt: "",
    language: option.None,
    featured_image: option.None,
    contents: [],
    extras: dict.new(),
  )
}

pub fn post_tags_render_below_the_date_test() {
  // A post with a tags frontmatter field renders its tags as rounded
  // labels below the date line; a post without tags renders no row.
  let tagged =
    post.Post(
      title: "Tagged",
      slug: "tagged",
      url: "https://ninjas.cl/blog/tagged/",
      date: timestamp.add(
        timestamp.system_time(),
        duration.seconds(-5 * 86_400),
      ),
      description: "d",
      excerpt: "",
      language: option.None,
      featured_image: option.None,
      contents: [],
      extras: dict.from_list([#("tags", "python, web, script")]),
    )
  let html = site.post_template(tagged, [tagged]) |> element.to_string
  assert html |> string.contains("post-tags")
  assert html |> string.contains("Bookmark_32x32_4.png")
  assert html
    |> string.contains("<span class=\"post-tag\">python</span>")
  assert html
    |> string.contains("<span class=\"post-tag\">web</span>")
  assert html
    |> string.contains("<span class=\"post-tag\">script</span>")
  // The row sits between the date and the description.
  let assert Ok(#(_, after_date)) = string.split_once(html, "post-meta")
  let assert Ok(#(before_desc, _)) =
    string.split_once(after_date, "post-description")
  assert before_desc |> string.contains("post-tags")

  // No tags: no row.
  let bare = featured_post_fixture(option.None)
  let bare_html = site.post_template(bare, [bare]) |> element.to_string
  assert string.contains(bare_html, "post-tags") == False
  assert string.contains(bare_html, "post-tag") == False

  // The pill styles ship in style.css.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-tags {")
  assert css |> string.contains(".post-tag {")
  assert css |> string.contains("border-radius: 16px;")
  assert css |> string.contains("background: #7540bd;")
}

pub fn post_navigation_links_adjacent_entries_test() {
  // Three posts, newest first: the middle one links both neighbors, the
  // ends link their single one, and the links follow the newest-first
  // sequence — "Anterior" to the newer entry, "Siguiente" to the older.
  let newest = nav_fixture("newest", 10)
  let middle = nav_fixture("middle", 20)
  let oldest = nav_fixture("oldest", 30)
  let all = [newest, middle, oldest]

  let middle_html = site.post_template(middle, all) |> element.to_string
  assert middle_html |> string.contains("post-nav")
  // Both buttons carry the showcase buttons' retrostrap classes and the
  // Win95 hand — each rotated by its own class to face "Anterior" or
  // "Siguiente" — and neither carries an arrow any more.
  assert middle_html
    |> string.contains("class=\"rs-btn rs-btn--icon rs-btn--large\"")
  let hand = "src=\"/icons/win95/Msow10_32x32_4.png\""
  assert list.length(string.split(middle_html, hand)) == 3
  assert string.contains(middle_html, "Hand_32x32_4.png") == False
  assert string.contains(middle_html, "ArrowLeft_32x32_4.png") == False
  assert string.contains(middle_html, "ArrowRight_32x32_4.png") == False
  let assert Ok(#(before_next, after_next)) =
    string.split_once(middle_html, "Siguiente: ")
  assert before_next |> string.contains("post-nav__hand--left")
  assert before_next |> string.contains("post-nav__hand--right") == False
  assert after_next |> string.contains("post-nav__hand--right")
  assert after_next |> string.contains("post-nav__hand--left") == False
  assert middle_html |> string.contains("Anterior: Entrada newest")
  assert middle_html
    |> string.contains("href=\"https://ninjas.cl/blog/newest/\"")
  assert middle_html |> string.contains("Siguiente: Entrada oldest")
  assert middle_html
    |> string.contains("href=\"https://ninjas.cl/blog/oldest/\"")

  // The ends: the newest post has only "Siguiente", the oldest only
  // "Anterior".
  let newest_html = site.post_template(newest, all) |> element.to_string
  assert newest_html |> string.contains("Siguiente: Entrada middle")
  assert string.contains(newest_html, "Anterior") == False

  let oldest_html = site.post_template(oldest, all) |> element.to_string
  assert oldest_html |> string.contains("Anterior: Entrada middle")
  assert string.contains(oldest_html, "Siguiente") == False

  // A lone post renders no navigation at all.
  let lone = site.post_template(newest, [newest]) |> element.to_string
  assert string.contains(lone, "post-nav") == False

  // The row's presentation ships in style.css — the flex row plus the
  // icon sizing the showcase buttons get.
  let assert Ok(css) = simplifile.read("./static/style.css")
  assert css |> string.contains(".post-nav {")
  assert css |> string.contains(".showcase__cols .rs-btn img,")
  assert css |> string.contains(".post-nav .rs-btn img {")
  // The up-pointing hand is turned a quarter each way; the pixelated
  // sizing above keeps the rotated sprite crisp.
  assert css |> string.contains(".post-nav__hand--left {")
  assert css |> string.contains("transform: rotate(-90deg);")
  assert css |> string.contains(".post-nav__hand--right {")
  assert css |> string.contains("transform: rotate(90deg);")
  assert css |> string.contains("scaleX(-1)") == False
}

pub fn post_navigation_stays_in_language_test() {
  // A translated page's links target the same language's variant of its
  // neighbors; the default page links the default variants.
  let es_new = nav_fixture("new-post", 10)
  let es_old = nav_fixture("old-post", 30)
  let en_new =
    post.Post(
      ..es_new,
      language: option.Some("en"),
      url: "https://ninjas.cl/blog/en/new-post/",
    )
  let en_old =
    post.Post(
      ..es_old,
      language: option.Some("en"),
      url: "https://ninjas.cl/blog/en/old-post/",
    )
  let all = [es_new, en_new, es_old, en_old]

  let en_html = site.post_template(en_old, all) |> element.to_string
  assert en_html
    |> string.contains("href=\"https://ninjas.cl/blog/en/new-post/\"")
  assert string.contains(en_html, "href=\"https://ninjas.cl/blog/new-post/\"")
    == False

  let es_html = site.post_template(es_old, all) |> element.to_string
  assert es_html
    |> string.contains("href=\"https://ninjas.cl/blog/new-post/\"")
}

pub fn random_posts_section_picks_five_others_test() {
  // Seven other posts: the section lists exactly five of them, never
  // the current post nor its navigation neighbor, in the site's list
  // presentation — order aside, every build's pick is a fresh random set.
  let current = nav_fixture("current", 5)
  let others =
    list.map([10, 20, 30, 40, 50, 60, 70], fn(days_ago) {
      nav_fixture("other-" <> int.to_string(days_ago), days_ago)
    })
  let all = [current, ..others]

  let html = site.post_template(current, all) |> element.to_string
  assert html |> string.contains("Otras entradas")
  assert html |> string.contains("rs-list rs-list--stars")
  // Exactly five rows — the fixtures' pages carry no other list items.
  let pieces = string.split(html, "<li>")
  assert list.length(pieces) == 6
  // The section itself (everything after its title) never lists the
  // current post or the navigation's neighbor — other-10, the next
  // entry, already rides the page as a button.
  let assert Ok(#(_, section)) = string.split_once(html, "Otras entradas")
  assert string.contains(section, "Entrada current") == False
  assert string.contains(section, "Entrada other-10") == False

  // A small catalog lists the non-neighbor remainder: other-10 is the
  // neighbor, so only other-20 remains for the list.
  let small_all = [
    current,
    nav_fixture("other-10", 10),
    nav_fixture("other-20", 20),
  ]
  let small = site.post_template(current, small_all) |> element.to_string
  assert small |> string.contains("Otras entradas")
  assert small |> string.contains("Entrada other-20")
  let small_pieces = string.split(small, "<li>")
  assert list.length(small_pieces) == 2

  // A pool exhausted by the navigation renders no section at all — the
  // only other entry is the neighbor, already on the page.
  let exhausted =
    site.post_template(current, [current, nav_fixture("other-10", 10)])
    |> element.to_string
  assert string.contains(exhausted, "Otras entradas") == False
}

pub fn posts_lists_lead_titles_with_their_icons_test() {
  // Both star lists lead each linked title with the entry's icon: the
  // home's "Más entradas" list and the post page's "Otras entradas"
  // list, the iconless entries keeping the newspaper icon.
  let iconed =
    post.Post(
      ..nav_fixture("iconed", 20),
      extras: dict.from_list([#("icon", "Earth_32x32_4.png")]),
    )
  let plain = nav_fixture("plain", 30)

  // The home: two entries, one featured and one listed — whichever the
  // random pick takes — each title led by its own icon, and the list
  // entry's link carrying its icon before its title.
  let home_html =
    home.view(home.spanish_text, [iconed, plain]) |> element.to_string
  let assert Ok(#(_, home_after_earth)) =
    string.split_once(home_html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert home_after_earth |> string.contains("Entrada iconed")
  let assert Ok(#(_, home_after_news)) =
    string.split_once(home_html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert home_after_news |> string.contains("Entrada plain")
  let home_items = string.split(home_html, "<li>")
  assert list.length(home_items) == 2
  let assert Ok(#(_, after_li)) = string.split_once(home_html, "<li>")
  let assert Ok(#(li_row, _)) = string.split_once(after_li, "</li>")
  let assert Ok(#(li_before_img, li_after_img)) =
    string.split_once(li_row, "src=\"/icons/win95/")
  assert li_before_img |> string.contains("<a href=\"https://ninjas.cl/blog/")
  assert li_after_img |> string.contains("Entrada ")

  // The post page's list: the current post newest with one excluded
  // neighbor, so both other entries list — the newspaper icon serving
  // exactly the two iconless titles, the page's own h1 and the plain
  // entry's row, in that order.
  let current = nav_fixture("current", 5)
  let near = nav_fixture("near", 10)
  let post_html =
    site.post_template(current, [current, near, iconed, plain])
    |> element.to_string
  assert post_html |> string.contains("Otras entradas")
  let earth_pieces =
    string.split(post_html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert list.length(earth_pieces) == 2
  let assert Ok(#(_, post_after_earth)) =
    string.split_once(post_html, "src=\"/icons/win95/Earth_32x32_4.png\"")
  assert post_after_earth |> string.contains("Entrada iconed")
  let news_pieces =
    string.split(post_html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert list.length(news_pieces) == 3
  let assert Ok(#(_, after_first_news)) =
    string.split_once(post_html, "src=\"/icons/win95/Mailnews8_32x32_4.png\"")
  assert after_first_news |> string.contains("Entrada current")
  let assert Ok(#(_, after_second_news)) =
    string.split_once(
      after_first_news,
      "src=\"/icons/win95/Mailnews8_32x32_4.png\"",
    )
  assert after_second_news |> string.contains("Entrada plain")
}

pub fn featured_post_is_a_random_pick_test() {
  // The featured entry is a build-time random pick among the
  // default-language posts: exactly one featured row with the "Leer
  // entrada" button, the remaining entries in the "Más entradas"
  // list, and a lone post always featured.
  let a = nav_fixture("pick-a", 10)
  let b = nav_fixture("pick-b", 20)
  let c = nav_fixture("pick-c", 30)

  let html = home.view(home.spanish_text, [a, b, c]) |> element.to_string
  assert html |> string.contains("Entrada destacada")
  // One featured row with its button.
  let pieces = string.split(html, "Leer entrada")
  assert list.length(pieces) == 2
  // Every entry appears somewhere: the pick in the featured row, the
  // other two in the list.
  assert html |> string.contains("Entrada pick-a")
  assert html |> string.contains("Entrada pick-b")
  assert html |> string.contains("Entrada pick-c")
  // The "Más entradas" list carries the remaining two entries.
  let list_items = string.split(html, "<li>")
  assert list.length(list_items) == 3

  // A lone post is always the featured one, with no more list.
  let lone = home.view(home.spanish_text, [b]) |> element.to_string
  assert lone |> string.contains("Entrada destacada")
  assert lone |> string.contains("Leer entrada")
  assert string.contains(lone, "rs-list--stars") == False
  assert string.contains(lone, "Ver Todos") == False
}

pub fn more_posts_list_is_trimmed_to_ten_test() {
  // The "Más entradas" list is a trimmed random sample: with thirteen
  // posts, whichever entry the featured pick lands on, the list
  // renders exactly ten of the remaining twelve — a fresh set each
  // build, order aside — under its icon-led heading, with the "Ver
  // Todos" button linking the blog index. A small catalog lists every
  // remaining entry and keeps the button.
  let posts =
    int.range(from: 1, to: 14, with: [], run: fn(acc, n) {
      [nav_fixture("trim-" <> int.to_string(n), n * 10), ..acc]
    })

  let html = home.view(home.spanish_text, posts) |> element.to_string

  // Exactly ten list rows — and eleven titles reach the page: the
  // featured one (twice: its cover alt and its row) plus the ten
  // picks, the two the sample left out appearing nowhere.
  let list_items = string.split(html, "<li>")
  assert list.length(list_items) == 11
  let title_pieces = string.split(html, "Entrada trim-")
  assert list.length(title_pieces) == 13

  // The heading leads with the stack-of-documents icon, following the
  // featured section.
  let assert Ok(#(before_files, after_files)) =
    string.split_once(html, "src=\"/icons/win95/Files_32x32_4.png\"")
  assert before_files |> string.contains("Entrada destacada")
  assert after_files |> string.contains("Más entradas")

  // The Ver Todos button follows the list: the site's document-view
  // icon, linking the blog index — the section's first Shdocvw icon,
  // ahead of the showcase buttons'.
  let assert Ok(#(_, section)) = string.split_once(html, "Más entradas")
  assert section
    |> string.contains(
      "class=\"rs-btn rs-btn--icon rs-btn--large\" href=\"/blog\"",
    )
  let assert Ok(#(_, after_shdocvw)) =
    string.split_once(section, "src=\"/icons/win95/Shdocvw257_32x32_8.png\"")
  assert after_shdocvw |> string.contains("Ver Todos")

  // A small catalog lists every remaining entry, button included:
  // three posts leave two for the list.
  let small =
    home.view(home.spanish_text, [
      nav_fixture("small-a", 10),
      nav_fixture("small-b", 20),
      nav_fixture("small-c", 30),
    ])
    |> element.to_string
  let small_items = string.split(small, "<li>")
  assert list.length(small_items) == 3
  let assert Ok(#(_, small_section)) = string.split_once(small, "Más entradas")
  assert small_section
    |> string.contains(
      "class=\"rs-btn rs-btn--icon rs-btn--large\" href=\"/blog\"",
    )
}

pub fn translated_home_pages_render_in_their_language_test() {
  // Each translated home reads in its own language — the navbar labels,
  // the showcase buttons' single words, the posts-section headings and
  // empty note, the back-to-top label, the about copy, the captions, the
  // marquee — and its head declares its language (lang, og:locale, the
  // translated description, its own og:url). The copyright line stays
  // verbatim, no machine-translation warning renders, and no Spanish
  // body sentence remains. Each home renders with its own language's
  // posts so the posts section's labels render at all.
  let defaults = [
    nav_fixture("lang-a", 10),
    nav_fixture("lang-b", 20),
    nav_fixture("lang-c", 30),
  ]
  let spanish_absent = [
    "Sobre nosotros", "Entrada destacada", "Más entradas", "Leer entrada",
    "Ver Todos", "^ volver arriba ^", "Bienvenido a Ninjas.cl", "Ver / View",
    "Código / Code",
  ]

  let cases = [
    #(
      home.english_text,
      [
        "Home", "About us", "Projects", "Books", "Games", "View</a>", "Code</a>",
        "Featured post", "Read post", "More posts", "View all",
        "^ back to top ^", "Since March 2022", "Since 2015",
        "We like creating beautiful artifacts",
        "★ Welcome to Ninjas.cl · artisan software from Chile",
      ],
      "en",
      "en_US",
      "https://ninjas.cl/en/",
      "Ninjas is an experimental software developer group from Chile 🇨🇱.",
    ),
    #(
      home.japanese_text,
      [
        "ホーム", "私たちについて", "プロジェクト", "書籍", "ゲーム", "見る</a>", "コード</a>", "注目の記事",
        "記事を読む", "他の記事", "すべて見る", "^ 上に戻る ^", "2022年3月から", "2015年から",
        "美しく、人のことを考えたアーティファクトを作るのが好きです。", "★ Ninjas.clへようこそ · チリからの職人ソフトウェア",
      ],
      "ja",
      "ja_JP",
      "https://ninjas.cl/ja/",
      "Ninjasはチリ🇨🇱の実験的なソフトウェア開発グループです。",
    ),
    #(
      home.portuguese_text,
      [
        "Início", "Sobre nós", "Projetos", "Livros", "Jogos", "Ver</a>",
        "Código</a>", "Postagem destacada", "Ler entrada", "Mais entradas",
        "Ver todos", "^ voltar ao topo ^", "Desde Março 2022", "Desde 2015",
        "Gostamos de criar artefatos bonitos",
        "★ Bem-vindo ao Ninjas.cl · software artesanal do Chile",
      ],
      "pt",
      "pt_BR",
      "https://ninjas.cl/pt/",
      "O Ninjas é um grupo desenvolvedor de software experimental do Chile",
    ),
  ]

  list.each(cases, fn(variant) {
    let #(text, present_strings, code, locale, url, description_start) = variant
    let html =
      home.view(text, language_variants(defaults, code))
      |> element.to_string

    // The page's language renders at every anchor label and piece of
    // copy, and no Spanish body sentence remains.
    list.each(present_strings, fn(expected) {
      assert html |> string.contains(expected)
    })
    list.each(spanish_absent, fn(spanish) {
      assert string.contains(html, spanish) == False
    })

    // The head declares the home's language, with the translated site
    // description in the description fields.
    assert html |> string.contains("lang=\"" <> code <> "\"")
    assert html
      |> string.contains("content=\"" <> locale <> "\" property=\"og:locale\"")
    assert html
      |> string.contains("content=\"" <> url <> "\" property=\"og:url\"")
    assert html |> string.contains("content=\"" <> description_start)

    // The copyright line keeps its verbatim prefix on every page, with
    // each home's own clause — the English line on the English home,
    // the Japanese and Portuguese homes' own clauses — and no
    // machine-translation warning renders on any home.
    assert html |> string.contains("Copyright 🥷🏽 Ninjas.cl © 2015–")
    assert html |> string.contains(" · " <> text.copyright_rights)
    assert string.contains(html, "machine translation of the original Spanish")
      == False
    assert string.contains(html, "機械翻訳したもので") == False
    assert string.contains(html, "tradução automática da publicação original")
      == False

    // The options row is labeled in the page's language, marks the
    // current language, and — with the navbar's own home link — every
    // home's URL is linked on the page.
    assert html |> string.contains(text.options_label <> ": ")
    assert html
      |> string.contains(
        "<span aria-current=\"page\">" <> text.name <> "</span>",
      )
    list.each(["/", "/en/", "/ja/", "/pt/"], fn(path) {
      assert html |> string.contains("href=\"" <> path <> "\"")
    })

    // The empty state reads in the page's language too.
    let empty = home.view(text, []) |> element.to_string
    assert empty |> string.contains(text.empty_note)
  })
}

pub fn translated_home_lists_its_language_posts_test() {
  // Each home lists its own language's variants: with the catalog
  // carrying all four languages of the same posts, the en home's
  // featured pick and list entries link the en variant URLs — never
  // the default-language pages nor another language's variants.
  let defaults = [
    nav_fixture("lang-a", 10),
    nav_fixture("lang-b", 20),
    nav_fixture("lang-c", 30),
  ]
  let all_posts =
    list.flatten([
      defaults,
      language_variants(defaults, "en"),
      language_variants(defaults, "ja"),
      language_variants(defaults, "pt"),
    ])

  let html = home.view(home.english_text, all_posts) |> element.to_string

  // Every en variant appears somewhere — the featured pick and the two
  // listed entries, three rows like the Spanish home's.
  list.each(["lang-a", "lang-b", "lang-c"], fn(slug) {
    assert html
      |> string.contains("href=\"https://ninjas.cl/blog/en/" <> slug <> "/\"")
  })
  // The default-language page and the other languages' variants appear
  // nowhere — three entries, all en.
  assert string.contains(html, "https://ninjas.cl/blog/lang-a/") == False
  assert string.contains(html, "https://ninjas.cl/blog/ja/lang-a/") == False
  assert string.contains(html, "https://ninjas.cl/blog/pt/lang-a/") == False
  let pieces = string.split(html, "<li>")
  assert list.length(pieces) == 3
}

/// The same posts in another language: the variant records carry the
/// language code and the variant URL blogatto derives from it.
fn language_variants(
  posts: List(post.Post(Nil)),
  language: String,
) -> List(post.Post(Nil)) {
  list.map(posts, fn(entry) {
    post.Post(
      ..entry,
      language: option.Some(language),
      url: "https://ninjas.cl/blog/" <> language <> "/" <> entry.slug <> "/",
    )
  })
}

pub fn random_posts_section_stays_in_language_test() {
  // The picks resolve to the reader's language: the en page links the
  // en variant of the remaining pool entry — the near post is the
  // navigation neighbor and stays out of the list.
  let es_current = nav_fixture("current", 5)
  let es_near = nav_fixture("near", 10)
  let es_far = nav_fixture("far", 20)
  let en_current =
    post.Post(
      ..es_current,
      language: option.Some("en"),
      url: "https://ninjas.cl/blog/en/current/",
    )
  let en_near =
    post.Post(
      ..es_near,
      language: option.Some("en"),
      url: "https://ninjas.cl/blog/en/near/",
    )
  let en_far =
    post.Post(
      ..es_far,
      language: option.Some("en"),
      url: "https://ninjas.cl/blog/en/far/",
    )
  let all = [es_current, en_current, es_near, en_near, es_far, en_far]

  let en_html = site.post_template(en_current, all) |> element.to_string
  assert en_html |> string.contains("Otras entradas")
  assert en_html |> string.contains("href=\"https://ninjas.cl/blog/en/far/\"")
  let assert Ok(#(_, section)) = string.split_once(en_html, "Otras entradas")
  assert string.contains(section, "href=\"https://ninjas.cl/blog/en/near/\"")
    == False

  // The default page links the default variant.
  let es_html = site.post_template(es_current, all) |> element.to_string
  assert es_html |> string.contains("href=\"https://ninjas.cl/blog/far/\"")
}
