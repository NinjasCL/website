# Design

## Context

See proposal.md — Why. The post template already receives every post,
newest first, and the site has the pieces this needs:
`default_language_posts` (the canonical catalog, the home page's own
filter), `in_language` (the navigation's variant resolution), and
`post_item` (the home list's row). Randomness is the only new
ingredient — and the Erlang target ships the `rand` module, which
`gleam_time`-style externals can reach without a new dependency.

## Goals / Non-Goals

**Goals:**

- Up to five fresh, random other entries on every post page, in the
  reader's language, using the site's existing list presentation.

**Non-Goals:**

- No relevance logic, no home/404 sections (proposal.md — out of
  scope).

## Decisions

1. **Erlang `rand` via a direct external.** `@external(erlang, "rand",
   "uniform")` yields `1..N`; the site targets Erlang (OTP 29, per
   CI), app code may declare externals, and `rand` seeds itself —
   every build picks a fresh set. *Alternative considered:* seeding
   pseudo-randomness from the build clock — rejected: indirect and
   still non-deterministic; *considered:* a `random` Hex package —
   rejected: a dependency for what one external already provides.

2. **Fisher–Yates over the pool that excludes the page's own cast.** The
   pool is `default_language_posts(all_posts)` minus three slugs: the
   current post's, and the navigation neighbors' (`post_neighbors`'
   previous and next — already on the page as buttons, so the random
   list never repeats them). Canonical entries only, never language
   variants as separate picks. The shuffle picks a random index per
   step (`list.take`-free recursive removal — the catalog is tiny,
   O(n²) is free), then `list.take(5)`.
   *Consequence:* a catalog where every other entry is a neighbor —
   today's two posts — leaves the pool empty and renders no section;
   the list appears as the catalog grows past its navigation.

3. **Each pick resolves to the reader's language** — the navigation
   buttons' own rule, via the existing `in_language` helper: a ja
   reader's list links ja variants, falling back to the picked entry
   itself if a variant were ever missing.

4. **The presentation is the home list's.** The section reuses the
   `rs-panel` + `rs-panel__title` (Notepad icon, like "Entradas del
   blog") and the `rs-list rs-list--stars` rows (`post_item`: title
   link + date) — retrostrap and the existing size-floor rules style
   it; no new CSS. The title reads "Otras entradas".

5. **Placement: inside `main`, after the navigation, before the
   footer** — the reading flow ends, the discovery list follows, the
   site chrome (footer) closes.

## Risks / Trade-offs

- [Randomness makes tests order-dependent] → The tests are
  set-agnostic: counts, pool membership, exclusions, and language
  targets — never a specific order.
- [A rebuild reshuffles the list] → Intended freshness; noted in the
  proposal so it is a documented behavior, not a surprise.
- [The pool grows beyond tiny] → The O(n²) shuffle is bounded by the
  catalog's size; irrelevant until hundreds of posts, and trivially
  replaceable then.

## Migration Plan

None. The section is additive markup; existing pages gain their list.
Rollback is reverting and rebuilding.
