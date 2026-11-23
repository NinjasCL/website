# Tasks

## 1. URL-aware configuration

- [x] 1.1 Add `production_url` and `dev_url` constants to `site.gleam`, parameterize `blog.config` with a `site_url`, and update the production and dev entrypoints and tests to pass the correct URL; verify `gleam test` passes and both config URLs are asserted.
- [x] 1.2 Add a `dev_build` entrypoint that builds with `site.dev_url`, wire the dev server rebuild command to it, and verify `gleam run -m dev_build` generates local URLs while `gleam run -m website` keeps production URLs; run `gleam test`.

## 2. Documentation and integration

- [x] 2.1 Update `README.md` to state that production builds use `https://ninjas.cl/` and the dev server uses `http://127.0.0.1:3000/`; verify the documented values match `site.gleam` and run `gleam format --check src test`.
- [x] 2.2 Start the dev server, request the home page, confirm its links use the local URL, then stop the server; run `gleam test`, `gleam format --check src test`, and `openspec validate fix-dev-server-site-url`.

## Workflow follow-up

- Archive the change after the project's review requirements are satisfied.
- Verify the archived result.
