# Tasks

## 1. Embed components

- [x] 1.1 Extend the content-block component in `src/ninjas/highlight.gleam`: a pass-through `pre` in `src/ninjas/blog.gleam` (via `post.pre`) hands structure to the code component, which then renders real code with its own `<pre>` panel, restructures `{summary}` toggles to `<details><summary>…</summary><pre><code>…`, and adds the three embed languages — `github` (card with the retro `github.gif`, repo name, repo link), `youtube` (URL/bare-id parsed to a single-element iframe), `ninjas` (`slug | title` parsed to a card linking `https://ninjas.cl/blog/slug/`); verify `gleam test` passes with component tests for each embed, the restructured toggle assertion, and the unchanged plain/highlighted code paths.
- [x] 1.2 Add the `.embed-card` rules to `static/style.css` — the site's dashed violet frame, block link, banner image sizing, hover hint; verify with stylesheet assertions.
- [x] 1.3 Sweep every migrated plain-link conversion to the new fences (one scripted pass over `blog/*/index*.djot`: `[github.com/X](…)` → ```` ```github ```` fences; super-club-net's ninjas link → the ninjas fence) and update the migration recipe (design.md of `migrate-old-catalog`) plus AGENTS.md conventions to record embed fences as the Liquid-tag conversion; verify `gleam test` passes and the built pages render the cards.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-embed-components` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm: migrated github links render as embed cards, super-club-net's ninjas tag renders its post card, solution toggles keep working in the restructured form, and code panels are unchanged.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-embed-components`).
- Archive the change (`openspec archive add-embed-components`) and verify the archived result.
