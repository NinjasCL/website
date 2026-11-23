# Tasks

## 1. Footer trim

- [x] 1.1 Rewrite `site_footer/0` in `src/site.gleam` to keep only the
  copyright line ("Copyright 🥷🏽 Ninjas.cl © 2015–2026 · All rights
  and lefts preserved") and the `^ volver arriba ^` back-to-top link targeting
  `#masthead`, deleting the Chile WebRing bar, the "Desde 2015 · Hecho a
  mano en Chile 🇨🇱" line, and the badges paragraph ("source code" /
  "written by human"). The `html.footer` element keeps its `rs-footer`
  class. Verify with `gleam test` once 1.2 lands, or by rendering
  `site.home_view([])` and observing the trimmed footer.
- [x] 1.2 Add a footer test in `test/ninjas_test.gleam` pinning the trim:
  "Chile WebRing", "Ir a un sitio aleatorio", "webri.ng", "rs-webring-bar",
  "Hecho a mano en Chile", "source code", "written by human", and
  `rs-button88` are all absent from the home markup, while the `rs-footer`
  element, the copyright line, and the `href="#masthead"` back-to-top link
  remain; the single post page keeps its own footer line
  ("Ninjas.cl — Desde 2015"). Verify with `gleam test`.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate trim-footer` and confirm it passes.

## Workflow follow-up

- After review, sync the deltas into the main specs and archive the change
  with the `openspec-archive-change` workflow.
- Summarize what shipped and any follow-up gaps against the specs when
  archiving.
