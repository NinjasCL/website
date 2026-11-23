# Tasks

## 1. Taskfile

- [x] 1.1 Add a root `Taskfile.yml` with `version: '3.14'`, a `build` task running `gleam run -m website`, and a `dev` task running `gleam run -m dev`; verify `task --list` succeeds and shows both tasks with descriptions.
- [x] 1.2 Run `task build` and verify `dist/index.html` is generated; run `task dev`, verify it serves `http://127.0.0.1:3000`, then stop the server.

## 2. Documentation

- [x] 2.1 Update `README.md` to document `task build` and `task dev`, including the local URL, while retaining the raw Gleam commands; verify the documented task names match `Taskfile.yml`.

## 3. Verification

- [x] 3.1 Run `gleam format --check src test`, `gleam test`, and `openspec validate add-taskfile`; verify all pass.
