# Tasks

## 1. Language-scoped Atom feeds

- [x] 1.1 Add a shared Atom feed builder in `src/ninjas/blog.gleam` that derives each feed's output path, absolute id, and `self` link from one path value, with the Spanish default at `/atom.xml` and translated feeds at `/en/atom.xml`, `/ja/atom.xml`, and `/pt/atom.xml`; verify the four configured feeds have distinct outputs by running `gleam test`.
- [x] 1.2 Give each feed a filter matching only its language variant — `option.None` for Spanish and `option.Some(code)` for the three translations — and keep the shared title, description, and author; verify filter assertions for all four feeds pass with `gleam test`.
- [x] 1.3 Register all four feeds with `config.atom_feed`; verify the production and dev config tests find each expected output and that `gleam format --check src test` passes.

## 2. Language-aware feed icon links

- [x] 2.1 Change `site.feed_link` to accept the page language code and resolve it to `/atom.xml` for Spanish and `/{code}/atom.xml` for translations, falling back to Spanish for unknown codes; verify rendered link assertions pass with `gleam test`.
- [x] 2.2 Pass the blog index text's code at its feed link call site and the home text's code at the posts section call site; verify the Spanish index still links `/atom.xml` and each translated index and home links its own feed with `gleam test`.
- [x] 2.3 Update the site-section-headers feed-link tests for the new behavior and verify `gleam format --check src test` passes.

## 3. Integration verification

- [x] 3.1 Run `gleam format src test` followed by `gleam format --check src test` and `gleam test`; verify both checks exit successfully.
- [x] 3.2 Build the production site and inspect `dist/atom.xml`, `dist/en/atom.xml`, `dist/ja/atom.xml`, and `dist/pt/atom.xml`; verify each file exists and contains only its own language's post entries.
- [x] 3.3 Run `openspec validate language-specific-atom-feeds`; verify the change validates without errors.

## Workflow follow-up

- Archive the change after review and verify the archived specs.
