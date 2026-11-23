# Tasks

## 1. Inline icon plumbing

- [x] 1.1 Add an `icon(path)` helper in `src/site.gleam` (an `img.site-icon` with the given path and an empty alt) and the `.site-icon` rule to `static/style.css` (`height: 1.25em; width: auto; image-rendering: pixelated; vertical-align: -0.25em;`) with an explanatory comment; verify the rule is present (test in 3.2 locks it).

## 2. Emoji replacements

- [x] 2.1 Replace the twelve emoji uses with their confirmed icons: the seven navbar links, the `section` helper's six titles (gaining an icon argument), the three showcase titles (via `ShowcaseItem` gaining an `icon` field — empty string for the Ninja Systems card), the contact "Escríbenos" button and GitHub link (`external_link` gains an icon argument), and the "Entrada destacada" heading — keeping 🇨🇱 ❤️ 🥷 🥷🏽 untouched; verify with the tests in 3.1.

## 3. Manifest and tests

- [x] 3.1 Add tests in `test/ninjas_test.gleam`: every icon `src` renders in the home page, the twelve replaced emojis are absent, the kept emojis remain (hero tagline, about text, "🥷 Ninja Systems", footer copyright), a nav icon precedes its label, and the wizard icon precedes "Elixir Chile 🇨🇱" (updating the row test's old assertion); verify with `gleam test`.
- [x] 3.2 Create `static/icons/emoji-matches.json` recording the twelve matches (emoji, label, icon file, where used, description) and the three kept emojis with reasons; add a test asserting the manifest names all twelve icons and the kept emojis; verify with `gleam test`.

## 4. Checks

- [x] 4.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 4.2 Run `gleam test` and confirm the whole suite passes.
- [x] 4.3 Run `openspec validate replace-emojis-with-icons` and confirm it passes.

## Workflow follow-up

- Eyeball the home page in a browser (`gleam run`): every swapped emoji now shows its Win95 icon at navbar, section-title, and card-title scale, with 🇨🇱 ❤️ 🥷 still emojis; any icon swap is a one-line call-site + manifest edit; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive replace-emojis-with-icons`.
