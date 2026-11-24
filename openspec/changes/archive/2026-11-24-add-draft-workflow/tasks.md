# Tasks

## 1. Shared configuration and dependency

- [x] 1.1 Add `str` as a direct dependency with `gleam add str` and verify `manifest.toml` records the same locked version already used transitively.
- [x] 1.2 Extract the production post wiring into a shared `post_config(path)` factory and verify `production_blog_config_test` still passes with `post.paths == ["./blog"]`.

## 2. Draft creation

- [x] 2.1 Add the draft CLI, FFI shim, and shared slug/frontmatter helpers, and verify `gleam test` covers title-derived slugs, explicit slugs, unsafe slug rejection, and argument parsing.
- [x] 2.2 Generate blogatto-compatible frontmatter dates and verify a scratch draft previews without a date-format error.

## 3. Isolated preview

- [x] 3.1 Add `blog.preview(site_url, draft_path)` using the shared post config, `.preview` output, and static assets, and verify `draft_preview_blog_config_test` asserts no feeds, sitemap, robots, or routes.
- [x] 3.2 Add the one-shot preview entrypoint and gitignore `.preview/`, and verify a scratch draft produces its post page under `.preview/blog/<slug>/`.

## 4. Live-reload preview server

- [x] 4.1 Add the preview dev-server entrypoint on port 4000 with a validated slug-based build command and verify `task --dry draft.preview -- <slug>` renders that command.

## 5. Promotion and documentation

- [x] 5.1 Add `draft`, `draft.preview`, and `draft.publish` tasks, with translation and variant verification before moving a draft into `blog/`, and verify `task --list` shows the tasks and aliases.
- [x] 5.2 Document the draft workflow in `AGENTS.md` and verify the documented task names match `Taskfile.yml`.

## 6. Integration verification

- [x] 6.1 Run `gleam format src test`, `gleam format --check src test`, and `gleam test`, and verify all pass.
- [x] 6.2 Verify a scratch draft can be created and previewed, then remove the scratch draft and preview output without starting a long-lived server or deploying.

## Workflow follow-up

- Sync the delta spec into `openspec/specs/`.
- Validate all changes and specs.
- Archive the completed change.
