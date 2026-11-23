# Tasks

## 1. Container wash

- [x] 1.1 Add the themed rule to `static/style.css` — `html[data-rs-theme="cosmic"] .rs-page { background: rgba(33, 4, 49, 0.945); }` — with a comment naming the old stylesheet's `.violet-frame` as the source of the ~5%-transparency wash; verify the rule is present and that no `--rs-` token override is added (test in 2.1 locks both).

## 2. Tests

- [x] 2.1 Add a test asserting `static/style.css` carries the cosmic container wash (the exact `rgba(33, 4, 49, 0.945)` under the themed `.rs-page` selector) and contains no `--rs-` token override; verify with `gleam test`.

## 3. Checks

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate page-container-violet-wash` and confirm it passes.

## Revision (2026-11-20)

- Per the site owner: the main container's border becomes dashed in the old website's violet (`#7540bd`) at retrostrap's existing 2px — the other half of the old `.violet-frame` recipe, joining the wash already shipped. The spec, proposal, and design were revised accordingly; only the main container's border changes, no other element's.

## 4. Dashed container border

- [x] 4.1 Extend the themed `.rs-page` rule in `static/style.css` with `border-style: dashed; border-color: #7540bd;` (keeping retrostrap's 2px width, updating the rule's comment to name the full old `.violet-frame` recipe) and extend the wash test to pin the dashed violet border; verify with `gleam test`.

## 5. Checks (revision)

- [x] 5.1 Run `gleam format src test` and confirm `gleam format --check src test` passes.
- [x] 5.2 Run `gleam test` and confirm the whole suite passes.
- [x] 5.3 Run `openspec validate page-container-violet-wash` and confirm it passes.

## Workflow follow-up

- Eyeball the home page in a browser (`gleam run`): the random tile pattern faintly ghosts through the container behind the content, and the container's frame reads as the old website's dashed violet; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive page-container-violet-wash`.
