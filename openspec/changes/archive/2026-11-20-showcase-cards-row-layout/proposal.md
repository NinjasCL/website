# Proposal

## Why

The showcase cards render their images with retrostrap's inline-block `rs-figure` treatment, so each image shows at its own natural size (a 460px square logo next to a 1050×1600 cover clamped to the card width) — odd, inconsistent image sizes across the cards, while the "Sobre nosotros" section right above shows the tidy pattern: image filling a left column at natural proportions with the text beside it. This change standardizes every showcase card onto that structure. The site owner confirmed the row layout matching the about grid's current values; initially scoped to proyectos y libros, the owner then extended the convention to Juegos so every showcase section presents its items uniformly.

## What Changes

- Every showcase card — the four "Proyectos", four "Libros", and four "Juegos" items — becomes a single row following the Sobre nosotros structure: the figure (image plus its "Desde …" caption) in a left column filling it at natural proportions, with the title, description, and buttons in the right column — reusing the about row's grid values (`3fr 6fr`, `2%` column gap) as they render today, and collapsing to a stacked column (image first) below the two-column breakpoint.
- One `showcase_card` helper with the row markup renders all twelve cards; the vertical variant and the interim `showcase_row_card` fold away.
- Every showcase card's image box takes the Super Club Net container height as a uniform minimum — implemented as that cover's 1050×1600 shape at the column width — so the image containers across the three sections present one uniform height; shorter or wider images letterbox centered and undistorted inside it.
- Guard requirements in main specs that pinned showcase figure sizing are superseded: `site-showcase-images` keeps only alt preservation (the presentation guard is removed, a narrower alt requirement is added), and `site-about-section` drops its "other figures keep their sizing" guard.
- Out of scope:
  - The Juegos image **sources** — they stay remote per the `local-showcase-images` scope; only their layout changes.
  - The images themselves (files, alts, and caption texts are untouched).
  - The about portrait keeps its natural-height presentation — the uniform image-box floor scopes to the three showcase sections only.
  - Reconciling the `site-about-section` spec's "~10% gap" wording with the about CSS's current 2% gap — still a flagged follow-up; this change copies the current CSS values.
  - Any new dependency, routing, content, or build-configuration change.

## Capabilities

### New Capabilities
- `site-showcase-cards`: Layout of the home page's showcase cards — the image-left/text-right row structure for the Proyectos, Libros, and Juegos sections, mirroring the about row's grid.

### Modified Capabilities
- `site-showcase-images`: The "Showcase presentation and alts are preserved" requirement is removed — no showcase figure keeps the vertical-card sizing once all sections adopt rows — and replaced by a narrower "Showcase alt texts are preserved" requirement.
- `site-about-section`: The "Other home page figures keep their sizing" requirement is removed as fully superseded; every showcase section's card presentation is owned by `site-showcase-cards`.

## Impact

- `src/site.gleam`: one `showcase_card` helper with the row markup renders all twelve cards — the games call sites keep their existing `showcase_card(...)` calls, and the proyectos/libros call sites that used the interim `showcase_row_card` return to the canonical name.
- `static/style.css`: the `.showcase__cols` grid and grouped figure-fill rules (already shipped for proyectos/libros) now cover the games cards automatically; their explanatory comments drop the "Juegos keeps the vertical layout" wording. The showcase img rule gains the Super Club Net ratio box while the about img rule splits out and keeps natural proportions.
- `test/ninjas_test.gleam`: the row test expects twelve `showcase__cols` rows across all three sections, adds a games-row assertion, and pins the uniform image-box rule in `static/style.css`.
- No `gleam.toml`, `manifest.toml`, or CI changes.
