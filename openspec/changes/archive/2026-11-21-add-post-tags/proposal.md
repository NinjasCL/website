# Proposal

## Why

The migrated posts carry their tags in the frontmatter (`tags: python,
web, script, mac, linux, windows`), blogatto stores them in `extras`,
and the old site rendered them as purple rounded pills after a 🏷️
emoji — right below the post's date. The new engine drops them
entirely: no tag renders on any post page.

## What Changes

- Every post page renders its tags as a row of small rounded labels
  below the date, led by the Win95 Bookmark icon (the site's emoji
  replacement for the old 🏷️), matching the old site's placement and
  pill treatment.
- The tags split from the `extras` `tags` field — a comma-separated
  string — trim each entry, and skip empties. Posts without tags
  render no row.
- The `.post-tags` and `.post-tag` styles live in `static/style.css`:
  the site's violet pill treatment from the old site's
  `.tag.tag-purple.tag-rounded` recipe, sized to the 16px floor.

Out of scope:

- No tag pages or tag-based filtering — the labels are visual only.
- No per-tag linking (the old site didn't link them either).

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post pages render their tags" — the
  tags row below the date, each tag a rounded label.

## Impact

- `src/site.gleam`: `post_tags(post)` in the post template, between
  the date and the description.
- `static/style.css`: `.post-tags` and `.post-tag` rules.
- `static/icons/win95/emoji-matches.json`: the Bookmark icon entry.
- `test/ninjas_test.gleam`: tag rendering assertions in the post
  template test.
