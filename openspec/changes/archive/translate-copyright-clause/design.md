# Design

## Context

The footer's clause is a `site_footer` parameter since the last change:
`copyright_rights_es` ("…reservados") feeds every Spanish page, and the
three translated homes pass the English constant `copyright_rights_en`
through their `HomeText.copyright_rights` field. The owner's review
found the English clause still on the Japanese and Portuguese homes and
preferred "preservados" in Spanish to mirror the English "preserved".

## Goals / Non-Goals

**Goals:**

- Every home's footer clause in that home's language; the Spanish
  clause reading "preservados" on every Spanish page.

**Non-Goals:**

- No changes to the "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix, the
  back-to-top labels, or any other chrome.

## Decisions

- **Spanish "preservados".** The English line's quirk is "preserved"
  where the legal standard reads "reserved" — the owner asked for the
  Spanish to mirror it, so the constant becomes "Todos los derechos e
  izquierdos preservados". *Alternative:* keeping the standard legal
  "reservados" — rejected by the owner's correction.
- **Japanese: "すべての権利と左派を保全".** A literal mirror of the joke —
  権利 (rights), 左派 (the left), 保全 (preserved) — following the
  site's machine-translation-quality convention for translated
  variants. Japanese has no native rights/lefts double meaning, so the
  translation preserves the shape of the pun for readers who know the
  English line, rather than localizing to the conventional
  "無断転載を禁じます", which would lose it.
- **Portuguese: "Todos os direitos e esquerdos preservados".** Mirrors
  the Spanish/English shape exactly — direitos/esquerdos and
  "preservados" for "preserved".
- **The clause values live where they're used.** The Spanish constant
  stays in `site.gleam` (post pages, the blog index, and 404 share it);
  the Japanese and Portuguese clauses are home-only strings, so they
  go inline in their `HomeText` records beside their other copy, and
  the English home keeps the shared English constant. No new shared
  constants for values only one page each renders.

## Risks / Trade-offs

- [The Japanese clause is a translated pun, not a native legal line] →
  The owner's mandate is translation, not localization; revising the
  wording later is a one-field edit.
- [The footer test now derives its expectation from `HomeText`] → Each
  home's assertion reads the record's own clause, so a future wording
  change updates with the record instead of a hardcoded string.

## Migration Plan

One constant's word, two record fields' values, and the test
assertions. No content, routing, or data changes.

## Open Questions

- None.
