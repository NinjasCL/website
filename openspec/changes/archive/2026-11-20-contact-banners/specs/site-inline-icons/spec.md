# Spec Delta

## MODIFIED Requirements

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

### Requirement: The icon manifest documents the matches
A JSON manifest in the site's static icon directory SHALL record every emoji-to-icon match — the emoji, its label, the icon file, where it is used, and a description of the match — plus the kept emojis with their reasons. Revised 2026-11-20: the 🐙→GitHub→Globe and ✉️→Contacto→Mail matches are removed together with all their usages (the Contacto GitHub link, the "Escríbenos" button, the navbar Contacto link, and the Contacto section title), leaving ten matches.

#### Scenario: Manifest present in the static assets
- **WHEN** the static icon directory is inspected
- **THEN** `emoji-matches.json` exists, listing the ten matches and the three kept emojis
- **AND** no match documents the removed Contacto controls: no 🐙 entry with the Globe icon and no ✉️ entry with the Mail icon remain

#### Scenario: Manifest ships with the site
- **WHEN** the site is generated
- **THEN** the manifest from the static asset directory is included in the generated site output
