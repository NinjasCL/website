# Design

## Context

See proposal.md - Why. The head renders in `page/3` (`src/site.gleam`) for all three templates; every asset the suite references already ships in `static/` and serves at the site root (webmanifest, humans.txt, logo_og.png, the icon PNGs). Lustre provides the needed primitives: `attribute.attribute(name, value)` for the OG `property` attributes, `attribute.type_` for the script's `type`, and `element.unsafe_raw_html` for unescaped inline content.

## Goals / Non-Goals

**Goals:**
- One head suite, all pages, with per-page mirroring for og/twitter title, description, and URL.
- Valid JSON inside the ld+json script (no HTML escaping of quotes).
- No duplicate meta description — the existing per-page one stays the only one.

**Non-Goals:**
- Per-page structured-data types or per-post `datePublished`.
- Editing the keywords list, webmanifest, or humans.txt — shipped as authored.
- Favicon.ico link or `og:image:alt`-style extras not present in the pasted block (twitter:description aside, which the owner's mirroring choice adds).

## Decisions

1. **Canonical URL plumbing: `page/4`.** `page` gains a `url: String` parameter; the callers pass the site URL (home), the post's URL (post template), and the site's `404.html` (not-found). og:url and twitter:url consume it. The parameter keeps mirroring data-driven instead of hardcoding a single URL in the head.
   - Alternative rejected: a fixed og:url everywhere — contradicts the owner's mirroring choice and misrepresents post pages.

2. **JSON-LD via `element.unsafe_raw_html("", "script", [attribute.type_("application/ld+json")], json)`.** `element.text` would escape the quotes into `&quot;` — invalid JSON inside a raw-text element. `unsafe_raw_html` renders the string verbatim; the content is a static, author-controlled Gleam string (no user input), so the XSS caveat does not apply. The JSON is hand-built with `string.replace`-free literal composition (a `const` holding the block with the description spliced in).

3. **OG/Twitter attributes via the generic constructor.** `attribute.attribute("property", "og:title")` plus `attribute.content(title)` — lustre has no dedicated `property`-meta helper, and its `attribute.property` fn is for server-component properties, not this.

4. **Normalizations of the pasted block (owner-confirmed or recorded):**
   - Descriptions: the current Spanish `site_description` replaces the pasted English identity texts in og/twitter/JSON-LD, per the owner's choice; the JSON-LD description splices the same constant.
   - `datePublished`: "2026-11-21" (the relaunch date), not the pasted microsecond timestamp.
   - Publisher logo: `https://ninjas.cl/img/Ninjas.png` (the shipped asset), not the pasted root `/Ninjas.png`.
   - Head comments (humans-not-AI, license explanation): lustre views render no comment nodes; the declarations live in `humans.txt` and the `usage-rights` meta, which the author link connects.
   - Keywords list and robots/usage-rights/generator values: verbatim from the paste.

5. **Head order.** The suite follows the paste's grouping — generator, icons and manifest, author link, robots, usage-rights, description (existing), keywords, og, twitter, JSON-LD — before the stylesheets and background script already in `page/3`. Order is stylistic; the browser and crawlers accept any.

## Risks / Trade-offs

- [`unsafe_raw_html` misuse is dangerous in general] → The block is a compile-time constant built from site-owned strings only; no post or frontmatter content enters it.
- [Fixed site-level JSON-LD on post pages is less precise than per-post typing] → Recorded as out of scope; the block matches the owner's pasted intent while og/twitter already mirror per page.
- [Keywords list includes personal names] → Shipped verbatim per the paste; editing the list is out of scope by the owner's own block.
