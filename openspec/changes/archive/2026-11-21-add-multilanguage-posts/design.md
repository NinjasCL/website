# Design

## Context

See proposal.md — Why. blogatto already treats `index-{lang}.djot` as an
independent post: `internal/path.gleam` derives `language` from the
filename (`index-en.djot` → `Some("en")`), and the default prefix routing
gives variants their own URLs (`/blog/{lang}/{slug}/`, the default at
`/blog/{slug}/`). The post template receives every post — all variants,
newest first — and `Post.language` distinguishes the default
(`option.None`) from translated variants. `gleam_time` is already a direct
dependency for `format_date`, so `timestamp.difference` and
`duration.to_seconds` are available without new packages.

## Goals / Non-Goals

**Goals:**

- One declared language configuration driving the options row, the
  translation warnings, and the page language.
- Warnings that need no per-post authoring: they derive from the variant
  and the post's date at render time.
- The shipped post demonstrating all three languages.

**Non-Goals:**

- Feed filtering, `og:locale`, translating the site chrome or the
  staleness text (proposal.md — out of scope); no new frontmatter fields.

## Decisions

1. **A Gleam configuration list is the language source of truth.**
   `const site_languages: List(SiteLanguage)` with one record per language —
   code, display name, `machine_translated` flag, and the
   machine-translated warning text (empty for Spanish). The default
   language maps from blogatto's `language: option.None`:
   `site_language(option.None)` returns the Spanish entry;
   `site_language(option.Some("en"))` the English one, with an unknown
   code falling back to the default entry so a stray variant can never
   crash the build.

2. **The options row is built from the sibling variants, not from URL
   conventions.** The template already receives every post, so
   `language_options(post, all_posts)` filters `all_posts` by the post's
   slug, orders the matches by the declared language order, marks the
   current language with `aria-current` and plain text, and links the
   others to their `post.url`. Computed URLs would work too, but reading
   the sibling `Post.url` can never drift from what blogatto actually
   routed. The row renders only when the post has more than one variant —
   a lone variant has nothing to switch to.

3. **Warnings are small amber panels derived at render time.** Both
   warnings reuse the shared `warning_box` helper — a `p.post-warning`
   led by the pack's `Warning_32x32_4.png` inline icon (added to the
   emoji-matches manifest). The machine-translated warning renders from
   the language configuration whenever `machine_translated` is true. The
   staleness warning renders when
   `days_since(post.date) > 365`: days elapsed are
   `timestamp.difference(post.date, system_time())` →
   `duration.to_seconds` → truncated days. The post's `date` frontmatter
   is the last-update date blogatto carries; authors bump it when they
   revise a post, and the pinned wording ("… desde su publicación")
   already reads it that way. The warning order is translation first,
   staleness second.

4. **The page gains a `language` parameter.** `page()` takes the html
   `lang` value: home and not-found pass the site's `es-CL`; the post
   template passes `es-CL` for the default variant and the variant's own
   code otherwise. Translated pages thereby declare their language to
   browsers and crawlers without touching the head suite's other fields.

5. **The home page filters to default-language posts.** blogatto hands
   every variant to the home route; `posts_section` filters
   `language == option.None` before listing, so translated variants are
   reachable through their own URLs, the sitemap, and each post's options
   row — not by duplicating the home list.

6. **The shipped post's variants keep the grouping invariants.** Both new
   files repeat the original's `slug` and `date` (the slug is what groups
   variants; an auto-generated slug from a translated title would break
   the options row) and translate title, description, and body with djot
   single-asterisk strong, matching the adopt-djot content convention.

7. **No new dependency and no blogatto change.** The filename convention,
   routing, and template data are all stock blogatto; `gleam_time` is
   already direct.

## Risks / Trade-offs

- [A translated variant drifts from its original] → The staleness warning
  is per-variant and derived from the same bumped `date`, so a stale
  translation warns like its original.
- [Feeds list translated variants] → Accepted for now (out of scope);
  recorded as a follow-up against `blog-site-generation`.
- [A variant ships with a slug that differs from its original] → The
  options row simply won't group them; the content convention in decision
  6 and the shipped example pin the pattern.
- [Days count shifts between build and render] → It is computed once at
  render time; a rebuild refreshes it, same as the footer's current year.

## Migration Plan

None. Variants are additive content files; the default pages' URLs and
markup are unchanged except for the added options row. Rollback is
reverting the commit and rebuilding.
