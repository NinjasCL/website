# Proposal

## Why

The site ships every post in four languages — Spanish (default), English,
Japanese, and Portuguese — but its front door exists only in Spanish: the
home page renders once at `/`, with every heading, paragraph, and button in
Spanish and its showcase buttons carrying the bilingual "Ver / View" and
"Código / Code" labels. A visitor who arrives through a translated post has
no home page in their language and no way to discover one. The site owner
asked for the home page translated into English, Japanese, and Portuguese —
Spanish staying the default — with the showcase buttons carrying one word
per language, and each language's home living under its own URL: `/` for
Spanish, `/en` for English, `/ja` for Japanese, and `/pt` for Portuguese.

## What Changes

- Four home pages, one per site language, registered as blogatto config
  routes: the Spanish home stays the default at `/`, and the machine-
  translated English, Japanese, and Portuguese homes render at `/en/`,
  `/ja/`, and `/pt/` — blogatto's `config.route` writes each as
  `<route>/index.html`, the same route mechanism the blog index pages use.
- Every home-owned copy renders in the page's language: the marquee, the
  about paragraphs, each section's title and intro, the thirteen showcase
  cards' descriptions and "Desde …" captions, the posts section's headings
  and empty-state note, and the hero's description note. The hero brand
  title "忍者 開発者 Ninjas.cl" and its tagline treatment stay as-is.
- Each home lists its own language's posts: the Spanish home keeps today's
  default-language list; the translated homes list that language's post
  variants — every post ships all four, so each home's list carries the
  same catalog — with the featured pick and the trimmed random sample
  drawing from that language's entries, linking their variant URLs.
- The showcase buttons carry a single word per language — the bilingual
  labels are gone: Spanish "Ver" / "Código", English "View" / "Code",
  Japanese "見る" / "コード", Portuguese "Ver" / "Código".
- The shared chrome reads in the page's language on the translated homes:
  the navbar's labels (and its Inicio/Home link, which stays the current
  page on every home, linking that home's own URL) and the footer's
  back-to-top label. The copyright line stays verbatim everywhere — it is
  the site's brand/legal line, not copy. Post pages, the blog index, and
  the not-found page keep today's Spanish chrome.
- Every home page renders the posts' language options row — "Idiomas:" on
  Spanish, its own label on the translated homes — linking the four home
  variants (`/`, `/en/`, `/ja/`, `/pt/`), so each home page is reachable
  from the others, mirroring the posts' options row.
- Each home page declares its own language in the head suite: `lang` on
  the html element, `og:locale` from the language configuration, and the
  translated site description in the meta description and its og/twitter
  mirrors, with `og:url` pointing at that home's own URL.
- The translated homes carry no machine-translation warning — they are
  site chrome, not post content (the site owner's choice).

Out of scope:

- No translation of the blog index, the post pages' chrome, the 404 page,
  or the feeds — the four post-variant pages and their warnings stay as
  they are.
- No per-language blog index routes; the "Ver Todos" button and the
  navbar's Blog link keep pointing at `/blog` from every home.
- No new dependencies, no new content format, and no machine-translation
  pipeline — the translated strings are hand-maintained constants beside
  the site's existing language configuration.
- No canonical/hreflang link machinery beyond the per-page `og:*` fields
  the head suite already renders.

## Capabilities

### New Capabilities

- `site-home-languages`: the home page in the site's four languages —
  the `/`, `/en/`, `/ja/`, `/pt/` routes, the per-language home copy and
  head fields, the language options row on every home, and the no-warning
  contract for the translated homes.

### Modified Capabilities

- `site-showcase-buttons`: the button labels change from the bilingual
  "Ver / View" and "Código / Code" to one word in the page's language.
- `site-masthead`: the navbar's labels and current-page home link follow
  the home's language, and the hero's description note renders in it.
- `site-footer`: the back-to-top label follows the home's language, the
  copyright line staying verbatim.
- `site-featured-post`: the featured, more-posts, and Ver Todos labels and
  the empty-state note follow the home's language, and each home's featured
  pick and sample draw from that home's language posts.
- `site-head-meta`: a home page's `og:locale` and description follow its
  language, not always the site's Spanish defaults.
- `site-about-section`: the about copy renders in the home's language,
  the Spanish text remaining the default home's own.

## Impact

- `src/ninjas/home.gleam`: `view` gains the page's language and renders
  through a per-language copy record; the language options row joins the
  hero; `showcase_card` and the section builders take the copy's labels.
- `src/site.gleam`: the `SiteLanguage` record carries the home texts (or
  the home module owns a parallel `HomeLanguage` record built from it);
  `masthead`/`site_nav` and `site_footer` accept the page's labels;
  translated site descriptions and the `og_locale` reuse already-public
  configuration.
- `src/ninjas/blog.gleam`: registers the three new routes
  (`config.route("/en", …)` and siblings) beside the existing `/`.
- `test/ninjas_test.gleam`: the config test gains the three routes; new
  per-language render tests (labels, copy, options row, head fields);
  the showcase-button label tests and the affected chrome tests update to
  the single-word labels.
- No dependency, content-file, or stylesheet changes.
