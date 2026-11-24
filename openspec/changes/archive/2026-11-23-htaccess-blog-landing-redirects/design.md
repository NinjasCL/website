# Design

## Context

See `proposal.md` for motivation. Today `static/.htaccess` only disables directory indexes and maps 404s, while the sole blog landing redirect is a generated `dist/blog/index.html` with a zero-delay meta refresh. blogatto copies `static/` verbatim into `dist/` and can register static routes, but it emits files only — it cannot set an HTTP status. The host already serves Apache-style `.htaccess`, so a server rule can provide the real redirect while the generated page remains useful on hosts that ignore the file.

## Goals / Non-Goals

**Goals:**

- Issue a real HTTP 301 from the shipped `.htaccess` for all four blog landing URLs, with and without a trailing slash.
- Keep a generated, language-correct fallback page at every landing URL so behavior degrades gracefully.
- Keep all landing routes out of the sitemap and the real paginated indexes unchanged.

**Non-Goals:**

- No changes to post routes, index content, feeds, robots, or the navbar's `/blog` target.
- No host-specific redirect files for other servers; the fallback page is the cross-platform answer.
- No dependency changes.

## Decisions

1. **Ship Apache rules first, keep HTML fallback.** `static/.htaccess` gains a `<IfModule mod_rewrite.c>` block with `RewriteEngine On` and two anchored rules:

   ```apache
   RewriteRule ^blog/?$ /blog/page/1/ [R=301,L]
   RewriteRule ^blog/(en|ja|pt)/?$ /blog/$1/page/1/ [R=301,L]
   ```

   The patterns omit the leading slash because per-directory `.htaccess` rules match a relative path. They are anchored, so `/blog/page/1/` and `/blog/en/page/1/` are untouched. Query strings are preserved by default. `<IfModule>` avoids a 500 on hosts without `mod_rewrite`; there the fallback page takes over. A 301 is used because the old URL contract is permanent, not a temporary campaign.

2. **Register one fallback route per language.** `ninjas/blog_pages.register` already folds the translated page routes; it will also register `/blog/en`, `/blog/ja`, and `/blog/pt` beside `/blog`. Each route calls a single language-aware view, so the build writes `dist/blog/{lang}/index.html` next to the translated post directories without a post-build side effect. blogatto's `config.route/3` is sufficient; no new API or dependency is needed.

3. **Reuse the existing language text records.** The `BlogIndexText` values in `site.gleam` already carry each index's `lang`, heading, and description. A small resolver shared with the existing index view lets the redirect view render the correct html `lang`, title heading, meta description, meta refresh target, and visible fallback link for all four languages. This avoids a second, drifting list of translated strings. The redirect view stays deliberately minimal — no masthead, footer, or duplicated post list.

4. **Filter every landing URL from the sitemap.** `ninjas/blog.gleam` currently excludes only `site_url <> "blog"`. It will exclude the four exact URLs (`blog`, `blog/en`, `blog/ja`, `blog/pt`) while the ordinary index routes continue to flow in automatically.

5. **Test both layers.** Gleam tests assert the four generated fallback pages and the sitemap exclusions, and read `static/.htaccess` to assert the four rewrite rules and the `mod_rewrite` guard. The server behavior itself is verified by a normal deploy check, not by the unit suite.

## Risks / Trade-offs

- [Host lacks `mod_rewrite`] → The `<IfModule>` guard prevents a server error and the generated meta-refresh pages still resolve every landing URL.
- [Browser or proxy caches the 301] → Expected for a permanent redirect; during verification a temporary 302 can be used locally, but the shipped rule stays 301.
- [Apache may add its own directory-slash redirect for `/blog`] → The rules match both `^blog$` and `^blog/$`, so the visitor still reaches page 1; at worst there is one extra hop on hosts where `mod_dir` runs first.
- [Route collision with a blogatto-generated language index] → Unlikely because translated posts are registered under `/blog/{lang}/{slug}/`; verify the built `dist/blog/{lang}/index.html` files after implementation.
- [Landing pages absent from the sitemap] → Intentional, matching the existing `/blog` exclusion; the real index pages remain discoverable.

## Migration Plan

Deploy normally with `task upload`: the updated `.htaccess` and the new fallback pages are copied into `dist/` together. Apache hosts begin issuing 301s; other hosts continue to use the meta-refresh fallback. Rollback is to remove the rewrite block from `static/.htaccess`, rebuild, and upload; the fallback pages keep the old URLs working throughout.

## Open Questions

None. The `mod_rewrite` guard makes host support a runtime detail rather than a blocker.
