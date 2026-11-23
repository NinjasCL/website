# Tasks

## 1. Index text records and language view

- [x] 1.1 Add a `BlogIndexText` record and four language consts (`spanish_index_text` carrying today's Spanish strings verbatim, plus English, Japanese, and Portuguese translations) to `src/site.gleam`; verify `gleam build` compiles.
- [x] 1.2 Rework `blog_index_page` to render from the record — per-language post filtering (`None` for es, `Some(code)` for a language), the `{page}` title template, per-language index paths, translated intro and pagination labels — and add the public `language_blog_index_view(code, n)` with a Spanish fallback for unknown codes; verify the default index output is unchanged by the existing `blog_index_*` tests.
- [x] 1.3 Add the index pages' language options row (current language plain with the current-page marker, others linking their same-numbered index page) to `blog_index_page`, reusing the `post-languages` presentation; verify with `gleam test`.

## 2. Language-aware card translation links

- [x] 2.1 Change `blog_entry_languages` to link every sibling variant in every other language (the entry's own language excluded — the card links it), so a translated index card links the Spanish original plus the other translations; verify the existing card assertions and `gleam test` still pass.

## 3. Route registration

- [x] 3.1 Register `/blog/{lang}/page/{n}` for en, ja, pt in `blog_pages.register`, alongside the default pages, using the same directory-derived page count; verify `gleam test` passes and no new dependency enters `gleam.toml`/`manifest.toml`.

## 4. Regression tests

- [x] 4.1 Add a test asserting the English index lists only English variants (newest first, 25 per page) and no default or other-language entries, using the existing `index_test_variant` fixture; verify with `gleam test`.
- [x] 4.2 Add a test asserting the Japanese page declares its language and speaks it — `lang` attribute, Japanese title/intro, Japanese pagination buttons — and that the Spanish page keeps its exact Spanish presentation; verify with `gleam test`.
- [x] 4.3 Add a test asserting the options row on the default index links the three language indexes with Español current, and on a language index links back to the default's same-numbered page with its own language current; verify with `gleam test`.
- [x] 4.4 Add a test asserting a translated index card's language row links the Spanish original and the other translations but not the entry's own language; verify with `gleam test`.

## 5. Verification

- [x] 5.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 5.2 Run `gleam test` and confirm the whole suite passes.
- [x] 5.3 Run `openspec validate blog-index-language-variants` and confirm it passes.

## Workflow follow-up

- Verified by an end-to-end `gleam run` build: `dist/blog/{en,ja,pt}/page/{1..5}/` exist, `lang="ja"` on the Japanese page, and the sitemap carries every language index route while the `/blog/` redirect stays excluded. The dev server stays out of committed changes.
- Sync the delta spec into the main specs, then archive the change once review requirements are satisfied.
