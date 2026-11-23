# Tasks

## 1. The head-meta suite

- [x] 1.1 Extend `page/3` in `src/site.gleam` to `page/4` with a
  canonical-URL parameter, and render the head suite on every page:
  the generator meta, the humans.txt author link, the apple-touch-icon
  (180×180), favicon 32×32 and 16×16 links, the site webmanifest link,
  the robots (`index,follow`) and usage-rights (`CC-BY-NC-ND`) metas,
  the pasted keywords list, the fixed `og:type`/`og:image` and
  `twitter:card`/`twitter:image`, and the mirrored
  `og:title`/`og:description`/`og:url` plus
  `twitter:title`/`twitter:description`/`twitter:url` from the page's
  title, description, and URL. Update the three callers: `home_view`
  passes `site.production_url`, `post_template` passes `post.url`, and
  `not_found_view` passes `site.production_url <> "404.html"`. Verify by
  rendering each view (gleam test lands with 1.2).
- [x] 1.2 Add the JSON-LD structured-data block to every page's head via
  `element.unsafe_raw_html` with `attribute.type_("application/ld+json")`:
  the site-level BlogPosting with headline "Ninjas Chile (Ninjas.cl)",
  the Spanish `site_description`, `datePublished` "2026-11-21", author
  `@CLSource`, image `https://ninjas.cl/logo_og.png`, publisher
  Ninjas.cl with logo `https://ninjas.cl/img/Ninjas.png`, and
  `mainEntityOfPage` the site root — unescaped so the JSON parses.
  Verify by rendering and checking the raw script content.
- [x] 1.3 Add `head_meta_suite_renders_on_every_page_test` in
  `test/ninjas_test.gleam`: for the home view, a post template render,
  and the not-found view — the head carries the generator meta, the
  humans.txt author link, the three icon links, the manifest link, the
  robots and usage-rights metas, the keywords list, and the ld+json
  script with the BlogPosting headline; og:title/og:description/og:url
  mirror each page (site identity on home, the post's title/URL on the
  post page, "404 — Ninjas.cl" on the not-found page); and the home
  keeps exactly one meta description. Verify with `gleam test`.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate add-head-meta` and confirm it passes.
- [x] 2.4 Run `gleam run` and confirm the generated `dist/index.html`
  head carries the og:image, the webmanifest link, and parseable
  ld+json.

## Workflow follow-up

- After review, sync/archive the change with the `openspec-archive-change`
  workflow. No dependency or asset changes ride along — every referenced
  asset already ships in `static/`.
