# Proposal

## Why

The post page's "Anterior" / "Siguiente" buttons currently carry
`Hand_32x32_4.png`, whose finger points right, so only the left button needs
a horizontal mirror. The site owner wants `Msow10_32x32_4.png` instead: the
same Win95 hand pointing up, which has to be rotated a quarter turn in CSS
to point left for the newer post and right for the older one.

## What Changes

- Both post-navigation buttons load `/icons/win95/Msow10_32x32_4.png`.
- The "Anterior" hand rotates counter-clockwise (`rotate(-90deg)`); the
  "Siguiente" hand rotates clockwise (`rotate(90deg)`). The shared
  pixelated sizing and the buttons' labels, targets, and language resolution
  stay unchanged.
- The `emoji-matches.json` ⬅️/➡️ entries name the new icon and its rotations.
- Tests assert the new sprite, the two direction classes, and both CSS
  rotations.

Out of scope: the blog index's pagination controls, post titles/lists, the
language options row, new icon files, new dependencies, and the neighbors'
selection order or labels.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `blog-site-generation`: "Post pages navigate to adjacent entries" — the
  direction icons are the up-pointing hand rotated left/right in CSS.
- `site-inline-icons`: "The icon manifest documents the matches" — the ⬅️/➡️
  matches name `Msow10_32x32_4.png` and its rotations.

## Impact

- `src/site.gleam`: the two `post_navigation` `html.img` paths and the right
  button's direction class.
- `static/style.css`: the left rotation rule changes and a right rotation
  rule is added.
- `static/icons/win95/emoji-matches.json`: the two direction entries.
- `test/ninjas_test.gleam`: the post-navigation render assertions, the CSS
  assertions, and the manifest assertion.
- No routing, content, or dependency changes; blogatto and the Gleam/OTP
  versions stay pinned.
