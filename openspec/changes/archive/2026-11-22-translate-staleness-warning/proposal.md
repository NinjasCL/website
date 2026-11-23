# Proposal

## Why

The staleness warning is pinned to the Spanish wording on every language
variant, so the English, Japanese, and Portuguese pages of a stale post
warn their readers in a language they may not read — "Este contenido
puede estar desactualizado ya que han pasado más de 963 días desde su
publicación" renders verbatim on the translated pages too.

## What Changes

- The site's language configuration (`SiteLanguage` in `src/site.gleam`)
  gains a per-language staleness template carrying a `{days}`
  placeholder; the Spanish wording stays exactly as it is today.
- The post page's staleness notice (`post_warnings`) is worded in the
  rendered variant's language, splicing the elapsed day count in place
  of `{days}` via gleam_stdlib's `string.replace`:
  - **en**: "This content may be outdated, as more than {days} days have
    passed since its publication"
  - **ja**: "このコンテンツは公開から{days}日以上が経過しているため、最新ではない可能性があります"
  - **pt**: "Este conteúdo pode estar desatualizado, já que mais de
    {days} dias se passaram desde sua publicação"
- Tests cover each translated variant's own wording and that no Spanish
  wording leaks into the translated pages.

Out of scope:

- No changes to the 365-day staleness threshold, the elapsed-day count,
  or the warning's presentation — `stale_days`, `days_since`, and
  `warning_box` are untouched.
- No changes to the machine-translated warning, which already follows
  the variant's language.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-post-languages`: the "Staleness warning on old posts"
  requirement drops its pinned Spanish wording — every language variant
  now renders the warning in its own language from the site's language
  configuration, keeping the elapsed day count in the message.

## Impact

- `src/site.gleam`: the `SiteLanguage` record gains one field
  (`staleness_warning`), and `post_warnings`/`staleness_message` render
  the rendered variant's template. No new dependencies — the day count
  is spliced with gleam_stdlib's `string.replace`.
- `test/ninjas_test.gleam`: a new test for the per-language wording
  beside the existing staleness test; the staleness date fixture learns
  the variant's language.
