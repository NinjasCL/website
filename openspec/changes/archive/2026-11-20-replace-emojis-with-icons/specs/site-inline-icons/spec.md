# Spec Delta

## Purpose

Defines the inline icons that replace the site's emoji chrome: the confirmed emoji-to-icon mapping from the site's static icon assets, the shared inline presentation, the emojis deliberately kept as emojis, and the JSON manifest documenting the matches.

## ADDED Requirements

### Requirement: Emoji chrome renders as matching static icons
Every emoji in the site chrome except the kept ones SHALL render as its matching icon from the site's own static icon assets, displayed inline beside its text: the seven navbar links, the six section titles, the Elixir Chile, Joy of ProcessWire, and Proyecto Chaucha showcase titles, the GitHub link in Contacto, and the featured-post heading.

#### Scenario: Navbar links carry their icons
- **WHEN** the home page is rendered
- **THEN** the Inicio, Blog, Nosotros, Proyectos, Libros, Juegos, and Contacto links each lead with their matching icon (Desktop, Notepad, D3FlowerBox, Bulb, HelpBook, Winmine, Mail)

#### Scenario: Section titles carry their icons
- **WHEN** the home page is rendered
- **THEN** the Sobre nosotros, Entradas del blog, Proyectos, Libros, Juegos, and Contacto section titles each lead with their matching icon

#### Scenario: Showcase titles, GitHub link, and featured heading carry their icons
- **WHEN** the home page is rendered
- **THEN** the Elixir Chile title leads with the Registration Wizard icon, Joy of ProcessWire with the FastBoot icon, Proyecto Chaucha with the Quartz icon, the GitHub link with the Globe icon, and the featured-post heading with the Star icon

#### Scenario: No replaced emoji remains
- **WHEN** the generated home page's markup is inspected
- **THEN** none of the replaced emojis (🏠 📖 🌸 🔮 📚 🎮 ✉️ 🧙 🚀 🪙 🐙 ⭐) appears in the markup

### Requirement: Chile, ninja, and heart emojis are kept
The 🇨🇱 Chile flag, ❤️ heart, and 🥷 ninja emojis (including its skin-toned 🥷🏽 form) SHALL stay as text emojis wherever they appear.

#### Scenario: Kept emojis render
- **WHEN** the home page is rendered
- **THEN** the hero description, the "Software from 🇨🇱 with ❤️" tagline, the about text, and the footer copyright keep their 🇨🇱, ❤️, and 🥷🏽 emojis
- **AND** the Ninja Systems showcase title keeps its 🥷 emoji

### Requirement: Inline icons share one presentation
All emoji-replacement icons SHALL render through one shared inline presentation: roughly text-sized relative to their context, crisp (pixelated) scaling, aligned with the text baseline, and served from the site's own static assets.

#### Scenario: Shared presentation in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** a single `.site-icon` rule sizes the icons relative to the text (so they scale from the navbar to the enlarged section titles) with pixelated rendering

#### Scenario: Icon assets ship with the site
- **WHEN** the site is generated
- **THEN** the icon files used by the mapping are included in the generated site output

### Requirement: The icon manifest documents the matches
A JSON manifest in the site's static icon directory SHALL record every emoji-to-icon match — the emoji, its label, the icon file, where it is used, and a description of the match — plus the kept emojis with their reasons.

#### Scenario: Manifest present in the static assets
- **WHEN** the static icon directory is inspected
- **THEN** `emoji-matches.json` exists, listing the twelve matches and the three kept emojis

#### Scenario: Manifest ships with the site
- **WHEN** the site is generated
- **THEN** the manifest from the static asset directory is included in the generated site output
