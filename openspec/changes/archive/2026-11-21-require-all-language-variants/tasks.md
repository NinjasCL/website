# Tasks

## 1. Full language coverage

- [x] 1.1 Write `blog/advent-of-code-in-onyx-day-01/index-ja.djot` — the full Japanese translation of the Spanish canonical: translated title ("Advent of Code — 1日目の解答"), description, narrative, section headings, solution credits, and toggle labels (`{summary="解答を表示"}` on the `go` and merged `elixir` fences), sharing the original's slug, date, and featured image with the code blocks untouched; verify `gleam test` passes with the completeness test below covering it.
- [x] 1.2 Write `blog/advent-of-code-in-onyx-day-01/index-pt.djot` — the full Brazilian Portuguese translation of the Spanish canonical: translated title ("Advent of Code — Solução do Dia 01"), description, narrative, and toggle labels (`{summary="Mostrar solução"}`), same shared frontmatter; verify the same way.
- [x] 1.3 Add the every-post completeness test to `test/ninjas_test.gleam` — every post directory under `blog/` ships `index.djot`, `index-en.djot`, `index-ja.djot`, and `index-pt.djot`, all four sharing one slug — and record the mandate in AGENTS.md's content conventions (a post missing any of its four variants is incomplete); verify `gleam test` passes with it.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate require-all-language-variants` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm every post page — both posts, all four variants each — renders the full four-entry options row, the non-Spanish pages carry their machine-translated warning, `lang`, and `og:locale`, and the sitemap lists all eight post URLs.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync require-all-language-variants`).
- Archive the change (`openspec archive require-all-language-variants`) and verify the archived result.
