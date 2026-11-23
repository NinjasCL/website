# Tasks

## 1. Shared configuration

- [x] 1.1 Create `src/blog.gleam` with `pub fn config()` returning the existing Ninjas.cl blogatto configuration (site URL, output/static directories, post path/prefix/template, and home route), and update `src/website.gleam` to build from `blog.config()`; verify `gleam run` still generates `dist/index.html` and the sample post page.
- [x] 1.2 Add a test that `blog.config()` exposes the expected site URL, output directory, static directory, and post source path; verify `gleam test` passes.

## 2. Dev server entrypoint

- [x] 2.1 Add `src/dev.gleam` using `blogatto/dev` with `blog.config()`, `dev.build_command("gleam run -m website")`, `dev.port(3000)`, and `dev.start()`, reporting errors; verify `gleam run -m dev` starts and serves the home page at `http://127.0.0.1:3000/`.
- [x] 2.2 Verify the served HTML includes the blogatto live-reload script and that touching a watched file triggers a rebuild; stop the dev server after verification.

## 3. Documentation and verification

- [x] 3.1 Update `README.md` with the build command (`gleam run`), dev server command (`gleam run -m dev`), and local URL; verify the documented dev command starts the server.
- [x] 3.2 Run `gleam format src test`, `gleam format --check src test`, and `gleam test`; verify all pass.
- [x] 3.3 Run `openspec validate add-blogatto-dev-server`; verify it passes.