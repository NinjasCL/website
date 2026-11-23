# Tasks

## 1. Split the masthead into a shared navbar and page heroes

- [x] 1.1 Extract `site_nav(on_home: Bool)`, `home_hero()`, and `marquee()` from `masthead()` in `src/site.gleam`, and change `masthead` to wrap `header#masthead` + navbar + page-provided children; wire `home_view` to `masthead(on_home: True, children: [home_hero(), marquee()])`. Verify the rendered home page is byte-identical to before the refactor (`site.home_view([]) |> element.to_string` before/after) and `gleam test` passes.
- [x] 1.2 Make `site_nav` page-aware: when `on_home: False`, section links render home-prefixed fragments (`/#about`, `/#projects`, …) and "Inicio" drops `aria_current("page")`; on home, anchors and aria-current stay exactly as today. Extend `home_view_renders_homepage_sections_test` (or add a sibling test) asserting the home page still renders `href="#projects"` and `aria-current` on "Inicio". Verify with `gleam test`.

## 2. Render the masthead in the single post template

- [x] 2.1 Add `post_hero()` — the compact hero panel (logo + site title via the existing `.hero`/`rs-cols-2` markup, without the `rs-note` description, `rs-btn` call-to-action row, and marquee) — and replace `post_template`'s `site-header` back-link block with `masthead(on_home: False, children: [post_hero()])`, leaving the `post_template(post, all_posts)` signature untouched. Verify `gleam test` passes.
- [x] 2.2 Add `post_template_renders_masthead_test` in `test/ninjas_test.gleam` using a `blogatto/post.Post` fixture: the rendered page contains `rs-navbar` and `id="masthead"`, `href="/#projects"` and the post title, and does not contain `site-header`, `rs-marquee`, or `aria-current`. Verify with `gleam test`.

## 3. Integration checks

- [x] 3.1 Run `gleam format src test`, then confirm `gleam format --check src test` passes.
- [x] 3.2 Confirm the full suite passes with `gleam test`.
- [x] 3.3 Confirm the change validates with `openspec validate add-masthead-to-post-template`.
- [x] 3.4 Smoke-check a generated page: run the site build and open `dist/blog/bienvenidos-a-ninjas-cl/index.html`, verifying the navbar is present at the top with working section links while no build output is committed.

## Workflow follow-up

- Archive the change after review with `openspec archive add-masthead-to-post-template`; archive creates `openspec/specs/site-masthead/spec.md` from the delta — verify it with `openspec validate --specs`.
- If the compact hero needs tuning (logo size, layout), adjust within the `post_hero()` helper; the spec's scenario only fixes what the compact hero omits.
