# Proposal

## Why

Unknown URLs on ninjas.cl fall to the host's default error behavior, which is not a page at all — the mist dev server returns a bare 404 with an empty body, and static hosts would serve their generic error. The site has no branded way to say a page is missing. The owner picked the perfect retro artifact for it: the `sad_mac.png` shipped in the static assets, beside the message "La página que buscabas está en otro castillo".

## What Changes

- A new not-found view for the site: the shared masthead navbar (as on every non-home page — section links point at the home page and "Inicio" carries no current-page marker), the Sad Mac image served from `/img/sad_mac.png`, the message "La página que buscabas está en otro castillo" as the page's main heading, and the site footer with its copyright and back-to-top link. The main menu and footer sections are kept, per the owner's direction.
- The generated site ships the page at the output root as `dist/404.html` — the static-host convention (GitHub Pages, Netlify, Cloudflare Pages) that turns the file into the site's 404, and a directly visitable page in the dev server. Blogatto's `config.route/2` cannot express a root-level `404.html` file (its builder always writes `<route>/index.html`), so the entrypoints write the rendered page after a successful `blogatto.build`: a new shared helper covers the production build and the dev build, which the live server re-runs on every rebuild.
- Tests pin the view's chrome (navbar without the current-page marker, footer, image, message).

## Capabilities

### New Capabilities
- `site-not-found-page`: Defines the site's 404 page — the Sad Mac and the "otro castillo" message under the shared navbar and footer, shipped as a root-level `404.html` by the build.

### Modified Capabilities
- None. `site-masthead` already requires the masthead on every generated page — the 404 page conforms rather than changing it, and `blog-site-generation` keeps holding as the entrypoint's build grows one extra output file.

## Impact

- `src/site.gleam`: a new `not_found_view/0` following the existing `page/3` + `masthead/2` structure; no existing view changes.
- `src/ninjas/extra_pages.gleam` (new): renders the view and writes `./dist/404.html` after the build. It uses `simplifile`, which this change promotes from a dev dependency (tests only) to a direct dependency — not a new package, it is already locked at 2.7.0 as a transitive dependency of blogatto; `config.route/2`'s insufficiency is documented in design.md.
- `src/ninjas.gleam` and `src/dev.gleam`: call the helper after a successful `blogatto.build`, so production and dev (and the live server's rebuilds) regenerate the page.
- `test/ninjas_test.gleam`: a not-found test rendering the view.
- No stylesheet change: the view reuses the existing panel, figure, and centering styles.

## Out of scope

- Dev-server unknown-path handling: the mist server keeps returning its empty-body 404 for arbitrary unknown URLs — the change ships the `404.html` convention file, it does not patch blogatto's server.
- Extra error-page chrome (hit counters, "under construction" bars, a dedicated back-home button) — the navbar already links home.
- Sitemap or feed entries for the error page — it is not site content and stays out of both.
