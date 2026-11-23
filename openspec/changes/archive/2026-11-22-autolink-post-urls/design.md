# Design

## Context

See `proposal.md` for motivation. The engine constraint that shapes
everything: blogatto renders post bodies through `jot` (djot), whose inline
parser hyperlinks only explicit constructs — `[text](url)` links and
`<url>` autolinks (`jot.parse_autolink` requires the `<…>` wrapping; it
accepts anything containing `://` between the braces). A bare URL in prose
parses as plain `Text`. No blogatto public API rewrites inline text: the
config hooks this site uses (`post.template`, `post.code`, `post.pre`) are
block-level, and the embeds/highlighting component in
`src/ninjas/highlight.gleam` only sees fenced blocks. So the site owner's
mandate — modify the djot sources — is also the engine-native route: djot's
own autolink syntax.

The corpus: 404 `.djot` files (101 posts × 4 language variants). A
context-aware scan finds 964 bare URLs in prose across 200 of those files
(dry-run validated against a temp copy of `blog/`).

## Goals / Non-Goals

Goals:

- Every bare `http(s)://` URL in post prose renders as an anchor, in all
  four variants, without touching anything that is already a link, code,
  raw HTML, embed payload, or frontmatter.
- The conversion is mechanical, idempotent, and reviewable as a plain
  `git diff` of `blog/`.

Non-Goals (see proposal for scope): render-time linkification, scheme-less
URLs, any site-code change. Also non-goal: rewriting the two
`$`-style or attribute syntaxes — none carry URLs in prose.

## Decisions

### 1. Source conversion to `<url>` autolinks, not a renderer feature

`<https://example.com>` is djot's autolink: jot renders it as an anchor
with href = text = the URL, needing no site code. Alternatives rejected:

- A custom linkifier over rendered HTML (regex over Lustre element trees
  or post-processing `element.to_string` output) — no blogatto hook exists
  at that level; it would be fragile string surgery around houdini's
  escaping and would fight the engine on every edge (code spans, embeds,
  raw HTML).
- Teaching the content-block component to linkify — it only receives
  fenced blocks, not prose.

### 2. Conversion rules (what the scanner touches and skips)

Per file, the scanner walks lines with block-level state, then inline
state per prose line:

- Block state: frontmatter (leading `---` block) is copied verbatim;
  fenced blocks (```` ``` ````/`~~~`, any info string — including
  `=html` raw blocks and the `github`/`youtube`/`ninjas`/`embed` fences)
  are copied verbatim from opening fence to closing fence; a raw HTML tag
  left unterminated at end of line suspends scanning until its `>` (none
  exist outside fences in this corpus, but handled anyway).
- Inline state, per prose line: backtick runs (inline code) are copied
  verbatim; a `[…](…)` link/image construct on the line is copied verbatim
  — destination **and** text, so `[url](url)` self-links and URLs in link
  text are untouched (wrapping text would nest links); a URL directly
  after `](` — a destination whose `[` sits on an earlier line (multi-line
  link, one case in the corpus) is copied verbatim, because jot takes the
  `(…)` interior literally and wrapping would corrupt the href; `<…>` spans
  (existing autolinks and raw tags) are copied verbatim.
- Bare URL match: starts at `https?://`, consumes until whitespace or one
  of `<>"'`[]{ }*|`; trailing `.,;:!?` stays outside; a trailing `)` joins
  only while the URL contains an unmatched `(`; the result is wrapped in
  `<…>`.

Idempotent by construction: `<…>`-wrapped content is never rescanned.
Validated on a full temp copy of `blog/`: correct handling of the
bibliography entries with trailing dots (`finanzas-personales`), the
parenthesized Wikipedia URL (`Acumulador_(inform%C3%A1tica)`), the
multi-line link in `wireshell…` (untouched), the `<video>` raw block
(inside an `=html` fence, untouched), and code URLs in fences (untouched);
a second pass reports zero changes.

### 3. One-off tooling, not a shipped script

The conversion runs once against the shipped sources; there is no
recurring need for a script in the repo (new posts can keep using djot
syntax directly, and the spec now states the behavior). The scanner lives
in the session workspace, and this document records its rules — the git
history of `blog/` is the durable record of what changed.

### 4. Verification through the build output

No new Gleam code means no new gleeunit tests for this change; the
observable contract is the generated HTML. Verification: rebuild, then
confirm in `dist/` that (a) a formerly plain URL (the Webpay guide's
`http://www.transbankdevelopers.cl/`) is now inside an `<a>`, and (b) no
anchor was added inside any code panel or embed card. The existing
`every_post_ships_all_languages_test` keeps guarding the four-variant
invariant, which this content-only change cannot break (no files added,
removed, or renamed; frontmatter untouched).

## Risks / Trade-offs

- [A prose line is misparsed as a protected context and a URL stays
  plain] → Acceptable failure mode (no corruption); the full `git diff`
  review of `blog/` before rebuilding is the backstop, and any missed URL
  is a one-line fix.
- [A URL is wrapped inside a context that is actually code or an
  attribute] → Mitigated by fence/inline state tracking and validated on
  the temp copy; the rebuild + output grep would surface it as a broken
  anchor inside a code panel.
- [Autolink text shows the raw URL] → Chosen over shortening the label:
  djot autolinks keep href = text, and inventing labels would alter the
  posts' editorial voice.

## Migration Plan

1. Run the scanner over `blog/` (in-place rewrite).
2. Review `git diff blog/` — expected shape: only `<…>` wrappers added
   around URLs in prose lines.
3. Rebuild (`task build`) and verify anchors in `dist/`.
4. Rollback: `git checkout -- blog/` restores every source; `dist/` is
   regenerated by the next build.
