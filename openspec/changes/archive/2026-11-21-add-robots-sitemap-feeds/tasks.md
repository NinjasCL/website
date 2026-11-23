# Tasks

## 1. Wire the generation configs

- [x] 1.1 Extend the shared builder in `src/ninjas/blog.gleam`: import
  `blogatto/config/robots`, `blogatto/config/sitemap`,
  `blogatto/config/feed/atom`, and `blogatto/config/feed/rss`, build the
  four configs — the Atom feed (id the site URL, title
  `atom.PlainText(site.site_title)`, `updated` the build time, subtitle
  the site description, author `@CLSource` with the GitHub URI), the RSS
  feed (`rss.new(site.site_title, site_url, site.site_description)`
  with `rss.language(site.site_language)`), `sitemap.new("/sitemap.xml")`,
  and `robots.new(site_url <> "sitemap.xml")` with the allow-all
  `User-agent: *` robot — and attach them with `config.atom_feed`,
  `config.rss_feed`, `config.sitemap`, and `config.robots`. Mind the
  trailing slash in the sitemap URL composition. Verify with the build
  in 2.4 or the test in 1.2.
- [x] 1.2 Extend `production_blog_config_test` in
  `test/ninjas_test.gleam`: the config carries one Atom feed and one RSS
  feed (with their `/atom.xml` and `/rss.xml` outputs), the sitemap at
  `/sitemap.xml`, and the robots config pointing at
  `https://ninjas.cl/sitemap.xml` with the allow-all robot. Verify with
  `gleam test`.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate add-robots-sitemap-feeds` and confirm
  it passes.
- [x] 2.4 Run `gleam run` and confirm the output root carries the four
  files with the expected content: `robots.txt` with the Sitemap
  pointer and the allow-all policy, `sitemap.xml` with the home and the
  post's absolute URLs, `atom.xml` and `rss.xml` with the site identity
  and the post as an entry.

## Workflow follow-up

- After review, sync/archive the change with the
  `openspec-archive-change` workflow. No entrypoint or asset changes
  ride along — the shared builder covers every build.
- Natural follow-up worth noting at archive time: feed auto-discovery
  `<link rel="alternate">` tags in the head (`site-head-meta`).
