# Proposal

## Why

The ninjas.cl catalog lives on in `old/sources/blog` — 102 remaining
posts (12,594 lines of markdown) while the new engine ships two. The
first migration (the Advent of Code post) proved the recipe; this change
migrates the rest of the catalog with it, in batches.

## What Changes

- Every remaining post migrates under the established conventions — no
  new mechanisms, only content:
  - the `*.md.eex` sources are plain markdown (no EEX tags exist; the
    extension is vestigial) and convert to djot with the JSON
    frontmatter mapped to blogatto's, preserving each post's original
    publication date and carrying its **`tags` array into the
    comma-separated `tags:` frontmatter field**, identical across the
    four variants;
  - every post ships **all four language variants** — the original text
    as the Spanish default for Spanish-origin posts (human-written),
    and machine translations for en/ja/pt; English-origin posts follow
    the owner's rule (Spanish translation as the default, the original
    English as the `en` variant);
  - post-adjacent files (`assets/cover.jpg`, data, code) copy flat into
    the post directory and serve at the post's URL;
  - the old cover-image convention (`![url-as-alt](assets/cover.jpg)`)
    becomes a proper alt plus the visible attribution line, as in the
    first migration.
- The old builder's **custom Liquid tags** convert to plain djot:
  `{% github owner/name %}`, `{% codeberg %}`, `{% devto %}`, and
  `{% embed URL %}` become links (the oEmbed fetches do not survive a
  static migration); `{% youtube … %}` becomes a single-element
  `<iframe>` raw-HTML fence — self-contained, so the div-wrapping that
  breaks paired tags cannot touch it. The sloppy tag spellings
  (`{% github ElixirCL % }`) are tolerated.
- The work is **batched, shortest posts first**: each batch ships all
  four variants of its posts (the completeness test enforces it
  mechanically), runs the suite, and rebuilds. Batch 1 covers the ten
  shortest posts; roughly ten further batches complete the catalog —
  one batch per working session, each a verifiable checkpoint.

Out of scope:

- No new site behavior — everything the migrated posts touch (djot
  conversion, variants, warnings, toggles, highlighting, navigation,
  the random-entries list) is already specced and tested; hence this
  change opts out of spec deltas.
- No layout or presentation work on the migrated bodies beyond the
  established conversions.

## Capabilities

### New Capabilities

- None — a pure content migration; the change sets `skip_specs: true`.

### Modified Capabilities

- None.

## Impact

- `blog/`: one directory per migrated post, four djot sources each,
  plus the copied adjacent files.
- `test/ninjas_test.gleam`: unchanged — the completeness test
  (`every_post_ships_all_languages_test`) enforces the four-variant
  floor for every new directory automatically.
- No source, stylesheet, or dependency changes.
