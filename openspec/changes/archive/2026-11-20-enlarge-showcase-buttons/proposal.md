# Proposal

## Why

Every showcase card in "Proyectos", "Libros", and "Juegos" carries two action links — "Ver / View" and "Código / Code" — rendered with retrostrap's smallest button variant (`rs-btn--small`, label size `--rs-font-size-1` = 0.625rem ≈ 10px with 1px/8px padding). Twenty-four buttons that small are hard to read and click. The site's static assets now include a Windows 95-era icon pack under `static/icons` (added by the site owner), and retrostrap already ships an `rs-btn--icon` variant built for icon-plus-text buttons.

## What Changes

- The showcase buttons drop `rs-btn--small` and render at retrostrap's large button size, carried by the `rs-btn--large` variant: a 1.125rem label (`--rs-font-size-4`, ≈1.8× the 0.625rem small default) with retrostrap's large padding. Revised 2026-11-20: the owner tuned the size down one ladder step from the initial "at least twice" floor after visual review.
- Each button carries a matching icon from the site's own static icon assets beside its label (chosen by the site owner from the pack): the Quick View icon (`/icons/Quikview1_32x32_4.png`) for "Ver / View", and the Windows Script icon (`/icons/Wscript100_32x32_4.png`) for "Código / Code", rendered crisp (pixelated) at about the label's size. Labels, hrefs, `target`/`rel`, and the two-buttons-per-card structure are unchanged.
- Out of scope:
  - Buttons outside the showcase cards — the contact mailto button and the footer controls keep their current classes and sizing.
  - The icon pack contents themselves (no additions, renames, or conversions).
  - Any new dependency, routing, content, or build-configuration change.

## Capabilities

### New Capabilities
- `site-showcase-buttons`: The action buttons on the home page's showcase cards ("Ver / View", "Código / Code") — their enlarged presentation (at least twice retrostrap's small-button default) and the icons they carry from the site's static assets.

### Modified Capabilities

None. The unarchived `showcase-cards-row-layout` delta says nothing about buttons, and no existing main spec (`blog-dev-server`, `blog-site-generation`, `site-about-section`, `site-masthead`, `site-section-headers`, `site-showcase-images`) covers them.

## Impact

- `src/site.gleam`: `external_button` gains an icon path argument and emits `rs-btn rs-btn--icon` with an `img` (empty alt — decorative; the label carries the meaning) before its label; its two call sites pass the chosen icons. `external_button` is used only by `showcase_card`, so no other markup changes.
- `static/style.css`: one scoped rule sizing the button icons (about 1.25em, pixelated) under `.showcase__cols`; the button size itself comes from retrostrap's `rs-btn--large` class in the markup.
- `test/ninjas_test.gleam`: tests asserting twenty-four icon buttons, no small variant left, each icon beside its label, and the CSS rules present.
- No `gleam.toml`, `manifest.toml`, or CI changes.
