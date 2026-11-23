# Tasks

## 1. Cursor pack coverage

- [x] 1.1 Add `cursor_pack_ships_in_stylesheet_test` in
  `test/ninjas_test.gleam`: the shipped `static/style.css` carries the
  retro cursor pack rules — `cursor: url("/cursors/arrow.cur"), auto;` as
  the body default, `cursor: url("/cursors/hand.cur"), pointer;` on the
  interactive-controls selector, and the disabled fallback
  `cursor: url("/cursors/arrow.cur"), default;`. Verify with `gleam test`.
  The stale-path reconciliation itself needs no code work — the markup
  and tests already serve and assert the `/icons/win95/` paths.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate fix-icon-pins-add-cursors` and confirm it
  passes.

## Workflow follow-up

- After review, archive the change with the `openspec-archive-change`
  workflow; when summarizing, carry the remaining gaps: the unused
  macOS 9 icon pack and `sad_mac.png`, the unpinned `site_description`,
  and the `site-masthead` home-hero scenario drift.
