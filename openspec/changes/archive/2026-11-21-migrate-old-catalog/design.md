# Design

## Context

See proposal.md — Why. The mechanisms are all in place and specced:
djot conversion (the first migration's recipe), the four-variant
mandate with its mechanical test, post-adjacent file copying by base
name, the English-origin rule, the `{summary}` toggles, smalto
highlighting, the navigation buttons, and the random-entries list. The
102 remaining sources are plain markdown with JSON frontmatter, cover
images under `assets/`, and ~104 custom Liquid tags. Two asset edge
cases exist: `moodbit-…` carries a 14 MB `moodbit.mp4` (it ships, per
the owner's "must be copied too"), and `odin-for-alchemists` has
nested directories under `assets/` (blogatto flattens by base name) —
deferred to a late batch with a conscious flattening.

## Goals / Non-Goals

**Goals:**

- The whole catalog migrated with every convention intact, in
  verifiable batches that never leave the suite red.

**Non-Goals:**

- No new behavior (proposal.md — out of scope).

## Decisions

1. **The per-post recipe, fixed across batches.** (a) Read the source;
   detect its origin language from the title/description/body —
   Spanish-origin posts keep their text as the Spanish default;
   English-origin posts follow the owner's rule (Spanish translation
   as default, original English as the `en` variant). (b) Convert
   markdown→djot: links and fences map directly; the JSON frontmatter
   maps to blogatto's with the original `published_at` preserved
   (UTC `Z` becomes `+00:00`) **and the `tags` array carried as the
   comma-separated `tags:` field, identical across all four variants
   (tags are metadata, not prose — they never translate)**; the cover
   becomes a proper alt plus the visible attribution line; `<details>` toggles become
   `{summary="…"}` fences if any appear. (c) Translate the other three
   variants from the canonical Spanish. (d) Copy the adjacent files
   flat. (e) All four sources share the slug, date, and
   `featured_image`.

2. **Liquid tags render as the site's embed components.** `{% github
   owner/name %}` (68 uses) → a ```` ```github ```` fence with
   `owner/name | description` (link, title, site name, and the
   `opengraph.githubassets.com/1/owner/name` social card image all
   derive from the repo); `{% ninjas X %}` → a ```` ```ninjas ```` fence
   with `slug | Post title | description | image` (the post's cover);
   `{% youtube … %}` (23 uses) → a ```` ```youtube ```` fence with the
   URL or video id (rendered full width); `{% codeberg %}`, `{% devto
   %}`, and `{% embed URL %}` → an ```` ```embed ```` fence with
   `url | title | description | image` (the site name derives from the
   URL's host). Each fence renders its full OpenGraph card — image,
   title, text — through the content-block component
   (`src/ninjas/highlight.gleam`). Malformed tag spellings are matched
   tolerantly. **Markdown
   pipe tables → raw HTML `<table>` fences** (discovered in tranche
   6): jot has no table container, so pipe tables render as
   paragraphs and smart punctuation mangles their delimiter dashes —
   a self-contained `<table>` in one ` ``` =html ` fence renders them
   correctly.

3. **Shortest-first batching, all four variants per batch.** The
   completeness test fails any directory missing a variant, so a
   batch is only done when its posts ship complete — no es-only
   intermediate states. Batch sizes flex with post length: the ten
   shortest posts (~270 lines total) fit one session; the 1,000-line
   `un-vistazo-al-…` post gets a batch of its own if needed.

4. **Assets ship as-is, flat.** Everything in the post directory
   copies by base name — covers (`.jpg`/`.webp`/`.png`), data files,
   code, and the 14 MB video. The nested-directory post flattens
   consciously in its own late batch (the structure loss is recorded
   there, not silently).

5. **No new dependencies, no new tests.** The suite enforces the
   floor; `task build` verifies the rendered pages per batch.

## Risks / Trade-offs

- [Batch fatigue across ~10+ sessions] → Each batch is a checkpoint:
  suite green, build verified, tasks checked — progress survives
  interruptions and reviews happen per batch.
- [Translation volume: ~12.6K lines × 4 variants] → Machine
  translations are the declared model (the warnings say so on every
  non-Spanish page); the canonical Spanish text is the source of
  truth each batch translates from.
- [Old embeds degrade to links] → The oEmbed machinery does not exist
  in the new engine; a link preserves the reference. Videos keep
  their embeds.
- [Ties in date ordering] → blogatto's stable sort decides, and the
  home list, navigation, and random pool all read the same order.

## Migration Plan

The batches themselves — see tasks.md. Rollback of any batch is
removing its directories; the suite stays green at every checkpoint.
