# Proposal

## Why

The home page always features the newest post — with a catalog growing
past two dozen entries, the same row headlines every build while the
rest sit in the compact list. The owner wants the spotlight earned by
chance instead: a randomly selected post as the featured entry.

## What Changes

- The home page's featured post becomes a build-time random pick
  among the default-language entries — the same `rand`-powered
  shuffle the post pages' random-entries list already uses, so every
  build (and every dev rebuild) features a fresh post.
- The "Más entradas" list shows the remaining entries, keeping its
  newest-first order.
- The featured row's presentation is untouched — the Sobre
  nosotros-style row, the figure with its placeholder fallback, and
  the "Leer entrada" button render exactly as specced; only which
  post gets them changes.
- Edge behavior: a single post is always the featured one, and the
  empty state keeps its "Todavía no hay entradas publicadas." note.

Out of scope:

- No changes to the featured row's layout, button, or figure; no
  weighting or exclusion rules (the random pool is every
  default-language entry); no home-page changes beyond the selection.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-featured-post`: ADDED "The featured post is a build-time
  random pick" — the featured entry is randomly selected from the
  default-language posts each build, the rest listed in "Más
  entradas".

## Impact

- `src/site.gleam`: `post_list` picks the featured entry from
  `shuffle(posts)` instead of `list.first(posts)` and lists the
  remaining entries in "Más entradas".
- `test/ninjas_test.gleam`: a selection test (one featured row, the
  others in the list, a lone post always featured).
- No dependency, content, or stylesheet changes.
