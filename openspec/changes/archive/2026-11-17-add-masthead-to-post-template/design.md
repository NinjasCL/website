# Design

## Context

See proposal.md — Why. Today `masthead()` in `src/site.gleam` hardcodes the
navbar, the home hero, and the marquee into one function used only by
`home_view`. `post_template` renders its own minimal `site-header` with a
"← Ninjas.cl" back link, so post pages have no navbar, no `#masthead` anchor,
and navbar section links (`#about`, `#projects`, …) exist nowhere off the home
page. blogatto already routes post rendering through `post.template(site.post_template)`
(see `src/ninjas/blog.gleam`); no blogatto feature is missing — this is purely a
view-layer reorganization of existing Lustre elements.

## Goals / Non-Goals

**Goals:**

- One shared navbar rendered by every template (home and single post first).
- Hero content chosen per page, with the home page's rendered markup unchanged.
- Navbar links that actually work from post pages, and correct
  `aria-current` only on the current page.
- Testable with the existing gleeunit + `element.to_string` pattern.

**Non-Goals:**

- No new routes or pages, no `/blog` index page, no footer unification
  (proposal.md — What Changes, out of scope).
- No new CSS; the compact hero reuses the existing `.hero`/`.hero__logo` styles.

## Decisions

1. **Split the masthead into navbar + page-provided hero elements.**
   `masthead()` becomes a wrapper that renders `header#masthead.masthead` with
   the shared navbar first and the page's hero elements after it:

   - `site_nav(on_home: Bool)` — the `rs-navbar` link list.
   - `home_hero()` — today's hero panel, markup unchanged.
   - `marquee()` — today's marquee div, unchanged.
   - `post_hero()` — compact variant of the hero panel: same
     `.hero rs-panel rs-panel--raised` classes and `rs-cols-2` logo + title
     layout, without the `rs-note` description, the `rs-btn` call-to-action
     row, and the marquee.

   Home composes `masthead(on_home: True, children: [home_hero(), marquee()])`;
   the post template composes `masthead(on_home: False, children: [post_hero()])`.
   The DOM of both pages keeps today's element order (header → nav → hero → …),
   so the home page's rendered output is identical.

   *Alternatives considered:* duplicating the navbar into the post template
   (rejected: the two copies would drift); passing a nav-prefix string instead
   of the flag (rejected: it only fixes link hrefs, not `aria-current`).

2. **Page-aware navbar via a `on_home: Bool` flag.**
   With `on_home: False`, section links render as home-prefixed fragments
   (`/#about`, `/#projects`, …) instead of dead in-page anchors, and the
   "Inicio" link drops `aria_current("page")`. "Blog" keeps `/blog`; "Inicio"
   keeps `/`. This is the smallest fix that makes every navbar entry resolve
   from a post page while leaving home markup untouched.

   *Alternative considered:* always rendering `/#projects` (works on home too,
   since same-page fragment links resolve) — rejected because it changes the
   home page's markup, which the proposal promises not to do. If a third page
   type ever needs its own current-page marker, the flag is promoted to a
   small enum; with two templates a bool is enough.

3. **Post template drops the back-link header.**
   `post_template` replaces its `site-header` block with the masthead. The old
   "← Ninjas.cl" link is removed without replacement: the navbar's "Inicio"
   entry covers it. The blogatto wiring in `src/ninjas/blog.gleam` and the
   `post_template(post, all_posts)` signature are unchanged, so routing and
   content loading are untouched.

4. **No new dependency.**
   Everything needed — Lustre elements/attributes and the existing
   `post.template` hook — already comes from the locked blogatto range; this
   change only reorganizes functions inside `src/site.gleam`.

5. **Tests construct a `Post` fixture directly.**
   `blogatto/post`'s `Post` constructor is public with all fields, so
   `test/ninjas_test.gleam` can call `site.post_template(fixture, [])` and
   assert on the rendered string: `rs-navbar` and `id="masthead"` present,
   `/#projects` present, no `site-header`, no `rs-marquee`, no
   `aria-current` — plus the post title still rendered. A matching home-page
   assertion pins the in-page `#projects` anchor and `aria-current` contrast.

## Risks / Trade-offs

- [Navbar drift between templates] → Mitigated by the single `site_nav`
  function both templates call; the shared function is the point of the split.
- [Wrong `aria-current` or link prefix slipping in] → Covered by the
  home/post assertion pair in the tests.
- [Compact hero feels large under a short post] → The `.hero__logo` size and
  hero composition can be tuned at apply time within the spec's scenario;
  recorded as an adjustable assumption in the proposal.
- [Flag proliferation when more page types appear] → Deliberate trade-off for
  now; promotion of `on_home: Bool` to an enum is a contained, local refactor.

## Migration Plan

None. The site is regenerated from source; no persisted state or URL changes.
Rollback is reverting the commit and rebuilding.
