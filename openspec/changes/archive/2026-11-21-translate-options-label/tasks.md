# Tasks

## 1. Per-language options row label

- [x] 1.1 Add the `options_label` field to `SiteLanguage` ("Idiomas" for Spanish and Portuguese (Brazil), "Languages" for English, "言語" for Japanese) and render the current page's label in `language_options` instead of the hardcoded "Idiomas"; verify `gleam test` passes with the options-row test extended — the Spanish and Portuguese pages label the row "Idiomas:", the English page "Languages:", the Japanese page "言語:", and the Spanish label appears on neither the English nor the Japanese page.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate translate-options-label` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm each variant page's options row carries its own language's label in the generated markup.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync translate-options-label`).
- Archive the change (`openspec archive translate-options-label`) and verify the archived result.
