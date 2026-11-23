# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `static/img/` already holds the four project logos as valid PNGs — `elixircl.png` (1007×1343), `joyofpw.png` (460×460), `chaucha.png` (376×376), `Ninjas.png` (2117×2716) — plus the about portrait `camilo.jpg`. The code ignores them: `projects_section` still points at `avatars.githubusercontent.com`, `raw.githubusercontent.com/ElixirCL/…`, and `https://ninjas.cl/img/Ninjas.png`.
- The four book covers are not on disk. `books_section` points at `https://ninjas.cl/covers/{superclubnet,elixir-fullstack,wren-libro,quirquincho}.jpg`, all verified reachable (`HTTP 200` today).
- blogatto copies the configured static directory (`./static`, see the `production_blog_config_test`) verbatim into the generated site — the same mechanism that already serves `/img/camilo.jpg`. The `ShowcaseItem.image` field is a plain string passed straight to the `img` `src`, so a local path works exactly like a remote URL.
- The games showcase still uses `raw.githubusercontent.com/NinjasCL/…` and other remote hosts — those URLs must survive untouched.

Routing, content files, and templates are not affected: no routes change, nothing under `blog/` changes, and `showcase_card` renders local paths identically to remote ones.

## Goals / Non-Goals

**Goals:**

- All eight "Proyectos" + "Libros" images load from `/img/…` on the generated site, with the four covers present in `static/img/`.
- Reuse the already-downloaded logos as-is, with no renaming or re-fetching.

**Non-Goals:**

- No image resizing, compression, or format conversion — files are stored exactly as fetched; retrostrap `rs-figure` sizing keeps handling proportions.
- No fetching code in Gleam, no build-time download step, no new dependency.
- Games images and the hero logo stay as they are (spec guard).

## Decisions

1. **Covers land flat in `static/img/`, keeping their production basenames** (`superclubnet.jpg`, `elixir-fullstack.jpg`, `wren-libro.jpg`, `quirquincho.jpg`). The old→new mapping is then mechanical (`https://ninjas.cl/covers/X.jpg` → `/img/X.jpg`), and the section mixes logos and covers under one convention, like `img/` already does. Alternative rejected: a separate `static/covers/` directory — the request is to serve from `img`, and a second directory adds a second convention for the same purpose.
2. **The covers are fetched with plain `curl` into `static/img/` as a one-time apply step**, following the `camilo.jpg` precedent from `about-image-full-width`. blogatto's static-asset copy already ships them; nothing in Gleam needs to know how the files arrived. Alternative rejected: a Gleam-side fetcher (new `gleam_http` code or a Taskfile step) — four one-time binaries don't justify network code that CI would then depend on. No new dependency is needed; blogatto's `static_dir` copy is the sufficient existing feature.
3. **The code change is eight `image:` field edits** in `projects_section` and `books_section`, mapping each card to the on-disk name: Elixir Chile → `/img/elixircl.png`, Joy of ProcessWire → `/img/joyofpw.png`, Proyecto Chaucha → `/img/chaucha.png`, Ninja Systems → `/img/Ninjas.png`, and the four covers → `/img/<name>.jpg`. `ShowcaseItem`, `showcase_card`, alts, and styles stay untouched — same pattern as the portrait's remote-to-local switch.
4. **Tests assert the local paths and the absence of the remote substrings unique to these two sections**: `avatars.githubusercontent.com` (projects only), `raw.githubusercontent.com/ElixirCL` (projects only), and `ninjas.cl/covers` (books only). The bare host `raw.githubusercontent.com` is deliberately still present via the games cards, so it is not asserted absent. Downloaded covers are verified the way `camilo.jpg` was: file exists, is a real JPEG, has a non-trivial size.

## Risks / Trade-offs

- [A cover URL could break between planning and apply] → Verified `HTTP 200` today; apply verifies each downloaded file's type and size before touching code, and pauses on a failed fetch rather than committing a dead local reference.
- [Repo and generated-site size grow by the four covers] → Accepted, the same trade-off already made for `camilo.jpg`; the logos add nothing new (already on disk).
- [`Ninjas.png` is shared with the hero, which keeps its absolute production URL] → The spec guard pins the hero source; only the showcase card's `image:` field changes, so the hero is untouched.

## Migration Plan

1. `curl` the four covers into `static/img/`; verify each is a valid JPEG with a non-trivial size.
2. Repoint the eight `image:` fields in `src/site.gleam` to the `/img/…` paths.
3. Add the home-view test asserting the eight local paths and the three gone remote substrings.
4. Verify: `gleam format src test`, `gleam test`, `openspec validate local-showcase-images`.

Rollback: revert the eight `image:` fields and delete the four cover files; nothing else persists.
