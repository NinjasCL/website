# Proposal

## Why

Each post page is a dead end: readers finishing a post must return to
the home page to find another. Posts are already ordered newest-first
(the home list, blogatto's sort), so the adjacent entries in that
sequence are a natural continuation for whoever just finished reading.

## What Changes

- Every post page renders navigation to its adjacent entries in the
  newest-first post list: **"Anterior"** links the previous entry (the
  newer post), **"Siguiente"** links the next entry (the older post) —
  the direction the home list itself reads, newest first.
- Each link targets the reader's current language: the neighbor is
  resolved to the page's own language variant (the completeness mandate
  ships every variant; the neighbor's default entry is the defensive
  fallback).
- The end posts show their single neighbor — the newest post has only
  "Siguiente", the oldest only "Anterior" — and a lone post renders no
  navigation at all.
- The links render in a `post-nav` row after the article, styled with
  one small flex rule; the labels stay Spanish like the rest of the
  site chrome.

Out of scope:

- No per-language navigation labels (the site chrome — navbar, footer,
  staleness warning — stays Spanish; a follow-up could localize like the
  options row).
- No pagination, no related-posts, no title-only variant of the links.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post pages navigate to adjacent
  entries" — every post page links its neighbors in the newest-first
  list, resolved to the reader's language.

## Impact

- `src/site.gleam`: `post_navigation` (neighbors in the
  default-language list, resolved per language) rendered in
  `post_template` after the article.
- `static/style.css`: the `.post-nav` row rule.
- `test/ninjas_test.gleam`: fixture tests for middle/end/lone posts and
  the language resolution, plus the stylesheet contract.
- No dependency, routing, or content changes.
