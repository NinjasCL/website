# Proposal

## Why

The single configured Atom feed has no language filter, so every Spanish, English, Japanese, and Portuguese post variant is serialized into `/atom.xml`. Subscribers therefore receive duplicate posts in languages they did not choose. Each site language needs its own Atom feed containing only that language's variants.

## What Changes

- Configure four Atom feeds through `config.atom_feed`: `/atom.xml` for the Spanish default (`post.language == None`) and `/en/atom.xml`, `/ja/atom.xml`, and `/pt/atom.xml` for their respective translated variants.
- Give each feed its own absolute id and a `rel="self"` link with a matching `hreflang`, while keeping the site title, description, and `@CLSource` author.
- Make the feed icon link in the blog index and home posts headers point to the feed for the page's language: `/atom.xml` on Spanish pages, `/{lang}/atom.xml` on translated pages.
- Add tests for feed outputs, filters, identities, and language-specific feed links.
- Out of scope: changing the RSS feed, adding per-language feed titles or translated descriptions, adding feed discovery links to page heads, and changing any post content or translation workflow.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: the Atom feed requirement changes from one all-posts feed to four language-scoped feeds.
- `site-section-headers`: the shared feed icon link changes from always `/atom.xml` to the current page language's Atom feed.

## Impact

- `src/ninjas/blog.gleam`: build multiple `AtomFeed` values using `atom.new`, `atom.output`, `atom.filter`, `atom.link`, and `config.atom_feed`; filter on `blogatto/post.Post.language`.
- `src/site.gleam`: `feed_link` takes the page language code and resolves its feed path; both blog index views pass their `BlogIndexText.code`.
- `src/ninjas/home.gleam`: the posts section passes its `HomeText.code` to `site.feed_link`.
- `test/ninjas_test.gleam`: config, filter, and rendered-link assertions.
- No new dependencies: blogatto's existing feed configuration is sufficient. The RSS feed and all generated HTML routes keep their current URLs.
