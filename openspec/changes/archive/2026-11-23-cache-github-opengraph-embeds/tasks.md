# Tasks

## 1. Dependencies and cache module

- [x] 1.1 Declare `gleam_httpc` plus direct `gleam_http` and `gleam_crypto` dependencies, then run `gleam deps download` to refresh `manifest.toml`
- [x] 1.2 Create `src/ninjas/github_opengraph.gleam` with `local_image_path(repo)` computing the lowercase MD5 of `https://github.com/{repo}` and returning `/opengraph/{md5}.png`
- [x] 1.3 Implement `image_source(repo)` and a testable `image_source_in(repo, cache_dir, output_dir, fetch_html, fetch_image)`: reuse `.opengraph/{md5}.png`, otherwise cache HTML at `{md5}.html.cache`, parse `og:image`/`twitter:image`, fetch the image (falling back to `https://opengraph.githubassets.com/1/{repo}`), cache it, and copy it to `dist/opengraph/{md5}.png`
- [x] 1.4 Return the remote deterministic URL on any fetch, parse, write, or copy failure so the build still emits a valid card

## 2. Component and build wiring

- [x] 2.1 Add `highlight.code_component_with_github_images(syntax, resolver)` and keep `highlight.code_component(syntax)` as the pure wrapper using `github_opengraph.local_image_path`
- [x] 2.2 Wire `blog.new` to the resolver variant so production and dev builds use the cache-aware image source
- [x] 2.3 Confirm no changes to non-GitHub fences, post routes, card markup, or `blog/` content

## 3. Tests and verification

- [x] 3.1 Update `embed_components_render_test` to expect the site-local `/opengraph/{md5}.png` GitHub image path
- [x] 3.2 Add offline cache tests with injected fetchers for cache hit, HTML+image write on miss, `og:image` parsing, image-fetch fallback, and failure fallback to the remote URL
- [x] 3.3 Run `gleam format src test` and `gleam test`, then `gleam format --check src test`
- [x] 3.4 Run `openspec validate cache-github-opengraph-embeds` and confirm all tasks checked before sync/archive
