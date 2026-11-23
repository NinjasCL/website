# Design

## Context

`src/site.gleam` already resolves every post page's language through the
`SiteLanguage` configuration (`language_config`), which carries the
per-language strings the page renders — the machine-translated warning
and the language options row's label. The staleness notice is the one
post-page message that ignores it: `staleness_message` hardcodes the
Spanish wording. See proposal.md — Why.

## Goals / Non-Goals

**Goals:**

- Word the staleness warning in the rendered variant's language, with
  the elapsed day count in the message.
- Keep the Spanish wording byte-for-byte as shipped today.

**Non-Goals:**

- No routing, content-file, or djot changes — the warning renders from
  the post template only.
- No changes to the 365-day threshold, the day-count arithmetic
  (`days_since`), or the warning's presentation (`warning_box`).

## Decisions

**Carry the wording as a `staleness_warning` field on `SiteLanguage`
with a `{days}` placeholder.** The record is already the per-language
string table, so a template there keeps every translated message in one
place. The day count is spliced with gleam_stdlib's
`string.replace(each: "{days}", with: int.to_string(days))`.

*Alternatives considered:* a prefix/suffix pair of fields (redundant
splitting of one message, awkward for Japanese where the count sits
mid-sentence); a `case` on the language code in `staleness_message`
(duplicates the language table a second time, and a missing translation
would silently fall back to Spanish again).

**No new dependency.** blogatto offers no per-language message
interpolation to reuse — its content translation works at the djot-file
level (`index-{lang}.djot`), not for view-level strings, which is why
the site's own `SiteLanguage` table exists.

**Wording.** Translations mirror the Spanish semantics — "more than
{days} days have passed since its publication", no trailing period, so
all four variants stay parallel with the shipped Spanish text.

## Risks / Trade-offs

- [A future language added without a translated template] → The field
  has no default: Gleam's record construction forces every
  `SiteLanguage` literal to fill it, and the test suite's
  every-language coverage exercises each variant's wording.
- [Placeholder typo in a template (`{days}` misspelled)] → The rendered
  warning would carry the literal placeholder; the per-language wording
  tests assert each language's full sentence around the day count.
