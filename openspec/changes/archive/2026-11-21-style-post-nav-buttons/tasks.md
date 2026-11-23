# Tasks

## 1. Button-styled navigation

- [x] 1.1 Rework `post_navigation`'s anchors in `src/site.gleam` into the site's large retrostrap icon buttons — `rs-btn rs-btn--icon rs-btn--large`, same-tab links (no `target`/`rel`), with `ArrowLeft_32x32_4.png` leading the "Anterior: {title}" label and `ArrowRight_32x32_4.png` trailing the "Siguiente: {title}" label, dropping the unicode arrows — and add the two icons to `static/icons/win95/emoji-matches.json`; verify `gleam test` passes with the navigation tests updated to assert the button classes, the icon sources, and the arrow-less labels, and the manifest test extended with the arrow icons.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate style-post-nav-buttons` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the post pages' navigation renders as the two retrostrap icon buttons — with the arrow icons beside the labels, the showcase buttons' classes, and the same-language targets as before.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync style-post-nav-buttons`).
- Archive the change (`openspec archive style-post-nav-buttons`) and verify the archived result.
