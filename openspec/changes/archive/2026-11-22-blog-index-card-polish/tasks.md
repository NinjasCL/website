# Tasks

## 1. Card presentation

- [x] 1.1 In `static/style.css`, turn the `.blog-entry` card's image into a full-height cover column — `position: absolute` against a `position: relative` frame with `top/right` insets at `--rs-space-2`, an explicit `height: calc(100% - var(--rs-space-3))`, `width: 40%`, and the 300px cap dropped (a replaced element will not stretch between top and bottom insets) — and reserve the column in flow with `calc(40% + var(--rs-space-3))` right padding on the card's main link and right margin on the meta row. Verify with `task build` and the shipped `dist/style.css`.
- [x] 1.2 In `src/site.gleam`'s `blog_entry_card`, lead the title with the post page's mail-news icon (`/icons/win95/Mailnews8_32x32_4.png`, via `title_with_icon`) and the date with its calendar icon (`/icons/win95/Timedate_32x32_4.png`, via `icon`), updating the card's doc comments to match. Verify the built `dist/blog/page/1/index.html` carries both icon paths in each entry card.
- [x] 1.3 In `static/style.css`, give `.blog-entry` a bottom margin (`var(--rs-space-4)`) for frame-to-frame separation and remove the 10% top-padding rhythm and its `:first-child` reset. Verify with `task build` and the shipped `dist/style.css`.
- [x] 1.4 In `static/style.css`, give the index title panel (`#blog`) a top margin (`var(--rs-space-5)`) so the floating "Blog" title clears the navigation menu. Verify with `task build` and the shipped `dist/style.css`.

## 2. Verification

- [x] 2.1 Run `gleam format --check src test` and `gleam test` and confirm both pass.
- [x] 2.2 Run `task build` and confirm the shipped site renders the polished cards: full-height covers, both icons per entry, and the frame/header spacing rules in `dist/style.css`.
- [x] 2.3 Run `openspec validate blog-index-card-polish` and confirm it passes.

## Workflow follow-up

- Sync the change's delta specs into the main specs, then archive it once verified.
