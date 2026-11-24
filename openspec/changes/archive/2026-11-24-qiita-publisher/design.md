# Design

## Context

See `proposal.md` for motivation. The site is a static Gleam/blogatto build with no server-side runtime, so exporting to Qiita is a separate command rather than a build step. Japanese sources live at `blog/<slug>/index-ja.djot` and use the same flat frontmatter blogatto reads. No blogatto route, template, or build output is affected.

## Goals / Non-Goals

**Goals:**

- Turn an existing Japanese djot source into a publishable Qiita item without hand-editing.
- Keep export generation deterministic and local, so it can be reviewed before publication.
- Make publication safe to repeat by remembering which remote item a file represents.

**Non-Goals:**

- Changing the generated site or its deployment.
- Translating or rewriting post content beyond the djot-to-CommonMark conversion Qiita requires.
- Automatic publication as part of the build or upload pipeline.

## Decisions

- **Dedicated Gleam entrypoint with a small Erlang shim.** Gleam's main cannot read process arguments or environment variables directly, so `qiita_ffi.erl` exposes both as binaries. This keeps argument and token handling testable in Gleam.
- **Generation and publication are separate actions.** `--generate` (the default) only writes TOML; `--publish` only reads TOML and calls Qiita. This prevents a network side effect from a routine export and lets a reviewer inspect the exact body before publishing.
- **Post selection resolves to a directory.** A slug, post path, or Japanese source path all normalize to the post directory, which is where the export is written and where publication looks for it. The latest post is chosen by comparing normalized UTC dates, so lexical order is chronological.
- **New dependencies are limited to parsing and HTTP.** `tom` reads the generated file for publication; `gleam_json` decodes Qiita's item-id response and encodes the request body. Blogatto has no export facility, and using it would couple publication to the static build. `gleam/httpc` and `gleam/time` are already available through the dependency tree.
- **The item id is written back into the TOML.** Creation uses `POST /api/v2/items` and later publications use `PATCH /api/v2/items/<id>`, so repeated runs converge on one item instead of creating duplicates.
- **Token lookup prefers `.env` over the process environment.** A blank `.env` value is treated as absent so an exported token still works.

## Risks / Trade-offs

- The djot-to-CommonMark conversion covers the constructs the shipped posts use; an unsupported djot feature would pass through verbatim → the generated body is committed beside the post and can be reviewed before publication.
- Publication depends on a valid `QIITA_TOKEN` and network access → failures are reported with the HTTP status or reason, and no item id is stored on failure.
- A published file can drift from its source until regeneration → publication intentionally uses the stored file so a reviewer controls what goes out.

## Migration Plan

No migration is required. The command is additive; existing posts and the build are unchanged. The first publication creates the remote item and stores its id.

## Open Questions

None.
