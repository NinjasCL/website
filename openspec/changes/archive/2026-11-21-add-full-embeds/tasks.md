# Tasks

## 1. Full embed components

- [x] 1.1 Rework the embed renderers in `src/ninjas/highlight.gleam`: one shared OG-card builder (site name, title, description, image, one link) with thin wrappers — `github` (`owner/repo | description`, image from `https://opengraph.githubassets.com/1/owner/repo`), `ninjas` (`slug | title | description | image`), and the new `embed` fence (`url | title | description | image`, site name from the host); parsing splits on `|`, trims, and tolerates short fences; verify with component tests for each card.
- [x] 1.2 Make the `youtube` renderer full width: a `div.embed-video` wrapping a raw `<iframe width="100%">` with the old template's allow list (`accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share`); verify the three URL forms still parse and the wrapper carries the class.
- [x] 1.3 Replace the `.embed-card` rules in `static/style.css` with `.embed-full` (the dashed violet frame, text column, right image capped like the old `max-height: 300px`, hover treatment) and add `.embed-video` (full-width 16:9 iframe, `max-height: 640px`); verify with stylesheet assertions.
- [x] 1.4 Update `test/ninjas_test.gleam`'s embed test: github card asserts the link, title, description text, site name, and social-card image; ninjas card asserts the four-field form; the new `embed` card asserts the link, host-derived site name, and carried fields; youtube asserts the `embed-video` wrapper, `width="100%"`, and the allow list; verify `gleam test` passes.

## 2. Content sweep and docs

- [x] 2.1 Sweep every existing fence in `blog/*/index*.djot` (all four variants) to the new grammar: a description on each of the 37 github fences (from each repo's embedding post and known taglines) and the two ninjas fences extended with description and cover image; verify the suite passes and a sample of built pages renders the full cards.
- [x] 2.2 Record the new fence grammar in the migration recipe (`migrate-old-catalog` design.md) and the AGENTS.md conventions bullet, so the remaining tranches author full fences; verify `openspec validate` passes for both changes.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm it completes.
- [x] 3.2 Run `gleam test` and confirm every test passes.
- [x] 3.3 Run `gleam format --check src test` and confirm it passes.
- [x] 3.4 Run `openspec validate add-full-embeds` and confirm it passes.
- [x] 3.5 Regenerate the site (`task build`) and confirm: a github card page renders the full card (image, title, description, site name), the ninjas cards carry their posts' covers, the youtube players render full width inside the frame, code panels and toggles are unchanged, and no page still carries the old `.embed-card` markup.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-full-embeds`).
- Archive the change (`openspec archive add-full-embeds`) and verify the archived result.
