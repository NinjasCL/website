# Tasks

## 1. The clause in every language

- [x] 1.1 In `src/site.gleam`, change the Spanish clause constant to `copyright_rights_es = "Todos los derechos e izquierdos preservados"` (mirroring the English "preserved"); in `src/ninjas/home.gleam`, set `japanese_text.copyright_rights` to "すべての権利と左派を保全" and `portuguese_text.copyright_rights` to "Todos os direitos e esquerdos preservados" (inline, replacing the English constant), leaving `spanish_text` and `english_text` as they are; verify `gleam build` passes.
- [x] 1.2 Update `test/ninjas_test.gleam`: the footer test's copyright line asserts " · Todos los derechos e izquierdos preservados" on the home and post page, and the translated-home test asserts each home's own clause — `html |> string.contains(" · " <> text.copyright_rights)` — replacing the blanket English-clause assertion, so the English home keeps "All rights and lefts preserved" and the Japanese and Portuguese homes assert their clauses; verify `gleam test` passes.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate translate-copyright-clause` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm: the Spanish home, a post page, the blog index, and the 404 show "Todos los derechos e izquierdos preservados"; `/en` shows "All rights and lefts preserved"; `/ja` shows "すべての権利と左派を保全"; and `/pt` shows "Todos os direitos e esquerdos preservados" — the "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix everywhere.

## Workflow follow-up

- Sync the delta specs into the main specs (`openspec sync translate-copyright-clause`).
- Archive the change (`openspec archive translate-copyright-clause`) and verify the archived result.
