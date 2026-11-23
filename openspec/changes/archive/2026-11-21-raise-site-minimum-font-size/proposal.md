# Proposal

## Why

The post body got its 16px step, but the rest of the site still reads at
the cosmic theme's 13px base — and several chrome elements style
themselves even smaller: figure captions and the back-to-top link at the
10px ladder step, navbar links, the hero note, the language options row,
and the post list's date fine print at 13px. The site owner wants sixteen
pixels as the floor everywhere.

## What Changes

- The base body text restores the font ladder's size-3 step (16px at the
  default root size): a single override of the cosmic theme's
  `--rs-font-size-body` shrink, so every inheriting element — paragraphs,
  lists, the footer, the marquee — follows.
- The chrome that styles itself below the floor lifts to size-3:
  `.rs-navbar a`, `.rs-note`, `.rs-figure__caption`, `.rs-top`, and
  `.rs-list small`, plus the site's own `.post-languages` row.
- Everything already at or above 16px keeps its size — headings, the
  enlarged section titles (size-5), the showcase buttons (all render as
  the 18px `rs-btn--large` variant), and the Night Owl code panel.

Out of scope:

- No retrostrap rules for elements the site does not render (`.rs-dos`,
  `.rs-quote`, `.rs-ascii`, `.rs-statusbar`, form inputs, h5/h6) — the
  floor applies to everything the site actually renders; the ladder
  stays available below it.
- No heading, button, or code-panel changes, and no layout rework for
  the larger chrome — retrostrap's wrapping handles the wider navbar
  links.

## Capabilities

### New Capabilities

- `site-typography`: the site's text-size floor — every rendered element
  reads at a sixteen-pixel minimum, from the restored body base to the
  lifted chrome.

### Modified Capabilities

- None. The post body's own 16px rule stays as the spec pins it; this
  change lifts everything around it.

## Impact

- `static/style.css`: the cosmic body-base override plus five chrome
  bumps and the `.post-languages` step change.
- `test/ninjas_test.gleam`: a stylesheet-contract test for the floor
  (the base restore, the bumps, and the untouched larger sizes).
- No source, content, or dependency changes.
