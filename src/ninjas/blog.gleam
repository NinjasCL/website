//// Shared blogatto configuration for the Ninjas.cl site.
////
//// The production build (`website`) and the development server (`dev`) use
//// this builder with their environment-appropriate site URL.

import blogatto/config
import blogatto/config/feed/atom
import blogatto/config/feed/rss
import blogatto/config/post
import blogatto/config/robots
import blogatto/config/sitemap
import gleam/list
import gleam/option
import gleam/string
import gleam/time/timestamp
import ninjas/blog_pages
import ninjas/github_opengraph
import ninjas/highlight
import ninjas/home
import site

/// Builds one of the site's language-scoped Atom feeds. The output path is
/// the single source for the feed's file location, absolute id, and self
/// link, so a feed always identifies the URL it is served from. The default
/// Spanish variant lives at the root; translations live under their code.
fn language_atom_feed(
  site_url: String,
  code: String,
  hreflang: String,
  path: String,
  updated: timestamp.Timestamp,
) -> atom.AtomFeed(Nil) {
  let url = site_url <> string.slice(path, 1, string.length(path) - 1)
  let language = case code {
    "es" -> option.None
    other -> option.Some(other)
  }

  atom.new(id: url, title: atom.PlainText(site.site_title), updated: updated)
  |> atom.output(path)
  |> atom.filter(fn(metadata) { metadata.post.language == language })
  |> atom.link(atom.Link(
    href: url,
    rel: option.Some("self"),
    content_type: option.Some("application/atom+xml"),
    hreflang: option.Some(hreflang),
    title: option.None,
    length: option.None,
  ))
  |> atom.subtitle(site.site_description)
  |> atom.author(atom.Person(
    name: "@CLSource",
    email: option.None,
    uri: option.Some("https://github.com/ninjascl"),
  ))
}

// The shared post wiring: one source path, the site's page template, and the
// djot component overrides. Production and draft previews use the same
// pipeline so a preview matches the published page.
fn post_config(path: String) -> post.PostConfig(Nil) {
  // Djot code blocks are routed through the site's content-block
  // component (src/ninjas/highlight.gleam), which owns each block's full
  // structure — code panels, summary toggles, and the github/youtube/
  // ninjas embed cards. Its `pre` component wraps only the bare code of
  // an untagged fence: inline spans stay inline and embeds never land
  // inside a code panel.
  let syntax = highlight.syntax_config()

  post.default()
  |> post.path(path)
  |> post.route_prefix("blog")
  |> post.template(site.post_template)
  |> post.code(highlight.code_component_with_github_images(
    syntax,
    github_opengraph.image_source,
  ))
  |> post.pre(highlight.pre_component)
}

pub fn new(site_url: String) -> config.Config(Nil) {
  let updated = timestamp.system_time()

  // The syndication and crawler outputs. The site URLs end in a slash,
  // so each feed's absolute URL composes from its output path's tail.
  let rss_feed =
    rss.new(site.site_title, site_url, site.site_description)
    |> rss.language(site.site_language)

  // The sitemap excludes every blog landing redirect: each points at the
  // first index page in its language, so it is not content of its own. The
  // index page routes are ordinary config routes and the sitemap lists them.
  let landing_urls = [
    site_url <> "blog",
    site_url <> "blog/en",
    site_url <> "blog/ja",
    site_url <> "blog/pt",
  ]
  let sitemap_config =
    sitemap.new("/sitemap.xml")
    |> sitemap.filter(fn(url) { !list.contains(landing_urls, url) })

  let robots_config =
    robots.new(site_url <> "sitemap.xml")
    |> robots.robot(
      robots.Robot(
        user_agent: "*",
        allowed_routes: ["/"],
        disallowed_routes: [],
      ),
    )

  config.new(site_url)
  |> config.output_dir("./dist")
  |> config.static_dir("./static")
  |> config.post(post_config("./blog"))
  // The home page in the site's four languages: the Spanish default at
  // the root, the machine-translated homes at their language routes.
  // Each route writes `<route>/index.html`, so the pages serve at `/`,
  // `/en/`, `/ja/`, and `/pt/` and join the sitemap like every route.
  |> config.route("/", fn(posts) { home.view(home.spanish_text, posts) })
  |> config.route("/en", fn(posts) { home.view(home.english_text, posts) })
  |> config.route("/ja", fn(posts) { home.view(home.japanese_text, posts) })
  |> config.route("/pt", fn(posts) { home.view(home.portuguese_text, posts) })
  |> blog_pages.register
  |> config.atom_feed(language_atom_feed(
    site_url,
    "es",
    site.site_language,
    "/atom.xml",
    updated,
  ))
  |> config.atom_feed(language_atom_feed(
    site_url,
    "en",
    "en",
    "/en/atom.xml",
    updated,
  ))
  |> config.atom_feed(language_atom_feed(
    site_url,
    "ja",
    "ja",
    "/ja/atom.xml",
    updated,
  ))
  |> config.atom_feed(language_atom_feed(
    site_url,
    "pt",
    "pt",
    "/pt/atom.xml",
    updated,
  ))
  |> config.rss_feed(rss_feed)
  |> config.sitemap(sitemap_config)
  |> config.robots(robots_config)
}

/// Build a draft preview outside the published catalog. The selected draft
/// directory is the only post source, so blogatto renders its djot variants
/// with the site's own templates and components. No routes, feeds, sitemap,
/// or robots are registered: this build exists only to preview one draft.
pub fn preview(site_url: String, draft_path: String) -> config.Config(Nil) {
  config.new(site_url)
  |> config.output_dir("./.preview")
  |> config.static_dir("./static")
  |> config.post(post_config(draft_path))
}
