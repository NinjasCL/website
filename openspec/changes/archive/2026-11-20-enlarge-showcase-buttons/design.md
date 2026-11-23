# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `external_button` in `src/site.gleam` renders `a.rs-btn.rs-btn--small` with a text label, and is called from exactly two places — both inside `showcase_card` ("Ver / View" and "Código / Code", 24 buttons across the twelve cards). `rs-btn--small` appears nowhere else in the markup.
- Retrostrap sizing: base `rs-btn` at `--rs-font-size-2` (0.8125rem); `rs-btn--small` at `--rs-font-size-1` (0.625rem ≈ 10px) with 1px/8px padding; `rs-btn--large` at `--rs-font-size-4` (1.125rem); and `rs-btn--icon` provides the icon-plus-text layout (`inline-flex`, centered, 4px gap).
- The icon pack under `static/icons` (site-owner added) holds Windows 95-era PNGs in 16×16 and 32×32 variants; the site owner picked `Quikview1_32x32_4.png` for View and `Wscript100_32x32_4.png` for Code from the name candidates.
- The showcase buttons live inside `.showcase__cols` grids, so a descendant selector there scopes cleanly and outranks retrostrap's single-class rules (0,2,0 vs 0,1,0) without `!important`.

Routing, content files, and templates are unaffected: markup via the existing Lustre helpers, styling in `static/style.css` (both shipped verbatim by blogatto), icons via the static copy. No new dependency.

## Goals / Non-Goals

**Goals:**

- All twenty-four buttons render at a label size ≥ 1.25rem — on the ladder, so page typography stays coherent.
- Each button leads with its matching icon, crisp and roughly label-sized, with the label text intact.

**Non-Goals:**

- No change to labels, hrefs, `target`/`rel`, or the two-buttons-per-card structure.
- No touch on contact/footer buttons or on the icon pack contents.

## Decisions

1. **Retrostrap's own `rs-btn--large` (label 1.125rem, ≈1.8×) carried in the markup.** Revised 2026-11-20: the owner tuned the buttons down one ladder step from the initial 2× floor after visual review — and size-4 with the large padding is exactly what retrostrap's `--large` variant ships, so the class replaces the earlier custom size override and the native `:active` press effect (which the override was suppressing) returns. Alternative rejected: keeping the custom override at size-4 — it duplicates a variant retrostrap already ships and keeps suppressing the press.
2. **Markup: `external_button(url, label, icon)`** emitting `a.rs-btn.rs-btn--icon` with an `img` (icon path, empty alt — decorative, the label carries the meaning) before the label text; the two call sites pass the chosen icon paths, keeping the mapping visible at the point of use. Retrostrap's `--icon` handles the flex/gap layout. `rs-btn--small` disappears from the markup entirely (it existed only here).
3. **Only the icon box stays custom** — `.showcase__cols .rs-btn img` (height ≈ 1.25em at the button's size, width auto, `image-rendering: pixelated` for crisp retro scaling), scoped like the figure rules. The button size itself is retrostrap's own `rs-btn--large`; the custom size/padding override from the first pass is deleted by the revision. Alternative rejected: a site button-variant class — retrostrap already ships the exact variant.
4. **Tests pin markup and CSS**: twenty-four `rs-btn--icon` buttons (one per button, proving every card carries them), zero `rs-btn--small` left anywhere, each icon's `src` preceding its label in the rendered markup, and both CSS rules present via `simplifile`.

## Risks / Trade-offs

- [1.125rem buttons sit below the original "at least 2×" ask] → Accepted by the owner's 2026-11-20 retune: the spec floor was revised to match, and the icons plus retrostrap's large padding keep the buttons prominent. The revision also resolves the earlier `:active` concern — the native press effect applies again.
- [Pixelated rendering is a stylistic bet at ~22px from 32px sources] → Near-native scale, so nearest-neighbor stays crisp; it can be dropped to `auto` later without spec impact.

## Migration Plan

1. Update `external_button` (icon argument, `rs-btn--icon` class, icon `img`) and its two call sites.
2. Add the two scoped rules in `static/style.css`.
3. Add the markup and CSS tests.
4. Verify: `gleam format src test`, `gleam test`, `openspec validate enlarge-showcase-buttons`.
5. Revised 2026-11-20: switch the class to `rs-btn rs-btn--icon rs-btn--large`, delete the size/padding override, and update the tests.

Rollback: revert the helper to the `rs-btn--small` text-only form and remove the CSS rules; nothing else persists.
