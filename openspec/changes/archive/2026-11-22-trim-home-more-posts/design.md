# Design

## Context

`src/ninjas/home.gleam` renders the posts section: `post_list` picks the
featured entry with `site.shuffle`, and `more_posts` lists every remaining
default-language entry newest-first — 100+ rows with today's catalog. The
shuffle itself is established machinery: a Fisher–Yates over the Erlang
`rand` FFI in `src/site.gleam`, already used by the featured pick and the
post pages' "Otras entradas" section. See proposal.md for motivation and the
delta spec for the required behavior.

## Goals / Non-Goals

**Goals:**

- Cap the "Más entradas" list at ten random entries, reusing the existing
  shuffle so every build samples freshly.
- Give the heading and the new button the site's icon-led presentation using
  icons already in `static/icons/win95/`.

**Non-Goals:**

- No weighting, pinning, or exclusion rules for the picks (beyond the
  featured post, already excluded by `post_list`).
- No changes to the featured row, the blog index, or the navbar.

## Decisions

- **Randomness: reuse `site.shuffle`, then take ten.** `more_posts` already
  receives the remaining entries from `post_list`; `list.take(site.shuffle(posts), 10)`
  gives the fresh random sample with no new helper and no new FFI. The
  featured pick stays a separate shuffle call, unchanged.
  *Alternative considered:* newest-first truncation (`list.take(posts, 10)`)
  — rejected: the owner asked for random posts, and the site already treats
  build-time randomness as the fresher choice for both the featured row and
  the post pages' random section.
- **Heading icon: `Files_32x32_4.png`.** The section title uses Notepad, the
  featured heading uses Star; "Más entradas" — several more documents — maps
  to the stack-of-documents icon, read at a glance alongside its siblings.
  Every heading in the section is then icon-led, like the rest of the page.
- **Ver Todos button: the site's own "Ver" language.** Large icon button
  (`rs-btn rs-btn--icon rs-btn--large`) led by `Shdocvw257_32x32_8.png` — the
  exact icon every "Ver / View" button on the home page already uses — and
  rendered as a plain internal anchor like the featured row's "Leer entrada"
  (no `target`/`rel`, unlike the external showcase buttons).
- **Link target: `/blog`.** The navbar's Blog link already points there, and
  the blog index serves `/blog/` as a redirect to `/blog/page/1/`, so the
  short URL stays the site's canonical "all entries" target. No new route is
  needed — blogatto's existing redirect feature is sufficient.
- **The button renders whenever the list renders.** Tying it to the trim
  would hide the only path to the full index on small catalogs, where it is
  still useful (the index also carries the featured entry). A lone post
  keeps rendering neither list nor button, matching `more_posts`'s existing
  empty case.

## Risks / Trade-offs

- [A visitor may not find a specific post on the home list] → The random
  sample rotates per build and the Ver Todos button leads to the full,
  paginated index — the canonical catalog path.
- [Random picks make the home page non-deterministic between builds] → Same
  trade-off the site already accepts for the featured row and the post
  pages' random section; tests assert set membership and counts, not order.

## Migration Plan

Single template change in `more_posts` plus tests; no content, routing, or
data migration. Rolling back is reverting the module edit.

## Open Questions

- None.
