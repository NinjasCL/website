# Proposal

## Why

The site ships a collection of 31 classic 88×31 web banners in `static/banners/`
(Get Firefox, Netscape Now, Valid HTML, Winamp, …) that currently sit unused in
the static assets, while the Contacto section holds a pitch heading, a paragraph,
a mailto button and a GitHub link — copy the visitor has already read in "Sobre
nosotros". A retro banner wall is the period-appropriate way to fill that panel
and finally put the shipped banners on display.

## What Changes

- The Contacto section body is emptied: the "¿Construimos algo juntos?" heading,
  its paragraph, the "Escríbenos" mailto button and the GitHub link are removed.
- Every banner GIF under `static/banners/` renders in that panel as a
  decorative image wall — plain `img` elements served from `/banners/`, no links
  (per the site owner's choice), no captions.
- The Contacto identity is stripped: the panel loses its "Contacto" title and
  the navbar loses its Contacto button — on every page, since the navbar is
  shared. The panel keeps only its `rs-panel` box and its `#contact` anchor
  (nothing on the site links there anymore; kept so external deep links keep
  resolving).
- The icon manifest `static/icons/emoji-matches.json` drops the 🐙→Globe and
  ✉️→Mail entries — the removed GitHub link, "Escríbenos" button, navbar link
  and section title were the Mail icon's every use — leaving ten matches.
- `static/style.css` gains a small banner-wall rule (wrapping, natural size,
  pixelated rendering).

## Capabilities

### New Capabilities
- `site-contact-banners`: The untitled banner panel — the former Contacto
  section, at the `#contact` anchor — renders every shipped banner from
  `static/banners/` as a decorative, unlinked image wall at natural proportions.

### Modified Capabilities
- `site-inline-icons`: The emoji-to-icon enumeration drops the Contacto
  controls — the GitHub link, the navbar Contacto link and the Contacto section
  title (none exist anymore; seven navbar links become six, six section titles
  become five) — and the manifest requirement drops the 🐙→Globe and ✉️→Mail
  matches with them: twelve matches become ten.
- `site-showcase-buttons`: The outside-the-showcase exclusion requirement is
  restated without the contact mailto button (the control no longer exists);
  only the footer controls remain excluded.
- `site-section-headers`: The enlarged-header enumeration drops contact — the
  banner panel renders no section header, leaving five titled sections.

## Impact

- `src/site.gleam`: `contact_section/0` is rewritten to render the banner wall
  in an untitled `rs-panel` (the shared `section()` helper always renders a
  title, so the panel stops using it), and the Contacto link is deleted from
  the shared `site_nav/1` — every page's navbar drops to six links (a Gleam
  list of banner filenames mapped to Lustre `html.img` elements — no new
  dependency, blogatto already ships the whole `static/` directory via the
  configured `static_dir`, so the GIFs need no routing work).
- `static/style.css`: new banner-wall presentation rule.
- `static/icons/emoji-matches.json`: two entries removed as above.
- `test/ninjas_test.gleam`: `home_view_renders_six_section_headers_test` shrinks
  to five headers and is renamed; the Globe/🐙 and Mail/✉️ assertions drop from
  `emojis_render_as_static_icons_test` and
  `icon_manifest_documents_matches_test`; new tests cover the banner wall and
  the Contacto removal.
- Contact channels survive elsewhere: `mailto:camilo@ninjas.cl` and the personal
  GitHub link remain in the "Sobre nosotros" text.

## Out of scope

- Curating, reordering or captioning the banners — all 31 ship as-is, in
  alphabetical order.
- Linking banners to their classic destinations (Get Firefox → mozilla.org,
  GitHub → ninjascl, RSS → blog feed) — they stay decorative per the owner's
  choice.
- Touching other sections, other navbar links, the footer badges, or any
  blogatto version/dependency.
