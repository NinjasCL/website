# Design

## Context

`books_section` in `src/ninjas/home.gleam` builds its cards from `ShowcaseItem` values and renders them through the shared `showcase_card` helper, which already handles the row layout, caption, language-specific copy, and both buttons. The cover image is already present in `static/img/` at 2400×3200; `elixir-fullstack.jpg` is 640×961. The stylesheet gives every showcase image the same `aspect-ratio: 1050 / 1600` box with `object-fit: contain`, so no CSS change is needed to display a new cover.

## Goals / Non-Goals

**Goals:**
- Ship the new book card with its published site, source repository, cover, alt text, and a two-line summary in all four languages.
- Keep the new cover's pixel size consistent with `elixir-fullstack.jpg` without distorting the photo.

**Non-Goals:**
- No new dependency, route, blog content, stylesheet rule, or change to the other showcase cards.

## Decisions

1. **Add one more `ShowcaseItem` at the head of `books_section`.** The repository was created in July 2025, later than the current newest book card (Robótica con Elixir, April 2025), so the card leads the "Libros" section with a `MonthYear(7, 2025)` caption. The existing `showcase_card` renderer needs no change: it already draws the icon-led title, image, caption, and buttons for any item.

2. **Write the two-line summary once per language in `CardText`.** Each variant gets two sentences: one on the book's scope (kernel, processes, concurrency, synchronization, file systems), one on its approach (Ada and Elixir examples, minishell, concurrency, and game-server projects). The Spanish original comes from the book's own introduction and table of contents; the other languages reuse the same structure. This keeps the copy beside the card, matching the existing convention, instead of adding a translation table.

3. **Center-crop the cover to 640×961, then resample to that exact size.** Run `sips --cropToHeightWidth 3200 2133` to trim the 2400×3200 photo symmetrically to 2133×3200, then `sips --resampleHeight 961` to reach 640×961, matching `elixir-fullstack.jpg` exactly. Alternative rejected: a direct resample to 640×961 would squeeze the photo's 3:4 proportions into a narrower box. The card's CSS box already letterboxes the result, so the asset size only governs the shipped file, not the layout.

4. **Update the home-view tests in place.** The card count grows from fourteen to fifteen and the icon buttons from twenty-eight to thirty; the showcase-image test gains the new `/img/` path and alt text, and the catalog test gains both new URLs. No test helper or fixture changes are needed.

## Risks / Trade-offs

- [Center cropping trims the photo's left and right edges] → Mitigation: only about 5% of the width is removed, and the card's `object-fit: contain` box displays the full cropped frame without further clipping.
- [A two-sentence summary may wrap into more than two visual lines on narrow viewports] → Mitigation: the requested two-line scope is preserved in the copy; wrapping follows the site's responsive layout like every other card description.

## Migration Plan

No migration: the new asset is added beside the existing covers, and the site is rebuilt with `task build` / `gleam run`. Rollback is removing the card, the asset, and the test changes.
