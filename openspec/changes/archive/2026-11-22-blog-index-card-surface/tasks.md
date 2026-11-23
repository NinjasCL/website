# Tasks

The implementation shipped with the request; each task is verified
against the current tree.

## 1. Presentation

- [x] 1.1 Give the `.blog-entry` frame its darker surface in `static/style.css`: the Night Owl navy `#011627` — the site's established darker-than-violet reading field, the same background the post code panels use — so the blocks differentiate from the page's violet wash.
- [x] 1.2 Add the spacing rhythm: 10% top padding on `.blog-entry`, with `.blog-entry:first-child` resetting it to zero so the first result of each page's list stays flush at the top.

## 2. Verification

- [x] 2.1 Run `gleam format --check src test` and `gleam test`; confirm both pass. (55 passed.)
- [x] 2.2 Run `task build` and confirm the shipped `dist/style.css` carries both rules and the index pages render with them.
- [x] 2.3 Run `openspec validate blog-index-card-surface` and confirm it passes.
