# Proposal

## Why

The static-asset reorg moved the Win95 icon pack under `/icons/win95/`, and its change updated the markup and tests — but two main specs still pin the icons at the old flat paths, contradicting the shipped behavior the tests already assert. Alongside, the site's retro cursor pack (arrow everywhere, hand on interactive controls) has shipped in the stylesheet with no spec coverage at all.

## What Changes

- The three stale icon pins update to the reorganized pack: the View button's globe icon (`/icons/win95/Shdocvw257_32x32_8.png`) and the Code button's script icon (`/icons/win95/Wscript100_32x32_4.png`) in `site-showcase-buttons`, and the "Leer entrada" Program Manager icon (`/icons/win95/Progman25_32x32_4.png`) in `site-featured-post`. No markup or test change rides along for these — the code and tests already serve and assert the win95 paths.
- A new capability `site-cursors` records the retro cursor pack: the arrow cursor as the page default, the hand cursor over interactive controls, and the disabled-controls fallback to the arrow, all served from `/cursors/`.
- A stylesheet test pins the cursor rules, giving the new capability coverage.

## Capabilities

### New Capabilities
- `site-cursors`: Defines the site's retro cursor chrome — the arrow/hand cursor pack served from `/cursors/` and applied by the shipped stylesheet.

### Modified Capabilities
- `site-showcase-buttons`: the "View and Code buttons carry matching icons" scenarios re-pin their icons at the reorganized `/icons/win95/` paths.
- `site-featured-post`: the "Leer entrada" button scenario re-pins the Program Manager icon at `/icons/win95/Progman25_32x32_4.png`.

## Impact

- `test/ninjas_test.gleam`: a new cursor-pack test asserts the shipped stylesheet's rules (`/cursors/arrow.cur` default, `/cursors/hand.cur` on interactive controls, the disabled fallback).
- No `src/site.gleam`, asset, or dependency changes: the markup already serves the win95 paths and the cursor pack already ships — this change reconciles the specs and adds coverage. No blogatto or Lustre API drives the design.

## Out of scope

- The unused shipped assets — the macOS 9 icon pack and `static/img/sad_mac.png`.
- The unpinned `site_description` constant and the `site-masthead` home-hero scenario drift (call-to-action links no longer rendered).
