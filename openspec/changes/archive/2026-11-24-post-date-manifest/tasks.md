# Tasks

## 1. Build-time date collection

- [x] 1.1 Read each default-language post's `slug` and `date` frontmatter and normalize dates to UTC RFC 3339, verified by `test/manifest_test.gleam` and `gleam test`.
- [x] 1.2 Write a `posts` section keyed by slug and ordered newest first, plus a `latest_post` section, verified by ordering assertions in `test/manifest_test.gleam`.
- [x] 1.3 Update the sections in place without changing other manifest content, verified by an idempotency test and a cache-preservation assertion in `test/manifest_test.gleam`.
- [x] 1.4 Call the update from the production build entrypoint and report the recorded count, verified by `task build` output and the resulting `website-manifest.json`.

## 2. Manifest writer preservation

- [x] 2.1 Carry `posts` and `latest_post` through the optimizer's manifest round trip, verified by `test_post_dates_survive_manifest_rewrite` and `task -d tools/optimize test`.
- [x] 2.2 Carry `posts` and `latest_post` through the FTP planner's manifest round trip, verified by `manifest_keeps_post_dates_when_ftp_cache_changes_test` and `tools/ftp/tests/run_tests.escript`.

## 3. Integration and verification

- [x] 3.1 Document the new manifest sections in `README.md`, verified by reading the manifest description.
- [x] 3.2 Run `gleam format src test` and `gleam test`, verified by clean output with no failures.
- [x] 3.3 Run `task build` and confirm the manifest lists all posts newest first with the correct `latest_post`, verified by inspecting `website-manifest.json`.
