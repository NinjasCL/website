# Proposal

## Why

Post pages end at the navigation buttons — a reader who arrived from
search or a shared link has no way to discover the rest of the catalog
short of returning home. A small list of other entries on every post
page closes the loop, and picking them at random keeps the list fresh
across the small catalog instead of always showing the same neighbors.

## What Changes

- Every post page renders an "Otras entradas" panel before the footer:
  a list of up to **five other posts**, picked at random at build time
  from the default-language catalog — **the current post and its
  navigation neighbors (the previous and next entries) excluded**, so
  the list never repeats what the page already offers — each pick
  resolved to the reader's current language variant, the same
  language-continuity rule the navigation buttons follow.
- A consequence worth knowing: with today's two-post catalog every
  other entry is a navigation neighbor, so no page renders the section
  yet — it appears as the catalog grows past its navigation.
- The randomness is build-time: a Fisher–Yates shuffle over the other
  default-language entries using the Erlang `rand` module (declared as a
  direct external — the same FFI pattern `gleam_time` itself uses for
  the clock; no new dependency), so every build picks a fresh set and
  the dev server's rebuilds reshuffle.
- The list reuses the home page's own presentation: the `rs-panel`
  with its Notepad-icon title and the `rs-list rs-list--stars` rows —
  title link plus date, styled by retrostrap and the existing rules.
  No new CSS.
- Edge behavior: a catalog too small to fill five slots lists all the
  other entries (today: one), and a lone post renders no section at
  all.

Out of scope:

- No weighting, pinning, or tag-based relevance — plain random, per the
  owner's wording.
- No variant entries in the pool (default-language catalog only; the
  resolution to the reader's language happens per pick), and no
  home-page or 404 changes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post pages list random other entries"
  — up to five random others, excluding the current post, in the
  reader's language.

## Impact

- `src/site.gleam`: `random_posts_section` (shuffle + take five +
  per-pick language resolution) rendered in `post_template` between the
  navigation and the footer; the `rand` external declaration and the
  Fisher–Yates helpers.
- `test/ninjas_test.gleam`: order-agnostic tests — exactly five picks
  from a seven-entry pool, the current post never listed, small and
  lone catalogs, and the language resolution.
- No dependency, content, or stylesheet changes.
