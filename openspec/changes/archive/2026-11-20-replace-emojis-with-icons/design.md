# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `src/site.gleam` holds twelve replaceable emoji uses (enumerated by grep): the seven navbar labels, six section titles passed as strings to the `section` helper, three `ShowcaseItem` titles, the contact "✉️ Escríbenos" button and "🐙 GitHub" link, and the "⭐ Entrada destacada" heading. The kept emojis — 🇨🇱 (five sites), ❤️ (two), 🥷 (one), 🥷🏽 (one) — are excluded per the owner, as are non-emoji symbols (the marquee's ★, the 忍者 開発者 kanji).
- The icon pack under `static/icons` provides every chosen icon in a 32×32 variant; the owner confirmed the mapping below.
- The related-but-separate `enlarge-showcase-buttons` change puts icons inside the card buttons; this change owns everything else. The two touch disjoint parts of `showcase_card` (buttons vs the title `h3`), so either apply order works.

Routing, content files, and templates are unaffected: this is view markup plus `static/style.css` plus a new static JSON file, all shipped verbatim by blogatto. No new dependency — the manifest is documentation, not build input.

## Goals / Non-Goals

**Goals:**

- One confirmed icon per emoji, rendered inline beside its text, sharing one em-relative presentation.
- A manifest that lets anyone (human or future code) see which icon replaced which emoji and why.

**Non-Goals:**

- No change to kept emojis, non-emoji symbols, icon pack contents, labels, or links.
- No JSON parsing in Gleam; the manifest is a shipped asset.

## Decisions

1. **The confirmed mapping** (owner-approved; icons are 32×32 variants served from `/icons`):

   | Emoji | Where | Icon | Why |
   |---|---|---|---|
   | 🏠 | Inicio nav | `Desktop_32x32_4.png` | the desktop — the Windows home screen |
   | 📖 | Blog nav + Entradas del blog | `Notepad_32x32_4.png` | written entries |
   | 🌸 | Nosotros nav + Sobre nosotros | `D3FlowerBox100_32x32_4.png` | the pack's flower |
   | 🔮 | Proyectos nav + section | `Bulb_32x32_4.png` | ideas/projects — the crystal ball's nearest neighbour |
   | 📚 | Libros nav + section | `HelpBook_32x32_4.png` | the pack's book |
   | 🎮 | Juegos nav + section | `Winmine1_32x32_4.png` | Minesweeper, THE Win95 game |
   | ✉️ | Contacto nav + section + Escríbenos | `Mail_32x32_4.png` | the classic envelope |
   | 🧙 | Elixir Chile title | `Regwiz117_32x32_4.png` | the Registration Wizard |
   | 🚀 | Joy of ProcessWire title | `Fastboot101_32x32_4.png` | fast/launch |
   | 🪙 | Proyecto Chaucha title | `Quartz100_32x32_4.png` | a crystal for the coin |
   | 🐙 | GitHub link | `Globe_32x32_4.png` | the web, in place of the octopus |
   | ⭐ | Entrada destacada | `Star_32x32_4.png` | the star |

   Two book emojis, one book glyph in the pack — so Blog takes the writing metaphor (Notepad) and Libros the book (HelpBook). Picks were made by name semantics (this agent cannot render image files); the manifest plus one-line call-site edits make any swap cheap after a browser check.
2. **A tiny `icon(path)` helper** emitting `img.site-icon` with an empty alt (decorative — the adjacent text carries the meaning), plus one CSS rule: `.site-icon { height: 1.25em; width: auto; image-rendering: pixelated; vertical-align: -0.25em; }`. Em-relative sizing makes the same icon sit correctly at navbar scale (~20px) and inside the enlarged 1.5rem section titles (~30px). Alternative rejected: fixed pixel sizes per context — extra rules for what `em` gives for free.
3. **Markup plumbing stays minimal and explicit:** the `section` helper gains an icon argument (all six sections pass one); `ShowcaseItem` gains an `icon: String` field with the empty string meaning "title keeps its text" (the Ninja Systems card — 🥷 stays); `external_link` gains an icon argument used only by the contact GitHub link; the nav links and the featured-post heading build their `[icon, text]` lists inline. Text keeps a leading space after each icon (e.g. `" Inicio"`), which the browser renders as the natural gap.
4. **The manifest `static/icons/emoji-matches.json`** records the twelve matches (emoji, label, icon file, where used, description) and the three kept emojis with reasons. Shape is documented in the file itself; a test reads it via `simplifile` and asserts it names all twelve icons and the kept emojis, keeping the manifest honest as the mapping evolves.
5. **Tests**: markup assertions — every icon `src` present in the rendered home page, the twelve replaced emojis absent, the kept emojis present (hero tagline, about text, Ninja title, footer copyright), ordering spot-checks (a nav icon precedes its label; the wizard icon precedes "Elixir Chile 🇨🇱"), the `.site-icon` CSS rule present, and the manifest contents. The existing row test's `"🧙 Elixir Chile 🇨🇱"` assertion updates to `"Elixir Chile 🇨🇱"` (the flag stays, the wizard becomes an icon).

## Risks / Trade-offs

- [Name-based icon picks were never visually verified (this agent cannot view images)] → The manifest documents intent; the browser eyeball step is the checkpoint, and any swap is a one-line call-site (and manifest) edit.
- [Inline icons inside the absolutely-positioned section-title tabs could widen long titles on narrow viewports] → Same wrap behavior the enlarged titles already have; the em-sized icon grows with its title, so the tab keeps scaling as one unit.
- [The manifest can drift from the markup] → The test asserts the manifest names exactly the icons the markup uses, so drift fails CI.

## Migration Plan

1. Add the `icon` helper and the `.site-icon` rule.
2. Swap the twelve emoji uses to icons (nav, sections, card titles, contact, featured heading), keeping the excluded emojis.
3. Write `static/icons/emoji-matches.json`.
4. Update the row-test assertion; add the mapping, CSS, and manifest tests.
5. Verify: `gleam format src test`, `gleam test`, `openspec validate replace-emojis-with-icons`.

Rollback: revert the markup strings and remove the helper, CSS rule, manifest, and tests; nothing else persists.
