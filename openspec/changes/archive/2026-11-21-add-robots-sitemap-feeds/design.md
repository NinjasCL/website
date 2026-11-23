# Design

## Context

See proposal.md - Why. The build pipeline already has the four generation steps — robots via webls, feeds via webls, sitemap XML — gated on configuration. The engine docs in `examples/blogatto/docs/` show the wiring; the locked signatures confirm it: `robots.new(sitemap_url)` + `robots.robot(Robot(...))`, `sitemap.new(path)`, `atom.new(id:, title:, updated:)` with `atom.subtitle/author` builders, and `rss.new(title, link, description)` with `rss.language`. All config lives in the shared builder `ninjas/blog.gleam`, so one edit covers production, dev, and the live server's rebuilds.

## Goals / Non-Goals

**Goals:**
- Four files (`robots.txt`, `sitemap.xml`, `atom.xml`, `rss.xml`) from every build, with the site's identity.
- Zero new dependencies — everything ships with blogatto.

**Non-Goals:**
- Feed filters, per-language feeds, custom serialization, sitemap priorities.
- Head auto-discovery links for the feeds (follow-up to `site-head-meta`).

## Decisions

1. **Sitemap URL composition: `site_url <> "sitemap.xml"`.** The site URLs end in a slash (`https://ninjas.cl/`), so the docs' `site_url <> "/sitemap.xml"` pattern would double the slash. Composing without the leading slash yields the canonical `https://ninjas.cl/sitemap.xml`. The same trailing-slash rule applies to the Atom feed's `id`.
2. **Feed identity from the site constants.** Atom: id the site URL, title `Ninjas.cl` as `PlainText`, subtitle the Spanish `site_description`, author `@CLSource` (with the GitHub organization as URI). RSS: title, link, description from the same constants, `language` the site's `es-CL`. Defaults cover outputs (`/atom.xml`, `/rss.xml`) and entry serialization (excerpt-based summaries).
3. **Atom `updated` is the build time** (`timestamp.system_time()`), per the docs' own example — for a static site the feed legitimately refreshes per build, and the spec's regenerate-on-every-build scenario pins that behavior.
4. **Robots policy: one allow-all robot.** `User-agent: *` with `allowed_routes: ["/"]` and no disallows — the owner's `index,follow` head meta already states the intent; the file just needs the sitemap pointer and an unambiguous default policy.
5. **The not-found page stays out of the sitemap automatically** — it is an extra file, not a `config.route`, and the sitemap builder walks routes and posts only. No filter needed.

## Risks / Trade-offs

- [Build-time `updated` makes builds non-deterministic] → Accepted and pinned by the spec scenario; feeds are meant to reflect publication time, and nothing else in the output depends on the stamp.
- [The sitemap's default serialization carries no `last_modified`] → Acceptable defaults; the posts' dates already surface in the feeds, and priorities can ride a later change if SEO review asks.
