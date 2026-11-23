# Design

## Context

See `proposal.md` for motivation. Today every home page section header is an `<h2 class="rs-panel__title">` produced by one shared helper (`section` in `src/site.gleam`), and retrostrap styles that class as a small tab label overlapping the panel's top border:

```css
.rs-panel__title {
  position: absolute;
  inset-block-start: -.7em;
  inset-inline-start: var(--rs-space-3);
  margin: 0;
  padding-inline: var(--rs-space-2);
  background: var(--rs-bg-content);
  font-size: var(--rs-font-size-2); /* 0.8125rem */
  font-weight: 700;
  line-height: 1;
}
```

Constraints that shape the approach:

- The tab offset (`inset-block-start: -.7em`) is in `em`, so it scales with font size on its own — growing the font needs no positioning fix.
- `page()` links `/style.css` after `/retrostrap.min.css` and `/cosmic.css`, so a same-specificity class rule in `static/style.css` wins the cascade. That file is the established override layer (cursor rules, `.about__cols`).
- `rs-panel__title` is used only by the six home section `h2`s in the generated markup; showcase card `h3`s, the featured post `h3`, the contact `h3`, and the hero headings do not carry the class, so a class-scoped override cannot leak to other headings.
- Retrostrap's type ladder: `--rs-font-size-2` 0.8125rem, `--rs-font-size-3` 1rem, `--rs-font-size-4` 1.125rem, `--rs-font-size-5` 1.5rem, `--rs-font-size-6` 2rem, `--rs-font-size-7` 3rem. The 2× floor is 1.625rem, so the smallest ladder step that clears it is `--rs-font-size-6` (2rem).

Routing, content files, and templates are not affected: the change is presentation-only, in a static asset that blogatto already copies verbatim to the generated site.

## Goals / Non-Goals

**Goals:**

- Every home page section header computes to a font size of 1.5rem (retrostrap's `--rs-font-size-5` ladder step, ≈1.85× the 0.8125rem panel-title default), uniformly across all six sections.
- Keep the fix in the site's own override layer; retrostrap's shipped stylesheet stays untouched.
- Lock the size contract with an automated test.

**Non-Goals:**

- No change to heading levels, markup, fonts, font weight, colors, or the retrostrap tab presentation beyond the font size.
- No responsive or breakpoint work; the em-based offset scales automatically.
- No resizing of non-section headings (post title, hero site title, showcase card titles, footer).

## Decisions

1. **Override `.rs-panel__title` in `static/style.css`** rather than editing `static/retrostrap.min.css` or introducing a new class in the Gleam template.
   - Editing the vendored, minified retrostrap stylesheet makes a site-local fix invisible and easy to lose on the next retrostrap refresh.
   - A new custom class would change generated markup and still need a rule that overrides the retrostrap default. The override achieves the same with zero markup churn: same specificity (0,1,0), and `style.css` loads last, so no `!important` is needed — the same load-order technique the file's cursor rules already document.

2. **`font-size: var(--rs-font-size-5)` (1.5rem ≈ 24px, ≈1.85×)** — revised 2026-11-20 after visual tuning. The original implementation shipped `--rs-font-size-6` (2rem, ≈2.46×) as the smallest ladder step clearing the initial "at least 2x" floor (1.625rem); that size read visually heavy in the tab presentation, so the site owner tuned it down one step and the contract was revised to match.
   - Both values are retrostrap type-ladder steps, so the site stays on the design system's scale either way.
   - `calc(2 * var(--rs-font-size-2))` remains rejected: it tracks a token that may drift and leaves the header off the ladder.

3. **Regression test reads `static/style.css`** and asserts the `.rs-panel__title` rule sets the enlarged font size. The size contract lives in a static asset, invisible to the markup-level `element.to_string` assertions the suite uses today.
   - This needs `simplifile` declared as a dev dependency (`gleam add --dev simplifile`). It is already in `manifest.toml` as a blogatto dependency, so this only exposes an already-locked package to tests — no new package or version enters the build, and the runtime dependency set is unchanged.
   - Rejected alternative: an `@external(erlang, "file", "read_file")` binding avoids the `gleam.toml` change but puts unidiomatic FFI in the test suite for a single assertion; blogatto has no public API for reading arbitrary site files.

## Risks / Trade-offs

- [The larger tab label covers more of each panel's top edge] → Only `font-size` is overridden; the em-based offset keeps the border overlap aligned automatically. If the tab needs rebalancing at the new size (e.g. wider inline padding), tune it in a follow-up — out of scope here.
- [Long titles on very narrow viewports may wrap inside the tab] → Acceptable for now: the label wraps within the panel width rather than overflowing. Revisit only if it looks wrong in practice.
- [A retrostrap upgrade could change the type ladder or panel-title default, shifting the 2× baseline] → The test pins the exact declaration, so an upgrade that invalidates the floor fails loudly and forces a conscious re-check.
- [1.5rem is ≈1.85×, below the original "at least 2x" ask] → Accepted by the site owner's 2026-11-20 retune: the header stays clearly larger than body text (1rem) and remains on the ladder; the spec, test, and CSS comment are aligned to the revised contract.

## Migration Plan

1. Add the override rule (and its explanatory comment) to `static/style.css`.
2. `gleam add --dev simplifile`; add the CSS regression test to `test/ninjas_test.gleam`.
3. Verify: `gleam format src test`, `gleam test`, `openspec validate enlarge-section-headers`.

Rollback: remove the rule and the test; the dev dependency may stay or be removed with `gleam remove --dev simplifile`. A normal rebuild regenerates the site; no content migration is involved.
