# Tasks

## 1. Align the about row test with the shipped copy

- [x] 1.1 Update `home_view_renders_about_row_test` in
  `test/ninjas_test.gleam` to pin the shipped copy per the delta spec:
  the caption assertion moves from "Camilo Castro — Software Engineer"
  to "@CLSource — Software Engineer" (with the former caption absent),
  the section-text assertion moves from "Ninja Systems es un grupo" to
  the first-person opening "Ninjas es un grupo experimental" (with the
  former third-person opening absent), and the values line
  ("Nos gusta crear artefactos hermosos…") and the closing
  "Puedes encontrarnos en GitHub" link to `https://github.com/ninjascl`
  are asserted after the portrait. The markup itself already ships in
  `src/site.gleam` and needs no edit. Verify with `gleam test`: the
  suite goes from one failing test to fully green.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate rewrite-about-copy` and confirm it passes.

## Workflow follow-up

- After review, sync/archive the change with the
  `openspec-archive-change` workflow; when summarizing, carry the
  follow-up gaps noted in the proposal's Out of scope: the unpinned
  `site_description` constant and the `site-masthead` home-hero
  scenario that still mentions call-to-action links the hero no longer
  renders.
- The `trim-footer` copyright-line wording ("All rights and lefts
  preserved") was corrected in that change's artifacts outside this
  delta; archive `trim-footer` as its own step.
