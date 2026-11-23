# Tasks

## 1. Icon URLs move to the Win95 pack directory

- [x] 1.1 Update the eighteen `/icons/<file>` references in `src/site.gleam`
  to `/icons/win95/<file>`: the six navbar links, the five section-title
  icons, the three showcase card icons (Regwiz117, Fastboot101,
  Quartz100), the two showcase action-button icons (Shdocvw257, Wscript100),
  the featured-post star, and the "Leer entrada" button's Progman25 icon.
  The site owner's partial edit at the featured title (an `img` carrying
  `href` instead of `src`) is left for task 2.1 to replace — do not keep
  it. Verify by rendering `site.home_view([])` or waiting for 2.3.
- [x] 1.2 Update the icon-path assertions in `test/ninjas_test.gleam`:
  every `src="/icons/…"` string gains the `/icons/win95/` prefix
  (`emojis_render_as_static_icons_test`, `showcase_buttons_carry_icons_test`,
  `featured_post_follows_about_row_test`'s Progman split), and
  `icon_manifest_documents_matches_test` reads the manifest from
  `./static/icons/win95/emoji-matches.json`. Verify with `gleam test`
  once the later icon tasks land, or by rendering and checking the paths.

## 2. Post title and date lead with icons

- [x] 2.1 Rewrite the featured post's title and date in
  `featured_post/1` (`src/site.gleam`): the title link leads with the
  newspaper icon `/icons/win95/Mailnews8_32x32_4.png` (replacing the
  owner's `href`-on-`img` partial edit; decorative icon with empty alt,
  beside the title text) and the `post-meta` date leads with the
  calendar icon `/icons/win95/Timedate_32x32_4.png`. Follow the shared
  inline presentation the navbar and section titles already use.
- [x] 2.2 Apply the same two icons in `post_template/2`
  (`src/site.gleam`): the article `h1` title leads with the newspaper
  icon and its `post-meta` date leads with the calendar icon, matching
  the featured post's presentation.
- [x] 2.3 Pin both spots in `test/ninjas_test.gleam`: the featured row's
  title and date carry Mailnews8 and Timedate before the title and date
  texts, and the post page's `h1` and `post-meta` do the same. Verify
  with `gleam test`.

## 3. Pattern set renamed macosx → macos9

- [x] 3.1 Update `static/background.js`: every offered tile prefix
  `macosx/` becomes `macos9/` (the `win3.1/` entries are untouched), so
  each offered tile resolves at the shipped file layout. Verify with
  `background_patterns_match_shipped_files_test` after 3.3, or by
  checking the offered list against `static/patterns/macos9/`.
- [x] 3.2 Update the `--random-pattern` fallback in `static/style.css`
  from `url("/patterns/macosx/128.png")` to
  `url("/patterns/macos9/128.png")`. Verify with
  `background_pattern_fallback_test` after 3.3.
- [x] 3.3 Update `background_patterns_match_shipped_files_test` in
  `test/ninjas_test.gleam` to read `./static/patterns/macos9` and prefix
  `macos9/`, and `background_pattern_fallback_test` to assert the
  `/patterns/macos9/128.png` fallback. Verify with `gleam test`.

## 4. New banners join the wall

- [x] 4.1 Add the two shipped banners to the `banners` const in
  `src/site.gleam`, keeping the list's alphabetical order:
  `#("No-AI-green.gif", "No AI")` after `netscape-now-1996.gif` and
  `#("Y2K.gif", "Y2K")` at the end. The directory-driven
  `banner_wall_renders_every_shipped_banner_test` already pins the
  count — verify with `gleam test`.

## 5. Verification

- [x] 5.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 5.2 Run `gleam test` and confirm the full suite passes (it starts
  with three failures: banner wall, icon manifest, background patterns).
- [x] 5.3 Run `openspec validate static-reorg-and-post-icons` and confirm
  it passes.

## Workflow follow-up

- After review, archive the change with the `openspec-archive-change`
  workflow; when summarizing, carry the gaps noted in the proposal's
  Out of scope: the unused macOS 9 icon pack, `static/img/sad_mac.png`,
  and the `trim-footer` / `rewrite-about-copy` archive steps still
  pending from earlier changes.
