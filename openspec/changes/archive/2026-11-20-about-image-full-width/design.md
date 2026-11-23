# Design

## Context

`about_section` in `src/site.gleam` renders the portrait (`camilo.jpg`) in a `figure.rs-figure` beside the section text. A first iteration of this change removed the original `rs-cols-2` grid and the fixed 250×250 attributes and rendered the portrait full-width with the text below; a second revision laid both out in one row (~30% left / ~70% right); the third revision refined the row to about 30% portrait, a 10% gap, and about 60% text, and moves the portrait asset itself into the site's static directory. The fixed-attribute removal, the figure-first markup order, and the `#about`-scoped sizing rules carry over unchanged. See `proposal.md` for the motivation.

Constraints: the same `rs-figure` component is used by the project, book, and game showcase cards, so styling must stay scoped to the about section. The site has three stylesheets: retrostrap (vendored, shared), the cosmic theme, and `static/style.css` (Ninjas.cl's own overrides, loaded last).

## Goals / Non-Goals

**Goals:**

- The portrait and the section text render in one row: portrait left at about 30% of the section content width, a gap of about 10% between them, text right at about 60%.
- The portrait fills its column's width with `height: auto`, preserving intrinsic proportions (no stretching, no cropping).
- The change stays scoped: showcase card figures and every other retrostrap figure are visually unaffected.
- The about portrait is served from the site's own static assets, so the section renders without a remote image dependency.

**Non-Goals:**

- No processing of `camilo.jpg` — it is downloaded as-is; no re-crop, no recompression. Routing and content files are untouched.
- Only the about portrait changes source; the masthead hero logo and the showcase images keep their remote URLs.
- No retrostrap-wide column variant (e.g. an `rs-cols-30-70` in the vendored library); this stays a site-level rule.
- No pixel-precise mandate beyond the requested shares: the row is implemented as a percentage column gap plus free-space ratios, which resolves to exactly ~30%, ~10%, and ~60% of the row.

## Decisions

### 1. Implement the row as a site-level grid scoped to the about section

Add to `static/style.css`:

```css
.about__cols {
  display: grid;
  grid-template-columns: 3fr 6fr;
  gap: var(--rs-space-2);
  column-gap: 10%;
}

@media (max-width: 639px) { /* below retrostrap's vga breakpoint */
  .about__cols {
    grid-template-columns: 1fr;
  }
}
```

`grid-template-columns: 3fr 6fr` with `column-gap: 10%` realizes the requested 30/10/60 row: the percentage gap resolves first against the row's width, and the remaining 90% splits `3fr:6fr` (1:2) into exactly 30% and 60% — the three shares sum to 100% with no overflow. `gap: var(--rs-space-2)` stays as the row gap (the later `column-gap` declaration overrides only the column axis), so the stacked narrow-viewport layout keeps the retrostrap spacing between the portrait and the text. The class is site-specific (`about__cols`, matching the BEM-ish naming of `hero__logo` and `post-meta`), so no `#about` prefix is needed for it; the collapse below retrostrap's 640 px `vga` breakpoint mirrors how `rs-cols-2` itself degrades to one column.

- Alternative: reuse `rs-cols-2` — rejected; it is a 50/50 split, not 30/10/60.
- Alternative: literal `30% 10% 60%` tracks with an empty spacer column — viable, since three tracks summing to 100% need no separate gap, but it requires a third, empty grid child in the markup; the percentage gap expresses the same geometry without extra markup.
- Alternative: flexbox (`display: flex` with 30%/60% children and a 10% spacer) — viable, but a grid matches how retrostrap itself implements columns and handles the gap uniformly.

### 2. Markup: wrap the figure and text in the about row

Wrap the existing `figure.rs-figure` and text `div` in `html.div([attribute.class("about__cols")], ...)` — figure first (left column), text second (right column). The figure, caption, and paragraphs are untouched; the portrait keeps no fixed `width`/`height` attributes (removed in the first iteration of this change).

### 3. Keep the `#about`-scoped sizing rules from the first iteration

`#about .rs-figure { display: block; margin-inline: 0; }` and `#about .rs-figure img { width: 100%; height: auto; }` carry over: `width: 100%` now resolves against the ~30% left column, and `height: auto` keeps the browser deriving the height from the file's intrinsic ratio — `object-fit: cover` would crop, and fixed HTML attributes would pin the box. Scoping by the existing `#about` section id keeps the rules off the showcase cards.

### 4. Keep dropping the fixed attributes (no aspect-ratio hint)

Modern browsers use `width`/`height` attributes to reserve space before load. Keeping `250×250` would hint a square ratio; if `camilo.jpg` is not square, the reserved box misrepresents the image. Removing the attributes lets the browser use the file's real intrinsic ratio once loaded.

- Alternative: a CSS `aspect-ratio` matching the file's true ratio — skipped; the intrinsic ratio is not known in the repo, and measuring it is not needed for correct rendering.

### 5. Verify through the existing string-based view tests

Update the home view test in `test/ninjas_test.gleam`: rename it for the row layout and assert the `about__cols` wrapper is present, the portrait's `src` is present, no `width="250"`/`height="250"` attributes remain, the section title precedes the portrait, the section text follows it, and the caption survives. CSS files are not exercised by `gleam test`, so the visual row (~30/10/60, same row, proportions kept) is confirmed once in the dev server and by review.

### 6. Serve the portrait from the site's static assets

Download `https://ninjas.cl/img/camilo.jpg` once into `static/img/camilo.jpg` (the remote serves a ~59 KB JPEG) and point the about portrait at the root-relative path `/img/camilo.jpg`, matching how the site references its other static assets (`/style.css`, `/background.js`, `/patterns/...`, `/cursors/...`). blogatto copies the configured static directory into the site output, so the portrait ships with the generated site and the about section no longer waits on — or breaks without — the remote host. The existing home view test asserts the old remote URL; it is updated to the local path.

- Alternative: keep the remote URL — rejected per the request; the portrait is the site's own content.
- Alternative: vendor the file under a different name or path — rejected; keeping `camilo.jpg` under `static/img/` preserves the asset's identity and follows the existing per-type directories (`cursors/`, `patterns/`).

## Risks / Trade-offs

- [Percentage sizes overflow the row] → only the gap uses a percentage; the tracks are `3fr 6fr` over the remaining 90%, so the shares sum to exactly 100%.
- [A ~30% column makes the portrait small on mid-size viewports] → accepted; the portrait fills its column at every two-column width, and the row collapses below 640 px so narrow screens get the portrait at full width.
- [Removing the 250×250 hint can cause a small layout shift while the image loads] → accepted; the previous hint was wrong unless the file is square, and the site is a small static page.
- [A broad selector leaks into showcase cards] → the rules stay scoped to `#about` and the site-specific `about__cols` class; the showcase markup is untouched.
- [Two copies of the portrait exist (remote and local)] → the committed `static/img/camilo.jpg` becomes the source of truth for this build; the remote URL keeps serving until the site is redeployed.

## Migration Plan

Static site: rebuild and redeploy as usual; rollback is reverting the commit. No data, routing, or content migration involved.
