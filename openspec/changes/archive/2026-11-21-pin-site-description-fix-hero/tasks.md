# Tasks

## 1. Test coverage for the reconciled specs

- [x] 1.1 Extend `home_view_renders_homepage_sections_test` in
  `test/ninjas_test.gleam`: the site description renders in both its
  places — the hero's `rs-note` and the page's meta description — so the
  description's opening ("Ninjas es un grupo desarrollador de software
  experimental de Chile") appears twice in the home markup, and the
  closing credits "por @CLSource" with the "¡11 años programando ❤️!"
  line. Verify with `gleam test`.
- [x] 1.2 Extend `not_found_view_renders_chrome_and_message_test` in
  `test/ninjas_test.gleam`: the not-found page's masthead renders the
  navbar alone — no hero element or class appears anywhere in the page.
  Verify with `gleam test`.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate pin-site-description-fix-hero` and
  confirm it passes.

## Workflow follow-up

- After review, sync/archive the change with the `openspec-archive-change`
  workflow. No code work beyond the test assertions — the markup already
  matches the specs this change reconciles.
- The last remaining gap after this one: the unused macOS 9 icon pack.
