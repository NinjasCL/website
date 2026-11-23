# Design

## Context

See `proposal.md` — Why. The shared blogatto configuration currently calls `config.new(site.site_url)` with the production URL, and the dev server rebuilds with `gleam run -m website`, which reuses that same production URL. Routing, content parsing, post templates, static assets, and the dev host/port are already working and do not need to change.

## Goals / Non-Goals

**Goals:**

- Keep `https://ninjas.cl/` as the site URL for production builds.
- Use `http://127.0.0.1:3000/` as the site URL for dev-server builds so generated links and other absolute URLs stay local.
- Keep one shared configuration builder for output directory, posts, routes, templates, and static assets.
- Make the URL choice explicit at each entrypoint.

**Non-Goals:**

- Changing the dev server host or port.
- Introducing environment-variable configuration or a deployment pipeline.
- Changing content files, routes, templates, or visual output beyond absolute URL selection.

## Decisions

### Parameterize the shared blogatto config

`blog.config` will accept a `site_url` argument and pass it to `blogatto/config.new`. The production and development entrypoints will call it with their own URL instead of branching on an environment variable inside the build.

Alternative considered: read an environment variable in `website.gleam`. Rejected because it hides the distinction inside one entrypoint and makes local behavior depend on shell setup.

### Use explicit production and development URL constants

`site.gleam` will expose `production_url` and `dev_url`. The dev URL will match the existing server address, `http://127.0.0.1:3000/`, including the trailing slash used by the production URL.

Alternative considered: duplicate the URL strings at each call site. Rejected because the URLs are site identity values and should have one source of truth.

### Add a development-only build entrypoint

A new `dev_build` module will call `blogatto.build(blog.config(site.dev_url))`. `dev.gleam` will pass `blog.config(site.dev_url)` to `dev.new` and set the rebuild command to `gleam run -m dev_build`. The production `website` entrypoint will keep `blogatto.build(blog.config(site.production_url))`.

Alternative considered: make the dev server rebuild with `gleam run -m website` and try to override the URL from the server. Rejected because blogatto's dev server only runs the configured command; it does not rewrite generated pages.

## Risks / Trade-offs

- [The dev server port and the dev URL could drift] → Keep both values together in `site.gleam` and verify the dev config URL in tests.
- [Future config changes could be applied to only one entrypoint] → Centralize all settings in `blog.config`; entrypoints only choose the URL.
- [Dev and production builds share `./dist`] → This is existing behavior; the dev server always rebuilds before serving, so verify the output after switching modes.

## Migration Plan

No data or deployment migration is required. Revert the code change to restore the previous production URL in dev builds.

## Open Questions

None.
