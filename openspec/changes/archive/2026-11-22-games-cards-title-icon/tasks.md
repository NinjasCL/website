# Tasks

## 1. Games card titles lead with the icon

- [x] 1.1 Set `icon: "/icons/win95/Mmsys108_32x32_4.png"` on all four
  `ShowcaseItem` records in `games_section` (`src/ninjas/home.gleam`):
  "Rolplay Manual", "Profesor Rossa", "¡Qué Chaucha!", "Munsta Jump!".
  Verify with a `home.view` render test asserting the icon precedes each
  title and appears exactly four times.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and `gleam test`; confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `openspec validate games-cards-title-icon` and confirm all
  checks pass.
