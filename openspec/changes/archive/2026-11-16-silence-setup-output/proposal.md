# Proposal

## Why

The `setup` task currently echoes each command before running it, which makes the toolchain check noisy. The useful output is the Gleam and Erlang/OTP versions; the command lines should stay hidden.

## What Changes

- Set `silent: true` on the `setup` task in `Taskfile.yml`.
- Keep the same preconditions, version checks, and `gleam deps download` behavior.

## Capabilities

### New Capabilities

None. This is developer tooling with no spec-level behavior change, so the change sets `skip_specs: true` in `.openspec.yaml`.

### Modified Capabilities

None.

## Impact

- `Taskfile.yml` only.
- No changes to dependencies, CI, site source, content, routes, templates, or other tasks.
- Out of scope: suppressing output from the underlying tools themselves.
