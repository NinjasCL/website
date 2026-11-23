# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `featured_post` in `src/site.gleam` renders a stacked card: `article.rs-panel.rs-panel--sunken` with a linked `h3`, a `post-meta` time, the description, and `a.rs-btn` reading "Leer entrada →".
- blogatto parses a post's `featured_image` frontmatter field into `post.featured_image: Option(String)` (verified in blogatto's builder source: `get_frontmatter_optional_field(frontmatter, "featured_image")`). The current site has one post — "Bienvenidos a Ninjas.cl" — whose frontmatter has no `featured_image`; per the owner, it gains `/img/Ninjas.png`, and posts without an image fall back to that same logo.
- The about row structure to mirror: a `3fr 6fr` grid with a 2% column gap, collapsing below 639px, with a block-level figure whose image fills the column at **natural proportions** (`width: 100%; height: auto`). This is distinct from the showcase cards' treatment, which adds the Super Club Net uniform ratio box — deliberately not wanted here.

Routing is unaffected (the posts route and template pipeline stay); the change is one content line, view markup, and `static/style.css`, all shipped verbatim by blogatto. No new dependency — `gleam/option` (stdlib) covers the frontmatter field.

## Goals / Non-Goals

**Goals:**

- The featured post reads as a Sobre nosotros row: figure left at natural proportions, text right, one grid, one collapse point.
- Every post shows the structure — own image or the Ninjas placeholder.
- The button matches the site's large icon-button language.

**Non-Goals:**

- No change to the "Entrada destacada" heading, the intro text, the "Más entradas" list, or the empty state.
- No uniform ratio box on the post figure — the about treatment, not the showcase one.

## Decisions

1. **A `.post__cols` grid mirroring the about values** (`3fr 6fr`, `--rs-space-2` gap, `2%` column gap) joined to the shared 639px collapse, rather than reusing `.showcase__cols`: the showcase class carries the Super Club Net `aspect-ratio` box in its descendant rules, which would impose the uniform height the owner did not ask for here; the post row wants the plain about treatment. The cross-referencing comment pattern from `.about__cols`/`.showcase__cols` continues.
2. **The natural-proportions figure treatment extends by grouping selectors**: `#about .rs-figure, .post__cols .rs-figure { display: block; margin-inline: 0 }` and the same grouping for the img rule (`width: 100%; height: auto`) — the post joins the about portrait, not the ratio-boxed showcase images.
3. **The placeholder via a tiny `featured_image(post)` helper** — `option.unwrap("/img/Ninjas.png")` over the frontmatter field — so the row markup is unconditional and every featured post renders the structure. The figure's alt is meaningful ("Imagen destacada de …" + title), unlike the decorative section icons.
4. **The button uses the retrostrap-native pattern from the retuned showcase buttons**: class `rs-btn rs-btn--icon rs-btn--large`, children built with the existing `icon()` helper (`/icons/ReaderOpened_32x32_4.png`, owner-picked) plus the label — the icon replaces the trailing "→", which otherwise duplicates the affordance. The `.site-icon` rule sizes the icon (≈1.25em, pixelated), consistent with the rest of the site.
5. **Tests drive both paths**: a post fixture with `featured_image: Some(...)` proves the own-image row (figure before title, button markup, natural-proportions CSS), a fixture with `None` proves the placeholder, and a `simplifile` read of the post's frontmatter pins the content line.

## Risks / Trade-offs

- [A post without an image shows the Ninjas logo, which is branding rather than content] → Accepted per the owner's explicit choice; writing a `featured_image` per post is the supported override.
- [`/img/Ninjas.png` is a tall portrait (2117×2716), so the placeholder figure is taller than the text] → The about row already makes this trade-off; the grid sizes the row to the taller column.
- [Name-based icon pick (ReaderOpened) was not visually verified] → Same mitigation as the other icon picks: one-line swap plus the browser eyeball.

## Migration Plan

1. Add the frontmatter line to the current post.
2. Rework `featured_post` into the row (with the `featured_image` helper) and the button markup; import `gleam/option`.
3. Add the `.post__cols` rule, join the shared media query, and extend the about figure rules.
4. Add the markup, CSS, placeholder, and frontmatter tests.
5. Verify: `gleam format src test`, `gleam test`, `openspec validate featured-post-row-layout`.

Rollback: revert the frontmatter line, the `featured_post` markup, and the three CSS additions; nothing else persists.
