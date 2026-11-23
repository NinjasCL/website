# Proposal

## Why

New contributors need to confirm that both Gleam and Erlang are available before building the site, and they often need to download dependencies first. A single Taskfile setup command makes that prerequisite check explicit and gives a consistent first step.

## What Changes

- Add a `setup` task to the root `Taskfile.yml`.
- The task verifies that `gleam` and `erl` are on the PATH, prints their versions, and then runs `gleam deps download`.
- Use clear precondition messages when either tool is missing.
- Document `task setup` in `README.md` as the first development step.

## Capabilities

### New Capabilities

None. This is developer tooling with no spec-level behavior change, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- `Taskfile.yml` and `README.md`.
- No new dependencies, no `gleam.toml` changes, no CI changes, and no changes to site source, content, routes, or templates.
- Out of scope: installing Gleam or Erlang automatically, enforcing exact tool versions, and changing the existing `build` or `dev` tasks.
