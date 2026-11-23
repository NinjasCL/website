# Tasks

## 1. Pointing hands replace the post arrows

- [x] 1.1 In `post_navigation` (`src/site.gleam`), swap both
  `/icons/win95/ArrowLeft_32x32_4.png` and
  `/icons/win95/ArrowRight_32x32_4.png` for
  `/icons/win95/Hand_32x32_4.png`, adding a `post-nav__hand--left` class
  to the "Anterior" image only. Verify with the updated
  `post_navigation_*` render test: both buttons carry the hand path, the
  left one carries the flip class, and neither carries an arrow path.
- [x] 1.2 Add `.post-nav__hand--left { transform: scaleX(-1); }` to
  `static/style.css` beside the existing `.post-nav .rs-btn img` sizing
  rule. Verify with a CSS assertion that the flip targets only the left
  class and that `image-rendering: pixelated` remains.
- [x] 1.3 Update the ⬅️/➡️ entries in
  `static/icons/win95/emoji-matches.json` to name `Hand_32x32_4.png` and
  describe the mirrored left direction. Verify with the manifest test.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and `gleam test`; confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `openspec validate post-nav-pointing-hands` and confirm all
  checks pass.
