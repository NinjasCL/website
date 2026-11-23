# Design

## Context

`src/site.gleam` carried everything: the site identity constants, the shared
page layout, the masthead/navbar/footer chrome, the post template with its
language options and warnings, the blog index with its pagination, the 404
page — and the whole home page (hero, marquee, five sections, banner wall,
showcase cards, featured-post list) in the same 1,644-line module. The home
page is the most frequently reworked surface, so it moves out on its own.

The audit that motivated the content half: `old/sources/home/*.json` versus
the rendered home page found exactly one missing item — Jasonelle — with the
old site's `jasonelle-small.png` no longer resolvable anywhere on the web
(the official site now serves `jasonelle.png`).

## Goals / Non-Goals

**Goals:**

- One module (`src/ninjas/home.gleam`) owns the home page, editable without
  touching the module the other views share.
- The home page keeps rendering identically through the same shared chrome.
- The old home catalog is complete again, and provably so.

**Non-Goals:**

- Restructuring the shared chrome itself — `site.gleam` only loses its
  home-only code and gains visibility on what the home page needs.
- Re-translating or re-styling existing showcase cards.
- Any change to the blog index, post template, feeds, sitemap, or robots.

## Decisions

### Two modules, one dependency direction

Gleam rejects circular module imports, so `site.gleam` cannot both be
imported by the home module and re-export the home view. The dependency
points one way: `ninjas/home` imports `site` and renders through the shared
chrome; the consumers of the home page — `ninjas/blog`'s `/` route and the
tests — import `ninjas/home` directly. A convenience re-export in `site.gleam`
(`pub fn home_view(...) { home.view(...) }`) is therefore impossible, which
is why the route and the test call sites change instead of the module
boundaries bending.

### What moves and what stays

Moved to `ninjas/home` — everything only the home page renders: the view, the
hero, the marquee, the about/posts/projects/books/games sections, the banner
wall with its banner list, the `ShowcaseItem` type and its card renderer, the
featured-post list (`post_list`, `featured_post`, `more_posts`), and the two
home-only helpers `external_link`/`external_button`.

Kept in `site` — everything shared or non-home: the identity constants, the
language configuration, the post template (warnings, language options,
navigation, random entries), the blog index, the `/blog` redirect, the 404
page, and the chrome. The shared helpers the home page calls become the
public API: `page`, `masthead`, `site_footer`, `icon`, `title_with_icon`,
`featured_image` (shared with the blog index cards and the post masthead
cover), `default_language_posts` (shared with the index and the post
navigation), `shuffle` (shared with the post page's random-entries list),
`post_item` (shared with that same list), and a new `default_og_locale`
accessor so the home page never reaches into the private language
configuration for the OpenGraph locale.

### Routing

`config.route("/", home.view)` — blogatto's route function takes
`fn(List(Post(Nil))) -> Element(Nil)`, which `home.view` matches directly; no
adapter. No other route changes: the blog index pages, the post template, the
feeds, sitemap, and robots are untouched.

### The restored card

Jasonelle ships as a `ShowcaseItem` like its siblings, after Elixir Chile per
the old catalog's `sort` order, with the description translated to Spanish
and the date reading "Noviembre 2018". The title keeps its 🛸 emoji with no
leading icon — the same pattern as the 🥷 Ninja Systems card — so no new
icon mapping is needed; the 🛸 joins the manifest's kept list with its
reason instead. The logo downloads once, from the official
`https://jasonelle.com/jasonelle.png`, and is downscaled at download time
(8445×5717 → 800×541) so the static asset stays web-sized; the showcase
image box already letterboxes with `object-fit: contain`, so no CSS joins.

### Tests

Two tests bound local variables named `home` (the rendered page string);
`home.view` would still resolve at those call sites (the binding is not in
scope in its own initializer), but the shadowing invites confusion — they
rename to `home_html`. The showcase counts move to thirteen card rows and
twenty-six buttons. `home_covers_old_catalog_items_test` lists every
old-catalog URL and asserts each renders as a card link, so the next
catalog-restoration gap fails a test instead of an audit.

### Dependencies

None. The split is plain Gleam modules over the existing blogatto/Lustre
stack; the logo asset flows through blogatto's existing `static_dir` copy.

## Risks / Trade-offs

- [Trade-off] The public surface of `site.gleam` grows by the shared helpers.
  The alternative — duplicating the footer, icons, and shuffle into the home
  module — would fork implementations the post page also uses; sharing keeps
  one source of truth.
- [Risk] A future change adds a card but forgets the manifest's kept/match
  lists → Mitigation: `icon_manifest_documents_matches_test` asserts the kept
  emojis, and the new catalog test pins the card set's URLs.
- [Accepted] The official Jasonelle logo is landscape (800×541) where most
  project logos are squarer; the shared letterboxing rule already handles it
  without distortion.

## Migration Plan

Shipped in one pass with the request: create the home module, trim and
publicize `site.gleam`, rewire the route and tests, restore the card and its
asset, update the manifest. Rollback is reverting the commit; no generated
output is committed.

## Open Questions

- None — the kept-emoji and letterboxing patterns were both settled by
  existing precedent (🥷 Ninja Systems, the showcase image box).
