# Tasks

## 1. Silence setup output

- [x] 1.1 Add `silent: true` to the `setup` task; verify `task setup` prints only the Gleam and Erlang/OTP version output, without `task: [setup]` command lines.
- [x] 1.2 Run `gleam format --check src test`, `gleam test`, and `openspec validate silence-setup-output`; verify all pass.
