# Tasks

The implementation shipped with the request; each task is verified against
the current tree.

## 1. Module separation

- [x] 1.1 Create `src/ninjas/home.gleam` owning the home page: `view`, the hero, the marquee, the about/posts/projects/books/games sections, the banner wall and its list, the showcase card type and renderer, the featured-posts list, and the home-only link/button helpers — rendering through the shared chrome in `site.gleam`.
- [x] 1.2 Trim `src/site.gleam` to the identity, shared chrome, and non-home views, making the home-shared helpers public: `page`, `masthead`, `site_footer`, `icon`, `title_with_icon`, `featured_image`, `default_language_posts`, `shuffle`, `post_item`, and the new `default_og_locale` accessor.
- [x] 1.3 Point the `/` route in `src/ninjas/blog.gleam` at `home.view` — Gleam forbids circular imports, so consumers import the home module directly.
- [x] 1.4 Update `AGENTS.md`'s project description and repository layout for the split.

## 2. Jasonelle restored

- [x] 2.1 Add the fifth "Proyectos" card after Elixir Chile per the old catalog's sort order, texts in Spanish, the title keeping its 🛸 emoji like the 🥷 Ninja Systems card, buttons linking jasonelle.com and github.com/jasonelle/.
- [x] 2.2 Download the official logo from `https://jasonelle.com/jasonelle.png` to `static/img/jasonelle.png`, downscaled for the web (8445×5717 → 800×541, 441 KB → 88 KB).
- [x] 2.3 Document the kept 🛸 in `static/icons/win95/emoji-matches.json`.

## 3. Tests and verification

- [x] 3.1 Home page tests call `home.view`; the two bindings named `home` rename to `home_html` so the module name stays reachable.
- [x] 3.2 Update the showcase counts: thirteen card rows and twenty-six enlarged icon buttons.
- [x] 3.3 Add the Jasonelle assertions (local image, alt, Spanish date, 🛸 kept emoji, manifest entry) and `home_covers_old_catalog_items_test` pinning every old-catalog URL.
- [x] 3.4 Run `gleam format --check src test` and `gleam test`; confirm both pass. (58 passed.)
- [x] 3.5 Run the production build and confirm the generated home page renders the Jasonelle card with the local `/img/jasonelle.png`. (Thirteen `showcase__cols` rows in `dist/index.html`.)
- [x] 3.6 Run `openspec validate separate-home-page` and confirm it passes.
