# Design

## Context

`post_navigation` in `src/site.gleam` renders two large retrostrap icon
buttons — "Anterior" with `ArrowLeft_32x32_4.png` and "Siguiente" with
`ArrowRight_32x32_4.png`. The static win95 pack ships a single
`Hand_32x32_4.png`: a 32x32 pixel-art hand with its index finger pointing
right, already used nowhere else in the site. `.post-nav .rs-btn img` in
`static/style.css` sizes those button icons to 1.25em with pixelated
rendering.

## Goals / Non-Goals

Goals: both post-neighbor buttons use the pointing hand, facing the
appropriate direction, with no new image assets.

Non-Goals (see proposal): index pagination, other chrome icons, nav
wording/order/targets, new assets or dependencies.

## Decisions

### One hand sprite, mirrored for the left direction

`Hand_32x32_4.png` points right in the pack, so the "Siguiente" button
uses it as-is and the "Anterior" button uses the same file with a
`.post-nav__hand--left` class whose CSS rule is `transform: scaleX(-1)`.
Alternatives rejected:

- New `HandLeft`/`HandRight` PNGs — duplicating the asset (and a mirror
  edit of pixel art) when CSS flips it losslessly, including pixelated
  scaling.
- `Hand_16x16_4.png` — same glyph at half the size; every icon button
  uses the 32x32 pack.
- A CSS arrow rotation — would keep an arrow, not a hand.

The right-facing hand keeps its `<img>` plain; the left-facing one gets
only the flip class, so the existing `.post-nav .rs-btn img` sizing rule
still applies to both.

### Manifest follows the markup

The two ⬅️/➡️ entries in `emoji-matches.json` change their `icon` to
`Hand_32x32_4.png` and their descriptions to the mirrored-hand behavior;
the match count stays fourteen, so the manifest contract is unchanged.

## Risks / Trade-offs

- [A mirror on a pixel-art sprite could look blurry] → the existing
  `image-rendering: pixelated` on `.post-nav .rs-btn img` keeps the flip
  crisp; the CSS rule only sets `transform`.
- [Tests pinning arrow paths] → the post-navigation render test and the
  manifest test are updated in place; the index pagination arrows remain
  unchanged and are not asserted by those tests.

## Migration Plan

Click-through chrome swap: no content, routing, config, or dependency
changes. Rollback is restoring the two arrow paths and dropping the CSS
rule and manifest edits.

## Open Questions

None.
