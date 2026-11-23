# Tasks

## 1. The Spanish strings

- [x] 1.1 In `src/site.gleam`, parameterize the copyright clause: add the Spanish clause constant `copyright_rights_es = "Todos los derechos e izquierdos reservados"` and the English one the translated homes keep (`copyright_rights_en = "All rights and lefts preserved"`), change `site_footer` to take the clause beside the back-to-top label, and thread the Spanish clause through the internal callers (post template, blog index, not-found); in `src/ninjas/home.gleam`, add the `copyright_rights` field to `HomeText` — Spanish on `spanish_text`, English on the other three records — and set `spanish_text.tagline` to "Software de 🇨🇱 con ❤️"; verify `gleam build` passes.
- [x] 1.2 Update `test/ninjas_test.gleam`: the footer test asserts the Spanish clause ("Todos los derechos e izquierdos reservados") on the home and the post page, the kept-emoji test asserts the "Software de 🇨🇱 con ❤️" tagline, and the translated-home test keeps asserting the English clause on `/en`, `/ja`, `/pt`; verify `gleam test` passes.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate translate-spanish-tagline-copyright` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm: the Spanish home shows "Software de 🇧🇱 con ❤️" and the Spanish clause, a post page and the blog index show the Spanish clause, and the translated homes keep the English clause.

## Workflow follow-up

- Sync the delta specs into the main specs (`openspec sync translate-spanish-tagline-copyright`).
- Archive the change (`openspec archive translate-spanish-tagline-copyright`) and verify the archived result.
