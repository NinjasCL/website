# Proposal

## Why

The most common action is generating the static site, but `task` with no arguments currently lists available tasks. Making `build` the default task matches the usual task-runner convention and lets contributors run the primary workflow with just `task`.

## What Changes

- Add a `default` task to the root `Taskfile.yml` that depends on `build`.
- Keep the explicit `task build`, `task setup`, and `task dev` commands unchanged.
- Document that running `task` with no arguments builds the site.

## Capabilities

### New Capabilities

None. This is developer tooling with no spec-level behavior change, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- `Taskfile.yml` and `README.md`.
- No new dependencies, no CI changes, and no changes to site source, content, routes, templates, or existing task commands.
- Out of scope: changing the build command itself or adding other default behavior.
