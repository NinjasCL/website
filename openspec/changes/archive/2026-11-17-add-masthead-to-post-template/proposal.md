# Proposal

## Why

Single post pages render a minimal `site-header` with only a "← Ninjas.cl" back
link, so readers lose the site navigation (and the `#masthead` anchor) as soon
as they leave the home page. The navbar should be site chrome — present on
every page — while the hero panel inside the masthead stays free to change per
page.

## What Changes

- Split `masthead()` in `src/site.gleam` into a shared navbar plus a
  page-specific hero area, so the masthead chrome (navbar, `#masthead` anchor)
  is reusable across templates.
- Render the masthead in `post_template`, replacing the minimal `site-header`
  back-link header on single post pages.
- Make the navbar page-aware: on non-home pages, section links (`#about`,
  `#projects`, …) point at the home page (`/#about`, …) instead of dead in-page
  anchors, and `aria_current("page")` is only set on the home page's "Inicio"
  link.
- Give the single post page a compact hero (logo + site title, without the home
  hero's description note, call-to-action buttons, and marquee). The exact
  compact-hero content is an assumption and can be adjusted during apply.
- The home page's rendered markup is unchanged.

Out of scope:

- Unifying the post page's simple footer with the home page's `site_footer()`
  (the post footer keeps its current form).
- New routes, pages, or navbar entries (for example a `/blog` index page).
- Any blogatto version bump or new dependency.

## Capabilities

### New Capabilities
- `site-masthead`: The site masthead — a global navbar shared by every
  generated page plus a per-page hero area — so primary navigation is present
  everywhere while hero content can differ per page.

### Modified Capabilities

None. `blog-site-generation`'s post-rendering requirement stays as written; the
masthead behavior is new and owned by `site-masthead`.

## Impact

- `src/site.gleam`: `masthead()` refactored into navbar + hero components;
  `post_template` renders the masthead instead of `site-header`. Uses only the
  existing Lustre view APIs (`lustre/element/html`, `lustre/attribute`).
- `test/ninjas_test.gleam`: new assertions that `post_template` renders the
  navbar/`#masthead` and page-aware section links; home page assertions
  unchanged.
- No configuration or dependency changes: blogatto's `post.template(...)`
  wiring in `src/ninjas/blog.gleam` is untouched.
- CI: `gleam test` and `gleam format --check src test` must keep passing.
