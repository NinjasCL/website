# Tasks

## 1. Content conversion

- [x] 1.1 Run the validated scanner over `blog/` to rewrite bare prose
  URLs as djot `<url>` autolinks in place, per `design.md`'s conversion
  rules (frontmatter, fences, code spans, existing links/autolinks, raw
  HTML, and multi-line link destinations untouched)
- [x] 1.2 Review `git diff blog/`: only `<…>` wrappers added around URLs
  on prose lines — spot-check the trailing-dot bibliography
  (`finanzas-personales`), the parenthesized Wikipedia URL
  (`introduccion-a-elixir`), the multi-line link (`wireshell…`), and the
  `<video>` `=html` fence (`zilog-cafe-app`) for zero unintended edits
- [x] 1.3 Re-run the scanner: reports zero remaining conversions
  (idempotency proof)

## 2. Build and output verification

- [x] 2.1 Rebuild the site with `task build`
- [x] 2.2 Verify the rendered output: the Webpay guide's
  `http://www.transbankdevelopers.cl/` is inside an `<a>` in
  `dist/blog/guia-webpay-kcc/index.html` (and its en/ja/pt variants), a
  trailing-dot reference renders its `.` outside the anchor, and no new
  anchor appears inside any code panel or embed card
- [x] 2.3 Verify no formerly-bare URL remains plain in `dist/`: grep the
  built post pages for bare `https?://` occurrences outside anchors,
  code, and attribute values

## 3. Checks

- [x] 3.1 Run `gleam format --check src test` (no Gleam source changes
  expected; must still pass)
- [x] 3.2 Run `gleam test` (the four-variant invariant test must pass)
- [x] 3.3 Run `openspec validate autolink-post-urls`

> Note on 3.2: the suite reports 57 passed, 1 failure —
> `emojis_render_as_static_icons_test`, whose "🥷 Ninja Systems" assertion
> matches nothing in the current `src/ninjas/home.gleam` (no such card is
> rendered). Empirically pre-existing: running the suite against the
> pre-conversion content snapshot shows the identical 57/1 result, and
> this change touches only `blog/*.djot` (no data path reaches that
> fixture-rendered view). The change's own guarded invariant,
> `every_post_ships_all_languages_test`, passes. The stale test is a
> follow-up for a separate change.

## Workflow follow-up

- Sync the delta spec into the main spec and archive the change
  (`openspec sync`, then `openspec archive autolink-post-urls`)
