# Proposal

## Why

Djot sends single-backtick inline code through blogatto's `post.code` component with no language, and the site's content-block component treated that case like an untagged fenced block — wrapping the word in `<pre><code>`. Every inline mention therefore broke out of its sentence as a separate code panel. Inline code should only highlight the word, in the site's violet, while keeping the JetBrains Mono face shared with block code.

## What Changes

- Render the no-language case of `post.code` as a bare `<code>` span so inline code flows with its sentence.
- Add a `post.pre` component that restores the `<pre>` wrapper only for untagged fenced blocks (the bare `code` elements djot passes to `pre`); tagged panels, summary toggles, and embed cards keep their existing structure.
- Style inline code spans with `color: #fafafa` on `background-color: #7540bd`, small padding and radius, and the same JetBrains Mono family as block code.
- Cover the inline span, the untagged-fence wrapper, and the stylesheet contract with tests.

Out of scope: changing fenced code block highlighting, the Night Owl panel palette, embed fences, language variants, or any blog content. No new dependency is introduced.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `blog-site-generation`: add the requirement that inline code spans render inline with the violet highlight instead of a block panel, and extend post code typography with the inline span's colors.

## Impact

- `src/ninjas/highlight.gleam` — `code_component`'s no-language branch and a new `pre_component`.
- `src/ninjas/blog.gleam` — registers the new `pre` component in place of the pass-through fragment.
- `static/style.css` — inline code presentation.
- `test/ninjas_test.gleam` — component and stylesheet tests.
- blogatto APIs involved: `post.code`, `post.pre`, and djot's inline-vs-fenced code routing; no dependency or version changes.
