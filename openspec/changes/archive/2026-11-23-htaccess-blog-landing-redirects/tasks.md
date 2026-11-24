# Tasks

## 1. Server-side redirect rules

- [x] 1.1 Add a `<IfModule mod_rewrite.c>` block to `static/.htaccess` with `RewriteEngine On`, `RewriteRule ^blog/?$ /blog/page/1/ [R=301,L]`, and `RewriteRule ^blog/(en|ja|pt)/?$ /blog/$1/page/1/ [R=301,L]`, leaving `Options -Indexes` and `ErrorDocument 404 /404.html` intact; verify the file contains the guard, all three directives, and no unguarded rewrite directive
- [x] 1.2 Add a Gleam test that reads `./static/.htaccess` and asserts the guarded 301 rules for `/blog` and each of `/blog/en`, `/blog/ja`, `/blog/pt`; verify with `gleam test`

## 2. Localized fallback pages and routes

- [x] 2.1 Extract the existing language-to-`BlogIndexText` mapping in `src/site.gleam` into a shared resolver used by both index views and the redirect view; verify with `gleam test` that all existing index and chrome tests still pass
- [x] 2.2 Make `site.blog_redirect_view` take a language code and render that language's `html lang`, title heading, meta description, meta refresh target, and visible fallback link; verify with updated `blog_redirect_view_test` cases for es, en, ja, and pt via `gleam test`
- [x] 2.3 Register `/blog`, `/blog/en`, `/blog/ja`, and `/blog/pt` in `ninjas/blog_pages.register`, all using the language-aware redirect view; verify with `gleam test` that the route-registration config test lists all four landing routes
- [x] 2.4 Extend the sitemap filter in `src/ninjas/blog.gleam` to exclude all four landing URLs while keeping the index routes; verify with `gleam test` that the sitemap config test rejects the four landing URLs and accepts `/blog/page/1`

## 3. Integration checks

- [x] 3.1 Run `gleam format src test` and then `gleam format --check src test`; verify both commands exit cleanly
- [x] 3.2 Run `gleam test`; verify the whole suite passes
- [x] 3.3 Run `task build` and inspect `dist/.htaccess`, `dist/blog/index.html`, `dist/blog/en/index.html`, `dist/blog/ja/index.html`, and `dist/blog/pt/index.html`; verify the rules are copied verbatim and each fallback refreshes and links to its own language's first index page
- [x] 3.4 Run `openspec validate htaccess-blog-landing-redirects`; verify the change validates

## Workflow follow-up

- Archive the change after review, applying the delta to `site-blog-index`.
