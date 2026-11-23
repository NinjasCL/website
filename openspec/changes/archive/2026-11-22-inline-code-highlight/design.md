# Design

## Context

See `proposal.md` for motivation. Blogatto's djot renderer sends inline code to `post.code` with no language and no `post.pre` call, and sends every fenced block to `post.pre` with the result of `post.code`. The site's content-block component in `src/ninjas/highlight.gleam` currently wraps the no-language case itself in `<pre><code>`, so inline spans become block panels. `src/ninjas/blog.gleam` registers that component and currently uses a pass-through `post.pre`. No routes, content files, or templates change; every post page and language variant gets the same rendering path.

## Goals / Non-Goals

**Goals:**
- Keep inline code a bare `code` span that flows in the paragraph, with the violet highlight and JetBrains Mono face.
- Preserve the existing block presentation: Night Owl panels for tagged and untagged fences, `details`/`summary` toggles, and the four embed fence cards.
- Keep the build-time highlighter and all four language variants untouched.

**Non-Goals:**
- Changing fenced block highlighting, token palette, embed payloads, post content, routing, or page templates.
- Adding a client-side script or a new dependency.

## Decisions

- **Split block structure between `code` and `pre`.** `post.code` emits a bare `code` for the no-language case; the new `pre_component` adds the `pre` wrapper only when djot calls `pre` with a bare `code` element. Tagged panels, summary toggles, and embeds already carry their own structure and pass through. Alternative: guessing inline vs block in `post.code` from the child text (e.g. a trailing newline) — rejected as a brittle heuristic; djot's `pre` call is the reliable signal, and blogatto does not expose an inline-vs-block flag on `post.code`.
- **Style via a selector, not markup classes.** `.post-body :not(pre) > code` targets only inline spans, so fenced code keeps its Night Owl panel and the shared `.post-body pre, .post-body code` font rule still supplies JetBrains Mono. Alternative: adding a class in `post.code` — unnecessary, since `pre` already distinguishes the two cases structurally.
- **No new dependency.** blogatto's `post.code`/`post.pre` extension points and the existing stylesheet are sufficient; no existing blogatto feature renders inline code with the site's violet highlight.

## Risks / Trade-offs

- [The `pre` wrapper check inspects the rendered child element] → Keep the check limited to a single `<code`-prefixed child, matching djot's one-code-element `pre` call; tests pin that tagged panels, toggles, and embeds are not re-wrapped.
- [Existing posts contain inline backticks in all four language variants] → The change is in the shared render path, so every variant benefits without content edits; the production build is checked against a known inline-span post.
- [CI checks must stay green] → Run `gleam format src test` and `gleam test` before finishing; no dependency or CI version changes.
