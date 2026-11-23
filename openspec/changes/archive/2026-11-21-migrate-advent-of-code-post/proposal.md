# Proposal

## Why

The ninjas.cl catalog lives in `old/sources/blog` while the new engine ships
only the relaunch post. Migrating one post proves the whole pipeline —
content conversion (the old `*.md.eex` files are plain markdown), post
images, and post-adjacent files like `input.txt` and `main.onyx` — before
the rest of the catalog moves.

## What Changes

- `advent-of-code-in-onyx-day-01` migrates under the site owner's rule for
  posts originally written in English: a **Spanish translation** becomes
  the default variant (`index.djot`, no translation warning, listed on the
  home page, at `/blog/advent-of-code-in-onyx-day-01/`), and the
  **original English content ships as the English variant**
  (`index-en.djot`, at `/blog/en/…`, carrying the standard
  machine-translated warning, linked from the language options row).
- The post-adjacent files move flat into the post directory:
  `assets/cover.jpg` → `cover.jpg`, plus `input.txt` and `main.onyx` —
  blogatto copies such files into the post's output directory by base
  name, so the flat source layout matches the served output 1:1.
- The markdown body converts to djot: links and fenced code blocks map
  directly; the `<details>/<summary>` solution toggles become djot
  `{=html}` raw blocks (jot renders them through); the empty `[]()` link
  becomes a plain code span; the cover's Wikimedia attribution becomes a
  visible link beside the image instead of alt-text-as-URL.
- The JSON frontmatter converts to blogatto's, preserving the original
  `2024-12-04` publication date (so the staleness warning renders on the
  post, by design) and pinning `featured_image` to the copied cover's
  absolute path — which also gives the post page its first real masthead
  cover. The old tags' "avent of code" typo is fixed.
- AGENTS.md records the English-origin rule as the standing convention
  for future migrations.

Out of scope:

- No other old posts — each later migration is its own change.
- No Japanese or Portuguese variants for this post; its options row shows
  the two shipped variants.
- No `src/` changes — the views already render the cover, options row,
  warnings, and staleness notice; and no redirects from the old site's
  URLs.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post-adjacent files ship with the post" —
  the site's first use of blogatto's per-post asset channel, pinned as
  observable behavior.
- `site-post-languages`: ADDED "Migrated English-origin posts" — the
  owner's rule: the English original ships as the English variant with the
  translation warning, its Spanish translation as the warning-free default.

## Impact

- `blog/advent-of-code-in-onyx-day-01/`: `index.djot`, `index-en.djot`,
  `cover.jpg`, `input.txt`, `main.onyx` (copied from
  `old/sources/blog/advent-of-code-in-onyx-day-01/`).
- `test/ninjas_test.gleam`: a migration test covering the files, the djot
  conventions, and the shared slug.
- `AGENTS.md`: the blog-content conventions gain the English-origin rule.
- No dependency, routing, or view changes.
