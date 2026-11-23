# Proposal

## Why

The `ninjas.cl` website repository currently has no blog engine implementation (`src/website.gleam` is a placeholder), but the project is intended to be built with blogatto. This change bootstraps the core blogatto-based static site generation so the site can be built and extended with Ninjas.cl identity and content.

## What Changes

- Replace the placeholder entrypoint in `src/website.gleam` with a blogatto build configuration that generates the site.
- Configure the site for Ninjas.cl: `site_url` `https://ninjas.cl/`, title `Ninjas.cl`, Spanish (Chile, `es-CL`) default language context, and the provided site description.
- Add core content and rendering conventions: a posts source directory with blogatto-compatible Markdown/frontmatter, a post page template, and a home route that lists posts.
- Establish static asset and output conventions for generation (e.g. `static/` input and `dist/` output) and include a minimal sample post/content needed to verify core generation.
- Reference blogatto/Gleam APIs such as `blogatto.build`, `blogatto/config` (`config.new`, `output_dir`, `static_dir`, `post`, `route`), `blogatto/config/post` (`post.default`, `post.path`, `post.route_prefix`, `post.template`), `blogatto/post` (`Post`), and Lustre elements for views/templates.

## Capabilities

### New Capabilities
- `blog-site-generation`: Core static blog/site generation for Ninjas.cl using blogatto, including site configuration, post loading/rendering, home and post routes, and build output.

### Modified Capabilities
<!-- None: no existing main specs under openspec/specs/. -->

## Impact

- **Code:** `src/website.gleam` (and any supporting modules added for views/templates/config helpers).
- **Content/assets:** new content directories/files for posts and static assets; generated `dist/` output (must remain uncommitted). May require `.gitignore` update for generated output.
- **Dependencies:** uses existing `blogatto >= 8.0.0 and < 9.0.0`; declares the already-locked `lustre` and `gleam_time` packages as direct dependencies for views/date formatting, without changing locked versions or the blogatto range.
- **Out of scope:** RSS/Atom feeds, sitemap, robots.txt, content migration from an existing Ninjas.cl source, custom styling/theme parity beyond minimal core templates, multilingual post variants (`index-{lang}.md`) beyond setting the default site language context, non-blog pages beyond the home/index route, and deployment pipeline changes. Routing/content-directory specifics not mandated above follow standard blogatto conventions and are recorded in `design.md` as assumptions.