# Design

## Context

The blog index renders its feed link inline in `blog_index_page`'s `<h2>`
(`src/site.gleam`), with the `.blog-feed` class and `/img/feed.svg` styled by
`static/style.css`. The home page builds all titled panels through one private
`section(id, icon, title, children)` helper in `src/ninjas/home.gleam`, so the
posts panel currently has no place for extra header content. `#posts` and
`#blog` already carry top-margin rules in the same stylesheet but no horizontal
offset. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**

- One shared feed-link element for both the blog index and the home posts header.
- A modest, consistent left inset on exactly the two blog panels.

**Non-Goals:**

- No changes to feed generation (`src/ninjas/blog.gleam`), routes, post content,
  or any other home section's header/alignment.

## Decisions

- **Extract the feed link into `site.feed_link()`** — a public Lustre
  `Element(Nil)` built with `html.a` / `html.img`, returning the existing
  `.blog-feed`, `/atom.xml`, `/img/feed.svg` and "Feed Atom RSS" alt text. The
  blog index uses it in place of its inline anchor, and the home posts header
  appends it after the title text. Alternative: duplicate the anchor in
  `home.gleam` — rejected because the two links must stay identical and the
  spec treats them as one presentation. No new dependency; `html`/`attribute`
  are already used by both modules.
- **Extend the home `section()` helper with header extras** — a
  `List(Element(Nil))` argument appended to the `<h2>` children after the
  icon-plus-title elements. `posts_section` passes `[site.feed_link()]`; about,
  projects, books, and games pass `[]`. Alternative: hand-roll a separate posts
  panel — rejected because it would duplicate the panel/icon markup.
- **Add `margin-left: var(--rs-space-3)` (8px) to the existing `#posts` and
  `#blog` rules** in `static/style.css`, keeping the current `margin-top`
  declarations. 8px is a visible but restrained inset; a larger token
  (`--rs-space-4`, 16px) would over-shift the floating panel titles.

Routing and content files are unaffected: `/atom.xml` is still produced by the
existing blogatto feed configuration, and the four home languages share the
same template code, so all variants pick up the link automatically.

## Risks / Trade-offs

- The extra `<h2>` child could alter the floating title's width in narrow
  viewports → the feed icon is sized in `em` by the existing `.blog-feed img`
  rule and the title can wrap; no layout-specific overrides are added.
- A shared helper in `site.gleam` couples the home module to an additional
  site-level function → acceptable, as `home.gleam` already imports `site` for
  its chrome and icons.

## Migration Plan

No data or route migration. Rebuild `dist/` (`task build`) and inspect the home
and `/blog/page/1/` panels; rollback is a source revert plus rebuild.

## Open Questions

None.
