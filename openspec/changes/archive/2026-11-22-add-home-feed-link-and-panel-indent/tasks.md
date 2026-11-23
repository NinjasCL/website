# Tasks

## 1. Shared feed link

- [x] 1.1 Add a public `feed_link()` element helper in `src/site.gleam` carrying the existing `.blog-feed` class, `/atom.xml` href, `/img/feed.svg` image, and "Feed Atom RSS" alt text; verify `gleam format src test` leaves it unchanged.
- [x] 1.2 Replace the inline feed anchor in `blog_index_page` with `site.feed_link()` and verify the blog index header still renders one link to `/atom.xml` after `gleam test`.

## 2. Home posts section header

- [x] 2.1 Extend the home page's private `section()` helper with a header-extras argument appended after the icon and title, updating every caller; verify `gleam format --check src test` and `gleam test` pass.
- [x] 2.2 Pass the shared feed link as the posts header's extra element and verify every generated home language page contains the `/atom.xml` link inside the posts heading after a site build.

## 3. Panel left inset

- [x] 3.1 Add `margin-left: var(--rs-space-3)` to the existing `#posts` and `#blog` rules in `static/style.css`, leaving their top margins and all other panels unchanged; verify by inspecting the stylesheet and a built home/index page.
- [x] 3.2 Run `gleam format src test`, `gleam format --check src test`, and `gleam test`, then rebuild with `task build` and verify the site still generates cleanly.

## Workflow follow-up

- Sync the delta specs into the main specs after implementation.
- Archive the change after sync and verification.
