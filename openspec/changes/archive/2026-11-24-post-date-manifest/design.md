# Design

## Context

See `proposal.md` for motivation. `website-manifest.json` is a committed file maintained by three separate writers: the image optimizer (`tools/optimize/optimize.py`), the FTP planner (`tools/ftp/ftp_sync.erl`), and now the production build. The build is the only step that knows all post sources, while the other two rewrite the whole manifest with a fixed set of top-level sections.

## Goals / Non-Goals

**Goals:**

- Derive the date data from the same djot frontmatter blogatto already reads.
- Keep the manifest valid and stable across repeated builds and tool rewrites.
- Make the newest post discoverable without scanning or sorting the whole section.

**Non-Goals:**

- Rendering dates in pages, feeds, or navigation.
- Changing the image or FTP cache formats or their hashing rules.
- Reading translated variants; the default `index.djot` is the source of truth.

## Decisions

- **A dedicated Gleam module runs after a successful production build.** The build entrypoint is the only place that already loads the full content, and failing the build if post dates cannot be computed prevents a silently stale manifest. The dev-URL build is intentionally not involved.
- **Dates are normalized with `gleam/time` and compared lexically.** Blogatto stores `YYYY-MM-DD HH:MM:SS ±HH:MM`; converting to UTC RFC 3339 gives directly comparable strings and a stable recorded format.
- **Sections are updated in place rather than by full JSON re-serialization.** The manifest is human-reviewed and holds hashes whose ordering other tools control, so only the two top-level blocks are replaced and all other bytes are left intact.
- **Both writers are extended explicitly.** The optimizer's fixed-order dict and the FTP planner's fixed pair list are the only places that drop unknown sections; adding the two keys there preserves them through `task upload`, where optimization runs before the build and FTP commit runs after it.
- **`latest_post` is explicit even though `posts` is ordered.** Rewriting tools may normalize object order, so the newest post has its own named section.

## Risks / Trade-offs

- A post missing `slug`, `date`, or a parseable date fails the build → the error names the offending source path so it can be fixed.
- The in-place section update assumes the manifest's two-space-per-level formatting → tests cover replacement, insertion before the FTP section, and idempotency.
- A date-only change to a post alters the manifest and therefore the FTP cache planning input → the post pages themselves are hashed independently by the planner, so this does not force unrelated uploads.

## Migration Plan

The first build adds both sections to the committed manifest. Existing image and FTP cache entries are untouched. Rollback is a plain revert of the manifest diff and the source changes.

## Open Questions

None.
