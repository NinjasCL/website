# Tasks

## 1. Button markup

- [x] 1.1 Update `external_button` in `src/site.gleam` to take an icon path and render `a.rs-btn.rs-btn--icon` (dropping `rs-btn--small`) with an icon `img` (empty alt) before the label, and pass `/icons/Quikview1_32x32_4.png` at the "Ver / View" call site and `/icons/Wscript100_32x32_4.png` at the "Código / Code" call site; verify with the tests added in 1.2.
- [x] 1.2 Add a home view test asserting twenty-four `rs-btn--icon` buttons, no `rs-btn--small` left in the markup, and each icon's `src` preceding its label; verify with `gleam test`.

## 2. Button sizing CSS

- [x] 2.1 Add the scoped rules to `static/style.css`: `.showcase__cols .rs-btn` with `font-size: var(--rs-font-size-5)` and large padding, and `.showcase__cols .rs-btn img` with the ~1.25em pixelated icon box, with an explanatory comment; verify with the tests added in 2.2.
- [x] 2.2 Add a test asserting `static/style.css` carries both scoped rules (the size-5 override and the icon box); verify with `gleam test`.

## 3. Checks

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate enlarge-showcase-buttons` and confirm it passes.

## Revision (2026-11-20)

- Per the site owner: the Ver/View and Código/Code buttons were too big at the size-5 step. They now render one ladder step down through retrostrap's own `rs-btn--large` variant (1.125rem ≈ 1.8×), and the custom size/padding override is deleted — the native `:active` press returns. The spec, proposal, and design were revised to make the large-variant size the contract.

## 4. One step down

- [x] 4.1 Switch `external_button`'s class to `rs-btn rs-btn--icon rs-btn--large`, delete the scoped `.showcase__cols .rs-btn` size/padding rule from `static/style.css` (keeping the icon-box rule and fixing its comment), and update the button tests (the markup carries `rs-btn--large`; the scoped size rule is gone); verify with `gleam test`.

## 5. Checks (revision)

- [x] 5.1 Run `gleam format src test` and confirm `gleam format --check src test` passes.
- [x] 5.2 Run `gleam test` and confirm the whole suite passes.
- [x] 5.3 Run `openspec validate enlarge-showcase-buttons` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`): the Ver/View and Código/Code buttons show large labels with the Quick View and script icons; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive enlarge-showcase-buttons`.
