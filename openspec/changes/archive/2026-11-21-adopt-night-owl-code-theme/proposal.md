# Proposal

## Why

Post code blocks currently have no background of their own — they sit
directly on the page's violet surface, so highlighted tokens read poorly
against the busy, mid-dark background. The Night Owl theme
(sdras/night-owl-vscode-theme, checked from the theme JSON at the owner's
request) is built for exactly this: a deep navy editor panel with a
high-contrast token palette.

## What Changes

- Post code blocks (`.post-body pre`) sit in their own Night Owl panel:
  the editor background `#011627` — darker than the page's violet — with
  the theme's foreground `#d6deeb`, padding, the theme's contrast border
  `#122d42`, and horizontal scrolling for wide code.
- The seventeen smalto token rules switch from the interim Catppuccin-ish
  colors to the Night Owl palette, mapped from the theme's scopes:
  keyword/storage `#c792ea` (italic), string `#ecc48d`, number `#f78c6c`,
  comment `#637777` (italic), function `#82aaff` (italic), operator
  `#7fdbca`, punctuation/variable `#d6deeb`, type `#ffcb8b`, module and
  builtin `#c5e478`, constant `#82aaff`, tag `#caece6`, attribute
  `#c5e478` (italic), selector `#c792ea` (italic), property `#80cbc4`,
  regex `#5ca7e4`.

Out of scope:

- No markup or component changes — the highlighter's classed spans stay
  exactly as they are; this is a stylesheet-only restyle.
- No theme anywhere else: the page surface, panels, and warnings keep the
  site's violet retro palette; Night Owl owns only the code panel.
- No line numbers, no copy buttons, no language tabs.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: the "Post code blocks are highlighted at build
  time" requirement's stylesheet scenario updates — post code blocks sit
  on the Night Owl editor background (darker than the page, framed by
  the theme's contrast border) and the smalto token classes carry the
  Night Owl palette.

## Impact

- `static/style.css`: the `.post-body pre` panel rule replaces the
  background-less pre, and the seventeen token rules take the Night Owl
  colors.
- `test/ninjas_test.gleam`: the stylesheet-contract test pins the panel
  and the palette.
- No source, content, or dependency changes.
