# Proposal

## Why

Every home page and every post ships in the site's four languages, but the blog index exists only in Spanish at `/blog/page/{n}/` — a reader arriving from the English, Japanese, or Portuguese home has no index in their language, and the translated post variants are reachable only card by card. The post routes already live under `/blog/{lang}/{slug}/`, so the index has a natural language home at `/blog/{lang}/page/{n}/`.

## What Changes

- The site SHALL render a blog index at `/blog/{lang}/page/{n}/` for each translated language (en, ja, pt), listing only that language's post variants — newest first, 25 per page, the same grammar as the Spanish index. Spanish stays the default at `/blog/page/{n}/`, unchanged.
- Each index page (Spanish included) SHALL carry a language options row — the current language as plain text, the other languages linking their index's same page number — following the home and post pages' options-row pattern.
- Language index pages SHALL render their own copy in their language: the html `lang` attribute, OpenGraph locale, page title, meta description, panel intro, pagination buttons, and the options row's label. The shared chrome (navbar, masthead, footer) stays in the site's default presentation, exactly as post pages render it today.
- Index entry cards' translation links SHALL become language-aware: the meta row links every sibling variant in every other language, excluding the entry's own language (the card itself links it). On the Spanish index this is exactly today's behavior (English, Japanese, Portuguese); on a translated index it links Español plus the other translated variants.
- Out of scope:
  - A `/blog/{lang}/` redirect route (mirroring `/blog` → `/blog/page/1/`) — nothing links it; the options row links the language indexes directly.
  - Per-language navbar Blog targets on the translated homes — the navbar keeps pointing at the canonical `/blog` from every page, as it does today.
  - Feeds, robots, or the post pages — unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-blog-index`: The index becomes multilingual — new requirements for the per-language index pages and their options row, and the entry-card translation-links requirement refined to exclude the entry's own language.

## Impact

- `src/site.gleam`: a `BlogIndexText` record (one per language, the `HomeText` pattern) plus four consts; `blog_index_page` renders from it (Spanish output byte-identical to today); a `language_blog_index_view(code, n)` route view; `pagination_nav` builds per-language hrefs; `blog_entry_languages` links every other language.
- `src/ninjas/blog_pages.gleam`: registers `/blog/{lang}/page/{n}` for en, ja, pt alongside the default pages — ordinary config routes, so they join the sitemap automatically.
- `test/ninjas_test.gleam`: new tests using the existing `index_test_variant` fixture — per-language listings, translated chrome, options row, and language-aware card links. Existing `site.blog_index_view(n)` tests are untouched (the default view's signature is unchanged).
- No dependency, lockfile, or CI changes; blogatto's route mechanism needs no new APIs (`config.route` registers the pages exactly as the default index does).
