# Proposal

## Why

The post page's "Anterior" / "Siguiente" buttons currently lead/trail with
the Windows left/right arrows. The site owner wants the older Win95
pointing-hand glyph instead: a hand pointing left for the newer post and
one pointing right for the older post, matching the example at
`/blog/me-conviene-un-bootcamp/`. The pack already ships
`Hand_32x32_4.png` — a hand pointing right — so the left direction is the
same sprite mirrored horizontally, with no new image assets.

## What Changes

- The post page's "Anterior" button leads with the pointing hand mirrored
  to face left; the "Siguiente" button trails with the pointing hand
  facing right. Both keep the large retrostrap button styling, the
  neighbor's title and URL, and the language-resolved target.
- The `emoji-matches.json` entries for ⬅️/➡️ record the pointing hand as
  the post-navigation icon (mirrored for the left direction), replacing
  the stale arrow entries.
- A `.post-nav__hand--left` CSS rule flips the left button's hand with
  `scaleX(-1)`; the shared `.post-nav .rs-btn img` sizing stays as-is.

Out of scope: the blog index's pagination arrows (they are page controls,
not post neighbors), post titles/lists, the language options row, new icon
files, new dependencies, and the neighbors' selection order or labels.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `blog-site-generation`: "Post pages navigate to adjacent entries" — the
  two buttons carry pointing hands instead of direction arrows.
- `site-inline-icons`: "The icon manifest documents the matches" — the
  ⬅️/➡️ matches name the pointing hand and its mirrored use.

## Impact

- `src/site.gleam`: the two `post_navigation` `html.img` elements swap the
  arrow paths for `/icons/win95/Hand_32x32_4.png` and the left one gains a
  flip class.
- `static/style.css`: one `.post-nav__hand--left` rule.
- `static/icons/win95/emoji-matches.json`: the two direction entries.
- `test/ninjas_test.gleam`: an updated post-navigation render assertion
  and an added CSS-flip assertion; the manifest test gains the hand path.
- No routing, content, or dependency changes.
