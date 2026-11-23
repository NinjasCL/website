# Spec Delta

## MODIFIED Requirements

### Requirement: Chile, ninja, and heart emojis are kept
The 🇨🇱 Chile flag, ❤️ heart, 🥷 ninja (including its skin-toned 🥷🏽 form), and 🛸 flying-saucer emojis SHALL stay as text emojis wherever they appear. Revised 2026-11-22: the restored Jasonelle card keeps its 🛸 emoji in its title — the same kept-emoji pattern as the Ninja Systems 🥷.

#### Scenario: Kept emojis render
- **WHEN** the home page is rendered
- **THEN** the hero description, the "Software from 🇨🇱 with ❤️" tagline, the about text, and the footer copyright keep their 🇨🇱, ❤️, and 🥷🏽 emojis
- **AND** the Ninja Systems showcase title keeps its 🥷 emoji
- **AND** the Jasonelle showcase title keeps its 🛸 emoji

### Requirement: The icon manifest documents the matches
A JSON manifest in the site's static icon directory SHALL record every emoji-to-icon match — the emoji, its label, the icon file, where it is used, and a description of the match — plus the kept emojis with their reasons. Revised 2026-11-20: the 🐙→GitHub→Globe and ✉️→Contacto→Mail matches are removed together with all their usages (the Contacto GitHub link, the "Escríbenos" button, the navbar Contacto link, and the Contacto section title), leaving ten matches. Revised 2026-11-22: the post-icons additions (⚠️→Warning, ⬅️➡️→Arrows, 🏷️→Bookmark) bring the matches to fourteen, and the kept 🛸 of the restored Jasonelle card joins 🇨🇱, ❤️, and 🥷 as the fourth kept emoji.

#### Scenario: Manifest present in the static assets
- **WHEN** the static icon directory is inspected
- **THEN** `emoji-matches.json` exists, listing the fourteen matches and the four kept emojis
- **AND** no match documents the removed Contacto controls: no 🐙 entry with the Globe icon and no ✉️ entry with the Mail icon remain
- **AND** the kept list documents the 🛸 flying saucer with its reason

#### Scenario: Manifest ships with the site
- **WHEN** the site is generated
- **THEN** the manifest from the static asset directory is included in the generated site output
