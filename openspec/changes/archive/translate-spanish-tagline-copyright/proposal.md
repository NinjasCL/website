# Proposal

## Why

Revising the language split, the site owner found the Spanish home still
carrying two English strings: the hero's tagline "Software from 🇨🇱 with
❤️" and the footer's rights clause "All rights and lefts preserved". The
Spanish site is the human-written default, so its own brand lines should
read in Spanish — with the tagline translated on the default home and the
copyright clause translated across the Spanish site's pages, keeping the
English line on the translated homes.

## What Changes

- The Spanish home's hero tagline becomes "Software de 🇨🇱 con ❤️" —
  the English tagline remains only on the English home (its own
  language) and the already-translated Japanese and Portuguese taglines
  are untouched.
- The footer's copyright line carries its rights clause in the page's
  language: "Todos los derechos e izquierdos reservados" on the site's
  Spanish pages — the default home, single post pages, the blog index,
  and the not-found page — and the English "All rights and lefts
  preserved" on the translated homes. The "Copyright 🥷🏽 Ninjas.cl ©
  2015–{year} ·" prefix stays verbatim on every page (the owner's
  wording pick: "Copyright" kept beside the universal ©, the
  rights/lefts wordplay carried as derechos/izquierdos).

Out of scope:

- No tagline changes beyond the Spanish home — the English, Japanese,
  and Portuguese taglines stay as shipped.
- No back-to-top, navbar, or other chrome changes; the translated homes
  keep today's English copyright line; and no stylesheet, content, or
  dependency changes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-masthead`: the default home's hero tagline changes from the
  English "Software from 🇨🇱 with ❤️" to the Spanish "Software de 🇨🇱
  con ❤️".
- `site-footer`: the copyright line's rights clause becomes per-language
  copy — Spanish on the Spanish pages, English on the translated homes —
  instead of one verbatim English line everywhere.
- `site-inline-icons`: the kept-emojis scenario's quoted tagline follows
  the Spanish home's new text (the 🇨🇱 and ❤️ emojis it checks stay).

## Impact

- `src/site.gleam`: `site_footer` gains the rights clause as a parameter
  beside the back-to-top label, with the Spanish and English clause
  constants; the internal callers (post template, blog index, not-found)
  pass the Spanish clause.
- `src/ninjas/home.gleam`: `spanish_text.tagline` becomes "Software de
  🇨🇱 con ❤️"; each `HomeText` record carries its copyright clause —
  Spanish for the default home, English for the translated homes.
- `test/ninjas_test.gleam`: the footer and kept-emoji tests assert the
  Spanish clause and tagline on the Spanish pages, while the
  translated-home tests keep passing on the English clause.
