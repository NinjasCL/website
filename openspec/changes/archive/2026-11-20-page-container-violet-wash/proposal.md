# Proposal

## Why

The main page container (`.rs-page rs-container rs-container--wide`) renders the cosmic theme's solid `--rs-bg-content` (`#330033`), so the randomly-tiled, purple-tinted body background disappears completely behind the content. The old ninjas.cl stylesheet (`/css/ninjas.css`, still deployed) styled its content panels as its signature `.violet-frame`: a translucent violet wash (`rgba(33, 4, 49, 0.945)`, about 5% transparency) paired with a dashed `#7540bd` border, so the gradient ghosted through the framed panels. This change brings that full recipe back: the container becomes the old scheme's deep-violet wash edged with the dashed violet border, letting today's pattern background show through at about 5%.

## What Changes

- One CSS rule in `static/style.css` styles the main container under the cosmic theme with the old stylesheet's full `.violet-frame` recipe: `html[data-rs-theme="cosmic"] .rs-page { background: rgba(33, 4, 49, 0.945); border-style: dashed; border-color: #7540bd; }` — the wash taken verbatim, plus the old scheme's dashed violet border at retrostrap's existing 2px width (the border joins the wash per the 2026-11-20 revision).
- Out of scope:
  - The cosmic theme's tokens, text, link, heading, and border colors — untouched; the wash is deliberately near the darkness of today's solid `#330033`, so the light cosmic text (`#FFCCFF`) keeps its contrast. Only the main container's border becomes dashed — no panel, figure, or other element's border changes.
  - The body's pattern background and tint (`site-background-patterns` owns those).
  - Any markup, routing, content, or build-configuration change; the container div and its classes stay exactly as they are.

## Capabilities

### New Capabilities
- `site-page-surface`: The main page container's background presentation — the old ninjas.cl scheme's deep-violet translucent wash (about 5% transparency) over the patterned body, with the theme's text presentation untouched.

### Modified Capabilities

None. No existing spec covers the page container's surface; `site-background-patterns` owns the body tile behind it.

## Impact

- `static/style.css`: one rule carrying the full recipe (plus its explanatory comment). The selector outspecifies retrostrap's `.rs-page` background and border, so the cascade wins without `!important`.
- `test/ninjas_test.gleam`: CSS assertions pinning the wash (exact color and themed selector) and the guard (no theme-token overrides).
- No `gleam.toml`, `manifest.toml`, or CI changes.
