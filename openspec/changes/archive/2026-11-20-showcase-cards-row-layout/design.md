# Design

## Context

See `proposal.md` for motivation. Current state, after the initial proyectos/libros implementation (revised 2026-11-20 to include Juegos):

- The initial implementation shipped `.showcase__cols` in `static/style.css` — mirroring `.about__cols` exactly (`grid-template-columns: 3fr 6fr; gap: var(--rs-space-2); column-gap: 2%;`, collapsing to one column below 639px) — plus the grouped figure-fill selectors `#about .rs-figure, .showcase__cols .rs-figure` (and the matching `img` rule). The eight Proyectos/Libros cards render rows via the interim `showcase_row_card`; the four Juegos cards still render the vertical `showcase_card`.
- The revision folds Juegos into the same convention: all twelve cards render the row through one canonical `showcase_card` helper.
- The about CSS currently uses a 2% column gap while its comment and the archived spec say ~10%; per the confirmed decision, this change copies the current values and leaves that reconciliation as a flagged follow-up.
- The Juegos images are remote (`raw.githubusercontent.com`, `ninjas.cl/blog`) — their sources stay out of scope; the row layout renders remote images identically to local ones.

Routing, content files, and blogatto configuration are unaffected: this is view markup plus `static/style.css`, both of which blogatto already ships verbatim. No template or build changes.

## Goals / Non-Goals

**Goals:**

- All twelve showcase cards render one row: figure filling a left column at natural proportions, text (title, description, buttons) in the right column, collapsing to figure-first stacking on narrow viewports.
- One card helper with the canonical name renders every section; no layout variants remain.

**Non-Goals:**

- No change to any image's source, file, alt, or caption text; Juegos keeps its remote sources.
- No shared-class refactor of the about markup (`about__cols` stays as-is); no new dependency.

## Decisions

1. **One `showcase_card` helper with the row markup renders all twelve cards.** The games call sites already say `showcase_card(...)`, so the fold is: give `showcase_card` the row body (grid `showcase__cols` → figure + text column), delete `showcase_row_card`, and rename the eight proyectos/libros call sites back to `showcase_card`. Alternatives rejected: keeping two helpers (nothing renders the vertical layout anymore — dead code); keeping the `showcase_row_card` name as the only helper (the row layout is now *the* card layout, so the canonical name wins).
2. **The CSS shipped for proyectos/libros already covers Juegos without new rules**: games cards carry `showcase__cols`, so the existing grid and grouped figure-fill selectors apply automatically. Only the two comments claiming "Juegos cards keep the vertical layout" and "Juegos figures keep retrostrap's rs-figure sizing" need updating to match reality.
3. **Tests assert structure, order, and coverage**: exactly twelve `showcase__cols` rows (four per section — proving every section carries them), a games-row ordering assertion (the figure alt precedes its card title), a caption surviving, and the CSS rules present in `static/style.css` (read via `simplifile`, already a dev dependency).
4. **A uniform image box via the Super Club Net cover's ratio: `aspect-ratio: 1050 / 1600` + `object-fit: contain` on `.showcase__cols .rs-figure img`.** The box is exactly the height that cover renders at the same column width; since it is the tallest shipped ratio (h/w ≈ 1.524 — next tallest: elixir-fullstack at 1.50; widest: Munsta Jump! at 0.25), the box equals the requested minimum for every shipped image and nothing exceeds it. `object-fit: contain` centers and letterboxes undistorted, keeping the no-distortion principle. The `#about .rs-figure img` rule splits out of the grouped selector and keeps the natural-height presentation — the request scopes to the three showcase sections. Alternatives rejected: a percentage `min-height` (percentages don't resolve against auto-height grid rows), container-query `cqw` units (adds a containment context and support surface for no observable gain over the ratio box), a fixed pixel floor (cannot track the responsive column width).

## Risks / Trade-offs

- [Remote Juegos images present inside the uniform image box like the local images] → Same presentation either way; `loading="lazy"` and the global `img { max-width: 100% }` keep behavior unchanged, and their remote availability remains a separate, accepted concern (source scope).
- [Wide images letterbox heavily inside the tall box — Munsta Jump! (600×150) renders as a centered strip] → Accepted: uniform height is the explicit ask, and the centered strip reads as a framed tile under the retrostrap chrome.
- [The ratio constant (1050/1600) is tied to the Super Club Net cover file] → The rule's comment and the test pin the declaration; changing that cover's proportions requires a conscious CSS update.
- [The wide games captures make some cards taller than their text] → Accepted, the same trade-off the about row and the portrait covers already make; the grid sizes the row to the taller column.
- [Copying the about values means a future about-grid tweak won't propagate to cards] → Accepted per the confirmed decision; both rules sit adjacent in `style.css` with cross-referencing comments, and the about-spec gap reconciliation is already flagged as a follow-up.

## Migration Plan

1. Fold the helpers: `showcase_card` gets the row markup, `showcase_row_card` is deleted, and the eight call sites rename back.
2. Update the two `style.css` comments.
3. Update the tests to twelve rows with a games-row assertion.
4. Verify: `gleam format src test`, `gleam test`, `openspec validate showcase-cards-row-layout`.
5. Split the grouped img rule and give the showcase cards the Super Club Net ratio box; pin it with a test and re-verify.

Rollback: restore the vertical helper for games and switch its four calls back; the CSS already shipped covers both layouts, and the uniform box reverts with the img-rule split.
