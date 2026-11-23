# site-inline-icons Specification

## Purpose

Defines the inline icons that replace the site's emoji chrome: the confirmed emoji-to-icon mapping from the site's static icon assets, the shared inline presentation, the emojis deliberately kept as emojis, and the JSON manifest documenting the matches.

## Requirements

### Requirement: Emoji chrome renders as matching static icons
Every emoji in the site chrome except the kept ones SHALL render as its matching icon from the site's own static icon assets, displayed inline beside its text: the six navbar links, the five section titles, the Elixir Chile, Joy of ProcessWire, and Proyecto Chaucha showcase titles, and the featured-post heading. Revised 2026-11-20: the banner-wall change removed the Contacto controls — the GitHub link, the navbar Contacto link, and the Contacto section title leave the enumeration (seven navbar links became six, six section titles became five).

#### Scenario: Navbar links carry their icons
- **WHEN** the home page is rendered
- **THEN** the Inicio, Blog, Nosotros, Proyectos, Libros, and Juegos links each lead with their matching icon (Desktop, Notepad, D3FlowerBox, Bulb, HelpBook, Winmine)

#### Scenario: Section titles carry their icons
- **WHEN** the home page is rendered
- **THEN** the Sobre nosotros, Entradas del blog, Proyectos, Libros, and Juegos section titles each lead with their matching icon

#### Scenario: Showcase titles, GitHub link, and featured heading carry their icons
- **WHEN** the home page is rendered
- **THEN** the Elixir Chile title leads with the Registration Wizard icon, Joy of ProcessWire with the FastBoot icon, Proyecto Chaucha with the Quartz icon, and the featured-post heading with the Star icon
- **AND** the removed Contacto controls leave no Globe or Mail icon anywhere on the home page

#### Scenario: No replaced emoji remains
- **WHEN** the generated home page's markup is inspected
- **THEN** none of the replaced emojis (🏠 📖 🌸 🔮 📚 🎮 🧙 🚀 🪙 ⭐) appears in the markup

### Requirement: Chile, ninja, and heart emojis are kept
The 🇨🇱 Chile flag, ❤️ heart, 🥷 ninja (including its skin-toned 🥷🏽 form), and 🛸 flying-saucer emojis SHALL stay as text emojis wherever they appear. Revised 2026-11-22: the restored Jasonelle card keeps its 🛸 emoji in its title — the same kept-emoji pattern as the Ninjas.cl 🥷.

#### Scenario: Kept emojis render
- **WHEN** the home page is rendered
- **THEN** the hero description, the "Software de 🇨🇱 con ❤️" tagline, the about text, and the footer copyright keep their 🇨🇱, ❤️, and 🥷🏽 emojis
- **AND** the Ninjas.cl showcase title keeps its 🥷 emoji
- **AND** the Jasonelle showcase title keeps its 🛸 emoji

### Requirement: Inline icons share one presentation
All emoji-replacement icons SHALL render through one shared inline presentation: roughly text-sized relative to their context, crisp (pixelated) scaling, aligned with the text baseline, and served from the site's own static assets.

#### Scenario: Shared presentation in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** a single `.site-icon` rule sizes the icons relative to the text (so they scale from the navbar to the enlarged section titles) with pixelated rendering

#### Scenario: Icon assets ship with the site
- **WHEN** the site is generated
- **THEN** the icon files used by the mapping are included in the generated site output

### Requirement: The icon manifest documents the matches
A JSON manifest in the site's static icon directory SHALL record every emoji-to-icon match — the emoji, its label, the icon file, where it is used, and a description of the match — plus the kept emojis with their reasons. Revised 2026-11-20: the 🐙→GitHub→Globe and ✉️→Contacto→Mail matches are removed together with all their usages (the Contacto GitHub link, the "Escríbenos" button, the navbar Contacto link, and the Contacto section title), leaving ten matches. Revised 2026-11-22: the post-icons additions (⚠️→Warning, ⬅️➡️→pointing hands, 🏷️→Bookmark) bring the matches to fourteen, and the kept 🛸 of the restored Jasonelle card joins 🇨🇱, ❤️, and 🥷 as the fourth kept emoji. The ⬅️/➡️ post-navigation matches name the Win95 `Msow10_32x32_4.png` hand — a quarter turn counter-clockwise for ⬅️, clockwise for ➡️ — in place of the former arrows.

#### Scenario: Manifest present in the static assets
- **WHEN** the static icon directory is inspected
- **THEN** `emoji-matches.json` exists, listing the fourteen matches and the four kept emojis
- **AND** no match documents the removed Contacto controls: no 🐙 entry with the Globe icon and no ✉️ entry with the Mail icon remain
- **AND** the kept list documents the 🛸 flying saucer with its reason
- **AND** the ⬅️ and ➡️ entries name `Msow10_32x32_4.png` and describe their counter-clockwise and clockwise rotations

#### Scenario: Manifest ships with the site
- **WHEN** the site is generated
- **THEN** the manifest from the static asset directory is included in the generated site output

### Requirement: The blog post title and date lead with icons
The blog post's presentation SHALL lead its title with the post's own title icon — the post's declared `icon` frontmatter value, or the newspaper icon as its fallback (see `site-post-icons`) — and its date with the calendar icon — on the home page's featured post row and on the post page's article alike — through the shared inline icon presentation: decorative icons beside their text, empty alt, served from the site's static icon assets.

#### Scenario: Featured post title and date on the home page
- **WHEN** the home page is rendered with at least one post
- **THEN** the featured post's title leads with that post's icon — its declared value, or the newspaper icon (`/icons/win95/Mailnews8_32x32_4.png`) when it declares none — and its post-meta date leads with the calendar icon (`/icons/win95/Timedate_32x32_4.png`)

#### Scenario: Post page title and date
- **WHEN** a post page is rendered from the post template
- **THEN** the post's title leads with the post's own icon — its declared value, or the newspaper fallback — and its post-meta date leads with the calendar icon, matching the featured post's presentation
