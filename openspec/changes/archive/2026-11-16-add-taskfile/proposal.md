# Proposal

## Why

The repository currently exposes two separate commands: `gleam run -m website` to generate the static site into `./dist`, and `gleam run -m dev` to start the local live-reload server. A Taskfile gives contributors short, discoverable commands without changing the underlying Gleam entrypoints.

## What Changes

- Add a root `Taskfile.yml` declaring `version: '3.14'` (minimum Task CLI 3.14; the locally installed Task 3.52.0 is compatible).
- Add a `build` task that runs `gleam run -m website` to generate the blog into `./dist`.
- Add a `dev` task that runs `gleam run -m dev` to start the local development server at `http://127.0.0.1:3000`.
- Document `task build` and `task dev` in `README.md`.
- Keep the raw Gleam commands documented as the underlying entrypoints.

## Capabilities

### New Capabilities

None. This is developer tooling with no spec-level behavior change, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- New file: `Taskfile.yml`.
- Documentation: `README.md`.
- No new dependencies, no `gleam.toml` changes, no CI changes, and no changes to site source, content, routes, or templates.
- Out of scope: `test`, `format`, and `clean` tasks; Task up-to-date caching (`sources`/`generates`); aliases and other features newer than Task 3.14; and changing the build or dev-server entrypoints.
