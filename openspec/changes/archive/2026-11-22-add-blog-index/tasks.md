# Tasks

## 1. Route plumbing

- [x] 1.1 Create `src/ninjas/blog_pages.gleam`: the page-size constant (25), a directory-count-to-page-count function over `./blog` (`simplifile.read_directory` + `is_directory` filter, `int.max(1, ceil(count / 25))`), and a route-registration helper that folds `config.route("/blog/page/" <> n, site.blog_index_view(n))` over `1..page_count` plus `config.route("/blog", site.blog_redirect_view)`.
- [x] 1.2 Wire it into `ninjas/blog.new/1` and exclude the `/blog` redirect route from the sitemap via `sitemap.filter`. Verify with `gleam format src test` and `gleam test`.

## 2. Views

- [x] 2.1 Add `site.blog_index_view(n)` in `src/site.gleam`: `default_language_posts` filter, descending-date sort, the `25*(n-1)..25*n` slice, rendered through the existing `page/1` layout with masthead and footer.
- [x] 2.2 Add the entry card: one link per post in the `.embed-full` structure — featured image (`featured_image/1` with the `/img/Ninjas.png` fallback), title, description, and `format_date` date — with the translation links (slug-matched en/ja/pt variant pages, the machinery behind `language_options`) and the tags (`post_tags`'s pill rendering) inside the block, and the pagination nav (retrostrap previous/next buttons, `n / total` counter, one-sided links on first and last pages). Add the minimal `static/style.css` support if the list needs spacing the existing classes do not carry.
- [x] 2.3 Add `site.blog_redirect_view`: the site's redirect page pointing at `/blog/page/1/`.
- [x] 2.4 Copy the old site's feed icon from `old/sources/assets/img/feed.svg` into `static/img/feed.svg` and add the title-section RSS link to the index page's heading: the icon beside the page title, linking the site's Atom feed (`/atom.xml`).
- [x] 2.5 Verify with `gleam format src test` and `gleam test`.

## 3. Tests

- [x] 3.1 Extend `production_blog_config_test`: the config registers `/blog`, `/blog/page/1` through `/blog/page/N` where `N = ceil(post-dirs / 25)` from the real `./blog` directory, and the sitemap filter drops the `/blog` route.
- [x] 3.2 Add a `blog_index_view` test suite rendering the view with `element.to_string`: newest-first ordering across pages, the 25-entry window on page 1 and the smaller remainder on the last page, default-language-only entries, card fields (image, title, description, date, post link, en/ja/pt translation links, tags) including the `/img/Ninjas.png` fallback, and the one-sided pagination links plus the `n / total` counter.
- [x] 3.3 Add a redirect-view test: `/blog/` renders a redirect to `/blog/page/1/`.
- [x] 3.4 Add chrome and feed-link tests: the rendered index page carries the site navigation menu, the masthead header, and the site footer; the title section's feed icon links the site's Atom feed.
- [x] 3.5 Verify with `gleam format src test` and `gleam test`.

## 4. Verification

- [x] 4.1 Run `gleam format src test` and `gleam test`; confirm both pass. (55 passed; `gleam format --check src test` passes too.)
- [x] 4.2 Run `task build` and confirm: `dist/blog/page/1/index.html` through `dist/blog/page/N/index.html` exist with 25-entry pages (remainder on the last), newest first, default-language entries only, each card carrying its post's en/ja/pt translation links and tags; the pages render with the site menu, masthead header, and footer, and the title section's feed icon links `/atom.xml`; `dist/blog/index.html` redirects to `/blog/page/1/`; the sitemap lists every `/blog/page/{n}/` route and not `/blog`; the pagination and translation links resolve to live pages. (N = 5: pages 1–4 with 25 entries, page 5 with 1; dates run 2026-11-16 down to 2011-06-02; the sitemap gained the five page routes for 410 total; the redirect route is absent.)
- [x] 4.3 Run `openspec validate add-blog-index` and confirm it passes.
