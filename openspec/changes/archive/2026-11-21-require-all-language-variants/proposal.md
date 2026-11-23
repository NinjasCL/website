# Proposal

## Why

The language system grew one variant at a time: the relaunch post ships
all four languages, but the migrated Advent of Code post ships only its
Spanish default and English original — a visitor on the post's options
row finds Japanese and Portuguese missing. The owner now mandates full
coverage: every post carries every declared language, Spanish as the
human-written original and the rest as machine translations with their
warnings.

## What Changes

- The language configuration requirement strengthens: every post SHALL
  ship a variant for each declared language — `index.djot` (Spanish,
  human-written) beside `index-en.djot`, `index-ja.djot`, and
  `index-pt.djot` (machine-translated, each rendering its warning
  automatically), all sharing the slug so every post page's options row
  offers the full set.
- The migrated Advent of Code post gains its Japanese and Brazilian
  Portuguese variants — full translations of the Spanish canonical (the
  warning's own semantics: non-default pages are machine translations of
  the original Spanish post), with translated titles, descriptions,
  narrative, toggle labels ("解答を表示" / "Mostrar solução"), and the
  shared slug, date, and featured image; code blocks stay untouched.
- AGENTS.md's content conventions record the mandate: a post missing any
  of its four variants is incomplete.
- A completeness test enforces the mandate mechanically: every post
  directory under `blog/` carries all four sources sharing one slug.

Out of scope:

- No new languages beyond the declared four, no translation tooling or
  glossaries — the translations are authored content like their
  siblings.
- No changes to the warnings, options row, or language configuration
  themselves — they already handle any variant; and no change to the
  relaunch post (already compliant).

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-post-languages`: the "Site language configuration" requirement
  strengthens — every post ships a variant for each declared language,
  and the shipped-post scenario covers all four variants for every post.

## Impact

- `blog/advent-of-code-in-onyx-day-01/`: new `index-ja.djot` and
  `index-pt.djot`.
- `test/ninjas_test.gleam`: the every-post completeness test.
- `AGENTS.md`: the content-conventions mandate.
- No source, dependency, or configuration changes — the views already
  render any variant set.
