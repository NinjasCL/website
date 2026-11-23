# Proposal

## Why

The home page's section panels — "Sobre nosotros", "Entradas del blog", "Proyectos", "Libros", "Juegos", and the untitled banner wall at `#contact` — sit too close to the content above them. Retrostrap's `.rs-panel` rule gives each panel a 16px (`--rs-space-4`) top margin, and each panel's title floats 0.7em above its border, so the next section's title nearly touches the previous panel and the sections read as one continuous block. The blog index already solved this exact clearance problem for its own title panel: `#blog` carries a 32px top margin for the same reason.

## What Changes

- Every home page section panel (`#about`, `#posts`, `#projects`, `#books`, `#games`, `#contact`) SHALL carry a 32px (`--rs-space-5`) top margin — doubling retrostrap's 16px default — via one id-list rule in `static/style.css`, placed beside the existing `#blog` clearance rule it mirrors.
- One regression test locks the rule in place, following the site's CSS-contract test pattern (reading `static/style.css`, like the section-header size test).
- Out of scope:
  - Retrostrap's own stylesheet — the override lives in the site's custom layer, which loads after it.
  - Panels on other pages: the post page's "Otras entradas" panel and the 404 page's panel keep retrostrap's default spacing; only the home sections' ids are targeted.
  - Bottom margins and any spacing other than the panels' top clearance.

## Capabilities

### New Capabilities
- `site-section-spacing`: Vertical clearance between the home page's section panels — the top margin each section keeps above the preceding content, so sections read as separate blocks.

### Modified Capabilities

None. `site-section-headers` owns the section headers' type size and `site-blog-index` owns the index title panel's own clearance below the navbar; neither covers spacing between the home sections.

## Impact

- `static/style.css`: one added id-list rule (plus its explanatory comment), beside the `#blog` rule.
- `test/ninjas_test.gleam`: one added test reading `static/style.css` via the already-declared dev dependency `simplifile`.
- No Gleam source, routing, content, or template changes — the rendered markup is unchanged; no dependency, lockfile, or CI changes.
