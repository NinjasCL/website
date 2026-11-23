# Proposal

## Why

The home page lived inside `src/site.gleam` (1,644 lines at the split) beside
the shared site chrome — the layout, the post template, the blog index, and the
404 page all depending on the same module the home page was modified in. Giving
the home page a module of its own makes it editable without touching anything
every other view depends on.

The separation began with an audit of the old site's home sources
(`old/sources/home/*.json`) against the current home page: every showcase item
ships on the new home page except one — Jasonelle (from `projects.json`), the
iOS 🍎 / Android 🤖 WebView framework, missing since the migration. The audit
confirmed all four books, all four games, the other three projects, and the
`website.json` identity (covered by the site constants) are present.

## What Changes

- The home page moves to its own module, `src/ninjas/home.gleam` (545 lines):
  the view, the hero, the marquee, the about/posts/projects/books/games
  sections, the banner wall and its list, the showcase card type and renderer,
  the featured-posts list, and the home-only link/button helpers. The `/` route
  and the tests render it as `home.view`.
- `src/site.gleam` (1,150 lines) keeps the site identity, the shared chrome —
  the page layout, the masthead and navbar, the footer, the icon helpers — and
  the non-home views: the post template, the blog index, the `/blog` redirect,
  and the 404 page. The shared helpers the home page calls become its public
  API, plus a new `default_og_locale` accessor.
- The missing Jasonelle project is restored as the fifth "Proyectos" card,
  placed after Elixir Chile per the old catalog's sort order, with its texts in
  Spanish and its title keeping the 🛸 emoji (the same pattern as the 🥷 Ninja
  Systems card). Its buttons link jasonelle.com and github.com/jasonelle/.
- Jasonelle's logo is served from the site's own assets: the official
  `https://jasonelle.com/jasonelle.png` downloaded to
  `static/img/jasonelle.png` and downscaled for the web (8445×5717 → 800×541,
  441 KB → 88 KB) — the old site's `jasonelle-small.png` is gone from the web,
  so the showcase sections keep no remote image host.
- The icon manifest documents the kept 🛸 emoji with its reason.
- A new `home_covers_old_catalog_items_test` pins every old-catalog URL on the
  home page, so no showcase item can silently disappear again.
- `AGENTS.md` documents the split in its project description and layout.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-showcase-images`: the projects enumeration gains Jasonelle — five
  project cards load their images from local `/img/…` paths — and a new
  requirement pins the five project logo files (the downloaded
  `jasonelle.png` included) as static assets shipped with the generated site.
- `site-showcase-buttons`: the enlarged-button requirement restates its count —
  twenty-six showcase buttons across thirteen cards.
- `site-inline-icons`: the kept-emoji set gains the 🛸 flying saucer on the
  Jasonelle title, and the manifest requirement restates its counts — fourteen
  matches (the post-icons additions had already outgrown the recorded ten) and
  four kept emojis.

## Impact

- `src/ninjas/home.gleam` (new): the home page module.
- `src/site.gleam`: home-only code removed; the shared surface public —
  `page`, `masthead`, `site_footer`, `icon`, `title_with_icon`,
  `featured_image`, `default_language_posts`, `shuffle`, `post_item`, and the
  new `default_og_locale`.
- `src/ninjas/blog.gleam`: the `/` route renders `home.view`.
- `test/ninjas_test.gleam`: home page tests call `home.view` (two local `home`
  bindings rename to `home_html`); the showcase counts read thirteen cards and
  twenty-six buttons; new Jasonelle and old-catalog assertions.
- `static/img/jasonelle.png` (new): the downscaled official logo.
- `static/icons/win95/emoji-matches.json`: the kept 🛸 entry.
- `AGENTS.md`: the module layout.

## Out of scope

- No changes to the home page's rendered structure or styling beyond the
  restored card — the separation itself is behavior-preserving.
- No other old-catalog items: the audit confirmed the rest already ship.
- No new dependency — plain Gleam modules over the existing blogatto/Lustre
  stack, and no blogatto or CI version changes.
