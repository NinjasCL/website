# Design

## Context

The current build entrypoint in `src/website.gleam` contains the blogatto config inline and is invoked with `gleam run`. Blogatto's dev server needs to run the build command as a subprocess, so the config must be reusable by both entrypoints. See the blogatto dev server documentation and `proposal.md` for the requested workflow; this document covers the local implementation choices.

## Goals / Non-Goals

**Goals:**
- Share one blogatto config between the production build and the dev server.
- Provide a single command to run a local server with file watching, auto-rebuild, and live reload.
- Keep the existing site output, routes, templates, and content unchanged.

**Non-Goals:**
- Docker/dev containers, deployment changes, custom asset pipelines, or new content features.
- Changing the default blogatto dev-server behavior beyond the project command and port.

## Decisions

### 1. Extract configuration into `src/blog.gleam`
- **Decision:** Move the `PostConfig` and `Config` construction from `src/website.gleam` into `pub fn config() -> config.Config(Nil)` in `src/blog.gleam`, importing `site` for views and constants.
- **Rationale:** Both the build entrypoint and the dev server can call `blog.config()`; this matches the blogatto setup guidance and keeps routes/templates in one place.
- **Alternatives:** Put `config()` in `src/site.gleam` — viable, but a dedicated `blog` module keeps the entrypoint boundary clear and mirrors the docs.

### 2. Keep `src/website.gleam` as the build entrypoint
- **Decision:** `src/website.gleam` calls `blogatto.build(blog.config())` and reports success/failure.
- **Rationale:** Preserves the existing `gleam run` build command and keeps production generation separate from development serving.

### 3. Add `src/dev.gleam` as the dev entrypoint
- **Decision:** Build the server with `blogatto/dev`:
  ```gleam
  blog.config()
  |> dev.new()
  |> dev.build_command("gleam run -m website")
  |> dev.port(3000)
  |> dev.start()
  ```
  Use the default host (`127.0.0.1`) and live reload (`True`).
- **Rationale:** `dev.new` derives watched paths from the shared config (`src/` always, plus post paths and static dir); the explicit build command avoids relying on the default module. Port 3000 is blogatto's default and the documented local URL.
- **Alternatives:** `gleam run` as the build command (works today but is implicit), or a custom shell script (unnecessary).

### 4. Document the workflow in `README.md`
- **Decision:** Add the dev server command (`gleam run -m dev`) and local URL, alongside the existing build/test commands.
- **Rationale:** The dev server needs a separate entrypoint, so the command is not discoverable from the existing README.

## Risks / Trade-offs

- **[Risk] Dev server blocks the terminal and rebuilds via a subprocess** → Expected behavior; document that it stops with Ctrl+C.
- **[Risk] Port 3000 may already be in use** → Use `dev.port(...)` in `src/dev.gleam` if needed; the server returns an error when binding fails.
- **[Risk] File watching on Linux requires `inotify-tools`** → Note the platform requirement in the README or troubleshooting section; macOS uses FSEvents without extra setup.
- **[Risk] Rebuild command uses the same project while the dev server runs** → Blogatto shells out to `gleam run -m website`, which compiles and rebuilds independently; keep the dev server entrypoint separate from the build entrypoint.

## Migration Plan

- No content or route migration. Implement the shared config, update `src/website.gleam`, add `src/dev.gleam`, and verify both `gleam run` and `gleam run -m dev`.
- Rollback: remove the dev entrypoint and inline config changes, restoring the previous single-entrypoint build.

## Open Questions

- None blocking; port/host can be adjusted later without changing the dev-server capability contract.
