# Design

## Context

See proposal.md — Why. `masthead()` in `src/site.gleam` renders
`header#masthead.masthead` as the shared navbar plus page-provided hero
children: the home page passes `home_hero()` and `marquee()`, and
`post_template` passes `post_hero()` — the compact logo-and-title panel the
site owner wants replaced by a cover image. blogatto already parses the
`featured_image` frontmatter field into `post.featured_image: Option(String)`
(see `build/packages/blogatto/src/blogatto/post.gleam`), and the home page
already resolves its absence to `/img/Ninjas.png` via `featured_image(post)`
in `src/site.gleam`. Routing, content loading, and the blogatto wiring in
`src/ninjas/blog.gleam` are untouched by this change.

## Goals / Non-Goals

**Goals:**

- Post masthead filled edge to edge by the post's header image, defaulting
  to the Ninjas logo, with no hero content inside.
- One shared masthead function keeps rendering the navbar for every page.
- Testable with the existing gleeunit + `element.to_string` pattern.

**Non-Goals:**

- No new frontmatter field, no `og:image`/`twitter:image` change, no home
  or not-found masthead change (see proposal.md — out of scope).
- No post-asset pipeline: the header image is a path the frontmatter
  already declares, served like every other site image.

## Decisions

1. **Reuse `featured_image` as the header image; reuse the existing
   placeholder resolution.** The post template resolves its cover with the
   same `featured_image(post)` helper the home featured row uses
   (`option.unwrap(_, "/img/Ninjas.png")`), so one frontmatter field feeds
   both presentations and the default stays pinned in one place.

   *Alternative considered:* a dedicated `header_image`/`cover` frontmatter
   field via blogatto's `extras` — rejected: two image fields would let the
   home row and the post masthead disagree, and the shipped post already
   declares `featured_image: /img/Ninjas.png`.

2. **The cover flows through the shared `masthead()` as a parameter.**
   `masthead()` gains a `cover: Option(String)` argument: `option.None`
   renders today's plain header (home, not-found), `option.Some(url)`
   renders `class="masthead masthead--cover"` plus an inline
   `background-image: url('…')` style. The post template calls
   `masthead(on_home: False, cover: option.Some(featured_image(post)),
   children: [])` — no hero children. Keeping the one function preserves the
   single-navbar property the archived `add-masthead-to-post-template`
   change established (a second header wrapper would drift).

   *Alternative considered:* a separate `post_masthead()` function —
   rejected for the same drift reason; *considered:* an empty-string
   sentinel instead of `Option` — rejected, `Option` states absence
   explicitly and the call sites stay readable.

3. **Inline style carries the per-post URL; the static presentation lives
   in `style.css`.** The image URL is per-post, so it must be an inline
   style attribute (`attribute.style("background-image", "url(" <> url <>
   ")")` — unquoted, because lustre escapes attribute values and quotes
   would serialize as `&#39;` noise; the values are repo-authored local
   image paths, which unquoted `url()` tokens accept). The
   covering behavior is page-independent and belongs in one
   `.masthead--cover` rule: `background-size: cover; background-position:
   center; background-repeat: no-repeat; min-height: 240px;`. The
   min-height keeps the masthead a banner once the hero (its only source of
   height) is removed — an adjustable value, like the archived changes'
   size tunings. `background-size: cover` crops rather than stretches, so
   any header image ratio renders undistorted.

   *Alternative considered:* a `data`-attribute plus generated CSS —
   rejected as over-engineering; `element.unsafe_raw_html` — rejected,
   lustre's attribute rendering already escapes safely.

4. **Delete `post_hero()`.** With the cover replacing the compact hero, the
   function has no callers; removing it keeps `src/site.gleam` free of dead
   view code.

5. **No new dependency.** blogatto's `featured_image` parsing and lustre's
   `attribute.style` cover the whole need; nothing in blogatto is missing.

## Risks / Trade-offs

- [Navbar legibility over busy covers] → retrostrap's `.rs-navbar` keeps its
  solid bevel background and border, so the link strip stays readable over
  any image.
- [A `featured_image` value with spaces or quotes breaks the `url()` token] →
  Values are authored in this repo's committed frontmatter, not visitor
  input; acceptable, and the style attribute is still escaped by lustre.
- [240px min-height too tall/short for some covers] → One value, tuned in a
  single CSS line at apply time; recorded in tasks as adjustable.
- [Home page's absolute hero logo URL vs the cover's local path] → The home
  hero keeps its absolute `https://ninjas.cl/img/Ninjas.png` src untouched;
  the post cover uses the local `/img/Ninjas.png` default, matching the
  featured row's placeholder.

## Migration Plan

None. The site is regenerated from source on every build; rollback is
reverting the commit and rebuilding.
