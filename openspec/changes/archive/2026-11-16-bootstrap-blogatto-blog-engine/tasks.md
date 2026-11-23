# Tasks

## 1. Content and output conventions

- [x] 1.1 Create the core site directories and conventions (`blog/` for posts, `static/` for assets) and ensure generated output is ignored by updating `.gitignore` to include `dist/` if missing; verify the directories exist and `git status` does not show `dist/` as trackable after a local build directory is created.
- [x] 1.2 Add a minimal sample Markdown post in `blog/` with valid blogatto frontmatter (`title`, `date`, `description`, and content) for Ninjas.cl; verify the file is present and contains the required frontmatter fields.

## 2. Blogatto core implementation

- [x] 2.1 Implement the Ninjas.cl blogatto configuration and build entrypoint in `src/website.gleam` using `blogatto.build` and `blogatto/config`/`blogatto/config/post` APIs (site URL `https://ninjas.cl/`, output `./dist`, static `./static`, posts from `./blog` with route prefix `blog`); verify `gleam run` completes without build errors.
- [x] 2.2 Implement the home route/view (`config.route("/", ...)`) and post template (`post.template(...)`) with Lustre to render Ninjas.cl identity (title, description, `es-CL` language context), a post listing on the home page, and per-post pages including rendered content; verify `gleam run` generates `dist/index.html` and a corresponding post page under the configured blog route containing the sample post.

## 3. Verification and quality checks

- [x] 3.1 Run `gleam format src test` and verify formatting is applied successfully.
- [x] 3.2 Run `gleam format --check src test` and verify it passes.
- [x] 3.3 Run `gleam test` and verify it passes. If deterministic helper logic is introduced during implementation, add or update tests in `test/` to cover it and verify they pass as part of this command.