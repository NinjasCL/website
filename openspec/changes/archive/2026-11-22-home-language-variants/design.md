# Design

## Context

The home page is a single blogatto route — `config.route("/", home.view)` in
`src/ninjas/blog.gleam` — and blogatto writes every route as
`<route>/index.html`, the mechanism the blog index pages and the language
post variants (`/blog/{lang}/{slug}/`) already ride. The site's language
configuration lives in `src/site.gleam`: a `SiteLanguage` record per
language (code, name, og_locale, per-language post-page texts), with
Spanish the human-written default and en/ja/pt machine translated. The
shared chrome the home renders through — `site.page`, `site.masthead`
(navbar), `site.site_footer`, `site.title_with_icon` — is already
parameterized everywhere except its hardcoded Spanish labels. The home
module (`src/ninjas/home.gleam`) owns the hero, marquee, sections,
showcase cards, banner wall, and the posts section, with every visible
string currently a Spanish (or bilingual "Ver / View") literal.

## Goals / Non-Goals

**Goals:**

- One home page per site language at `/`, `/en/`, `/ja/`, `/pt/`, generated
  by the existing route mechanism and covered by the sitemap.
- Every home-owned string in the page's language, from one translation
  table adjacent to the markup it feeds; the Spanish home's strings byte-
  for-byte today's.
- The shared chrome (navbar, footer back-to-top) reading in the home's
  language on the translated homes, without touching post pages' chrome.
- The posts' language options row on every home, linking the four homes.
- Per-home posts lists: each home features and samples its own language's
  entries, linking their variant URLs.

**Non-Goals:**

- No translated blog index, post chrome, 404 page, or feeds.
- No hreflang/canonical machinery, no client-side language negotiation, no
  translation pipeline — the strings are hand-maintained constants.
- No fix for the pre-existing quirk that the home view pins
  `site.production_url` into `og:url` even on dev builds; the language
  homes follow the same pattern.

## Decisions

- **Routing: three more `config.route` registrations.**
  `config.route("/en", fn(posts) { home.view(home.english, posts) })`
  (and `/ja`, `/pt`) beside the existing `/` registration. blogatto writes
  `dist/en/index.html`, so the pages serve at `/en/` — exactly the URL
  shape the owner asked for — and the sitemap lists the routes with no
  extra configuration. A new dependency or a blogatto feature would buy
  nothing: static routes already express arbitrary nested URLs.
- **One `HomeText` record per language, in `home.gleam`.** A record type
  carrying every home-owned string — head fields (language code, og
  locale, page URL, translated site description, options label) plus the
  visible copy (hero tagline, marquee, section titles and intros, about
  paragraphs, posts-section labels, showcase button labels, caption
  prefix and month names, nav labels, footer back-to-top label) — with
  four constants (`spanish_text`, `english_text`, `japanese_text`,
  `portuguese_text`) and `home.view(text, posts)` taking the record. The
  translations live in the module that renders them, next to the Spanish
  strings they translate, so reviewing a language means reading one
  block. *Alternative:* extending `SiteLanguage` in `site.gleam` —
  rejected: it would couple the post pages' language config to ~forty
  home-only strings. *Alternative:* a separate translations module —
  rejected: `home.gleam`'s charter is that everything the home page owns
  lives in it.
- **The shared chrome takes its labels as parameters.** `site.masthead`
  and its navbar gain a labels record (the six nav labels plus the
  navigation aria-label) and the current home's URL (the "Inicio" link
  target); `site.site_footer` gains the back-to-top label. `site.gleam`
  keeps a Spanish-defaults value for its own pages — post pages, the
  blog index, and 404 render with exactly today's chrome — and each home
  passes its own labels. The chrome functions stay pure presentation.
- **Each home lists its own language's posts.** The home view filters
  the catalog by its language (the Spanish home keeps
  `site.default_language_posts`; translated homes filter
  `language == Some(code)`), so the featured pick and the ten-entry
  random sample draw from that language's variants and link their
  variant URLs — every post ships all four, so each home's list matches
  the catalog. *Alternative:* every home listing the default posts —
  rejected: a translated home showing Spanish titles would defeat its
  purpose.
