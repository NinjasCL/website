# Tasks

## 1. Tests

- [x] 1.1 Update the two test assertions to the owner's icon picks — `showcase_buttons_carry_icons_test`: the View button's icon `src` becomes `/icons/Shdocvw257_32x32_8.png`; `featured_post_follows_about_row_test`: the Leer entrada icon becomes `/icons/Progman25_32x32_4.png` (both files verified as valid 32×32 PNGs in `static/icons/`); verify with `gleam test`.

## 2. Checks

- [x] 2.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 2.2 Run `gleam test` and confirm the whole suite passes.
- [x] 2.3 Run `openspec validate update-button-icon-picks` and confirm it passes.

## Workflow follow-up

- The markup already carries the new picks (the owner's edit), so this change touches only the spec contracts and the tests.
- Archive the change after review requirements are satisfied: `openspec archive update-button-icon-picks`.
