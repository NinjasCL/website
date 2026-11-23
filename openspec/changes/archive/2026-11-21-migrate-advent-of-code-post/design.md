# Design

## Context

See proposal.md — Why. The old source at
`old/sources/blog/advent-of-code-in-onyx-day-01/` is a `*.md.eex` file with
JSON frontmatter and a plain-markdown body (no actual EEX directives), an
`assets/cover.jpg`, `input.txt`, and `main.onyx`. blogatto groups every
file under a post directory into sources versus assets
(`internal/builder/post.gleam`), and copies assets into the post's output
directory **by base name** — subdirectory structure is flattened. The
frontmatter date parser accepts `YYYY-MM-DD HH:MM:SS` with an optional
`±HH:MM` offset. jot renders djot `{=html}` raw blocks as pass-through HTML
via `element.unsafe_raw_html`.

## Goals / Non-Goals

**Goals:**

- A faithful migration: every paragraph, code block, and solution toggle of
  the old post, in Spanish as the default and English as the `en` variant,
  with the companion files served beside the page.
- The owner's English-origin rule applied and documented for the next
  migrations.

**Non-Goals:**

- No other posts, no ja/pt variants for this post, no redirects, no view
  code changes (proposal.md — out of scope).

## Decisions

1. **Flat post directory.** blogatto copies assets by base name, so
   `assets/cover.jpg` would land flattened as `…/cover.jpg` anyway; keeping
   the source flat (`cover.jpg`, `input.txt`, `main.onyx` beside the djot
   sources) makes the served output match the source 1:1 and lets the body
   reference the cover relatively (`cover.jpg` resolves against the post
   page's URL).

2. **The language mapping follows the owner's rule.** The Spanish
   translation is the default `index.djot` (no warning, home-listed); the
   original English ships as `index-en.djot` with the automatic
   machine-translated warning. Both share the slug, so each page's options
   row links the other. The site's per-language machinery needs no changes.

3. **The djot conversion is mostly syntax-preserving.** Markdown links,
   fenced code blocks, and inline code spans are djot syntax already. The
   three real conversions: `<details>/<summary>` blocks become `` ```{=html} ``
   raw fences (three raw blocks around each code block — jot renders
   `RawBlock` as pass-through HTML); the old `[`~~` Operator]()` link with
   an empty destination becomes a plain `` `~~` `` code span; and the cover's
   Wikimedia attribution, previously the alt text, becomes a visible
   "Imagen: …" link beside a properly-alt-texted image.

4. **The original publication date is preserved** (`2024-12-04 15:14:22
   +00:00`, the old UTC `published_at`). The post is therefore older than
   the 365-day threshold and renders the staleness warning with its day
   count — the designed behavior for aged content, and a live
   demonstration of the feature on a real post.

5. **`featured_image` uses the copied cover's absolute path**
   (`/blog/advent-of-code-in-onyx-day-01/cover.jpg`): the masthead cover
   renders it on the post page and the home featured row would need it to
   resolve from the home URL too, so relative is not an option there. The
   old tags' "avent of code" typo is corrected to "advent of code".

6. **No new dependency.** Conversion is manual authoring; jot's raw blocks
   and blogatto's asset copying are stock behavior.

## Risks / Trade-offs

- [The old `assets/…` URLs break] → The old site is archived under `old/`;
  no redirect layer exists and none was requested — recorded as a known
  gap if inbound links matter later.
- [The Spanish default is a machine translation of a human English
  original] → The owner's explicit rule accepts this framing: after
  migration the Spanish page is the canonical presentation and the English
  page warns like every non-default variant.
- [Translation drift in the long Advent of Code narrative] → The
  translation preserves every section, example, and solution verbatim in
  structure; only prose is translated, code blocks stay untouched.

## Migration Plan

None. The post is additive content; existing pages, URLs, and tests are
untouched except for the home "Más entradas" list gaining the post.
Rollback is removing the directory and rebuilding.
