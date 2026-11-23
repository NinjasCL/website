# Tasks

## 1. Post content and files

- [x] 1.1 Copy the old post's companion files flat into `blog/advent-of-code-in-onyx-day-01/` — `assets/cover.jpg` as `cover.jpg`, plus `input.txt` and `main.onyx`; verify the three files sit beside the djot sources and `old/` stays untouched.
- [x] 1.2 Write `index.djot` — the Spanish translation of the old body with blogatto frontmatter (title "Advent of Code — Solución del Día 01", description translated, slug and the original 2024-12-04 date preserved, `featured_image: /blog/advent-of-code-in-onyx-day-01/cover.jpg`, tags with the "avent" typo fixed), converting `<details>/<summary>` to djot `{=html}` raw fences, the empty `[]()` link to a code span, and the Wikimedia attribution to a visible link; verify the djot conventions hold (djot single-asterisk strong where needed, no `**`, no markdown sources in the directory).
- [x] 1.3 Write `index-en.djot` — the original English content as-is under the same conversion rules, sharing the slug, date, and featured image; verify the two sources group as one post's language variants (same slug, different filenames).

## 2. Tests and conventions

- [x] 2.1 Add the migration test to `test/ninjas_test.gleam` — the post directory ships `index.djot`, `index-en.djot`, `cover.jpg`, `input.txt`, and `main.onyx`; both sources are djot with the same slug; the Spanish source carries the translated title and the English source the original one; verify `gleam test` passes with it.
- [x] 2.2 Record the English-origin rule in AGENTS.md's blog content conventions — Spanish translation as the warning-free default, original English as the `en` variant with the standard warning — and note it applies to future old-post migrations; verify the section reads back with the rule.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm it completes.
- [x] 3.2 Run `gleam test` and confirm every test passes.
- [x] 3.3 Run `gleam format --check src test` and confirm it passes.
- [x] 3.4 Run `openspec validate migrate-advent-of-code-post` and confirm it passes.
- [x] 3.5 Regenerate the site (`task build`) and confirm: the Spanish page at `/blog/advent-of-code-in-onyx-day-01/` renders the cover as its masthead background, the staleness warning with the day count, the options row linking English, and no translation warning; the English page at `/blog/en/…` carries the machine-translated warning and links back; `cover.jpg`, `input.txt`, and `main.onyx` are served at the post's URL; the home page's "Más entradas" lists the post; both variants appear in the sitemap.

## Workflow follow-up

- Sync the delta specs into the main specs (`openspec sync migrate-advent-of-code-post`).
- Archive the change (`openspec archive migrate-advent-of-code-post`) and verify the archived result.
