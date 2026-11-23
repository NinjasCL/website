# Tasks

## 1. Style override

- [x] 1.1 Add a `.rs-panel__title` rule with `font-size: var(--rs-font-size-6)` to `static/style.css`, with a comment stating the ≥2× floor (2rem vs the 0.8125rem retrostrap panel-title default); verify the rule is present in `static/style.css` and that `static/retrostrap.min.css` is untouched.

## 2. Dev dependency

- [x] 2.1 Declare `simplifile` as a dev dependency with `gleam add --dev simplifile` (already locked via blogatto, so no new package or version enters the build); verify `gleam deps download` succeeds and only `gleam.toml`/`manifest.toml` changed (no hand edits to `manifest.toml`).

## 3. Regression tests

- [x] 3.1 Add a test that reads `static/style.css` (via `simplifile.read`) and asserts its `.rs-panel__title` rule sets `font-size: var(--rs-font-size-6)`, locking the ≥2× size floor; verify with `gleam test`.
- [x] 3.2 Add a test asserting the rendered home page contains exactly six `rs-panel__title` headers — the six sections, no leak into other headings; verify with `gleam test`.

## 4. Verification

- [x] 4.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 4.2 Run `gleam test` and confirm the whole suite passes.
- [x] 4.3 Run `openspec validate enlarge-section-headers` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`) to confirm the enlarged headers look right; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive enlarge-section-headers`.

## Revision (2026-11-20)

- Per the site owner's decision, the section header size was retuned from `--rs-font-size-6` (2rem, ≥2×) to `--rs-font-size-5` (1.5rem, ≈1.85×). The rule in `static/style.css`, its comment, the test assertion in `test/ninjas_test.gleam`, and this change's proposal, spec, and design were aligned to make 1.5rem the contract.
