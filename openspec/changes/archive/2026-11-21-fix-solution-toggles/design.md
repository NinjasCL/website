# Design

## Context

See proposal.md — Why. The migrated post's toggles are structurally
broken: blogatto's djot renderer maps each `` ``` =html `` raw block to
`element.unsafe_raw_html("", "div", [], content)`, so `<details>` opens
inside a wrapper div and the parser closes it (implicitly, at `</div>`)
before the code block — the code is a sibling and the toggle is an empty
shell. The raw-fence approach cannot span a code block. Meanwhile the
fence's info line travels intact: jot hands the whole trimmed line to the
component as the "language" (e.g. `go {summary="Mostrar solución"}`),
and blogatto's grammar lookup already strips it to the leading token
(`language_token` drops everything from the first space or colon) — so a
summary attribute costs the highlighting nothing.

## Goals / Non-Goals

**Goals:**

- Working toggles, one well-formed `details` per collapsible block, with
  highlighting intact.
- The content convention documented so future migrations use the fence
  attribute, not raw fences.

**Non-Goals:**

- No toggle styling, no multi-block grouping mechanism, no raw-HTML
  rehabilitation (proposal.md — out of scope).

## Decisions

1. **The component owns the toggle.** `code_component` gains
   `fence_summary(language)` — it finds `summary="` in the info string
   and reads to the closing quote (the value may contain spaces, like
   "Mostrar solución"). When present, the block's `<code>` element is
   wrapped: `details([summary([text]), code])`. The `details` opens and
   closes around the code in one element tree, so no parser recovery is
   involved — the toggle works by construction.
   *Alternative considered:* fixing the raw-fence split (rejected: the
   div wrapper is blogatto-internal; spanning is impossible without
   forking the renderer).

2. **The `<code>` class keeps the bare language token.** The info string
   is now attribute-laden, so the component derives the class name from
   the token before the first space or colon — mirroring blogatto's own
   `language_token` — instead of stamping the whole line into
   `language-go {summary="…"}`.

3. **The toggle renders inside the block's `pre` panel.** The djot
   renderer wraps the component's output in the components' `pre`
   unconditionally, giving `<pre><details><summary>…</summary><code>…`
   . That keeps the Night Owl panel, mono font, and panel padding around
   the collapsed line — a collapsed solution reads as a one-line panel
   with the summary and the browser's disclosure triangle, and expanding
   reveals the code in place. Valid markup, no CSS changes needed.
   *Alternative considered:* overriding the `pre` component to unwrap
   (rejected: the panel styling and mono font all hang off `.post-body
   pre`).

4. **The Elixir section's two blocks merge into one fence.** The original
   post wrapped both Elixir modules in a single toggle; per-block
   toggles would show two identical "Mostrar solución" lines. One
   `{summary}` fence with both modules, separated by a blank line, keeps
   the original single toggle.

5. **No new dependency; nothing outside the component and content.**

## Risks / Trade-offs

- [Info strings with `summary="` inside a code sample] → The parser reads
  to the first closing quote; a code fence whose *language token*
  contains the marker would misfire — no such fence exists, and the
  content convention documents the form.
- [A future grammar named like the attribute] → The summary wrap is
  independent of the grammar lookup: unknown languages fall back to the
  plain code inside the toggle.
- [Toggle inside `pre` is unusual markup] → Valid HTML; browsers render
  and toggle it; verified in the built output at apply time.

## Migration Plan

The broken fences are replaced in both variants of the migrated post;
nothing else uses `` ``` =html `` today. Rollback is reverting the
commit and rebuilding.
