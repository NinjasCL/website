# Design

## Context

The tagline lives in one place: `spanish_text.tagline` in
`src/ninjas/home.gleam`, rendered by the hero. The copyright line is
built inside `site.site_footer` in `src/site.gleam` — "Copyright 🥷🏽
Ninjas.cl © 2015–" plus the dynamic year plus the English clause — and
every page renders it: the four homes pass the back-to-top label
already, while the post template, blog index, and not-found page call
`site_footer` directly.

## Goals / Non-Goals

**Goals:**

- The Spanish home's tagline in Spanish; the copyright clause in Spanish
  on every Spanish page, English kept on the translated homes.

**Non-Goals:**

- No tagline changes on the English, Japanese, or Portuguese homes.
- No changes to the navbar, back-to-top labels, or any other chrome.

## Decisions

- **The tagline is a one-constant edit.** `spanish_text.tagline`
  becomes "Software de 🇨🇱 con ❤️"; the English record keeps "Software
  from 🇨🇱 with ❤️" as its own language's tagline, and the Japanese and
  Portuguese records their already-translated ones.
- **The copyright clause becomes a footer parameter.** `site_footer`
  gains the clause beside the back-to-top label it already takes, with
  two constants in `site.gleam`: the Spanish "Todos los derechos e
  izquierdos reservados" — carrying the rights/lefts wordplay as
  derechos/izquierdos, with "Copyright" kept beside the universal © per
  the owner's wording pick — and the English "All rights and lefts
  preserved". The internal callers (post template, blog index,
  not-found) pass the Spanish clause: the owner chose site-wide Spanish
  consistency over a home-only edit. *Alternative:* translating only the
  home's footer — rejected: the Spanish post pages would then show the
  English line beside the home's Spanish one.
- **Each `HomeText` carries its copyright clause.** A new
  `copyright_rights` field — Spanish for the default home, English for
  the three translated homes, which the owner left on the English line —
  keeps `view` passing one text record into the footer, the same
  threading the back-to-top label uses.
- **The kept-emoji contract is untouched.** The new tagline and clause
  keep their 🇨🇱, ❤️, and 🥷🏽 emojis, so only the quoted strings in the
  specs' scenarios change, not the emoji-keeping behavior.

## Risks / Trade-offs

- [The translated homes keep an English copyright while their other
  chrome is translated] → The owner's explicit scoping from the language
  split, unchanged here; revising it later is a one-field edit per
  record.
- [Two clause constants where one hardcoded string used to be] → One
  extra parameter on `site_footer`, threaded exactly like the
  back-to-top label the footer already takes.

## Migration Plan

Two string constants, one `HomeText` field, one footer parameter, and
the test assertions that pin the strings. No content, routing, or data
changes; rolling back is reverting the two source files.

## Open Questions

- None.
