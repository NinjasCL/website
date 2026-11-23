# Proposal

## Why

The site owner rewrote the "Sobre nosotros" copy directly in `src/site.gleam`: the portrait caption now credits the handle `@CLSource` instead of the personal name, and the section text speaks in the site's own first-person voice. The spec and the test still pin the old copy — `home_view_renders_about_row_test` fails against the shipped markup — so this change aligns them with the copy as it now renders.

## What Changes

- The portrait's figure caption changes from "Camilo Castro — Software Engineer" to "@CLSource — Software Engineer".
- The about text is rewritten in first person, opening with "Ninjas es un grupo experimental de desarrollo de software de Chile 🇨🇱 fundado por @CLSource. Participamos en proyectos de videojuegos, software y otras actividades relacionadas." — the former third-person copy opened with "Ninja Systems es un grupo".
- The section's remaining copy is pinned as it now renders: the values line ("Nos gusta crear artefactos hermosos y pensados en las personas. Valoramos lo humano en los proyectos tecnológicos.") and the closing "Ninjas.cl nació el 2015. Puedes encontrarnos en GitHub." paragraph, its GitHub label linking `https://github.com/ninjascl`.
- The home view test pins the new caption and opening, and asserts the former "Camilo Castro — Software Engineer" caption and "Ninja Systems es un grupo" opening are gone.
- No markup structure, stylesheet, asset, or dependency changes ride along — only `element.text` string literals in `about_section/0` and the test's string assertions. No blogatto or Lustre API drives the design.

The copy already shipped in `src/site.gleam`; the only remaining code work is the test update.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `site-about-section`: The "About text and caption are preserved in the right column" requirement's caption scenario is updated — the caption now identifies `@CLSource` as a Software Engineer, not Camilo Castro — and the section gains a requirement pinning its copy: the first-person group introduction crediting `@CLSource`, the values line, and the GitHub find-us link.

## Impact

- `src/site.gleam`: `about_section/0`'s `figcaption` label and `element.text` literals (already shipped; no further edit needed).
- `test/ninjas_test.gleam`: `home_view_renders_about_row_test` — its caption and section-text assertions move from the old strings to the new ones; this is the change's implementation work.
- `openspec/changes/trim-footer/`: corrected separately, outside this change's delta — its copyright-line quotes now match the code's "All rights and lefts preserved" wording.

## Out of scope

- The `site_description` constant — it already reads in Spanish and credits `@CLSource`, but no spec pins its text; recording it can ride a future copy/identity change.
- The hero's call-to-action links — `site-masthead`'s home-hero scenario still mentions links the hero no longer renders; that drift needs its own reconciliation change.
- The "🥷 Ninja Systems" showcase card title, the marquee copy, and the post page's footer line — all untouched by this rewrite.
