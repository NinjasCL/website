# Tasks

## 1. Style rule

- [x] 1.1 Add the home sections' clearance rule to `static/style.css` — an id-list selector (`#about`, `#posts`, `#projects`, `#books`, `#games`, `#contact`) setting `margin-top: var(--rs-space-5)`, with an explanatory comment, placed beside the `#blog` rule it mirrors; verify the rule is present and `static/retrostrap.min.css` is untouched.

## 2. Regression test

- [x] 2.1 Add a test that reads `static/style.css` (via `simplifile.read`) and asserts the home sections' clearance rule ships — the id list and `margin-top: var(--rs-space-5)` — following the section-header size test's pattern; verify with `gleam test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate home-section-top-margin` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`task dev`) to confirm the sections breathe; keep the dev server out of committed changes.
- Sync the delta spec into the main specs, then archive the change once review requirements are satisfied.
