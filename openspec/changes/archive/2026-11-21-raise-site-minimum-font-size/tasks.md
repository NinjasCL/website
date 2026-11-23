# Tasks

## 1. The sixteen-pixel floor

- [x] 1.1 Add the floor to `static/style.css`: override the cosmic theme's body shrink (`html[data-rs-theme="cosmic"] { --rs-font-size-body: var(--rs-font-size-3); }`), bump the rendered chrome to the size-3 step (`.rs-navbar a`, `.rs-note`, `.rs-figure__caption`, `.rs-top`, `.rs-list small`), and move the site's own `.post-languages` rule from size-2 to size-3; verify `gleam test` passes with a stylesheet-contract test asserting the base restore, every bump, and that nothing above the floor shrank (section titles still size-5, `.post-body` still size-3).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate raise-site-minimum-font-size` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the shipped stylesheet carries the floor rules — the body-base restore and every chrome bump — with no sub-16px font-size rule left for anything the site renders.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync raise-site-minimum-font-size`).
- Archive the change (`openspec archive raise-site-minimum-font-size`) and verify the archived result.
