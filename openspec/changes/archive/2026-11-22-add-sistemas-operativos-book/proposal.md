# Proposal

## Why

The free book "Conceptos de Sistemas Operativos" (`https://ninjascl.github.io/sistemas-operativos/`) is published but missing from the home page's "Libros" showcase, so visitors cannot discover it alongside the site's other books.

## What Changes

- Add a "Conceptos de Sistemas Operativos" book card to `books_section` in `src/ninjas/home.gleam`, using `ShowcaseItem`/`CardText` for its two-line summary and Spanish, English, Japanese, and Portuguese copy.
- Point the card at the published site and the `NinjasCL/sistemas-operativos` source repository, with the cover at `/img/niklas-konig-1cTFuvI14J4-unsplash.jpg` and the alt text "Foto de Niklas König en Unsplash".
- Resize the shipped cover asset to the same pixel dimensions as `elixir-fullstack.jpg` (640×961), keeping its proportions.
- Extend the home-view tests for the new card, its links, its image and alt text, and the updated showcase card/button counts.
- Update the affected capability specs so the book showcase and its local assets describe the new card.

Out of scope: new dependencies, blog posts or routes, CSS/layout changes, and edits to the existing book cards.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `site-showcase-cards`: the "Libros" showcase gains the "Conceptos de Sistemas Operativos" card with its two-line summary rendered in every site language.
- `site-showcase-images`: the new book's cover is served from the site's own `/img/` assets with the required alt text and joins the shipped book covers.

## Impact

- `src/ninjas/home.gleam` — one more `ShowcaseItem` in `books_section` (rendered through the existing `showcase_card` Lustre helper).
- `static/img/niklas-konig-1cTFuvI14J4-unsplash.jpg` — resized cover asset.
- `test/ninjas_test.gleam` — home-view assertions and card/button counts.
- `openspec/specs/site-showcase-cards/spec.md` and `openspec/specs/site-showcase-images/spec.md` — delta specs.
