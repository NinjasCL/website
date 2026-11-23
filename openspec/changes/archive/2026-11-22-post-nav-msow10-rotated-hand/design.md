# Design

## Context

See proposal.md for motivation. `post_navigation` in `src/site.gleam` renders
the two neighbor buttons with Lustre `attribute.class`/`attribute.src` and the
`Hand_32x32_4.png` sprite, which points right; `static/style.css` flips only
`.post-nav__hand--left` with `scaleX(-1)`. The site uses a 32×32 Win95 icon
pack copied verbatim into the generated site by blogatto.

## Goals / Non-Goals

**Goals:**

- Reuse the shipped `Msow10_32x32_4.png` sprite for both directions.
- Make each direction explicit in markup and stylesheet so it can be tested.

**Non-Goals:**

- Generating new icon files or editing the sprite bitmap.
- Changing the neighbor list, labels, URLs, language resolution, or button
  styling.

## Decisions

- **Rotate the up-pointing sprite with CSS** instead of shipping mirrored
  copies: `rotate(-90deg)` for "Anterior", `rotate(90deg)` for "Siguiente".
  A quarter turn is lossless for pixel art, keeps `image-rendering: pixelated`
  crisp, and preserves the 32×32 footprint so the flex row does not shift.
  Alternatives considered: new left/right PNGs (extra assets to maintain) and
  Unicode arrows (not the requested hand glyph).
- **Add a `--right` direction class** to the "Siguiente" image, mirroring the
  existing `--left` class, rather than relying on an unmodified default. Both
  buttons then declare their direction, and tests can assert each separately.
- **Routing and content files are untouched.** The post's own URL and its
  language variants still come from blogatto's post collection; this change
  only edits the post template's image elements and the stylesheet.
- **No new dependency.** blogatto's existing `code`/`html` helpers and Lustre
  attributes already cover the template and the static asset is served by the
  existing static copy step; no library feature is insufficient here.

## Risks / Trade-offs

- [The hand's glyph direction differs from an arrow] → The spec and manifest
  describe the rotation explicitly so the intent survives future icon edits.
- [CSS transforms can look blurry on fractional scaling] → The sprite is
  square and rotated by exactly 90°, and the shared `image-rendering:
  pixelated` rule remains in place.

## Migration Plan

No migration: the old sprite stays in the pack for other uses, and a rebuild
regenerates `dist/` with the new paths. Rolling back means restoring the two
`attribute.src` values and the stylesheet rules.
