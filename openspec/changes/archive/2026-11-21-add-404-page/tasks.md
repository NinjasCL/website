# Tasks

## 1. The not-found view and its build step

- [x] 1.1 Add `not_found_view/0` in `src/site.gleam`: `page` titled
  "404 — Ninjas.cl" with the message as its meta description, the body
  composed of `masthead(on_home: False, children: [])` (the shared navbar,
  no hero — the owner scoped the page to main menu + footer), an
  `html.main` holding one sunken panel with the Sad Mac figure
  (`/img/sad_mac.png`, descriptive alt, existing `rs-figure` classes) and
  the message "La página que buscabas está en otro castillo" as the page's
  single `h1`, closing with `site_footer()`. Verify by rendering
  `site.not_found_view()` or with `gleam test` once 1.3 lands.
- [x] 1.2 Promote `simplifile` from `[dev_dependencies]` to
  `[dependencies]` in `gleam.toml` (same requirement range; refresh the
  lock with `gleam deps download`), add `src/ninjas/extra_pages.gleam`
  with `pub fn write_not_found()` rendering the view via
  `element.to_document_string` and writing `./dist/404.html`, and call it
  from `src/ninjas.gleam` and `src/dev.gleam` after a successful
  `blogatto.build` — surfacing a write failure like a build failure.
  Verify by running the build (`gleam run` and `gleam run -m dev`) and
  confirming `dist/404.html` exists at the output root.
- [x] 1.3 Add `not_found_view_renders_chrome_and_message_test` in
  `test/ninjas_test.gleam`: the rendered view carries the `rs-navbar`
  with its six icon links and no `aria-current` marker, closes with the
  `rs-footer` copyright and `href="#masthead"` back-to-top link, shows
  `src="/img/sad_mac.png"`, keeps exactly one `h1` reading "La página que
  buscabas está en otro castillo", and titles the page
  "404 — Ninjas.cl". Verify with `gleam test`.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate add-404-page` and confirm it passes.

## Workflow follow-up

- After review, sync/archive the change with the `openspec-archive-change`
  workflow; when summarizing, carry the still-open gaps: the unused
  macOS 9 icon pack and `sad_mac.png` is now used — update that note —
  the unpinned `site_description`, and the `site-masthead` home-hero
  scenario drift.
