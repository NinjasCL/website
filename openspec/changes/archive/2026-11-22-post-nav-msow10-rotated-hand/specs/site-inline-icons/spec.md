# Spec Delta

## MODIFIED Requirements

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
