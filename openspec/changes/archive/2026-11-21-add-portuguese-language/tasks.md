# Tasks

## 1. Portuguese (Brazil) language and content

- [x] 1.1 Add the Portuguese (Brazil) entry to `site_languages` in `src/site.gleam` — code `pt`, name "Português (Brasil)", machine-translated with its Brazilian-Portuguese warning text, `og_locale: "pt_BR"` — and extend the template tests: the options row shows four entries ending in the linked "Português (Brasil)", the pt page carries its translation warning and `lang="pt"`, and og:locale renders `pt_BR`; verify `gleam test` passes with all of them.
- [x] 1.2 Ship `blog/bienvenidos-a-ninjas-cl/index-pt.djot` — same slug, date, and featured image as the original, translated title, description, and body in djot (single-asterisk strong); verify the blog-sources test extended to the fourth variant passes.
- [x] 1.3 Update AGENTS.md's site-languages row and blog-content conventions to include Portuguese (Brazil); verify the row reads `es (default), en, ja, pt`.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-portuguese-language` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the Portuguese post page at `/blog/pt/bienvenidos-a-ninjas-cl/` renders with the four-entry options row, its machine-translation warning, `lang="pt"`, and `og:locale` `pt_BR` — and that the other three variant pages gained the "Português (Brasil)" option.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-portuguese-language`).
- Archive the change (`openspec archive add-portuguese-language`) and verify the archived result.
