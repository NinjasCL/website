# Proposal

## Why

The Taskfile commands are useful but longer to type than necessary. Short aliases make the common setup, build, and dev actions faster while keeping the full task names available.

## What Changes

- Bump the Taskfile `version` from `3.14` to `3.17`, the first Task release that supports aliases.
- Add `s`, `b`, and `d` as aliases for `setup`, `build`, and `dev`.
- Document the aliases in `README.md`.
- Keep the existing task names and behavior unchanged.

## Capabilities

### New Capabilities

None. This is developer tooling with no spec-level behavior change, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- `Taskfile.yml` and `README.md`.
- No new dependencies, no CI changes, and no changes to site source, content, routes, or templates.
- The Taskfile now requires Task `v3.17.0` or newer.
- Out of scope: adding aliases for other tasks or changing the default task.
