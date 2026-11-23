# Design

## Context

`site.site_footer(rights, top_label)` in `src/site.gleam` builds one
paragraph of text — "Copyright 🥷🏽 Ninjas.cl © 2015–{year} · " <> rights —
plus the back-to-top link. It is the single footer renderer: the post and
404 views call it with the Spanish clause, and the four homes call it via
`home.view` with their own clause and top label. All other labeled chrome
leads with a 32x32 Win95 icon through `site.icon` (class `site-icon`,
empty alt), whose presentation is already shipped in `static/style.css`.

## Goals / Non-Goals

Goals: the copyright line leads with one authorship icon on every page,
using the shared inline icon presentation.

Non-Goals (see proposal): no emoji changes, no new assets, no manifest
entry, no per-post title icons, no footer wording or link changes.

## Decisions

### The icon is Win95's document-and-pencil

`/icons/win95/FilePencil_32x32_4.png` — a document with a pencil, the
pack's authorship glyph, in the 32x32 4-bit form every chrome icon uses.
Alternatives rejected:

- `Copy_16x16_4.png` — means duplicate, not authorship, and is only 16x16.
- `Oiui400Textstamp_32x32_4.png` — a text stamp, less legible at
  text size than the document-and-pencil glyph.
- `Bookmark_32x32_4.png` — already the tags row's icon; reusing it would
  make two unrelated rows look alike.
- `Globe_32x32_4.png` — banned by the site's own tests after the Contacto
  removal.

### One constant, one call site

`pub const copyright_icon = "/icons/win95/FilePencil_32x32_4.png"` beside
the other chrome icon constants in `src/site.gleam`; `site_footer`'s
paragraph renders `icon(copyright_icon)` before the text, with a leading
space in the text node as `title_with_icon` already does. No CSS changes:
`.site-icon` already sizes and aligns the icon relative to the row text.

## Risks / Trade-offs

- [Exact-substring footer assertions] → the icon is inserted before the
  verbatim text; `string.contains(html, "Copyright 🥷🏽 …")` keeps matching
  unchanged, and a new test pins the icon's order.
- [The icon choice is subjective] → it lives in one constant; swapping the
  path is a one-line change with no template edits.

## Migration Plan

Additive chrome: no content, routing, config, or dependency changes.
Rollback is removing the icon element and the constant.

## Open Questions

None.
