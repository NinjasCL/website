# Proposal

## Why

The initial button icon picks were name-based (this agent cannot render images) and flagged as one-line swaps pending a browser check. The site owner reviewed the pack and swapped two picks directly in the markup: the "Ver / View" button now carries the Internet Explorer globe (`/icons/Shdocvw257_32x32_8.png`) instead of the Quick View icon, and the "Leer entrada" button carries the Program Manager tile (`/icons/Progman25_32x32_4.png`) instead of the ReaderOpened icon. The archived specs and their tests still pin the old picks, so the suite fails — this change re-pins the contracts to the owner's picks.

## What Changes

- `site-showcase-buttons`: the View-icon requirement (and its scenario) now names the Internet Explorer globe icon, `Shdocvw257_32x32_8` — revised 2026-11-20 from the initial Quick View pick.
- `site-featured-post`: the Leer-entrada-button requirement (and its scenario) now names the Program Manager icon, `Progman25_32x32_4` — revised 2026-11-20 from the initial ReaderOpened pick.
- The two test assertions follow; the markup already carries the new picks (the owner's edit), so no `src/site.gleam` change is part of this change.
- Out of scope:
  - The Código/Code button (Wscript100, unchanged) and every other icon on the site.
  - The emoji manifest — the button icons are not part of it.
  - Any markup, routing, content, or build-configuration change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-showcase-buttons`: The "View and Code buttons carry matching icons" requirement changes its View-icon pick from the Quick View icon to the Internet Explorer globe icon.
- `site-featured-post`: The "Leer entrada button is a large icon button" requirement changes its icon pick from ReaderOpened to the Program Manager icon.

## Impact

- `openspec/specs/` contracts re-pinned via this change's delta specs (applied on archive/sync).
- `test/ninjas_test.gleam`: the two assertions move from `/icons/Quikview1_32x32_4.png` and `/icons/ReaderOpened_32x32_4.png` to the new picks.
- No source, content, or dependency changes — both icon files already ship in `static/icons/` (verified as valid 32×32 PNGs).
