# Tasks

## 1. Highlighting component and styles

- [x] 1.1 Create `src/ninjas/highlight.gleam` — `code_component(syntax)` returning the djot `code` component: source extraction (per-child `element.to_string`, joined, `unescape_html` with `&amp;` last), `code.highlight` for tagged blocks with a recognized language, `<code class="language-{lang}">` with token spans on success, plain `<code>` fallback otherwise — and wire it in `src/ninjas/blog.gleam` by building the syntax configuration once and passing `highlight.code_component(syntax)` to `post.code`; verify `gleam test` passes with component tests asserting `go` and `elixir` blocks render `smalto-*` token spans, untagged and unknown-language blocks render plain, and `&`/`<`/`>` survive the extraction round-trip.
- [x] 1.2 Add the smalto token color rules to `static/style.css` (the documented minimal dark theme — keyword, string, number, comment, function, operator, punctuation, type, module, variable, constant, builtin, tag, attribute, selector, property, regex); verify with stylesheet assertions in the test (the presentation contract lives in the static asset, like the banner wall's).
- [x] 1.3 Note the highlighting behavior in AGENTS.md's blog content conventions — djot code blocks tagged with a smalto-default language highlight at build time via the site's `code` component; verify the bullet reads back.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-code-highlighting` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the migrated post's `go` and `elixir` blocks render smalto token spans with the stylesheet's colors, its `text` example blocks stay plain, and the relaunch post's markup is otherwise unchanged.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-code-highlighting`).
- Archive the change (`openspec archive add-code-highlighting`) and verify the archived result.
