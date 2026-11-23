# Design

## Context

See `proposal.md` for motivation. Three records own the Portuguese display name: `SiteLanguage` and `BlogIndexText` in `src/site.gleam`, and `HomeText` in `src/ninjas/home.gleam`. The shared options-row helpers render those `name` fields verbatim, so changing the three fields updates the post, index, and home rows at once. No routes, content files, or templates change; locale-specific fields (`code`, `lang`, `og_locale`, warning descriptions) are independent of `name`.

## Goals / Non-Goals

**Goals:**
- Render "Português" as the Portuguese option on every page with a language options row.
- Keep the existing four-language order, links, current-page marking, and locale declarations intact.

**Non-Goals:**
- Changing the `pt` route, `lang="pt"`, `pt_BR` locale, or any translated copy.
- Rewriting archived OpenSpec change records, which describe the state at the time they shipped.
- Adding a dependency or a blogatto API change.

## Decisions

- **Change the name field in each owning record.** No shared-name module is introduced: the codebase already keeps per-record copy (`SiteLanguage`, `HomeText`, `BlogIndexText`), and only these three fields carry the display name. Alternative: mapping at render time — rejected, since it would add a special case to three shared helpers instead of fixing the data.
- **Pin the behavior with a spec requirement and a test.** A single scenario checks the rendered options row; the build output is inspected to confirm no stale label survives anywhere in `dist/`.
- **No new dependency.** The change is data-only in existing Gleam records.

## Risks / Trade-offs

- [A stale copy of the old label remains in another page record] → Repo-wide search and generated-site inspection verify no "Português (Brasil)" survives outside archived change records.
- [Locale fields might be accidentally changed with the name] → The spec scenario pins `pt`, `pt_BR`, and the `pt` route; the existing tests for those fields continue to pass.
- [CI checks must stay green] → Run `gleam format src test` and `gleam test` before finishing; no dependency or CI version changes.
