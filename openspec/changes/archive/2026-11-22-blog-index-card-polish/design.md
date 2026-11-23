# Design

## Context

The entry card is an `article.blog-entry` frame holding two siblings:
the `a.embed-full` link row (text body + `img.embed-full__image`) and
the `div.blog-entry__meta` row (tags + translation links). Anchors
cannot nest, so the meta row must stay outside the link. The image
today is an in-flow flex child of the link row, capped at 300px, so
it can only ever cover the link row — never the meta region — and a
tall image makes the row grow instead of cropping. See proposal.md for
motivation.

## Goals / Non-Goals

**Goals:**

- The image covers the whole frame — both rows — at its current 40%
  width share, zooming (cropping) to whatever height the text needs.
- Uniform card heights driven by text, with the icons matching the
  post pages and clear separation between frames and from the menu.
- No markup restructuring of the card's link semantics: the whole
  link row stays one anchor, the meta row stays outside it.

**Non-Goals:**

- No responsive redesign of the card below the vga breakpoint.
- No changes to the in-post `embed-full` OpenGraph cards.

## Decisions

**Absolute-positioned cover column, scoped under `.blog-entry`.**
The frame gets `position: relative`; the image gets
`position: absolute` with `top/right` insets at `--rs-space-2`,
`width: 40%`, an explicit `height: calc(100% - var(--rs-space-3))`,
and `max-height: none` to drop the 300px cap. Its containing block
becomes the frame, so the one image spans both the link row and the
meta row without any DOM change, and its intrinsic size stops
contributing to layout — the card's height follows text alone. The
explicit height matters: a replaced element does not stretch between
`top` and `bottom` insets — its height would follow its intrinsic
ratio and portrait covers would spill past the frame — so the height
is stated against the frame instead of a `bottom` inset. The existing
`object-fit: cover` on `.embed-full__image` does the zooming; width
keeps its 40% share. Alternatives: stretching the image with the flex
`align-items:` stretch (can never cross into the meta region); a grid
frame (the image is not a direct child of the frame, so it cannot
participate); restructuring the DOM (breaks the one-link card or
nests anchors). Absolute positioning wins on all three counts.

**Reserve the column in flow with `calc`-padding.** The link row gets
`padding-right: calc(40% + var(--rs-space-3))` and the meta row the
same as `margin-right`, so text, tags, and the meta divider stay in
the left column and out from under the image; percentages resolve
against the same frame width on all three rules, so the columns line
up. The meta's `margin-right` also ends its dashed top border at the
text column, instead of running it under the image.

**Separation between frames, not inside them.** The frame's spacing
becomes `margin-bottom: var(--rs-space-4)` (16px, up from a collapsed
4px), and the 10% top-padding rhythm (and its `:first-child` reset) is
removed — the breathing room the padding tried to create now lives
between the blocks, where consecutive results actually read it.

**Header clearance under the menu.** `#blog` gets
`margin-top: var(--rs-space-5)` (32px): retrostrap's 16px default left
the floating `rs-panel__title` (raised 0.7em above the panel border)
nearly touching the navbar; 32px gives it real clearance.

**Icons through the existing helpers.** `blog_entry_card` reuses
`title_with_icon("/icons/win95/Mailnews8_32x32_4.png", …)` for the
title and `icon("/icons/win95/Timedate_32x32_4.png")` for the date —
the exact grammar of the post template's own heading and date row, so
the card and the post page agree by construction. No new assets, no
new Lustre patterns, no `gleam.toml` change.

## Risks / Trade-offs

- [Very tall cards crop the image hard] → Accept: `cover` cropping is
  the requested behavior — zoom to fit, keep the width; the alt text
  and the linked post page still carry the full image.
- [The absolute image stops contributing to height, so a card whose
  text is very short shows a thin image strip] → Accept: the row keeps
  its text-driven minimum (date, title, description lines) and the
  fallback logo covers it the same way.
- [A very long description makes the image zoom far past its natural
  resolution] → Accept: covers are large enough for a 40%-wide column;
  the same trade-off already exists on the masthead covers.
