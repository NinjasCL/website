# Design

## Context

See proposal.md - Why. The build pipeline is blogatto 8.0.0: `blogatto.build/1` cleans the output directory, copies `static/`, then builds posts, `config.route/2` pages, feeds, and sitemap. The project's two entrypoints (`src/ninjas.gleam` production, `src/dev.gleam` dev) each call `blogatto.build`; the live dev server (`src/ninjas/local.gleam`) re-runs the dev entrypoint as its rebuild command. Views live in `src/site.gleam` (`page/3`, `masthead/2`, `site_footer/0`).

Routing constraint: blogatto's page builder computes every route's output as `<output_dir>/<route>/index.html` (`blogatto/internal/path.route/2`), so `config.route("/404.html", …)` would produce `dist/404.html/index.html` — a directory, not the root-level file the static-host convention requires.

## Goals / Non-Goals

**Goals:**
- Ship a branded `dist/404.html` from the normal build commands, regenerating on every build.
- Reuse the site chrome exactly: `masthead(on_home: False)` (navbar only — the owner asked to keep the main menu, not a hero) and `site_footer()`.
- Keep the view pure and testable like the other views.

**Non-Goals:**
- Patching the dev server's unknown-path behavior (still a bare 404; the page is visitable at `/404.html`).
- Sitemap/RSS inclusion of the error page.
- New styling — the view composes existing retrostrap classes.

## Decisions

1. **Post-build write instead of `config.route/2`.** An existing blogatto feature is insufficient: routes always append `index.html`, so no route can yield a root-level `404.html`. The entrypoints therefore call a shared helper after a successful `blogatto.build`. Because the build's first step wipes the output directory, the write must come after `build` returns — never before. The dev entrypoint is the live server's rebuild command, so dev rebuilds regenerate the file with no extra wiring.
   - Alternative rejected: hand-authoring `static/404.html` (copied verbatim to `dist`) — it would fork the navbar/footer markup from the Lustre views and drift immediately.
   - Alternative rejected: `route("/404")` (`dist/404/index.html`) — GitHub Pages and most static hosts only honor the `404.html` file, so it would never be served as the error page.

2. **Helper placement: new `src/ninjas/extra_pages.gleam`.** Both entrypoints need it; `ninjas/blog.gleam` is the shared config builder, so the IO-coupled writer gets its own small module (`pub fn write_not_found() -> Result(Nil, String)`) rather than stretching the config module's role. It renders `site.not_found_view()` with `element.to_document_string` and writes it via `simplifile`.
   - Dependency note: `simplifile` is today a dev dependency (usable only from `test/`); main-source imports need it in `[dependencies]`. The change moves the existing requirement (`>= 2.7.0 and < 3.0.0`) from `[dev_dependencies]` to `[dependencies]` in `gleam.toml` and refreshes the lock with `gleam deps download` — no new package, the version is already pinned at 2.7.0 transitively through blogatto.

3. **View structure: `site.not_found_view/0`.** `page(title: "404 — " <> site_title, description: <the message>, body: [masthead(on_home: False, children: []), html.main([id "main"], [content]), site_footer()])`. The content is one sunken panel with the Sad Mac figure (existing `rs-figure` classes, `alt` describing the image) and the message as the page's only `h1` — mirroring how each existing page keeps exactly one main heading. No hero children: the owner scoped the page to main menu + footer + content.

4. **Accessibility/semantics.** The message is the `h1` (the page's statement), the image carries a descriptive alt (it is content, not decoration), and the skip link and `#main` anchor from `page/3` apply unchanged.

## Risks / Trade-offs

- [A future blogatto version could add a first-class error-page config] → The helper is a thin seam: swapping it for a native config option later touches only `extra_pages.gleam` and the two entrypoints.
- [Hosts without the 404.html convention] → Unknown URLs fall back to the host default; the file still serves as a visitable page and covers GitHub Pages, Netlify, and Cloudflare Pages.
- [The write step runs outside blogatto's error reporting] → The helper returns a `Result` the entrypoints surface like the build's own errors, so a failed write is visible rather than silent.
