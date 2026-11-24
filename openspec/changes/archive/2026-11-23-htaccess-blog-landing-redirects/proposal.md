# Proposal

## Why

`/blog/` currently works only because blogatto generates a tiny meta-refresh page, so every visit is a 200 response followed by a client-side jump. The deployment already ships a `static/.htaccess`, which can issue a real HTTP redirect on Apache before any HTML is downloaded. Making the server rule the primary mechanism and keeping the generated page as a fallback gives a proper redirect where it is supported without breaking hosts that ignore `.htaccess`.

## What Changes

- Add Apache `mod_rewrite` rules to `static/.htaccess` for every blog landing URL in the site's four languages: `/blog/`, `/blog/en/`, `/blog/ja/`, and `/blog/pt/`. Each rule matches with or without a trailing slash and issues a **301** to that language's first index page (`/blog/page/1/`, `/blog/en/page/1/`, and so on).
- Register a blogatto config route for each translated landing URL so the build emits a fallback `index.html` at `/blog/en/`, `/blog/ja/`, and `/blog/pt/`, mirroring the existing `/blog/` fallback. Each fallback keeps the current meta refresh and visible link, but uses the language's own `lang`, title, description, and link text.
- Keep the existing `/blog/` fallback and generalize its view so all four landing pages share one implementation.
- Exclude all four landing routes from the sitemap, not just `/blog`.
- Update tests for the four fallbacks and the sitemap exclusion.

Out of scope:

- Changing the real paginated index pages, their routes, or their content.
- Changing the navbar's Blog target: it still points at `/blog`, which now redirects on Apache and falls back elsewhere.
- Adding host-specific redirect files for Nginx, Netlify, Cloudflare, or other platforms. On those hosts the fallback page remains the behavior.
- Adding or upgrading dependencies; `config.route/3`, `config.sitemap.filter/2`, the static-file copy, and Lustre views already cover the change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `site-blog-index`: the landing-URL requirement expands from `/blog/` only to all four languages, and gains the server-rule-first / HTML-fallback behavior plus the matching sitemap exclusion.

## Impact

- `static/.htaccess`: gains `RewriteEngine On` and four `RewriteRule` entries above the existing directory-index and 404 settings.
- `src/site.gleam`: `blog_redirect_view` becomes language-aware; its view is resolved from the same per-language text records used by the blog index.
- `src/ninjas/blog_pages.gleam`: registers `/blog/en`, `/blog/ja`, and `/blog/pt` alongside `/blog`.
- `src/ninjas/blog.gleam`: the sitemap filter skips all four landing URLs.
- `test/ninjas_test.gleam`: coverage for each language's fallback and the sitemap exclusions.
- `openspec/specs/site-blog-index/spec.md`: the landing redirect and sitemap requirements are updated when this change is archived.
