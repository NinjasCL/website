# Tasks

## 1. Command surface and post selection

- [x] 1.1 Parse `--generate`, `--publish`, `--all`, `--help`, and one optional post selector; reject unknown options and conflicting combinations, verified by `test/qiita_test.gleam` and `gleam test`.
- [x] 1.2 Resolve a slug, post path, or Japanese source path to a post directory and choose the latest Japanese post by normalized date, verified by tests in `test/qiita_test.gleam`.
- [x] 1.3 Add the Erlang shim for CLI arguments and environment variables and wire the `qiita` entrypoint, verified by `gleam build` and `gleam run -m qiita -- --help`.

## 2. Export generation

- [x] 2.1 Read Japanese frontmatter into title, slug, UTC date, and tags with safe defaults, verified by metadata tests in `test/qiita_test.gleam`.
- [x] 2.2 Convert the Japanese djot body to CommonMark with absolute site-root asset URLs and empty item id, verified by conversion tests in `test/qiita_test.gleam`.
- [x] 2.3 Write a `qiita.toml` for the selected post or catalog without any network call, verified by generation tests and `gleam test`.

## 3. Publication

- [x] 3.1 Resolve `QIITA_TOKEN` from `.env` with an environment fallback, verified by token tests in `test/qiita_test.gleam`.
- [x] 3.2 Build create/update requests from an existing TOML and decode the returned item id, verified by request and response tests.
- [x] 3.3 Store a newly returned item id back in the TOML and leave an existing id unchanged, verified by publication tests and `gleam test`.

## 4. Integration and verification

- [x] 4.1 Add `task qiita` and `task qiita.publish` selectors plus the `QIITA_TOKEN` template entry, verified by reading `Taskfile.yml` and `env.txt`.
- [x] 4.2 Run `gleam format src test` and `gleam test`, verified by clean output with no failures.
