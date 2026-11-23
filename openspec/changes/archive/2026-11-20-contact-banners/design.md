# Design

## Context

`src/site.gleam` builds the home page as pure Lustre views; `contact_section/0`
currently renders a titled panel (via the shared `section()` helper) with a
heading, a paragraph, a mailto button and a GitHub link, and the shared
`site_nav/1` ends with a Contacto link. `static/banners/` ships 31 retro GIFs —
28 at the classic 88×31 button size, plus `iframsuc.gif` (87×31),
`ubuntu-88x31.gif` (90×32) and `netbsd2.gif` (90×33). blogatto already copies
the whole `static/` tree into the generated site (the blog config pins
`static_dir` to `./static`, covered by `production_blog_config_test`), so every
GIF is already servable at `/banners/<name>`; nothing about routing or asset
delivery needs to change. Revised 2026-11-20: the owner also removed the
Contacto navbar button and the section title, so the panel ships untitled and
no site link targets `#contact` anymore.

## Goals / Non-Goals

**Goals:**

- Render all 31 shipped banners in the former Contacto panel as decorative,
  unlinked images, with markup that keeps working without JavaScript.
- Strip the Contacto identity: no navbar button on any generated page, no
  section title — the word "Contacto" disappears from the markup entirely.
- Keep the rendered banner list provably in sync with `static/banners/`.

**Non-Goals:**

- Linking banners, ordering them beyond alphabetical, or recompressing the GIFs.
- Restoring the removed contact copy anywhere else on the page — the
  "Sobre nosotros" text already carries the mailto and GitHub references.

## Decisions

### Banner list as a Gleam const, cross-checked by a test

A `const banners: List(#(String, String))` of `(filename, alt)` tuples in
`src/site.gleam`, mapped by `contact_section/0` to `html.img` elements pointing
at `/banners/<filename>`. Rationale: views are pure element builders here —
`home_view([])` renders without touching the disk, and tests render it
directly, so reading the directory with `simplifile` inside the view would
couple rendering to filesystem IO. Drift is instead caught by a test that
compares the rendered wall against `simplifile.read_directory("./static/banners")`
— the same pattern `background_patterns_match_shipped_files_test` already uses
for the background pattern list. Alternative rejected: generating the wall in
`background.js`-style client script (banners must exist for no-JS visitors, and
the wall is content, not chrome).

Each tuple carries a short descriptive alt (the banner's own message, e.g.
`"Get Firefox"`), because the GIFs are readable text art — `alt=""` would hide
31 meaningful images from assistive tech even though they are non-interactive.

### Untitled `rs-panel`, not the `section()` helper

The shared `section()` helper always renders an `h2` title, so the banner panel
stops using it and renders `html.section` directly with `id="contact"` and the
`rs-panel` class — the same untitled-panel pattern the showcase cards already
use (`html.article` with `rs-panel`, no `rs-panel__title`). The panel keeps its
`#contact` anchor even though nothing links to it anymore: external deep links
to `ninjas.cl/#contact` keep resolving, and the anchor costs nothing (recorded
assumption; dropping it is a one-line follow-up if the owner prefers).

The navbar edit is symmetric: `site_nav/1` drops its Contacto entry, leaving
six links (Inicio, Blog, Nosotros, Proyectos, Libros, Juegos). `site_nav/1` is
shared by every generated page, so post pages lose the Contacto link too —
and with it the `/#contact` form of the section-link pattern. The
`section_link()` helper keeps its other callers.

### Presentation: a `.banner-wall` rule, not retrostrap's `rs-button88`

`static/style.css` gains:

```css
.banner-wall {
  display: flex;
  flex-wrap: wrap;
  gap: var(--rs-space-3);
  justify-content: center;
}

.banner-wall img {
  image-rendering: pixelated;
}
```

retrostrap's `rs-button88 img` rule was the obvious reuse, but it forces
`inline-size: 88px; block-size: 31px`, which would distort the three
odd-sized banners (`iframsuc`, `ubuntu-88x31`, `netbsd2`), and the class
carries a bevel button chrome meant for anchors. The custom rule keeps each
GIF at its intrinsic size — the flex-wrap row handles the responsive layout,
reusing the project's established "custom grid/row rule in style.css" pattern
(`about__cols`, `showcase__cols`). Images also get
`attribute.loading("lazy")` since 31 GIFs sit at the bottom of the page.

### Routing, content files, templates

No routes change: the wall is more content in the existing home view, and
`/banners/*` already resolves through blogatto's `static_dir` copy. No content
files are added, moved or edited — the GIFs ship as-is, alphabetical order.
Two shared-template contracts shrink with the Contacto removal: five sections
keep `rs-panel__title` headers (the enlarged-header rule still applies to all
of them), and the inline-icon enumeration loses its Mail usages.

### Dependencies

None. `html.img` + `list.map` from Lustre/stdlib cover the markup; the assets
flow through an existing blogatto feature (`static_dir`), which is sufficient —
no new package or blogatto capability is needed.

### Spec-adjacent cleanup

Removing the Contacto controls removes the only uses of both the Globe and Mail
icons (the GitHub link, "Escríbenos" button, navbar link and section title were
the Mail icon's every use), so `static/icons/emoji-matches.json` drops the
🐙→Globe and ✉️→Mail entries — twelve matches become ten. The affected tests are
updated in the same pass: `emojis_render_as_static_icons_test` loses its
Globe/🐙 and Mail/✉️ assertions, `icon_manifest_documents_matches_test` stops
asserting those icons, and `home_view_renders_six_section_headers_test` shrinks
to five headers (six pieces after splitting) and is renamed.

## Risks / Trade-offs

- [Risk] The const banner list drifts from `static/banners/` (a GIF added or
  renamed without updating code) → Mitigation: the new test compares the
  rendered wall against `simplifile.read_directory("./static/banners")`.
- [Risk] 31 GIFs at page bottom add weight (≈100 KB total, the largest single
  GIF ≈15 KB) → Mitigation: `loading="lazy"` keeps them out of the initial
  viewport load; total is modest for a retro site.
- [Trade-off] The Contacto section loses its call-to-action copy and its
  navigation identity — the mailto and GitHub links survive only in "Sobre
  nosotros", and `#contact` becomes an orphaned (but stable) anchor — accepted
  by the owner.

## Migration Plan

Single-pass template/static change with no data or route migration: rewrite
`contact_section/0`, delete the navbar link, add the style rule, update the
manifest, update/add tests. Rollback is reverting the commit; no generated
output is committed.

## Open Questions

- Exact Spanish alt wording for a few ambiguous banners (e.g. `iframsuc`,
  `hotgraphics`) — content polish, adjustable later without touching the
  structure; tests assert on filename-derived presence rather than alt text.
