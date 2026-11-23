# Tasks

## 1. Add aliases

- [x] 1.1 Bump `Taskfile.yml` to `version: '3.17'` and add aliases `s`, `b`, and `d` to `setup`, `build`, and `dev`; verify `task s`, `task b`, and `task --dry d` resolve to the intended tasks.
- [x] 1.2 Update `README.md` to document the aliases; verify the documented aliases match `Taskfile.yml`.

## 2. Verification

- [x] 2.1 Run `gleam format --check src test`, `gleam test`, and `openspec validate add-taskfile-aliases`; verify all pass.
