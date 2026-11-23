# Design

## Context

See proposal.md - Why. blogatto 8 discovers post sources by extension — `.md` renders through its markdown source format (mork), `.dj`/`.djot` through its djot source format (jot, already locked at 12.x as a transitive dependency). Frontmatter is parsed format-agnostically before the body render; the djot renderer strips the `---` block itself. The current post body is markdown-flavored: only `**Ninjas.cl**` differs from djot, whose strong emphasis is single asterisks (`*Ninjas.cl*`) with `_underscores_` for regular emphasis (see `examples/djot/doc/syntax.md`).

## Goals / Non-Goals

**Goals:**
- One content syntax, enforced by convention and pinned by the spec.
- The shipped post renders identically after conversion (same HTML for heading, strong, and links).
- Contributors find both references without leaving the repo: djot syntax and the blogatto engine docs.

**Non-Goals:**
- No `src/` changes — the engine already parses djot natively.
- No linting or CI enforcement of the syntax rule beyond the test that pins the shipped state.

## Decisions

1. **Extension: `.djot` over `.dj`.** blogatto accepts both; the long form names the format explicitly, which is what the convert-don't-add convention needs a contributor to see. Recorded here so apply does not relitigate it.
   - Alternative rejected: `.dj` — shorter, but opaque to anyone who has not read this design.

2. **Conversion is minimal and verifiable.** Rename `index.md` → `index.djot`, rewrite `**Ninjas.cl**` as `*Ninjas.cl*`; every other construct in the post (`## heading`, `[link](url)`, paragraphs, emoji) is valid djot as-is. Frontmatter stays untouched. Verification: build the site and confirm the generated post page renders `<strong>Ninjas.cl</strong>` and the existing heading/link output, plus the updated test suite.

3. **No new dependency.** blogatto's djot support is the existing feature this change selects — the design rule to justify new dependencies does not trigger; `jot` is already in the lock as blogatto's parser.

4. **AGENTS.md placement: the tech-stack table.** A "Blog content" row (syntax djot, `.djot`, convert-don't-add) with the two reference locations keeps the convention where agents read the stack summary, rather than burying it in the conventions list.

## Risks / Trade-offs

- [Markdown habits produce djot-invalid constructs (e.g. `**bold**`)] → The AGENTS.md row points at the cheatsheet and the quickstart-for-markdown-users page in `examples/djot/doc`; the spec's conversion duty makes the expectation explicit.
- [blogatto's markdown format remains available for stray `.md` files] → The spec's requirement and the test pin the shipped no-`.md` state; the convention covers future additions.
