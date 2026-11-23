# Proposal

## Why

The blog section has no index: on the new engine `/blog/` serves nothing,
while the old site gave every post a browsing surface at
`/blog/page/{n}/` (example: `https://ninjas.cl/blog/page/1/`). The catalog
now holds 101 default-language posts, and inbound links still point at the
old `/blog` URL. A generated, paginated index restores both.

## What Changes

- A paginated blog index at `/blog/page/{n}/`:
  - lists **only the Spanish default-language entries** (the human-written
    `index.djot` posts — the same set the home page lists; translated
    variants stay options on each post's own page, never duplicate list
    entries);
  - orders posts **newest first** and shows **25 posts per page**;
  - renders each entry as a full OpenGraph-style card, like the site's
    ninjas embed cards: the post's featured image (header image,
    `/img/Ninjas.png` fallback), title, description, and date, the whole
    card linking the post page;
  - inside each card, **links to the post's English, Japanese, and
    Portuguese translations** — resolved by slug the same way the post
    page's language options row does — so a reader can jump straight to
    a translation from the list;
  - shows the post's **tags** in the card, as the same pills the post
    pages render;
- The page renders with the **full site chrome** — the shared navigation
  menu (`site_nav`), the masthead header, and the site footer, the same
  components every page uses — and its **title section carries the RSS
  link with an icon**: the old site's own feed icon (`feed.svg`, copied
  from the old assets), linking the site's syndication feed beside the
  page title.
  - carries pagination navigation — previous/next buttons plus an
    `n / total` counter — in the site's existing retrostrap button style.
- `/blog/` becomes a redirect page to `/blog/page/1/`, restoring the old
  site's URL contract (the old site served exactly this meta-refresh
  redirect).
- The pages are **real blogatto routes generated on every build**: the page
  count is derived from the post directories at configuration time
  (`ceil(post-dirs / 25)`), so each build regenerates the pagination for
  the current catalog without manual steps — the index is always current,
  exactly like the sitemap: create a post, rebuild, and the pagination
  grows. The page routes join the sitemap; the `/blog` redirect route
  stays out of it.
- Involved APIs: `blogatto/config.route/2` (route registration —
  `config.route` writes `{output}/{route}/index.html`),
  `blogatto/config/sitemap.filter/2` (redirect-route exclusion), the
  `List(Post(Nil))` every route view receives, and the site's existing
  view helpers (`page/1`, `default_language_posts/1`,
  `featured_image/1`, `format_date/1`, `.embed-full` card styles).

Out of scope:

- No translated index pages (`/blog/en/page/…`) — the index is
  Spanish-only, like the home list.
- No tag, category, or per-year archive pages.
- No changes to the home page's list, the RSS/Atom feeds themselves, or
  post pages. The home page keeps its full unpaged post section — the
  blog index is an additional, canonical-by-URL view, not a replacement
  (owner-confirmed).

## Capabilities

### New Capabilities

- `site-blog-index`: the paginated blog index pages at `/blog/page/{n}/`
  and the `/blog/` redirect that points at the first page.

### Modified Capabilities

- None.