- **The homes' options row reuses the posts' row presentation.** Each
  home renders the row from the four `HomeText` records (language name,
  home URL, current-page marker), styled by the existing
  `.post-languages` rules — the same label-then-" · "-joined-entries
  shape the posts' row uses, with the current language plain text. The
  links are the four home URLs, resolved from the record, not from
  post slugs.
- **Caption dates become data.** The showcase cards' `started` strings
  ("Marzo 2022", "2015") become a year plus an optional month, formatted
  per language — "Desde Marzo 2022" (es), "Since March 2022" (en),
  "2022年3月から" (ja), "Desde Março 2022" (pt), and the year-only
  forms ("Desde 2015" / "Since 2015" / "2015年から" / "Desde 2015") —
  with per-language month-name lists. *Alternative:* storing four
  caption strings per card — rejected: thirteen cards × four languages
  of near-duplicate strings for a mechanical date format.
- **The head mirrors the home's language; JSON-LD stays site-level.**
  `site.page` already takes language, og_locale, description, and url —
  each home passes its own (translated description, og locale, own URL,
  `lang`). The JSON-LD structured-data block keeps the Spanish site
  description on every page: it describes the site itself, and the
  `site-head-meta` spec pins it as site-level.
- **Key strings, fixed at design time.** Spanish keeps today's copy
  byte for byte (only "Ver / View" → "Ver" and "Código / Code" →
  "Código" change, per the owner). The other languages' anchor labels:
  nav — "Home/Blog/About us/Projects/Books/Games" (en),
  "ホーム/ブログ/私たちについて/プロジェクト/書籍/ゲーム" (ja),
  "Início/Blog/Sobre nós/Projetos/Livros/Jogos" (pt); posts section —
  "Featured post/Read post/More posts/View all" (en),
  "注目の記事/記事を読む/他の記事/すべて見る" (ja),
  "Postagem destacada/Ler entrada/Mais entradas/Ver todos" (pt);
  options row label — "Languages:"/"言語:"/"Idiomas:"; back-to-top —
  "^ back to top ^"/"^ 上に戻る ^"/"^ voltar ao topo ^"; tagline —
  "Software from 🇨🇱 with ❤️" kept on es and en,
  "🇨🇱から ❤️ を込めたソフトウェア" (ja), "Software do 🇨🇱 com ❤️" (pt).
  The remaining body copy (marquee, section intros, about paragraphs,
  thirteen card descriptions, the translated site description) is
  machine-translation-quality prose translated from the Spanish
  originals during implementation, following the site's existing
  convention for machine-translated variants.
- **No warning on the homes.** The post pages' translation and staleness
  warnings live in the post template; the homes never render them — no
  new machinery, just the absence of the warning elements.

## Risks / Trade-offs

- [Fourfold copy maintenance] → The strings are constants in one module;
  the Spanish block is the reference, and the completeness test pins the
  per-language anchor labels so a forgotten translation fails the build
  rather than shipping half-translated chrome.
- [Translated homes list variant URLs, so a post page reached from /en/
  still renders its own language's variant — but the navbar on that post
  page is Spanish] → Accepted per the owner's scoping: post-page chrome
  is out of scope; the deep-links back to a home land on that home's
  language.
- [Random featured pick per home doubles the non-determinism per build]
  → Same trade-off the site already accepts for the featured row and the
  post pages' random section; tests assert set membership and counts,
  not order or identity.
- [Machine-translation quality of hand-entered Japanese/Portuguese copy]
  → The site already ships machine-translated post variants; the homes
  follow the same convention and can be revised like any constant.

## Migration Plan

One module rewrite (`home.gleam` gains the `HomeText` records and a
`view(text, posts)` entrypoint), small chrome-parameter changes in
`site.gleam` threaded through its internal callers, three route
registrations in `blog.gleam`, and test updates. No content files, no
data migration; rolling back is reverting the four source files. The
`/` route's output is byte-identical except the two single-word button
labels, so no external contract shifts.

## Open Questions

- None.
