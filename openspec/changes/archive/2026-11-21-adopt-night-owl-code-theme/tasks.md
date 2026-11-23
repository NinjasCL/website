# Tasks

## 1. Night Owl panel and palette

- [x] 1.1 Restyle `static/style.css`: add the `.post-body pre` Night Owl panel (background `#011627`, foreground `#d6deeb`, padding, the theme's `#122d42` contrast border, horizontal scroll) and switch the seventeen smalto token rules to the Night Owl palette mapped from the theme JSON (keyword `#c792ea` italic, string `#ecc48d`, number `#f78c6c`, comment `#637777` italic, function `#82aaff` italic, operator `#7fdbca`, punctuation and variable `#d6deeb`, type `#ffcb8b`, module and builtin `#c5e478`, constant `#82aaff`, tag `#caece6`, attribute `#c5e478` italic, selector `#c792ea` italic, property `#80cbc4`, regex `#5ca7e4`); verify by replacing the stylesheet-contract test with Night Owl assertions (the panel rule plus the keyword, string, number, comment, and function colors).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate adopt-night-owl-code-theme` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the migrated post's code blocks render on the darker Night Owl panel with the palette's token colors, on both language variants.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync adopt-night-owl-code-theme`).
- Archive the change (`openspec archive adopt-night-owl-code-theme`) and verify the archived result.
