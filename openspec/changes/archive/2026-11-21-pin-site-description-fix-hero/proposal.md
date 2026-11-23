# Proposal

## Why

Two main specs lag the shipped site. The site description — now Spanish and crediting `@CLSource` — is referenced by the identity requirement ("the Ninjas.cl site description") but its text was never pinned, so the spec cannot say what the site says about itself. And `site-masthead`'s home-hero scenario still lists "call-to-action links" the hero no longer renders, while its hero scenarios predate the not-found page's navbar-only masthead.

## What Changes

- `blog-site-generation` gains a requirement pinning the site description's current text — "Ninjas es un grupo desarrollador de software experimental de Chile 🇨🇱. Participa en diversos proyectos tecnológicos, tales como videojuegos, software y otras actividades relacionadas. Ninjas.cl fue fundado en 2015 (¡11 años programando ❤️!) por @CLSource." — with scenarios for the two places it renders: the home hero's description note and the home page's meta description.
- `site-masthead`'s "Per-page masthead hero" requirement is updated to match the shipped hero: the home scenario drops the call-to-action links (pinning their absence) and names the hero's "Software from 🇨🇱 with ❤️" tagline; the post scenario drops the stale call-to-action mention; and a new scenario records the not-found page's navbar-only masthead.
- Tests pin both: the home test asserts the description renders in the note and the meta description; the not-found test asserts the masthead carries no hero elements.

No markup change rides along — the code already matches; this change reconciles the specs and adds coverage.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `blog-site-generation`: gains the site-description requirement under its site-identity scope.
- `site-masthead`: the per-page hero requirement's scenarios match the shipped hero and cover the not-found page.

## Impact

- `test/ninjas_test.gleam`: description assertions in `home_view_renders_homepage_sections_test`, hero-absence assertion in `not_found_view_renders_chrome_and_message_test`. No `src/` changes, no asset or dependency changes.

## Out of scope

- The macOS 9 icon pack — the last shipped-but-unused asset, unaffected here.
- Any rewording of the site description itself — this change records it as it is.
