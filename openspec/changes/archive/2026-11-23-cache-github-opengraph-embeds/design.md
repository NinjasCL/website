# Design

## Context

`src/ninjas/highlight.gleam` renders `github` fences as a full OpenGraph card whose `src` is currently the remote `https://opengraph.githubassets.com/1/owner/repo`. Every language variant of a post repeats the same fence, so one page can ask the visitor's browser for dozens of GitHub images; GitHub answers some of those with HTTP 429. The old site's `old/sources/build.exs` `Tags.render/2` avoided this by hashing each URL with MD5, caching the fetched HTML in `.opengraph/{md5}.html.cache`, and reusing it. The new static build has no fetch step, and `.opengraph/` is already git-ignored.

blogatto renders posts during `blogatto.build`, after it copies `static/` into `dist/`. It has no HTTP client or HTML-cache abstraction, and its `post.code` component is the only extension point that sees a `github` fence. That component must stay deterministic for unit tests, so cache side effects are injected rather than called unconditionally.

## Goals / Non-Goals

**Goals:**

- Fetch each distinct GitHub repository once per cache lifetime, not once per fence.
- Store HTML and image artifacts under the existing git-ignored `.opengraph/` keyed by MD5 of `https://github.com/owner/repo`.
- Serve the image from the generated site at `/opengraph/{md5}.png`, so the browser never requests GitHub for a card image.
- Keep a valid remote fallback for cold/offline builds and cache-copy failures.
- Keep `gleam test` fully offline and `gleam format --check src test` passing.

**Non-Goals:**

- Caching `youtube`, `ninjas`, or external `embed` fences.
- Committing cache artifacts or adding cache expiry/invalidation controls.
- Changing post frontmatter, routes, or the card's HTML structure.
- Replacing `tools/ftp-upload`; cached images are ordinary `dist/` files and upload incrementally like any other asset.

## Decisions

- **New `src/ninjas/github_opengraph.gleam` owns hashing, fetching, caching, and copying.** It computes `md5(bit_array.from_string("https://github.com/" <> repo)) |> bit_array.base16_encode`, mirroring the old site's lowercase-hex key. `local_image_path(repo)` is pure and shared by the card renderer; `image_source(repo)` performs the cache-aware work and returns the final `src`.
- **Fetch through `gleam_httpc` with `gleam_http` request/response types and `gleam_crypto` for MD5.** `gleam add gleam_httpc` is required for the client; `gleam_http` and `gleam_crypto` are already locked transitively but are declared directly because the new module imports them. blogatto offers no build-time fetch or cache facility, so no existing blogatto feature is sufficient.
- **Cache HTML first, then the image.** On a miss the module reads `.opengraph/{md5}.html.cache`; if absent it GETs the repository page with a browser-like User-Agent, follows redirects, and writes the body. The image URL is extracted from the first `property="og:image"` (or `name="twitter:image"`) meta tag; if parsing or fetching it fails, the deterministic `https://opengraph.githubassets.com/1/owner/repo` URL is tried. A successful binary response is written to `.opengraph/{md5}.png`.
- **Copy cached images into the generated site as part of `image_source`.** The module ensures `./dist/opengraph/` exists and copies the cached PNG there. Because blogatto cleans `dist/` before rendering, this happens during post rendering — after blogatto's static copy — and is safe. If the copy fails, the card falls back to the remote URL instead of pointing at a missing file.
- **Inject the resolver into the content-block component.** `highlight.code_component(syntax)` stays pure and uses `github_opengraph.local_image_path`, which is what unit tests assert. `highlight.code_component_with_github_images(syntax, resolver)` uses the supplied `fn(String) -> String`; `blog.new` wires it to `github_opengraph.image_source`. Only the GitHub branch changes; `youtube`, `ninjas`, `embed`, highlighting, and summary toggles are untouched.
- **Fail soft.** Any fetch, parse, write, or copy error returns the old deterministic remote URL. A failed build never produces a broken local path, and a warm cache avoids all network access.

## Routing, content, and templates

- **Routing:** no new page routes. Cached image files appear under `/opengraph/` in `dist/` alongside `/static`-copied assets and are uploaded by the existing incremental SFTP task.
- **Content:** no `blog/` sources change. Existing ```` ```github ```` fences keep their `owner/repo | description` form; repeated language variants hit the same cache key.
- **Templates:** `og_card` and the site's post template are unchanged. Only the `src` value passed to `og_card` from the GitHub branch changes, selected by the injected resolver.

## Risks / Trade-offs

- [GitHub still serves a 429 for the hashed image URL during the first fetch] → The deterministic `/1/` URL is the fallback and was verified to return 200; only one fetch per repository is attempted, and the result is cached forever.
- [A cached image becomes stale when a repository's social card changes] → Accepted to match the old site's permanent cache; deleting `.opengraph/{md5}.png` refreshes one repository.
- [Tests could accidentally perform network calls through `blog.new`] → Config tests only build the config; rendering tests call the pure component. Cache tests use injected stubs and temporary directories.
- [Parallel builds could race on the same cache file] → Not supported today; a partially written file is overwritten on the next miss, and the remote fallback keeps cards valid.
- [Adding three direct dependencies for a small cache] → They are already in `manifest.toml` through blogatto/httpc; the declarations only make imports legal and explicit.

## Migration Plan

Build and deploy normally. On the first build `.opengraph/` fills and `dist/opengraph/` gains one PNG per distinct GitHub repository; card markup changes from a GitHub-hosted `src` to a same-origin `src`. Rollback restores the remote URL by reverting the resolver in `blog.new`; cache files are git-ignored and need no cleanup.

## Open Questions

None.
