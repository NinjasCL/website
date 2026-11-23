# Proposal

## Why

The cosmic theme overrides retrostrap's body font size to the 13px ladder
step (`--rs-font-size-body: var(--rs-font-size-2)`), so long-form,
code-heavy posts read small — and their code blocks render in
retrostrap's Courier stack, which does the migrated Onyx/Elixir code no
favors. JetBrains Mono, loaded per the owner's example from Google Fonts,
is built for exactly this content.

## What Changes

- The post body text (`.post-body`) renders at the ladder's size-3 step —
  **16px** at the default root size, one step up from the cosmic theme's
  13px body. The ladder variable keeps the size honoring the reader's own
  browser font preferences.
- Post code — both blocks and inline spans — uses the JetBrains Mono
  family: `'JetBrains Mono', var(--rs-font-mono)`, so retrostrap's mono
  stack remains the fallback when the font fails to load.
- Every generated page's head carries the owner's example trio before the
  stylesheets: the `preconnect` to `fonts.googleapis.com`, the
  `crossorigin` preconnect to `fonts.gstatic.com`, and the JetBrains Mono
  stylesheet (weights 400/500/600/700, `display=swap`, so text never
  blocks on the font).

Out of scope:

- No other page's text sizes — the 16px step applies to post bodies only;
  titles, meta, warnings, and the rest of the site keep their current
  sizes.
- No font self-hosting or subsetting — the Google Fonts CDN per the
  example; no new font files in `static/`.
- No changes to the code panel's Night Owl colors, padding, or borders.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post body typography" — the post body
  renders at the 16px ladder step, its code in JetBrains Mono, and every
  page head carries the font's Google Fonts links.

## Impact

- `src/site.gleam`: three link elements in the shared head of `page()`
  before the stylesheets.
- `static/style.css`: the `.post-body` size rule and the
  `.post-body pre, .post-body code` family rule.
- `test/ninjas_test.gleam`: head-suite assertions for the font links and
  stylesheet assertions for the size and family rules.
- No dependency or content changes.
