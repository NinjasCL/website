# Proposal

## Why

Post bodies carry bare URLs in prose — references, bibliographies, tool
homepages, list pointers — that render as plain text because djot (via
blogatto's `jot` engine) only hyperlinks URLs written as explicit links:
jot's inline parser turns `<url>` autolinks and `[text](url)` links into
anchors, while a bare `https://…` in a paragraph stays literal text. About
964 such URLs sit in 200 of the 404 post variant files today (for example
`http://www.transbankdevelopers.cl/` in the Webpay guide renders unclickable),
so readers cannot follow them.

## What Changes

- Convert every bare `http(s)://` URL in post body prose, across all four
  language variants (`index.djot`, `index-en.djot`, `index-ja.djot`,
  `index-pt.djot`), into a djot autolink (`<url>`), which jot renders as an
  anchor whose href and visible text are the URL.
- Leave untouched, by construction: URLs inside fenced code blocks and
  inline code spans, existing `[text](url)` links and image targets
  (including `[url](url)` self-links), existing `<…>` autolinks and raw HTML
  tags, embed fence payloads (`github`/`youtube`/`ninjas`/`embed`), and
  frontmatter values such as `featured_image`.
- Rebuild the site so the regenerated pages carry the new anchors.
- No site code, template, routing, dependency, or CI changes: this is a
  content-source conversion only.

Out of scope: a render-time linkification feature in the site's Gleam code
(blogatto exposes no public inline/text hook that could linkify post prose
without a custom djot pass), scheme-less URLs (`www.example.com`), and any
change to feeds, sitemap, or robots output.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `blog-site-generation`: one added requirement — plain-text post URLs
  render as clickable links — covering the prose contexts converted, the
  contexts that stay plain, punctuation handling, and the all-variants
  reach.

## Impact

- Content: ~200 `.djot` files under `blog/` rewritten in place (all four
  variants of each affected post); no posts added or removed, frontmatter
  and embed fences untouched, so the `every_post_ships_all_languages_test`
  invariant is unaffected.
- Build output: `dist/` regenerated; the rendered post pages gain `<a>`
  anchors where the URLs previously rendered as text.
- Code and dependencies: none.
