# Proposal

## Why

Building the Ninjas.cl site currently requires running `gleam run` manually and refreshing the browser after every content or source change. Blogatto includes a development server with file watching, automatic rebuilds, and live reload; configuring it will make local iteration faster and keep the build and development entrypoints consistent.

## What Changes

- Extract the Ninjas.cl blogatto build configuration from `src/website.gleam` into a shared module so both the production build and the development server use the same config.
- Add a dedicated development entrypoint that starts blogatto's dev server with the shared config.
- Configure the dev server to rebuild with `gleam run -m website` and serve the generated site locally on the default blogatto host/port (`127.0.0.1:3000`), watching `src/`, `blog/`, and `static/`.
- Document the dev server command in `README.md`.
- Use blogatto/Gleam APIs: `blogatto/dev` (`dev.new`, `dev.build_command`, `dev.port`, `dev.start`), `blogatto/config`, and `blogatto/config/post`.

## Capabilities

### New Capabilities
- `blog-dev-server`: Local development workflow for the Ninjas.cl blog, including shared build configuration, file watching, automatic rebuilds, live reload, and serving the generated site.

### Modified Capabilities
<!-- None: no existing main specs under openspec/specs/. -->

## Impact

- **Code:** new shared config module (e.g. `src/blog.gleam`), update `src/website.gleam` to use it, and add a dev entrypoint (e.g. `src/dev.gleam`).
- **Dependencies:** no new packages; `blogatto/dev` is part of the existing `blogatto >= 8.0.0 and < 9.0.0` dependency.
- **Documentation:** `README.md` gains the dev server command and local URL.
- **Out of scope:** production deployment, Docker/dev containers, external build pipelines (e.g. Tailwind), changing the blog routes/templates, and adding new content features.