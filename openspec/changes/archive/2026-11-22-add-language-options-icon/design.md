# Design

## Context

The language options row renders in three places — `language_options`
(post pages) and `index_language_options` (blog index pages) in
`src/site.gleam`, `home_language_options` (home pages) in
`src/ninjas/home.gleam` — each a `post-languages` paragraph starting with
a bare text label ("Idiomas: ", "Languages: ", "言語: ", "Idiomas: "). The
site's other labeled rows all lead with a 32x32 Win95 icon through the
shared `icon()` helper (class `site-icon`, empty alt, pixelated scaling).

## Goals / Non-Goals

Goals: one languages icon leading the label on all three rows, consistent
with the site's icon-led chrome.

Non-Goals (see proposal): manifest entries, new assets, per-post title
icons, the row's entries and links.

## Decisions

### The icon is Win95's Regional Settings indicator

`/icons/win95/Intl101_32x32_4.png` — the international/regional settings
icon from the Win95 shell pack, the era's own "languages" glyph, in the
32x32 4-bit form every inline chrome icon uses. Alternatives rejected:

- `Internat151_16x16_4.png` — the internat.exe language indicator, the
  most authentic pick, but it ships only in 16x16; every chrome icon is
  32x32, so it would render at odds with the pack.
- `Globe_32x32_4.png` — banned by the site's own tests: the Contacto
  removal established "no Globe icon anywhere" (and no Globe entry in
  `emoji-matches.json`), so reusing it would fight the shipped contract.
- `Earth_32x32_4.png` — a planet, not languages, and already the fixture
  icon of the post-icon tests.

### One shared constant, three lead positions

`src/site.gleam` exposes `pub const languages_icon =
"/icons/win95/Intl101_32x32_4.png"`; the three rows render
`icon(languages_icon)` before `element.text(" " <> label <> ": ")`,
matching how `title_with_icon` leads its labels and how the tags row
leads the Bookmark icon. No CSS changes: `.site-icon` already sizes the
icon relative to the row's text.

## Risks / Trade-offs

- [The 16x16-only Internat purists] → the Intl101 pick keeps the 32x32
  pack consistency; swapping the constant later is a one-line change.
- [Exact-substring tests on the row] → the icon renders before the label,
  so the existing `"Idiomas: <span…"` / `"Idiomas: "` assertions keep
  matching (the label text is unchanged, only preceded).

## Migration Plan

Additive chrome: no content, routing, or config changes. Rollback is
removing the three icon elements and the constant.

## Open Questions

None.
