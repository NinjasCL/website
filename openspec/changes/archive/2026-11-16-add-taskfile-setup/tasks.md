# Tasks

## 1. Setup task

- [x] 1.1 Add a `setup` task to `Taskfile.yml` that preconditions on `gleam` and `erl`, prints both versions, and runs `gleam deps download`; verify `task --list` shows the task and `task setup` completes successfully.
- [x] 1.2 Update `README.md` to document `task setup` as the first development step; verify the documented task name matches `Taskfile.yml`.

## 2. Verification

- [x] 2.1 Run `gleam format --check src test`, `gleam test`, and `openspec validate add-taskfile-setup`; verify all pass.
