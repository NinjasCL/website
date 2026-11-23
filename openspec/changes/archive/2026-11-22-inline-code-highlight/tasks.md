# Tasks

## 1. Code component behavior

- [x] 1.1 Change `code_component`'s no-language branch to emit a bare `<code>` span, and verify `inline_code_stays_a_bare_span_test` passes with `gleam test`.
- [x] 1.2 Add `pre_component` that wraps only a bare `code` child in a `<pre>` panel, and verify `pre_component_wraps_only_untagged_blocks_test` covers untagged fences, tagged blocks, summary toggles, and embeds with `gleam test`.

## 2. Configuration and presentation

- [x] 2.1 Register `post.pre(highlight.pre_component)` in `blog.gleam`, and verify with `gleam run` that a known post renders inline code as `<code>` while untagged fences stay inside `<pre>`.
- [x] 2.2 Style `.post-body :not(pre) > code` with `#fafafa` text on `#7540bd` and the JetBrains Mono family, and verify `inline_code_highlight_ships_test` passes with `gleam test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and `gleam format --check src test` so formatting stays green in CI.
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate 2026-11-22-inline-code-highlight` and confirm the change artifacts are valid.

## Workflow follow-up

- Sync the delta spec into main specs.
- Archive the change after verification.
