# Design

## Context

See proposal.md — Why. `site_footer()` in `src/site.gleam` renders the
`rs-footer` block (copyright line + `rs-top` back-to-top link) for the home
and not-found pages, while `post_template` renders its own minimal
`html.footer` with the "Ninjas.cl — Desde 2015" line. The copyright line
hardcodes "2015–2026". `format_date` in the same module already reads the
system clock through `gleam/time/timestamp` + `gleam/time/calendar`.

## Goals / Non-Goals

**Goals:**

- One footer function rendered by every template, like the shared navbar.
- A copyright line that never goes stale: its end year is computed at
  build time.

**Non-Goals:**

- No footer layout/CSS work (proposal.md — out of scope); no client-side
  JavaScript, no `datePublished` change.

## Decisions

1. **Unify on `site_footer()`.** `post_template` replaces its minimal
   footer element with the existing `site_footer()` call the home and
   not-found pages already use. One function keeps the three templates'
   footers from drifting, the same property the shared `site_nav` and
   `masthead()` give the header.

   *Alternative considered:* copying the two elements into the post
   template — rejected: drift.

2. **The end year is the build's current year, read from the system
   clock.** A private `current_year()` helper mirrors `format_date`'s
   existing pattern — `timestamp.system_time()` →
   `timestamp.to_calendar(_, calendar.utc_offset)` → the calendar year —
   and `site_footer` splices it between the static parts:
   `"Copyright 🥷🏽 Ninjas.cl © 2015–" <> current_year() <> " · All rights
   and lefts preserved"`. The site is regenerated on every build (Taskfile
   `build`, CI, dev rebuilds), so each regeneration stamps the year it was
   built in — a static site's no-JavaScript equivalent of "always the
   current year".

   *Alternative considered:* JavaScript `new Date().getFullYear()` —
   rejected: the site keeps its content readable without JavaScript
   (background.js is progressive enhancement only), and a build-time stamp
   needs no script. A hand-edited constant — rejected: that is exactly the
   staleness being fixed.

3. **Tests compute the expected year through the same `gleam/time` API.**
   The footer assertions build their expected line with
   `timestamp.system_time() |> timestamp.to_calendar(utc_offset)` in the
   test, then assert the rendered markup contains the full line — the
   rendered and expected years agree except across a New Year rollover in
   the microseconds between the two clock reads, a negligible flake window
   a rerun clears.

   *Alternative considered:* asserting only the static prefix/suffix around
   a year-shaped pattern — rejected: string matching on digits is weaker
   than checking the actual current year.

4. **No new dependency.** `gleam/time/timestamp` and
   `gleam/time/calendar` are already imported by `src/site.gleam`; no
   blogatto feature is missing — this is view-layer only.

## Risks / Trade-offs

- [A year pinned in committed artifacts goes stale] → Only the rendered
  site carries the dynamic year; specs describe it as "the current year",
  never a literal.
- [Footer appears twice if a template later wraps `site_footer()` in
  another footer] → The three templates each call it exactly once, as the
  navbar/masthead pair already does.
- [New Year rollover flake in tests] → Microsecond window, rerun clears it;
  recorded in decision 3.

## Migration Plan

None. The site is regenerated from source; rollback is reverting the
commit and rebuilding.
