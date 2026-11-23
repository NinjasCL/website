# Proposal

## Why

The home page's "🔮 Proyectos" and "📚 Libros" showcase images are loaded from remote hosts: the project logos from `avatars.githubusercontent.com` and `raw.githubusercontent.com`, the book covers from `https://ninjas.cl/covers/…`. That makes the home page depend on third-party availability and keeps the showcases inconsistent with the about portrait, which is already served from the site's own assets. The four project logos (Elixir Chile, Joy of ProcessWire, Proyecto Chaucha, Ninja Systems) have in fact already been downloaded into `static/img/` as `elixircl.png`, `joyofpw.png`, `chaucha.png`, and `Ninjas.png` — but the code still points at the remote URLs, and the four book covers are not on disk at all.

## What Changes

- Download the four book covers into `static/img/` from their current production URLs: `superclubnet.jpg`, `elixir-fullstack.jpg`, `wren-libro.jpg`, and `quirquincho.jpg` (from `https://ninjas.cl/covers/…`, verified reachable today).
- Repoint all eight showcase images in `src/site.gleam` — the four "Proyectos" logos and the four "Libros" covers — from remote URLs to the site's own `/img/…` asset paths. The `showcase_card` helper, `ShowcaseItem` shape, alt texts, and retrostrap figure sizing are unchanged; no styling is involved.
- Out of scope:
  - The "🎮 Juegos" showcase images — they keep their current remote URLs (a natural follow-up change).
  - The masthead/hero logo (`https://ninjas.cl/img/Ninjas.png`) — not part of the proyectos/libros showcases.
  - Any image editing or resizing: files are stored exactly as downloaded, and `rs-figure` sizing keeps handling proportions.
  - Any new dependency: downloading is a one-time asset fetch, and blogatto already copies `static/` into the generated site.

## Capabilities

### New Capabilities
- `site-showcase-images`: Serving of the home page's "Proyectos" and "Libros" showcase images from the site's own static assets under `/img/` — no remote image hosts in those two sections.

### Modified Capabilities

None. The about portrait's local serving is already covered by the `site-about-section` delta from the `about-image-full-width` change; no existing main spec (`blog-dev-server`, `blog-site-generation`, `site-masthead`) covers showcase images.

## Impact

- `static/img/`: four added cover files; the four already-downloaded logos are reused as-is.
- `src/site.gleam`: the eight `image:` fields in `projects_section` and `books_section` change from remote URLs to `/img/…` paths. No routing, content, template, or build-configuration changes.
- `test/ninjas_test.gleam`: gains assertions that the rendered home page uses the local image paths and no longer references the remote hosts unique to proyectos/libros (`avatars.githubusercontent.com`, `raw.githubusercontent.com/ElixirCL`, `ninjas.cl/covers`).
- No `gleam.toml`, `manifest.toml`, or CI changes.
