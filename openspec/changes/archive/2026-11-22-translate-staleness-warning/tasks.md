# Tasks

## 1. Per-language staleness template

- [x] 1.1 Add a `staleness_warning` field to the `SiteLanguage` record in `src/site.gleam` — a per-language template with a `{days}` placeholder, Spanish keeping today's exact wording and English, Japanese, and Portuguese carrying the translations from the proposal.
- [x] 1.2 Word the post page's staleness notice from the rendered variant's template — `post_warnings` passes the page's language to `staleness_message`, which splices the elapsed days over `{days}` with `string.replace` — and verify the existing `stale_post_warns_with_day_count_test` still passes.

## 2. Tests

- [x] 2.1 Give the staleness date fixture a language and add a test asserting that a stale post's English, Japanese, and Portuguese pages each render the warning in their own wording, verified with `gleam test`.
- [x] 2.2 In the same test, assert no Spanish staleness wording leaks into the translated pages and the default page keeps its Spanish wording, verified with `gleam test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes.
- [x] 3.2 Run `gleam test` and confirm the full suite passes.
- [x] 3.3 Run `openspec validate translate-staleness-warning` and confirm it passes.

## Workflow follow-up

- Sync the delta spec into the main `site-post-languages` spec.
- Archive the change once implementation is complete, and confirm the main spec carries the modified requirement.
