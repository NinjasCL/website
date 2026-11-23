# Proposal

## Why

Every page's head is bare: charset, viewport, title, per-page description, stylesheets, and the background script — nothing else. Search engines get no keywords or robots directive, link previews get no Open Graph or Twitter fields, browsers get no icon links or webmanifest, the humans-not-AI declaration has no `humans.txt` link, and there is no structured data. The owner has already shipped every asset this needs into `static/` (apple-touch-icon, favicon 16/32 and android-chrome 192/512, `site.webmanifest`, `humans.txt`, `logo_og.png`) — the change is the head markup itself.

## What Changes

- A head-meta suite renders in the head of every generated page (home, post pages, and the not-found page): the generator credit (blogatto), the humans.txt author link, the icon links (apple-touch-icon 180×180, favicon 32×32 and 16×16, and the site webmanifest), the robots directive (`index,follow`), and the usage-rights declaration (`CC-BY-NC-ND`, the Creative Commons BY-NC-ND 4.0 terms).
- SEO and social metadata, mirroring each page: the existing per-page `meta description` stays the single one (no duplicate), og:title, og:description, og:url and their Twitter counterparts carry the page's own title, description, and URL — the home mirrors the site identity, a post mirrors the post, the not-found page mirrors its 404 title. Fixed site-level fields ride along: the pasted keywords list, `og:type` website, `og:image` the site's logo_og.png, `twitter:card` summary_large_image, and the twitter image.
- A JSON-LD structured-data block ships on every page: the site-level BlogPosting the owner pasted — headline "Ninjas Chile (Ninjas.cl)", the current Spanish site description, the 2026-11-21 relaunch date, `@CLSource` as author, the og image, and Ninjas.cl as publisher with its logo — rendered unescaped so the JSON parses.
- Owner-directed normalizations of the pasted block, confirmed with the owner: the og/twitter/JSON-LD descriptions use the current Spanish site description (not the pasted English identity texts); the per-page fields mirror instead of staying fixed; `datePublished` is the clean relaunch date rather than the pasted microsecond timestamp; the publisher logo points at the shipped `/img/Ninjas.png`; `twitter:description` joins the mirror set; and the pasted head comments (humans-not-AI, license terms) live on in `humans.txt` and the usage-rights meta, since the views carry no comment nodes.

## Capabilities

### New Capabilities
- `site-head-meta`: Defines the head-meta suite on every generated page — identity chrome, SEO/social fields mirroring each page, the structured-data block, and the assets that serve them.

### Modified Capabilities
- None. `blog-site-generation`'s identity requirement keeps holding; the description requirement is untouched (the per-page meta description stays exactly one).

## Impact

- `src/site.gleam`: `page/3` gains a canonical-URL parameter and the head suite; the three callers pass their URLs (home the site URL, the post template the post URL, the not-found view the site's 404.html). No new dependency — lustre's generic `attribute` constructor and `element.unsafe_raw_html` render the `property` metas and the unescaped JSON-LD.
- `test/ninjas_test.gleam`: a head-meta test pinning the chrome, the mirrored fields per template, the single description meta, and the structured-data block.
- No asset changes: every referenced file (apple-touch-icon.png, favicon-32x32.png, favicon-16x16.png, site.webmanifest, humans.txt, logo_og.png) already ships in `static/`.

## Out of scope

- Per-page structured-data typing (the home as `WebSite`, posts carrying their own `datePublished`) — the block stays the fixed site-level BlogPosting as pasted.
- The `favicon.ico` link element — the file keeps serving by convention; the pasted block references only the PNG favicons.
- Editing the keywords list, the webmanifest, or `humans.txt` — they ship as the owner authored them.
