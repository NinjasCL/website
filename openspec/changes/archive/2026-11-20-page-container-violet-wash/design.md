# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- Retrostrap gives `.rs-page` a solid `background: var(--rs-bg-content)` with `--rs-space-3` padding; the container div carries `rs-page rs-container rs-container--wide`, and the background lives on `.rs-page` (the container classes are width utilities).
- The cosmic theme sets `--rs-bg-content: #330033` — a solid deep purple fully covering the body — whose text colors are light (`--rs-text: #FFCCFF`), tuned for dark surfaces.
- The body behind it carries the random `/patterns` tile plus the purple tint (`site-background-patterns`), currently invisible behind the solid container.
- The old stylesheet (`https://ninjas.cl/css/ninjas.css`, fetched today) styles its content panels with translucent violet washes: `.flower-frame` `rgba(99, 18, 142, 0.5)`, `.purple-frame` `rgba(99, 18, 142, 0.3)`, `.post-content` `rgba(23, 23, 23, 0.745)`, and the container-grade `.violet-frame` `rgba(33, 4, 49, 0.945)` — the only wash in the scheme at about 5% transparency, and the one this change takes verbatim. Those frames were edged with `border-style: dashed; border-color: #7540bd` (the `.violet-frame`'s full recipe), their width left to the browser default (medium ≈ 3px); retrostrap gives `.rs-page` a solid 2px bevel border that the cosmic theme recolors (`#9966CC #330033 #330033 #9966CC`).

Routing, content files, and templates are unaffected: one stylesheet rule that blogatto ships verbatim. No new dependency.

## Goals / Non-Goals

**Goals:**

- The container surface becomes the old scheme's violet wash, with the patterned body ghosting through at about 5%.
- The cosmic text presentation and every theme token stay exactly as they are.

**Non-Goals:**

- No changes to the body pattern/tint, borders, bevels, or any color token.
- No markup change to the container div or its classes.

## Decisions

1. **The full old `.violet-frame` recipe, verbatim: `rgba(33, 4, 49, 0.945)` + `border-style: dashed; border-color: #7540bd`.** The wash is the scheme's only "about 5% transparency" wash and its content-container grade; at 94.5% opacity over the patterned `#330066` body, the surface stays essentially as dark as today's solid `#330033`, so the light text keeps its contrast while the tiles ghost through. The dashed `#7540bd` border is the same old rule's other half, replacing retrostrap's solid bevel; the width stays retrostrap's 2px (the old site left width to the browser default, medium ≈ 3px — rejected for this pass: keeping the container's existing border weight, and widening later is one word). Alternatives rejected: the scheme's lighter `.purple-frame` `rgba(99, 18, 142, 0.3)` — 70% transparent, far beyond the "about 5%" ask and too light a surface for the light text; a literal "5% opacity" wash (`rgba(33, 4, 49, 0.05)`) — would nearly erase the container and put bright tiles directly behind the text.
2. **One themed rule in `static/style.css`: `html[data-rs-theme="cosmic"] .rs-page { background: rgba(33, 4, 49, 0.945); }`.** The selector's specificity (0, 2, 1) outspecifies retrostrap's `.rs-page` (0, 1, 0) without `!important`, and the theme scoping mirrors the file's existing body-pattern override (`html[data-rs-theme="cosmic"] body`). Alternative rejected: overriding `--rs-bg-content` — a global token change would recolor every panel that uses it, not just the page surface.
3. **Tests pin the recipe and the guard via `simplifile`:** the exact rgba under the themed selector plus the dashed `#7540bd` border, and the absence of any `--rs-` token override in the file (only the container's surface changes).

## Risks / Trade-offs

- [The tiles now ghosting through the container add visual noise behind the text] → At 5.5% visibility over a near-black wash, the ghosting is a subtle texture — the exact effect the old site's panels had over its gradient; the browser eyeball is the checkpoint.
- [A 2px dashed border renders with chunky dashes] → Accepted retro look; the old site's frames were dashed too, and widening to the browser-default medium is a one-word change if the dashes read too fine.
- [The wash is a static color, not a token] → Deliberate: it is one surface, copied verbatim from the old scheme; promoting it to a token is trivial later if a second use appears.
- [A retrostrap upgrade could restyle `.rs-page`'s background] → Our higher-specificity rule keeps winning regardless of load order; the test pins the declaration.

## Migration Plan

1. Add the rule (and its comment) to `static/style.css`.
2. Add the CSS assertions to `test/ninjas_test.gleam`.
3. Verify: `gleam format src test`, `gleam test`, `openspec validate page-container-violet-wash`.
4. Revised 2026-11-20: extend the rule with the dashed `#7540bd` border, update the comment, and extend the test; re-verify.

Rollback: remove the rule and the tests; nothing else persists.
