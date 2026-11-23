# Proposal

## Why

GitHub repository cards rely on `https://opengraph.githubassets.com/...` images loaded by the visitor's browser. When a page contains many `github` fences, GitHub rate-limits those requests (HTTP 429) and the cards render broken. The old site avoided this by fetching each URL once and reusing a local HTML cache; the current static build has no such cache.

## What Changes

- Add a build-time cache for GitHub repository embeds, modeled on the old site's `.opengraph/{md5}.html.cache`: fetch the repository page once, cache its HTML, and derive the social-card image from it.
- Download each social-card image into the same git-ignored cache and copy it into the generated site under `/opengraph/`, so the rendered card references a local image and browsers never call GitHub.
- Cache only the GitHub fence; `youtube`, `ninjas`, and external `embed` fences keep their current behavior.
- Fall back to GitHub's deterministic `/1/owner/repo` image URL when a fetch or cache write fails, so a cold/offline build still emits valid cards.
- Inject the image-source resolver into the content-block component so pure tests stay offline and deterministic; production builds use the caching resolver.

Out of scope: caching external-website `embed` fences, committing cache files to git, cache expiry/invalidation, and changing non-GitHub embed markup.

## Capabilities

**Modified capabilities:** `blog-site-generation` — the GitHub embed rendering requirement gains cached, locally served images and a documented fallback.

**New dependencies:** `gleam_httpc` plus direct declarations of its `gleam_http`/`gleam_crypto` types for build-time fetches and MD5 cache keys. blogatto offers no HTTP fetch or file-cache abstraction, so an existing blogatto feature cannot replace this.

The implementation touches `src/ninjas/highlight.gleam` (component wiring), a new `src/ninjas/github_opengraph.gleam` (cache/fetch/copy), `src/ninjas/blog.gleam` (production resolver), the build entrypoints only through configuration, and `test/ninjas_test.gleam`.
