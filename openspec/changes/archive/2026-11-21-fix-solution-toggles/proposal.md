# Proposal

## Why

The migrated post's "Mostrar solución" / "Show Solution" toggles are
broken: the djot raw-HTML fences put `<details>` in one block and
`</details>` in another, and blogatto wraps every raw block in its own
`<div>` — so the browser closes the `<details>` empty at the wrapper's
`</div>` and the code renders as a sibling, always visible. Clicking the
summary reveals nothing.

## What Changes

- Collapsible solutions are declared on the code fence itself, in djot's
  attribute syntax: ```` ```go {summary="Mostrar solución"} ````. The
  site's `code` component reads the summary from the fence's info string
  and wraps the highlighted block in a real `<details><summary>`
  element — one well-formed toggle per block, with the code inside it.
- Highlighting is unaffected: the info string reaches the component as
  the "language" (`go {summary="Mostrar solución"}`) and blogatto's
  grammar lookup already takes the leading token, so `go` and `elixir`
  still tokenize.
- The migrated post's two variants replace their `` ``` =html `` fences
  with summary-carrying `go` and `elixir` fences; the Elixir section's
  two code blocks merge into one fence so the section keeps its single
  "Mostrar solución" / "Show Solution" toggle, as in the original post.
- AGENTS.md's migration conventions drop the now-disproven
  `` ``` =html `` guidance and record the fence-attribute form.

Out of scope:

- No new styling for the toggles — the summary line renders inside the
  Night Owl panel with the site's mono font, and the browser's default
  disclosure triangle serves as the toggle.
- No change to any other use of raw HTML (none exists in the content
  today) and no `pre` wrapper changes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Collapsible solution code blocks" — a
  code fence carrying a `{summary="…"}` attribute renders as a working
  details/summary toggle around its (highlighted) code.

## Impact

- `src/ninjas/highlight.gleam`: the code component reads the fence
  attribute (`fence_summary`) and wraps the block in `details`/`summary`;
  the `<code>` class keeps the bare language token.
- `blog/advent-of-code-in-onyx-day-01/`: `index.djot` and `index-en.djot`
  swap the raw fences for summary-carrying fences, merging the Elixir
  blocks.
- `test/ninjas_test.gleam`: component tests for the toggle (and the
  still-working highlighting), migration-test assertions updated to the
  new fence form.
- `AGENTS.md`: the migration bullet's conversion guidance.
- No dependency or blogatto changes.
