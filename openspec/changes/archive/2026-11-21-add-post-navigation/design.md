# Design

## Context

See proposal.md — Why. blogatto hands the post template every post,
newest first (`sort_newest_first` in the builder), including translated
variants. The home page already filters that list to default-language
entries, and the completeness mandate guarantees every post ships all
four variants, so a neighbor's same-language variant exists for any
reader.

## Goals / Non-Goals

**Goals:**

- Neighbor links on every post page, following the newest-first
  sequence the home list reads.
- Language continuity: navigating keeps the reader in their variant.

**Non-Goals:**

- No per-language labels, no pagination, no related-posts
  (proposal.md — out of scope).

## Decisions

1. **The newest-first default-language list defines the sequence.**
   `post_navigation` walks `default_language_posts(all_posts)` (the
   home page's own filter, newest first by blogatto's sort) and takes
   the entries around the current post's default entry — matched by
   slug, since the page being rendered may itself be a variant.
   "Anterior" = the entry before (newer), "Siguiente" = the entry
   after (older): the direction the home list reads, so a reader who
   just finished the newest post continues naturally down the catalog.
   *Alternative considered:* the WordPress polarity (next = newer) —
   rejected: the site presents posts newest-first everywhere, and the
   owner's ordering wording reads as the list's own sequence.

2. **Neighbors resolve to the reader's language.** Each neighbor is
   looked up in the full post list by slug plus the current page's
   `language`; the mandate ships every variant, and the neighbor's
   default entry is the fallback if a variant is ever missing —
   navigation never dead-ends.

3. **Rendering: a `nav` row after the article.** One link per existing
   neighbor (`"← Anterior: {title}"` / `"Siguiente: {title} →"`),
   dropped entirely when no neighbors exist — a lone post shows
   nothing rather than an empty nav. The flex row rule in
   `static/style.css` spreads the two links apart; a single link sits
   inline.

4. **No new dependency; the template signature is unchanged.** The
   navigation uses the `all_posts` the template already receives —
   the same source the options row reads.

## Risks / Trade-offs

- [Two posts share a date] → blogatto's sort is stable, and the
  neighbor walk preserves that order — the links match the home list
  exactly, whatever the tie order.
- [A future post ships without a variant] → The fallback link targets
  the neighbor's default page; the completeness test already fails the
  suite for missing variants, so the fallback is a safety net, not a
  path.
- [Label polarity tastes wrong to the owner] → Two strings in one
  function; a one-line swap if the WordPress polarity is preferred.

## Migration Plan

None. The navigation is additive markup on post pages; existing pages
gain their one neighbor link. Rollback is reverting and rebuilding.
