# Tasks

## 1. Card row styling

- [x] 1.1 Add a `.showcase__cols` rule to `static/style.css` mirroring the about grid exactly (`grid-template-columns: 3fr 6fr; gap: var(--rs-space-2); column-gap: 2%;` plus the `@media (max-width: 639px)` single-column collapse), with a cross-referencing comment; verify the rule is present and the `.about__cols` values are unchanged.
- [x] 1.2 Extend the about figure-fill treatment to card rows by grouping the selectors: `#about .rs-figure, .showcase__cols .rs-figure` (and the matching `img` rule for `width: 100%; height: auto`); verify the grouped selectors appear in `static/style.css`.

## 2. Row cards and tests

- [x] 2.1 Add a `showcase_row_card` helper in `src/site.gleam` — `article.rs-panel` wrapping a `showcase__cols` grid of the `rs-figure` (image + "Desde …" caption) and a text column (`h3` title, description, buttons) — and use it for the four "Proyectos" and four "Libros" cards, leaving `showcase_card` (games) untouched. Verify with the tests added in 2.2.
- [x] 2.2 Add tests in `test/ninjas_test.gleam`: the rendered home page contains exactly eight `showcase__cols` rows (proyectos + libros, none in juegos), each card's figure alt precedes its card title, a caption survives, and `static/style.css` (via `simplifile.read`) contains the `.showcase__cols` rule and the grouped figure selectors; verify with `gleam test`.

## 3. Checks

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate showcase-cards-row-layout` and confirm it passes.

## Revision (2026-11-20)

- Per the site owner's decision, the row convention extends to the Juegos section: all twelve showcase cards render the row structure through one canonical `showcase_card` helper. The delta specs, proposal, and design were revised accordingly — the Juegos-vertical guard and the two games-sizing guard clauses are removed as superseded. Juegos image sources stay remote, out of scope.
- Also per the site owner: every showcase card's image box takes the Super Club Net container height as a uniform minimum — shorter or wider images letterbox undistorted. The `site-showcase-cards` delta, proposal, and design were revised again; the about portrait keeps its natural height.

## 4. Juegos row cards

- [x] 4.1 Fold the two card helpers into one `showcase_card` with the row markup (delete the vertical variant and `showcase_row_card`, and rename the eight proyectos/libros call sites back) so all twelve cards — proyectos, libros, and juegos — render the row; update the two `style.css` comments that still say Juegos keeps the vertical layout. Verify with the tests updated in 4.2.
- [x] 4.2 Update the row test: twelve `showcase__cols` rows across the three sections, with a games-row ordering assertion (figure alt before its card title); verify with `gleam test`.

## 5. Checks (revision)

- [x] 5.1 Run `gleam format src test` and confirm `gleam format --check src test` passes.
- [x] 5.2 Run `gleam test` and confirm the whole suite passes.
- [x] 5.3 Run `openspec validate showcase-cards-row-layout` and confirm it passes.

## 6. Uniform image box height

- [x] 6.1 Split the grouped img rule in `static/style.css`: keep `#about .rs-figure img` at natural proportions, and give `.showcase__cols .rs-figure img` the Super Club Net ratio box (`aspect-ratio: 1050 / 1600; object-fit: contain`) with an explanatory comment; verify with the tests added in 6.2.
- [x] 6.2 Add a test asserting `static/style.css` carries the showcase img box rule (`aspect-ratio: 1050 / 1600` and `object-fit: contain`) and no longer groups the about img rule with it; verify with `gleam test`.

## 7. Checks (uniform height)

- [x] 7.1 Run `gleam format src test` and confirm `gleam format --check src test` passes.
- [x] 7.2 Run `gleam test` and confirm the whole suite passes.
- [x] 7.3 Run `openspec validate showcase-cards-row-layout` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`): all three showcase sections present image-left/text-right rows with uniform-height image boxes; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive showcase-cards-row-layout`.
