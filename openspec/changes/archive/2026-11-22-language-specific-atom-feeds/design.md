# Design

## Context

`src/ninjas/blog.gleam` currently registers one `AtomFeed` with no filter, so blogatto serializes every post variant into `/atom.xml`. Both `site.blog_index_page` and `home.posts_section` render the shared `site.feed_link`, which hard-codes `/atom.xml`. The site already carries a language code on both `HomeText` and `BlogIndexText`, and blogatto's `FeedMetadata.post.language` distinguishes the default Spanish variant (`None`) from translated variants (`Some("en")`, `Some("ja")`, `Some("pt")`). See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**

- Build four Atom feeds from one source configuration, with identical channel identity and a filter per language.
- Keep each feed's self-identifying metadata consistent with its output URL.
- Have every language's feed icon lead to that language's feed.

**Non-Goals:**

- Splitting the RSS feed or adding RSS feeds per language.
- Translating the feed title/subtitle or adding feed discovery `<link>` elements to page heads.
- Changing post filenames, routes, or templates beyond the feed icon's destination.

## Decisions

- **One `AtomFeed` value per language through `atom.new` + `atom.output` + `atom.filter` + `config.atom_feed`.** blogatto already supports multiple Atom feeds and gives each filter the full `FeedMetadata`, so no new dependency or custom writer is needed. The alternative of generating feeds in a post-build step would duplicate blogatto's serialization and diverge from the dev build.
- **Map the default Spanish variant to the root feed.** The filter matches `option.None`, matching the site's existing language mapping (`home.language_posts` and `site.blog_index_page`). Translated feeds match `option.Some(code)` for `en`, `ja`, and `pt`. No post content needs to change.
- **Derive each feed's id and `self` link from the configured site URL plus its output path.** The root feed uses the es-CL hreflang; translated feeds use their language code. This keeps absolute IDs correct in both production and dev builds without hard-coding `https://ninjas.cl/`.
- **Make `site.feed_link` take the page's language code.** The code maps `"es"` to `/atom.xml` and all other supported codes to `/{code}/atom.xml`. Both call sites already hold the code, so no new field is added to `HomeText` or `BlogIndexText`. Unknown codes fall back to the Spanish feed, consistent with the site's existing language fallback behavior.

## Risks / Trade-offs

- [Existing subscribers to the root feed will see their entries reduced to Spanish] → The root URL remains valid and now matches the site's default language; translated readers must resubscribe to their language's URL.
- [A feed's path could drift from its id/self link] → Build all three from one shared `path` value in the helper rather than repeating literals.
- [Filter order or duplicate favorites in `atom_feed` list assertions] → Tests locate feeds by `output` rather than assuming the list order produced by `config.atom_feed`'s prepend behavior.
- [A language code in a page view could be unsupported] → Map unknown codes to the Spanish feed, matching existing language resolution.

## Migration Plan

Build and deploy normally. `atom.xml` keeps its URL but changes content to Spanish-only; the three translated URLs are new files under the existing language directories. No redirects or content migration are required. Rollback restores the single unfiltered feed and the hard-coded feed link.

## Open Questions

None.
