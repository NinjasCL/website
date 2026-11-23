# Tasks

## 1. Local game assets

- [x] 1.1 Download the four "Juegos" images into `static/img/` — `rolplay-manual.png` from the production blog path, `rossa.gif`, `quechaucha.jpg`, and `munstajump.gif` from their `raw.githubusercontent.com` URLs (with `-f`, so an HTTP error fails loudly) — and verify each file exists, has the right type (the two captures must be GIF image data), and has a non-trivial size; pause rather than proceed if any download fails.

## 2. Repoint and tests

- [x] 2.1 Repoint the four `image:` fields in `games_section` to `/img/rolplay-manual.png`, `/img/rossa.gif`, `/img/quechaucha.jpg`, and `/img/munstajump.gif`; alts unchanged, and the masthead hero logo untouched. Verify with the tests updated in 2.2.
- [x] 2.2 Update `home_view_serves_showcase_images_from_img_test`: the four local games paths are present; the rossa remote-URL guard becomes absence assertions — no `raw.githubusercontent.com` and no `ninjas.cl/blog` anywhere in the markup — and the hero logo URL assertion stays. Verify with `gleam test`.

## 3. Checks

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate local-games-images` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`): the Juegos cards load their captures locally — the two GIFs still animate inside the uniform image boxes; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive local-games-images`. At sync time, also refresh the `site-showcase-images` main spec's Purpose wording from the two-section scope to the three-section scope — a direct Purpose edit sanctioned by the sync workflow.
