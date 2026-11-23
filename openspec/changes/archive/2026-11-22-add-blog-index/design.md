# Design

## Context

blogatto's route system registers static routes at configuration time:
`config.route(path, view)` stores a closure and the build later calls it
with the full parsed `List(Post(Nil))`, writing
`{output_dir}/{route}/index.html`. There is no dynamic-route or
parameterized-route mechanism, no public post loader, and no after-build
hook — `blogatto.build` returns `Result(Nil, BuildError)`. So the page
count cannot be computed from parsed posts at registration time, but it
does not need to be: the number of post directories under `./blog` is
known before the build starts, and blogatto parses exactly those
directories (a malformed one fails the whole build; the completeness test
guarantees one directory per four-variant post). Directory count and
parsed default-post count therefore agree by construction.

## Goals / Non-Goals

**Goals:**

- `/blog/page/{n}/` for every page, generated on every build, listing
  only the Spanish default-language posts, newest first, 25 per page.
- Entries as full OpenGraph-style cards — the `.embed-full` visual
  grammar of the site's ninjas embed cards — using each post's featured
  image.
- `/blog/` as a redirect page to `/blog/page/1/` (the old site's URL
  contract), kept out of the sitemap while the page routes join it.

**Non-Goals:**

- Translated index pages, tag/category archives, home-list changes (see
  proposal — out of scope).

## Decisions

1. **Page count from the post directories at configuration time.** A new
   module `src/ninjas/blog_pages.gleam` owns the page-size constant (25)
   and a function that counts post directories under `./blog`
   (`simplifile.read_directory` + `is_directory` filter) and returns
   `int.max(1, ceil(count / 25))` — page 1 always exists even for an
   empty catalog. `ninjas/blog.new/1` folds that many routes into the
   config: `config.route("/blog/page/" <> int.to_string(n),
   site.blog_index_view(n))` for `n` in `1..page_count`, plus
   `config.route("/blog", site.blog_redirect_view)`. Both entrypoints
   (`src/ninjas.gleam`, `src/dev.gleam`) share `blog.new`, so production
   and dev builds get the pages automatically. The count is taken fresh
   on every build from the same directories the post builder parses, so
   the index regenerates with the catalog — the same always-current
   property the sitemap already has: creating a post and rebuilding
   extends the pagination with no manual step and no pinned list.

2. **The view reuses the site's list machinery and full chrome.**
   `site.blog_index_view` receives all posts (every language variant),
   filters with the existing `default_language_posts`, sorts descending
   by date (blogatto already hands views newest-first, but the view
   sorts defensively, mirroring the blogatto docs' own archive example),
   and slices the page window `[25*(n-1), 25*n)`. The page renders
   through the existing `page/1` layout, and its body composes exactly
   like `home_view`'s: `masthead` + `main` + `site_footer`. The shared
   components carry the chrome the owner requires — the masthead header,
   the `site_nav` navigation menu inside it, and the footer — with no
   page-specific chrome code. The home page is untouched: it keeps its
   full unpaged list (owner-confirmed); the index is an additional view.

3. **Entries are embed cards.** Each entry is one `html.a` in the
   `.embed-full` card structure (already styled by `static/style.css`):
   the post's title and description beside `featured_image(post)` — the
   header image with the `/img/Ninjas.png` fallback — plus the post's
   formatted date. This is the owner's ask: the header image presented
   "as an oembed similar to a ninjas embed tag". Inside each card, two
   pieces of existing machinery render without duplication: the
   **translation links** reuse the post page's variant resolution — the
   slug-matching lookup behind `language_options` (`find_variant`
   against the variants sharing the entry's slug) — linking the post's
   English, Japanese, and Portuguese pages (the Spanish entry is the
   card itself, so it renders no self-link); and the **tags** reuse
   `post_tags`'s pill rendering (`.post-tags`/`.post-tag` are already
   styled). Because variant lookup needs the full list, the view
   threads `all_posts` into the card renderer while the entry list
   itself stays defaults-only. A thin wrapper keeps the home list
   untouched; if the wrapper needs list-specific spacing, a small
   `style.css` addition (not a fork of `.embed-full`) covers it.

4. **Pagination navigation in the site's button idiom.** Previous/next
   links reuse the retrostrap button classes the post page's
   Anterior/Siguiente navigation already uses, with an `n / total`
   counter between them — the same grammar the old site's page showed
   (`Next ⏭️` beside `1 / 7`). Page 1 links only next; the last page
   links only previous.

5. **The title section carries the site's own feed icon.** The old
   site's header linked its feed as an icon
   (`<a href="/feed.xml"><img src="/img/feed.svg"></a>`); the icon
   itself survives at `old/sources/assets/img/feed.svg`. Copy it into
   `static/img/feed.svg` and render it beside the index page's title
   heading, linking `/atom.xml` — the Atom feed the new site generates,
   the faithful equivalent of the old site's Atom `feed.xml` link (the
   site also generates `/rss.xml`; switching the icon's target is a
   one-line change if the owner prefers it). No new icon is authored:
   the retro banner wall's `rss-button.gif` stays a banner; the feed
   link uses the old site's own small icon, as the old blog page did.

6. **`/blog/` is a meta-refresh redirect, not a second copy of page 1.**
   The old site served exactly this redirect page at `/blog/`; keeping
   it preserves inbound links and avoids duplicate content at two URLs.
   `sitemap.filter` excludes that route string from the sitemap while
   the real page routes flow in automatically — they are ordinary config
   routes, so the sitemap builder already lists them; no side-effect
   file writes, no extra-pages machinery.

7. **No new dependencies.** `simplifile`, `gleam/int`, `gleam/list`, and
   Lustre are already in use; blogatto's own route and sitemap features
   carry the design. Alternatives rejected: a fixed over-provisioned
   route set (writes stub pages and sitemap entries for pages that do
   not exist) and post-build side-effect writes in the style of
   `ninjas/extra_pages` (files the sitemap builder cannot see, and I/O
   hidden inside a view closure).

## Risks / Trade-offs

- [Directory count vs parsed count] They can only diverge if a directory
  fails to parse — which fails the build outright — or if loose
  non-post directories appear under `blog/`, which the repo's layout and
  tests already preclude.
- [Date ties] blogatto's stable sort decides, and the home list,
  navigation, and index pages all read the same order.
- [Page count grows past registered routes] Impossible by construction:
  routes are registered from the same directory count on every build, not
  pinned in source.

## Migration Plan

Pure addition: one new module, one view (plus the redirect view) in
`src/site.gleam`, route registration in `ninjas/blog.gleam`, the sitemap
filter, one copied static asset (the old site's `feed.svg` icon), and
tests. No content or template changes; rollback is removing the routes.
Tasks below.
