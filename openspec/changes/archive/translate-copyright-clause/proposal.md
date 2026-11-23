# Proposal

## Why

Reviewing the shipped footer translation, the site owner found two
gaps: the Japanese and Portuguese homes still carry the English clause
"All rights and lefts preserved" — left over from the language split's
scoping — and the Spanish clause reads "reservados" where the English
line says "preserved". The owner asked for the clause translated on
every home and for the Spanish to mirror the English's "preserved".

## What Changes

- The Spanish clause becomes "Todos los derechos e izquierdos
  **preservados**" — mirroring the English's "preserved" instead of the
  standard legal "reservados" — on every Spanish page (home, posts, blog
  index, 404).
- The Japanese home's footer carries its own clause, "すべての権利と左派を
  保全" — a literal mirror of the joke: 権利 (rights), 左派 (the left),
  保全 (preserved).
- The Portuguese home's footer carries "Todos os direitos e esquerdos
  preservados" — mirroring the Spanish/English shape.
- The English home keeps its own clause, "All rights and lefts
  preserved", and the "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix
  stays verbatim on every page.

Out of scope:

- No changes to the Copyright/© prefix, the back-to-top labels, the
  navbar, or any other chrome; no post-page, index, or 404 changes
  beyond the Spanish clause's word.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-footer`: the rights clause now renders in the page's language
  on every home — Spanish pages "Todos los derechos e izquierdos
  preservados", the English home "All rights and lefts preserved", the
  Japanese home "すべての権利と左派を保全", the Portuguese home "Todos os
  direitos e esquerdos preservados" — instead of English on the
  translated homes and "reservados" in Spanish.

## Impact

- `src/site.gleam`: the Spanish clause constant's word changes from
  "reservados" to "preservados" (the English constant stays).
- `src/ninjas/home.gleam`: `japanese_text` and `portuguese_text` carry
  their own clause instead of the English constant; `spanish_text` and
  `english_text` keep theirs.
- `test/ninjas_test.gleam`: the footer test asserts "preservados"; the
  translated-home test asserts each home's own clause through its
  `HomeText` record instead of the blanket English clause.
