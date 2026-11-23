# Tasks

## 1. Working solution toggles

- [x] 1.1 Extend `src/ninjas/highlight.gleam`'s code component: parse the `{summary="…"}` attribute from the fence's info string (`fence_summary`), derive the `<code>` class from the bare language token, and wrap the block in `details`/`summary` when a summary is declared — highlighting and the plain fallback untouched; verify `gleam test` passes with component tests asserting a `go {summary="Mostrar solución"}` fence renders `<details><summary>Mostrar solución</summary><code class="language-go">` with smalto tokens inside, unknown-language and untagged fences keep their current rendering, and blocks without the attribute carry no toggle.
- [x] 1.2 Rework both variants of `blog/advent-of-code-in-onyx-day-01/`: drop every `` ``` =html `` fence, tag the Onyx `go` fence and the merged Elixir fence (both modules in one block) with `{summary="Mostrar solución"}` in `index.djot` and `{summary="Show Solution"}` in `index-en.djot`; verify the migration test's raw-fence assertions are replaced by the new fence forms and no `=html` or `<details>` markup remains in either source.
- [x] 1.3 Update AGENTS.md's migration conventions: collapsible solutions use the fence attribute form (`` ```go {summary="…"} ``), not `` ``` =html `` raw fences, which blogatto wraps in divs and thereby breaks; verify the bullet reads back.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate fix-solution-toggles` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm, on both variants, the structure is `<pre><details><summary>Mostrar solución</summary><code class="language-go">…</code></details></pre>` — the highlighted code inside the `details`, one toggle for Onyx and one for the merged Elixir blocks — a structural check, not a string-presence check.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync fix-solution-toggles`).
- Archive the change (`openspec archive fix-solution-toggles`) and verify the archived result.
