//// The blog index pages: the paginated post lists at `/blog/page/{n}/`
//// and their translated versions at `/blog/{lang}/page/{n}/`.
////
//// blogatto registers static routes at configuration time — there is no
//// dynamic-route mechanism and no public post loader — so the page count
//// is derived from the post directories under `blog/` before the build
//// starts. Those directories are exactly what the post builder parses
//// moments later (a malformed one fails the whole build; the
//// completeness test guarantees one directory per four-variant post), so
//// the count and the parsed per-language post lists agree by
//// construction. Every build re-registers the routes, so the pagination
//// regenerates with the catalog — the same always-current property the
//// sitemap has.

import blogatto/config
import gleam/int
import gleam/list
import gleam/result
import simplifile
import site

/// The number of index pages for the posts under a directory: the post
/// directory count rounded up to whole pages of `site.blog_page_size`
/// posts, always at least one page. One count serves every language's
/// index — the completeness mandate ships all four variants of every
/// post, so each language's list fills the same page count.
pub fn page_count(directory: String) -> Int {
  let post_directories =
    directory
    |> simplifile.read_directory
    |> result.unwrap([])
    |> list.filter(fn(entry) {
      simplifile.is_directory(directory <> "/" <> entry)
      |> result.unwrap(False)
    })
  let pages =
    { list.length(post_directories) + site.blog_page_size - 1 }
    / site.blog_page_size
  int.max(pages, 1)
}

/// Register the blog index routes: one list page per page count in the
/// site's default language plus one in each translated language (en,
/// ja, pt — Spanish stays the default at `/blog/page/{n}/`), and a landing
/// redirect at each language's canonical blog URL. The index routes are
/// ordinary config routes, so they join the sitemap like the default pages;
/// the landing routes are excluded by the sitemap filter.
pub fn register(cfg: config.Config(Nil)) -> config.Config(Nil) {
  let pages = page_count("./blog")

  let cfg =
    int.range(from: 1, to: pages + 1, with: cfg, run: fn(cfg, n) {
      cfg
      |> config.route(
        "/blog/page/" <> int.to_string(n),
        site.blog_index_view(n),
      )
      |> list.fold(["en", "ja", "pt"], _, fn(cfg, language) {
        cfg
        |> config.route(
          "/blog/" <> language <> "/page/" <> int.to_string(n),
          site.language_blog_index_view(language, n),
        )
      })
    })

  cfg
  |> config.route("/blog", fn(_posts) { site.blog_redirect_view("es") })
  |> list.fold(["en", "ja", "pt"], _, fn(cfg, language) {
    cfg
    |> config.route("/blog/" <> language, fn(_posts) {
      site.blog_redirect_view(language)
    })
  })
}
