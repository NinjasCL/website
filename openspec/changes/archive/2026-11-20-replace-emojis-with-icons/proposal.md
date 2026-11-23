# Proposal

## Why

With the showcase buttons gaining icons from the site's Windows 95-era icon pack (`static/icons`, owner-added), the rest of the site still speaks emoji — a mixed visual language. This change migrates the site's emoji chrome to matching icons from the same pack, with the owner-confirmed mapping, and documents the matches in a JSON manifest shipped inside the icon directory. Per the owner: the Chile 🇨🇱, ninja 🥷 (including 🥷🏽), and heart ❤️ emojis stay as emojis.

## What Changes

- Twelve emoji uses render as their matching static icon instead (mapping confirmed by the owner; see design.md for the full table with rationale): the seven navbar links (🏠 Inicio, 📖 Blog, 🌸 Nosotros, 🔮 Proyectos, 📚 Libros, 🎮 Juegos, ✉️ Contacto), the six section titles (Sobre nosotros, Entradas del blog, Proyectos, Libros, Juegos, Contacto), three showcase card titles (🧙 Elixir Chile, 🚀 Joy of ProcessWire, 🪙 Proyecto Chaucha), the 🐙 GitHub link in Contacto, and the ⭐ Entrada destacada heading.
- Icons render inline beside their text through one shared presentation (a helper plus a `.site-icon` rule — roughly text-sized, crisp pixelated).
- A new `static/icons/emoji-matches.json` manifest records every match (emoji, label, icon file, where used, description) plus the kept emojis with reasons. It ships with the site as a documentation asset — nothing in Gleam parses it (no `gleam_json` dependency).
- Out of scope:
  - The kept emojis 🇨🇱 ❤️ 🥷 🥷🏽 — untouched wherever they appear (hero, description, about text, the Ninja Systems card title, footer copyright).
  - Non-emoji symbols: the marquee's ★ dingbats and the 忍者 開発者 kanji stay.
  - The icon pack contents themselves, apart from adding the manifest.
  - Button presentation beyond the emoji swap — the "✉️ Escríbenos" button keeps its primary styling, only its leading emoji becomes the mail icon; the separate `enlarge-showcase-buttons` change owns button sizing.
  - Any new Gleam dependency, routing, content, or build-configuration change.

## Capabilities

### New Capabilities
- `site-inline-icons`: The inline icons that replace the site's emoji chrome — the confirmed emoji→icon mapping, their shared inline presentation, the emojis kept as emojis, and the manifest documenting the matches.

### Modified Capabilities

None. No existing spec covers the navbar, section titles, or emoji presentation; the unarchived `enlarge-showcase-buttons` delta covers only button sizing and button icons.

## Impact

- `src/site.gleam`: a small `icon(path)` helper; the seven nav links, the shared `section` helper (gains an icon argument), `ShowcaseItem` (gains an icon field — empty string for none), the contact mailto button, `external_link` (gains an icon argument used by the GitHub link), and the featured-post heading.
- `static/style.css`: one `.site-icon` rule (about text size, pixelated, baseline-aligned).
- `static/icons/emoji-matches.json`: new manifest.
- `test/ninjas_test.gleam`: the row test's "🧙 Elixir Chile 🇨🇱" assertion updates to the new title ("Elixir Chile 🇨🇱" — the flag stays), plus new tests asserting each icon renders, the replaced emojis are gone, the kept emojis remain, and the manifest lists the matches.
- No `gleam.toml`, `manifest.toml`, or CI changes.
