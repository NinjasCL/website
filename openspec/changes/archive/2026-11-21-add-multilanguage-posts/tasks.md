# Tasks

## 1. Language configuration and post template

- [x] 1.1 Add the `SiteLanguage` configuration to `src/site.gleam` (Spanish default mapping from `language: None`, English and Japanese machine-translated with their per-language warning texts), the `site_language` lookup with unknown-code fallback, and the `language` parameter on `page()` — home and not-found pass `es-CL`, the post template passes the variant's code; verify `gleam test` passes with the page-language assertions (default `es-CL`, English `en`, Japanese `ja`).
- [x] 1.2 Add the `language_options` row built from the sibling variants in `all_posts` (same slug, declared language order, current language marked `aria-current`, others linked to their URLs, row only when more than one variant), filter `posts_section` to default-language posts, and add the `.post-languages` style; verify with template tests covering the three-variant row, the single-variant absence, and the home page listing no translated duplicates.
- [x] 1.3 Add the `warning_box` helper, the machine-translated warning for non-default variants, and the staleness warning when the post's date is older than 365 days (elapsed days via `timestamp.difference` + `duration.to_seconds`, text "Este contenido puede estar desactualizado ya que han pasado más de {days} días desde su publicación"), plus the `.post-warning` style and the `Warning_32x32_4.png` manifest entry; verify with template tests for the English and Japanese warnings, the default's absence, and stale vs. fresh posts.

## 2. Content variants

- [x] 2.1 Ship `blog/bienvenidos-a-ninjas-cl/index-en.djot` and `index-ja.djot` — same slug, date, and featured image as the original, translated title, description, and body in djot (single-asterisk strong); verify `gleam test` passes with the blog-sources assertions extended to the variants and the built pages carrying the options row.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm it completes.
- [x] 3.2 Run `gleam test` and confirm every test passes.
- [x] 3.3 Run `gleam format --check src test` and confirm it passes.
- [x] 3.4 Run `openspec validate add-multilanguage-posts` and confirm it passes.
- [x] 3.5 Regenerate the site (`task build`) and confirm the default, English (`/blog/en/…`), and Japanese (`/blog/ja/…`) post pages render with the options row, the translated pages carry their machine-translated warning and `lang` attribute, and no staleness warning renders on the fresh shipped post.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-multilanguage-posts`).
- Archive the change (`openspec archive add-multilanguage-posts`) and verify the archived result.
- Update AGENTS.md to the latest repository state per the user's request.
