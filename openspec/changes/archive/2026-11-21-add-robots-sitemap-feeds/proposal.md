# Proposal

## Why

Search engines and feed readers have nothing to find: the build emits no `robots.txt` (so crawlers get no sitemap pointer or crawl policy), no `sitemap.xml` (no URL discovery), and no Atom or RSS feed (no syndication at all). blogatto generates all four natively — `config.robots/2`, `config.sitemap/2`, `config.atom_feed/2`, and `config.rss_feed/2`, per the vendored engine docs at `examples/blogatto/docs/` (`sitemap-and-robots.md`, `atom-feeds.md`, `rss-feeds.md`) — so the site only needs to wire them into its shared configuration builder.

## What Changes

- `robots.txt` generates on every build: the sitemap pointer plus a single allow-all policy (`User-agent: *`, allow `/`).
- `sitemap.xml` generates on every build, listing the static routes (the home) and every post URL at the site's absolute URLs.
- An Atom 1.0 feed (`atom.xml`) and an RSS 2.0 feed (`rss.xml`) generate on every build from the posts, carrying the site's identity: the Ninjas.cl title, the Spanish site description, the es-CL language (RSS), and `@CLSource` as the Atom author. The Atom feed's `updated` stamp is the build time, so rebuilds keep the feed fresh.
- All four wire into the shared builder in `ninjas/blog.gleam`, so the production build, the dev build, and the live server's rebuilds all emit them — no entrypoint changes, no new dependency (the feed, robots, and sitemap modules ship with blogatto and are already in the lock).
- Tests extend the production-config assertions to the syndication configuration, and the build verification confirms the four files land in `dist/` with the expected content.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `blog-site-generation`: gains three requirements — the sitemap generation, the robots.txt generation, and the Atom + RSS feed generation, as outputs of the configured build.

## Impact

- `src/ninjas/blog.gleam`: the shared builder gains the four config calls (atom, rss, sitemap, robots) with the site identity constants already exported by `site.gleam`.
- `test/ninjas_test.gleam`: `production_blog_config_test` asserts the atom/rss feeds, the sitemap path, and the robots sitemap URL + allow-all policy.
- No `src/site.gleam`, entrypoint, asset, or dependency changes. The not-found page is an extra file rather than a route, so it stays out of the sitemap automatically.

## Out of scope

- Feed auto-discovery `<link rel="alternate">` tags in the head — a natural follow-up for `site-head-meta`, not part of generation.
- Feed filters, per-language feeds, custom entry serialization, or sitemap priority hints — the defaults cover the site as it stands.
- `humans.txt`-style extra crawler rules (AI-specific blocks) — the allow-all policy is the owner's choice here.
