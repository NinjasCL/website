# Proposal

## Why

Every post title on the site leads with the same hardcoded newspaper icon
(`/icons/win95/Mailnews8_32x32_4.png`) — on the post page, the blog index
cards, the home featured row, and the posts lists. The site owner wants each
post to declare its own icon from the site's static packs (`static/icons/`),
the retro equivalent of a per-post emoji, so a post about a tool can carry
that tool's icon next to its title.

## What Changes

- A new djot frontmatter key `icon` in posts. It rides blogatto's
  `post.extras` (`Dict(String, String)`), the same path the `tags` field
  uses today, so no blogatto change is involved.
- The value names an icon file from `static/icons/`: a bare filename
  (e.g. `icon: Bulb_32x32_4.png`) resolves by searching the win95 pack first
  and then macos9; a subdirectory-qualified (`win95/Star_32x32_4.png`) or
  `/icons/`-prefixed value resolves directly.
- Fallback: when the key is absent, empty, or names a file that does not
  exist under `static/icons`, the title icon falls back to
  `/icons/win95/Mailnews8_32x32_4.png` — so a typo can never render a broken
  image; the title keeps today's newspaper icon.
- The resolved icon renders beside the post's title everywhere the title
  already leads with an icon, plus the two star lists that today render plain
  titles: the post page's `h1`, the blog index entry cards, the home
  featured post row, the home "Más entradas" list, and the post page's
  "Otras entradas" random list (the last two share the `post_item` renderer).
- Translated variants repeat the default variant's `icon`, the same
  convention as `slug`, so every language page of a post shows it. A test
  enforces the repetition like the slug check does.

Out of scope: the navbar/section icon mapping (fixed by the chrome), the
` ```ninjas `/` ```github ` embed cards (they carry their own image argument),
the Anterior/Siguiente navigation buttons, the Atom/RSS feeds, new icon
assets, and `emoji-matches.json`.

## Capabilities

### New Capabilities
- `site-post-icons`: the per-post title icon — the `icon` frontmatter key,
  its resolution against the static icon packs, the newspaper fallback, and
  the title sites that render it.

### Modified Capabilities
- `site-inline-icons`: "The blog post title and date lead with icons" — the
  title now leads with the post's own icon with the newspaper icon as
  fallback (was: always the newspaper icon); the date keeps the calendar icon.
- `site-blog-index`: "Index entries are post cards with the header image" —
  entry card titles lead with the post's own icon (was: the hardcoded
  mail-news icon); dates keep the calendar icon.
- `site-featured-post`: "The rest of the posts section keeps its
  presentation" — the more-posts star list entries lead their linked titles
  with the post's icon (was: plain linked titles).

## Impact

- `src/site.gleam`: a new `post_icon_url(post)` helper — the `post.extras`
  lookup, the `static/icons` file-existence resolution via
  `simplifile.is_file` (already a direct dependency), and the fallback — used
  by `post_template`'s `h1`, `blog_entry_card`'s title, and `post_item`.
- `src/ninjas/home.gleam`: `featured_post`'s title link switches to the helper.
- `test/ninjas_test.gleam`: resolution and fallback tests with `post.Post`
  fixtures, plus the variants-repeat-icon check in the catalog test.
- No new dependencies, no routing or build-config changes.
