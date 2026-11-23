# Tasks

## 1. The copyright line leads with its icon

- [x] 1.1 Add `pub const copyright_icon`
  (`/icons/win95/FilePencil_32x32_4.png`) to `src/site.gleam` and render
  `icon(copyright_icon)` at the head of `site_footer`'s copyright
  paragraph, keeping the text, 🥷🏽 emoji, clause, year, and back-to-top
  link verbatim. Verify with a render test asserting the icon's src
  precedes "Copyright 🥷🏽" on the home page, a post page, and a blog
  index page.
- [x] 1.2 Confirm the existing footer tests stay green with no edits:
  `footer_renders_copyright_and_back_to_top_test`, the translated-home
  footer tests, and the not-found footer test.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and `gleam test`; confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `openspec validate add-copyright-icon` and confirm all
  checks pass.
