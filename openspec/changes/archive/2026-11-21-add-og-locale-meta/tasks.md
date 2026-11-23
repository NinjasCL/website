# Tasks

## 1. og:locale meta and tests

- [x] 1.1 Add the `og_locale` field to `SiteLanguage` (`es_CL`, `en_US`, `ja_JP`), add the `og_locale` parameter to `page()` passed from the language configuration at all three call sites (home and not-found from the default language, the post template from the variant's configuration), and render the `og:locale` meta in the head's Open Graph block after `og:image`; verify by extending the head-meta suite test — every page carries `content="es_CL" property="og:locale"` — and adding a per-variant test asserting `en_US` and `ja_JP` on the translated post pages.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-og-locale-meta` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the default, English, and Japanese post pages (plus the home and 404 pages) carry their own `og:locale` value in the generated markup.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-og-locale-meta`).
- Archive the change (`openspec archive add-og-locale-meta`) and verify the archived result.
