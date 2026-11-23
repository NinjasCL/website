# Proposal

## Why

The home page's section headers ("🌸 Sobre nosotros", "📖 Entradas del blog", "🔮 Proyectos", "📚 Libros", "🎮 Juegos", "✉️ Contacto") are styled by retrostrap's `.rs-panel__title` rule, which sizes them as small tab labels at `--rs-font-size-2` (0.8125rem ≈ 13px) — smaller than the body text. The titles barely read as headings, and section navigation by scrolling suffers. "Sobre nosotros" is the example that prompted this; all six sections share one helper and one style rule, so the fix applies to them all.

## What Changes

- The font size of every home page section header SHALL be enlarged to retrostrap's `--rs-font-size-5` type-ladder step (1.5rem, ≈1.85× the 0.8125rem `.rs-panel__title` default), instead of today's 0.8125rem. Revised 2026-11-20: the original at-least-2× floor (1.625rem) was tuned down one ladder step after visual review; see design.md.
- The change is a `font-size` override for `.rs-panel__title` in `static/style.css`, the site's custom layer on top of retrostrap. No markup or template changes: headers stay `<h2 class="rs-panel__title">` as rendered by the shared `section()` helper in `src/site.gleam`.
- Out of scope:
  - Non-section headings: the post page `h1`, the hero site title, `h3`s inside sections (showcase card titles, "Entrada destacada", "¿Construimos algo juntos?"), and footer text — all keep their current sizes.
  - Heading semantics (levels stay as they are), colors, fonts, font weight, and the retrostrap "tab overlapping the panel border" presentation (its em-based offset scales with the new size on its own).
  - Any change to retrostrap's own stylesheet, `static/retrostrap.min.css`.

## Capabilities

### New Capabilities
- `site-section-headers`: Presentation of home page section headers rendered by the shared `section()` helper — a minimum size relative to retrostrap's panel-title size, applied uniformly across all home page sections ("Sobre nosotros" among them).

### Modified Capabilities

None. No existing spec (`blog-dev-server`, `blog-site-generation`, `site-masthead`) covers section header presentation.

## Impact

- `static/style.css`: one added override rule (plus its explanatory comment). This file loads after retrostrap, so it wins the cascade.
- `gleam.toml` / `manifest.toml`: a dev-only dependency declaration for `simplifile` (already in the lockfile via blogatto) so the test suite can read `static/style.css`. Runtime dependencies, the blogatto range, and CI versions are unchanged.
- No Gleam source, routing, content, or template changes; the generated markup is unchanged.
- `test/ninjas_test.gleam`: gains an assertion locking the override in place, since the size contract lives in a static CSS file rather than in rendered markup.
