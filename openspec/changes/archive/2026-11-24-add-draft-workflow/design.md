# Design

## Context

See `proposal.md` for motivation. The current site and every publisher enumerate `./blog` directly; blogatto discovers all post sources under configured paths and exposes no post filter or public single-djot renderer. Unknown frontmatter values are plain strings, so a `published` flag cannot suppress rendering. The dev server already serves a configured output directory and injects live reload at response time.

## Goals / Non-Goals

**Goals:**

- Make “unpublished” a filesystem property that all existing consumers already honor.
- Reuse the production post rendering pipeline for preview output without duplicating djot rendering.
- Keep preview generation outside `build/` and `dist/`.
- Make promotion safe: translate first, verify, then move.
- Keep CLI inputs from escaping `drafts/` or being injected into the preview rebuild command.

**Non-Goals:**

- No blogatto fork, internal-module import, or frontmatter flag.
- No draft listing page or multi-draft preview.
- No automatic build or FTP upload after promotion.
- No changes to Qiita, manifest, feed, sitemap, pagination, or optimizer logic.

## Decisions

### Use `drafts/<slug>/` as the only draft boundary

Blogatto, Qiita, the manifest updater, pagination, the optimizer, and the translate-by-latest task all scan `./blog`. Keeping drafts outside that directory excludes them without adding filters to each consumer. Promotion is an explicit directory move into `blog/<slug>/`, which is auditable in git.

Alternative considered: a `published: false` frontmatter field. Rejected because blogatto parses it as an inert string and renders every discovered source anyway.

### Share one post configuration factory

`src/ninjas/blog.gleam` owns one `post.PostConfig(Nil)` builder that sets the source path, `blog` route prefix, `site.post_template`, and the site's code/pre components. Production passes `./blog`; preview passes one `./drafts/<slug>` path. This preserves highlighting and custom `github`, `ninjas`, `youtube`, and `embed` fences.

Alternative considered: hand-build a `Post` and call `site.post_template` directly. Rejected because `Post.contents` would have to be re-rendered with blogatto's internal djot component pipeline, which is not public.

### Build preview into `.preview/`

Each `blogatto.build` recursively deletes its own output directory. Preview output therefore uses a dedicated `.preview/` root, which is git-ignored. `build/` belongs to Gleam compilation and `dist/` belongs to production output; neither is safe for a second independent build.

Alternative considered: Python's `http.server`. Rejected because blogatto's Gleam/Mist dev server already serves the output directory, watches configured paths, and sends live-reload events.

### Run the selected draft through the dev server's build command

`preview_local` validates the slug, constructs `gleam run -m preview -- <slug>`, and passes it to `blogatto/dev`. The slug validator permits only lowercase letters, digits, and internal hyphens, so the shell command cannot be extended with extra arguments or path traversal.

### Generate the slug with `str`

`str` was already present transitively through blogatto. Promoting it to a direct dependency makes `str.slugify` an explicit API contract; it folds Spanish accents to ASCII, which keeps draft directory names and generated URLs stable. Explicit slugs are validated rather than silently rewritten.

### Generate a blogatto-compatible date

Blogatto's frontmatter parser accepts `YYYY-MM-DD HH:MM:SS +00:00`, not RFC3339 with fractional seconds. Draft creation formats the current UTC time accordingly so a newly created draft previews without edits.

### Translate before moving

Promotion calls the existing `task translate` against the draft path, verifies the three translated files, then moves the directory. A translation failure leaves the draft intact and never creates an incomplete published post.

## Risks / Trade-offs

- **OpenCode translation may fail or write partial variants** → promotion verifies all three files before moving and leaves the draft in place on failure.
- **Preview output is replaced on every preview build** → safe because it is disposable and git-ignored; no production output is touched.
- **Explicit slugs are shell and path inputs** → validation restricts them to a safe lowercase ASCII subset and rejects leading/trailing separators.
- **Drafts have no index or discovery task** → accepted for this change; users pass a slug to preview and promotion commands.
- **Promotion does not rebuild or deploy** → deliberate separation from `task build` and `task upload`, consistent with the rest of the project.

## Migration Plan

1. Add the draft commands, shared config helper, preview entrypoints, and tests.
2. Add `drafts/` and `.preview/` documentation and gitignore rules.
3. Verify with `gleam format src test`, `gleam format --check src test`, `gleam test`, and a scratch draft preview build.
4. No content migration is required; existing posts remain in `blog/`.

## Open Questions

None.
