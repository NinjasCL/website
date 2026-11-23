# Tasks

## 1. Post navigation icons

- [x] 1.1 Point both `post_navigation` image elements at `/icons/win95/Msow10_32x32_4.png` and give the "Siguiente" hand a `post-nav__hand--right` class; verify with `post_navigation_links_adjacent_entries_test` in `gleam test`
- [x] 1.2 Replace the left-hand `scaleX(-1)` rule with `rotate(-90deg)` and add `rotate(90deg)` for `.post-nav__hand--right`, keeping the shared pixelated sizing; verify with the stylesheet assertions in `post_navigation_links_adjacent_entries_test`

## 2. Manifest and verification

- [x] 2.1 Update the ⬅️/➡️ entries in `static/icons/win95/emoji-matches.json` to name `Msow10_32x32_4.png` and its two rotations; verify with the manifest assertion in `gleam test`
- [x] 2.2 Run `gleam format src test` then `gleam format --check src test` and confirm no formatting diffs remain
- [x] 2.3 Run `gleam test` and confirm all tests pass

## Workflow follow-up

- Sync the delta specs into the main specs and archive the change once implementation is verified.
