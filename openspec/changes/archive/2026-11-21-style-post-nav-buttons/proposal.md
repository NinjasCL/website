# Proposal

## Why

The post navigation renders as bare text links, visually unrelated to the
rest of the site's controls — the showcase "Ver / View" and "Leer
entrada" buttons are the site's established action style, and the
navigation deserves the same treatment.

## What Changes

- The previous and next anchors become the site's large retrostrap
  icon buttons — the same `rs-btn rs-btn--icon rs-btn--large` classes
  and inline icon treatment as the showcase "Ver / View" buttons, minus
  their `target`/`rel` (navigation stays in the same tab).
- Each button carries its direction icon from the Win95 pack:
  `ArrowLeft_32x32_4.png` beside the "Anterior: {title}" label and
  `ArrowRight_32x32_4.png` after the "Siguiente: {title}" label — the
  arrows bracket the row pointing outward, replacing the old unicode
  arrows in the text.
- The two icons join the `/icons` emoji-matches manifest, keeping its
  "names every icon the markup uses" contract true.
- The `.post-nav` row keeps its flex spread; the buttons' own retrostrap
  styling does the rest.

Out of scope:

- No changes to the neighbors logic, language resolution, or the
  end-post/lone-post behavior — only the anchor presentation.
- No per-language labels and no new CSS beyond what the row already
  has.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: the "Post pages navigate to adjacent entries"
  requirement's links render as the site's large retrostrap icon
  buttons with their direction icons.

## Impact

- `src/site.gleam`: `post_navigation`'s two anchors take the
  `rs-btn rs-btn--icon rs-btn--large` classes and their arrow icons.
- `static/icons/win95/emoji-matches.json`: two arrow-icon entries.
- `test/ninjas_test.gleam`: the navigation tests assert the button
  classes, the icon sources, and the arrow-less labels; the manifest
  test covers the new icons.
- No dependency or content changes.
