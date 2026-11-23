# Proposal

## Why

The "Sobre nosotros" section pins its portrait (`camilo.jpg`) to a hardcoded 250×250 box inside an equal two-column grid (`rs-cols-2`). The fixed square dimensions can misrepresent the photo's natural proportions, and the equal split gives the portrait and the text no deliberate share of the row.

## What Changes

- The about section lays out the portrait and its text in one row: the portrait in a left column taking about 30% of the section content's width, a gap of about 10% between them, and the text in a right column taking about 60%.
- The portrait fills its column's width with `height: auto`, so its height follows the image's intrinsic aspect ratio — it covers its space without stretching, squashing, or cropping (proportions preserved).
- The fixed `width`/`height` (250) HTML attributes are removed from the `<img>`; sizing moves to CSS scoped to the about section.
- Below the site's two-column breakpoint, the row collapses to a single column: portrait first, text below.
- The figure caption ("Camilo Castro — Software Engineer") and all section text are preserved unchanged.
- The portrait is downloaded once into the site's own static assets (`static/img/camilo.jpg`) and served from there at `/img/camilo.jpg`, so the about section no longer depends on a remote image host.
- Only the Lustre view markup and the site stylesheet change; no blogatto/Gleam APIs beyond the `lustre/element/html` and `lustre/attribute` helpers already in use.

## Capabilities

### New Capabilities
- `site-about-section`: Rendering behavior of the home page's "Sobre nosotros" section — the portrait and text sharing one row (~30% left / ~60% right with a ~10% gap between), the portrait served from the site's own static assets at its natural proportions, and its caption preserved.

### Modified Capabilities
<!-- None: no existing spec under openspec/specs/ covers the about section. blog-site-generation's home-route behavior and site-masthead are unaffected. -->

## Impact

- **Code:** `src/site.gleam` (the private `about_section` view: wrap the figure and text in a two-column row, drop the fixed `attribute.width(250)`/`attribute.height(250)`, point the portrait at the local asset) and `static/style.css` (a 30/60 grid with a 10% column gap for the about row, plus rules scoped to `#about` making the figure block-level and the image `width: 100%; height: auto`), plus a new `static/img/camilo.jpg` asset (~59 KB JPEG) downloaded once from `https://ninjas.cl/img/camilo.jpg`.
- **Tests:** `test/ninjas_test.gleam` home view test asserting the portrait carries no fixed 250×250 attributes, the about row wrapper is present, the portrait is served from `/img/camilo.jpg`, and the section text follows the image.
- **Dependencies:** none. The styling uses the existing retrostrap `rs-figure` component and the site's own stylesheet; no new packages or blogatto API changes.
- **Out of scope:** every other `rs-figure` use (project/book/game showcase cards), the masthead hero logo and the showcase images (they keep their remote URLs), any processing of `camilo.jpg` beyond downloading it as-is (no re-crop or recompression), other home sections, and any change to site generation or routing.
