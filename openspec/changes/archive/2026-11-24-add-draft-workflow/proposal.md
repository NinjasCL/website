# Proposal

## Why

The old Elixir site had a `published` frontmatter flag, but blogatto treats unknown frontmatter as plain strings and has no post filter hook, so a draft flag in `blog/` would still render, feed, and publish the post. Drafts need a filesystem boundary that every existing publisher already respects.

## What Changes

- Add `drafts/<slug>/` as the unpublished content root. Nothing under it is read by the production build, Qiita, feeds, sitemap, manifest, pagination, image optimizer, or translation-by-latest tasks.
- Add a draft creation command that derives a URL-safe slug from the title with `str.slugify`, or uses a validated explicit slug, and writes a Spanish djot source with complete frontmatter.
- Add a single-draft preview build that uses the production post components (`site.post_template`, `post.code`, `post.pre`) through a draft-scoped `blogatto.build`, writing only to git-ignored `.preview/`.
- Add a preview dev server on port 4000 using `blogatto/dev` with blogatto's watcher and live reload.
- Add a promotion task that generates en/ja/pt variants with the existing `task translate` flow before moving the directory into `blog/<slug>/`.
- Publish through `blogatto/config`: share one `post.PostConfig(Nil)` factory between production and preview, changing only `post.path`.

Out of scope:

- No `published` frontmatter flag or blogatto fork.
- No frontmatter parsing changes.
- No Qiita, manifest, pagination, optimizer, sitemap, or feed code changes.
- No automatic FTP deployment after promotion; `task build` and `task upload` remain separate.

## Capabilities

### New Capabilities

- `draft-workflow`: Draft creation, isolation from publishers, single-draft preview with live reload, and translation-inclusive promotion into the published catalog.

### Modified Capabilities

- None. `blog-site-generation`, `blog-dev-server`, and `qiita-publisher` keep their existing requirements; the new behavior is isolated in a new capability.

## Impact

- New Gleam entrypoints: `src/drafts.gleam`, `src/preview.gleam`, `src/preview_local.gleam`, plus `src/drafts_ffi.erl`.
- New shared helper module: `src/ninjas/drafts.gleam`.
- `src/ninjas/blog.gleam` gains a shared post-config factory and a draft preview config.
- `Taskfile.yml` gains `draft`, `draft.preview`, and `draft.publish` tasks.
- New direct dependency `str` (already present transitively) for accent-aware slug generation.
- `.gitignore` gains `/.preview/`; `AGENTS.md` documents the workflow.
- Tests cover slug rules, argument parsing, draft paths, and the preview config.
