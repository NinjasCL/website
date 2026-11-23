# Design

## Context

The default index registers one `config.route` per page at build time (`src/ninjas/blog_pages.gleam`) because blogatto has no dynamic-route mechanism and no public post loader; the page count comes from the post directories under `blog/` before the build starts. The site's language machinery already exists: `SiteLanguage` in `src/site.gleam` declares the four languages, post variants carry `language: Some(code)` and route at `/blog/{lang}/{slug}/`, and the home pages render from per-language `HomeText` records in `src/ninjas/home.gleam`. See proposal.md — Why.

## Goals / Non-Goals

**Goals:**

- Language index pages at `/blog/{lang}/page/{n}/` for en, ja, pt, each listing only its language's variants, with the default index untouched.
- Every index page links its sibling languages' same-numbered page.
- Language pages declare their language (`lang`, OpenGraph locale) and speak it in their own copy.

**Non-Goals:**

- `/blog/{lang}/` redirect routes, per-language navbar targets, translated feeds, post-page changes.
- A new dependency: none — `config.route` is the exact mechanism the default index already uses.

## Decisions

- **Route registration stays in `blog_pages.register`.** The default pages loop gains an inner fold over `["en", "ja", "pt"]`, registering `/blog/{code}/page/{n}` → `site.language_blog_index_view(code, n)`. This keeps all route grammar in one place, mirroring how `src/ninjas/blog.gleam` hardcodes the four home routes. No blogatto API beyond `config.route`.
- **One page count serves every language.** The existing directory count already assumes one directory per post; the completeness mandate (`every_post_ships_all_languages_test`) guarantees each language's variant count equals it, so per-language page counts match. `blog_index_page` still recomputes the total from the filtered list at render time, so a hypothetically missing variant degrades to an empty tail page — never a wrong-language entry.
- **The page copy travels in a `BlogIndexText` record, one const per language** — the `HomeText` pattern: self-contained records in `src/site.gleam` (which owns the index view), Spanish as the human-written reference, the others machine-translation-quality translations. Fields: `code`, `name`, `lang`, `og_locale`, `title` (a `{page}` template), `description`, `intro`, `previous`, `next`, `nav_aria`, `options_label`.
- **`blog_index_page(text, page_number, posts)` renders from the record; the Spanish record carries today's strings verbatim**, so the default index output is byte-identical and `blog_index_view(n)` keeps its signature — the existing tests are the regression proof.
- **A language's posts filter mirrors the home page's `language_posts`:** `language: None` for the Spanish index (`code "es"`), `language: Some(code)` for a translated index.
- **Card translation links exclude the entry's own language** (`site_languages` minus `language_config(post.language).code`). On the default index this equals today's machine-translated filter; on a translated index the Spanish original and the other translations get linked instead.
- **The options row links same-numbered pages**, not page 1 — the completeness mandate keeps the counts equal, so switching language preserves the reader's position. Presentation reuses the `post-languages` class (existing styles), like the home pages' row.
- **Shared chrome (navbar, masthead, footer) stays in the default presentation** — the post pages' convention: content in the page's language, chrome in the site's default.

## Risks / Trade-offs

- [Route/slug collision: a variant slug literally named `page`] → Same theoretical collision already exists for the default index (`/blog/page/{n}` vs `/blog/{slug}`); no new class of problem, and no real post uses it.
- [A missing variant leaves a reachable but empty tail page] → The completeness test prevents it; the render-time total keeps pagination self-consistent per language.
- [Machine-translated index copy quality] → Follows the site's convention for translated records (en/ja/pt homes, warnings, tags); the owner revises reference-quality wording as needed.

## Migration Plan

Purely additive routes and views; the default index's rendering is unchanged, so rollout is a rebuild and rollback is a revert of the commit. No data or content migration.
