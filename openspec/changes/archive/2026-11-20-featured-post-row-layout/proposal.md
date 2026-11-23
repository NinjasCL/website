# Proposal

## Why

The "Entradas del blog" section still renders its featured post as a plain stacked card (title, date, description, button), while the rest of the home page — Sobre nosotros and every showcase card — now presents the image-left/text-right row structure. Per the site owner, the featured post must follow the same Sobre nosotros structure, and its "Leer entrada" button must match the site's button language (a respective `static/icons` icon at the `rs-btn--large` size).

## What Changes

- The featured post renders as a Sobre nosotros-style row: its figure fills a left column (~⅓, 2% gap, same grid values as the about row) and the text — linked title, date, description, and the button — fills the right column (~⅔), collapsing to figure-first stacking below the two-column breakpoint. The figure shows at natural proportions, like the about portrait (no uniform ratio box).
- The figure's source is the post's own `featured_image` frontmatter field (blogatto parses it into the `Post` record); when a post has none, the Ninjas logo (`/img/Ninjas.png`) fills the column as a placeholder so the row structure always renders (owner-confirmed).
- The current post ("Bienvenidos a Ninjas.cl") gains `featured_image: /img/Ninjas.png` in its frontmatter so the structure is visible on the site today.
- The "Leer entrada →" button becomes a large icon button: `rs-btn rs-btn--icon rs-btn--large` with the ReaderOpened icon beside the label; the trailing arrow is dropped (the icon is the affordance).
- Out of scope:
  - The "Más entradas" list (link + date lines with no images) and the "Todavía no hay entradas publicadas." empty state — unchanged.
  - The "Entrada destacada" heading and the section's intro text — unchanged.
  - Any new dependency, routing, or build-configuration change; blogatto's `featured_image` frontmatter field is the existing, sufficient feature.

## Capabilities

### New Capabilities
- `site-featured-post`: The featured post's presentation on the home page — the Sobre nosotros-style row (figure left at natural proportions with the Ninjas placeholder fallback, text right), and its "Leer entrada" large icon button.

### Modified Capabilities

None. `blog-site-generation` covers the route-level "home route lists available posts" behavior, not presentation; no other spec covers the posts section.

## Impact

- `blog/bienvenidos-a-ninjas-cl/index.md`: one frontmatter line added (`featured_image: /img/Ninjas.png`).
- `src/site.gleam`: `featured_post` renders the row (gaining a small `featured_image` fallback helper); the button markup; a new `gleam/option` import for the frontmatter field.
- `static/style.css`: a `.post__cols` grid rule mirroring the about values, the narrow-viewport collapse grouped with the shared media query, and the natural-proportions figure treatment extended to cover the post row.
- `test/ninjas_test.gleam`: a test driving the row with post fixtures (with and without a featured image) and a content test pinning the frontmatter addition.
- No `gleam.toml`, `manifest.toml`, or CI changes.
