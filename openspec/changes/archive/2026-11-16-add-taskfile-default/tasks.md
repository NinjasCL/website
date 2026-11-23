# Tasks

## 1. Default task

- [x] 1.1 Add a `default` task to `Taskfile.yml` that depends on `build`; verify `task --list` shows it and running `task` generates `dist/index.html`.
- [x] 1.2 Update `README.md` to document that `task` with no arguments builds the site; verify the documented behavior matches `Taskfile.yml`.

## 2. Verification

- [x] 2.1 Run `gleam format --check src test`, `gleam test`, and `openspec validate add-taskfile-default`; verify all pass.
