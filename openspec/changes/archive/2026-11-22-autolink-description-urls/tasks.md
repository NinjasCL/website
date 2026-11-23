# Tasks

## 1. The linkify helper

- [x] 1.1 Add `pub fn linkified_text` and its private helpers to
  `src/site.gleam` next to `title_with_icon` — bare `http(s)://` runs as
  anchors, trailing `.,;:!?` and an unbalanced `)` outside the link, per
  `design.md`'s rules
- [x] 1.2 Use it in the post page's description paragraph
  (`post_template`'s `.post-description` `<em>`)

## 2. The featured row

- [x] 2.1 Use it in the home page's featured-post description paragraph
  (`src/ninjas/home.gleam`)

## 3. Tests

- [x] 3.1 Add a post-page test: a description with a bare URL renders
  the anchor inline in the description paragraph, with trailing
  punctuation outside the link
- [x] 3.2 Add a featured-row test: the home page renders the anchor in
  the featured post's description
- [x] 3.3 Add raw-consumer tests: the blog index page renders no anchor
  to the URL, and the post page's meta description carries the raw text

## 4. Checks and build

- [x] 4.1 Run `gleam format src test` and `gleam test` (58 tests plus
  the new ones, all passing)
- [x] 4.2 Run `openspec validate autolink-description-urls`
- [x] 4.3 Rebuild with `task build` and verify the wren-playground page
  links `https://runjs.app/` in its description in `dist/` for all four
  variants, and its meta description stays raw

## Workflow follow-up

- Sync the delta spec into the main spec and archive the change
  (`openspec sync`, then `openspec archive autolink-description-urls`)
