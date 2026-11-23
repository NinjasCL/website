# Design

## Context

`games_section` in `src/ninjas/home.gleam` builds four `ShowcaseItem`
records; all four currently pass `icon: ""`. `showcase_card` renders
`site.title_with_icon(item.icon, item.title)`, which renders the icon
only when the path is non-empty, so the title icon is data-driven and the
template needs no change. `Mmsys108_32x32_4.png` already ships in the
win95 pack and is unused elsewhere on the site.

## Goals / Non-Goals

Goals: all four games card titles lead with the given icon, with the same
inline presentation as the other showcase titles.

Non-Goals (see proposal): section heading, other sections' cards, new
assets, manifest entries, layout changes.

## Decisions

### Data-only change

Set `icon: "/icons/win95/Mmsys108_32x32_4.png"` on the four records. No
component changes, no CSS changes, and no icon-resolution helper: the
path is literal, like the projects and books icons. Alternative rejected:
a `games_icon` constant would add indirection for a value used four times
in one function; the neighboring sections also spell their paths inline.

### No manifest entry

`emoji-matches.json` records emoji replacements only; these games titles
never carried an emoji, so adding an entry would make the manifest
inaccurate. The icon still ships in the static output as part of the
whole `/icons` directory.

## Risks / Trade-offs

- [A title's icon could be missed in one language] → `showcase_card`
  is language-agnostic; one data setting applies to all four home pages,
  and the render test checks the Spanish page where all four titles
  appear verbatim.

## Migration Plan

Additive chrome: no content, routing, config, or dependency changes.
Rollback is restoring the four `icon: ""` values.

## Open Questions

None.
