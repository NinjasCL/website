# Design

## Context

Posts are djot sources under `blog/` whose frontmatter blogatto parses into
`blogatto/post.Post`, exposing unknown keys through `extras:
Dict(String, String)` — the path `src/site.gleam`'s `post_tags` already uses
for `tags`. Four title sites today hardcode the newspaper icon
(`/icons/win95/Mailnews8_32x32_4.png`): `post_template`'s `h1` and
`blog_entry_card`'s title in `src/site.gleam`, and `featured_post`'s title
link in `src/ninjas/home.gleam`; the two star lists (home "Más entradas" and
post page "Otras entradas") render plain linked titles through the shared
`site.post_item`. The static icon packs live in `static/icons/win95/` and
`static/icons/macos9/`; `simplifile` (>= 2.7) is already a direct dependency
and is what the tests use for file reads.

## Goals / Non-Goals

Goals: a per-post title icon resolved from the static packs with a safe
fallback, rendered at every title site, carried by every language variant.

Non-Goals (see proposal): chrome icon mapping, embed cards, post navigation
buttons, feeds, new icon assets, `emoji-matches.json`.

## Decisions

### The frontmatter key rides `post.extras`

`icon: Bulb_32x32_4.png` needs no blogatto change: like `tags`, unknown
frontmatter keys land in `extras` as strings, read with
`dict.get(post.extras, "icon")`. Alternative rejected: a blogatto
feature would require a version bump outside the pinned range.

### Resolution checks the file system at render time

`post_icon_url(post)` trims the `icon` value, strips an optional
`/icons/` prefix, and resolves it against `static/icons/`:

1. As given — `static/icons/<value>` — covering qualified values like
   `win95/Star_32x32_4.png`.
2. As `static/icons/win95/<value>` — the pack the site chrome uses.
3. As `static/icons/macos9/<value>` — the second pack (bare numeric
   names like `1.png` live only there).

The first candidate that `simplifile.is_file` confirms becomes
`/icons/<relative path>`; none found falls back to
`/icons/win95/Mailnews8_32x32_4.png`. A value containing `..` falls back
immediately (no traversal outside the packs). Alternative rejected: an
Erlang-FFI `filelib:is_file` check — unnecessary since `simplifile` is
already a direct dependency; and a build-time icon allow-list passed
through the config is impossible without new blogatto API surface, since
templates only receive `(post, all_posts)`.

The existence check runs per rendered title. That is a few thousand `stat`
calls at build time — negligible for a static build — so no memoization.

### Templates affected

- `src/site.gleam`: `post_template`'s `h1`, `blog_entry_card`'s title, and
  `post_item`'s link switch to `title_with_icon(post_icon_url(post), …)`.
  `post_item` is the single renderer both star lists use, so both lists gain
  the icon together.
- `src/ninjas/home.gleam`: `featured_post`'s title link switches to
  `site.title_with_icon(site.post_icon_url(post), …)`.
- No routing, build-config, or content-file changes: existing posts simply
  gain an optional key.

### Variants repeat the icon

Each variant's own page, index card, and list entries render from that
variant's `Post` record, so the value must be present per variant — the
same convention already mandated for `slug`. A catalog test enforces it,
mirroring the slug check in `every_post_ships_all_languages_test`.

## Risks / Trade-offs

- [An author names an icon that is later removed from `static/icons/`] →
  the fallback renders the newspaper icon instead of a broken image; the
  next rebuild self-heals.
- [A variant drops the `icon` key in a machine-translation pass] → the
  variants-repeat test fails the build before shipping an inconsistent
  language page.
- [File-existence checks depend on the build's cwd] → every entry point
  (`gleam run`, `gleam run -m dev`, `gleam test`) runs from the project
  root, the same assumption the tests' `./blog` and `./static` reads
  already make.

## Migration Plan

Additive: posts without `icon` render exactly as before through the
fallback. No content backfill is required; authors adopt the key per post.
Rollback is reverting the four call sites.

## Open Questions

None.
