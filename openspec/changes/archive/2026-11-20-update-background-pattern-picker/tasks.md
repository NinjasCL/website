# Tasks

## 1. Background script

- [x] 1.1 Rewrite the offered-tile list in `static/background.js` generated from the actual directory contents (74 `macosx/…` + 18 `win3.1/…` entries, each carrying its set prefix), keeping the random-pick IIFE and the `url("/patterns/${pattern}")` template unchanged, and update the header comment; verify the list covers both sets and excludes the LICENSE file.

## 2. Stylesheet fallback

- [x] 2.1 Update the `--random-pattern` fallback in `static/style.css` to `url("/patterns/macosx/128.png")`; verify the old flat path no longer appears in the file.

## 3. Tests

- [x] 3.1 Add a test that reads `static/background.js`, extracts the offered list (the first quoted string), and asserts it matches the `.png` files of both pattern directories exactly — every offered tile exists, every shipped PNG is offered, no duplicates, LICENSE not offered; verify with `gleam test`.
- [x] 3.2 Add a test asserting `static/style.css` sets the `--random-pattern` fallback to `/patterns/macosx/128.png`; verify with `gleam test`.

## 4. Checks

- [x] 4.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 4.2 Run `gleam test` and confirm the whole suite passes.
- [x] 4.3 Run `openspec validate update-background-pattern-picker` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`): each load shows a random tile from either set under the purple tint; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive update-background-pattern-picker`.
