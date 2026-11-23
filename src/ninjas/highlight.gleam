//// Build-time syntax highlighting for djot code blocks.
////
//// blogatto's syntax highlighting tokenizes markdown sources only — djot
//// code blocks reach the `code` component untokenized (see
//// `examples/blogatto/docs/syntax-highlighting.md`). This module supplies
//// that tokenization for the site's djot content, mirroring what
//// blogatto's markdown renderer does internally: the component extracts
//// the block's raw source, highlights it through the public
//// `code.highlight` (smalto, the default 28 grammars), and falls back to
//// a plain `<code>` for inline spans, untagged blocks and unrecognized
//// languages. The `pre` component adds the block wrapper back for
//// untagged fences — inline code never passes through it.

import blogatto/config/post/code
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ninjas/github_opengraph

/// The site's syntax highlighting configuration: smalto's default
/// grammars with class-based token rendering — each token's text in a
/// span carrying its `smalto-*` class, so the site's stylesheet owns the
/// colors. smalto's built-in rendering is inline-styled for light
/// backgrounds, which the setters here replace token type by token type.
pub fn syntax_config() -> code.SyntaxHighlightingConfig(Nil) {
  code.default()
  |> code.keyword(class_span("smalto-keyword"))
  |> code.string(class_span("smalto-string"))
  |> code.number(class_span("smalto-number"))
  |> code.comment(class_span("smalto-comment"))
  |> code.function(class_span("smalto-function"))
  |> code.operator(class_span("smalto-operator"))
  |> code.punctuation(class_span("smalto-punctuation"))
  |> code.type_(class_span("smalto-type"))
  |> code.module(class_span("smalto-module"))
  |> code.variable(class_span("smalto-variable"))
  |> code.constant(class_span("smalto-constant"))
  |> code.builtin(class_span("smalto-builtin"))
  |> code.tag(class_span("smalto-tag"))
  |> code.attribute(class_span("smalto-attribute"))
  |> code.selector(class_span("smalto-selector"))
  |> code.property(class_span("smalto-property"))
  |> code.regex(class_span("smalto-regex"))
}

/// One token-type renderer: the token's text in a span carrying its
/// smalto class.
fn class_span(class: String) -> fn(String) -> Element(Nil) {
  fn(value) { html.span([attribute.class(class)], [element.text(value)]) }
}

/// Build the site's code component with deterministic GitHub image paths.
/// Unit tests use this form: it stays offline by pointing cards at the
/// site-local path the production cache will occupy.
///
/// A fence's info string may declare a collapsible summary in djot's
/// attribute form (` ```go {summary="Mostrar solución"} `): the block then
/// renders inside a `details`/`summary` toggle. The whole info string
/// reaches the component as the "language" (jot keeps the braces), and the
/// grammar lookup already takes only the leading token, so highlighting is
/// unaffected.
pub fn code_component(
  syntax: code.SyntaxHighlightingConfig(Nil),
) -> fn(Dict(String, String), Option(String), List(Element(Nil))) ->
  Element(Nil) {
  code_component_with_github_images(syntax, github_opengraph.local_image_path)
}

/// The same component with an explicit GitHub image resolver. Production
/// builds pass `github_opengraph.image_source`, which warms and reuses the
/// build-time cache before the card's `src` is rendered.
pub fn code_component_with_github_images(
  syntax: code.SyntaxHighlightingConfig(Nil),
  github_image: fn(String) -> String,
) -> fn(Dict(String, String), Option(String), List(Element(Nil))) ->
  Element(Nil) {
  fn(_attributes, language, children) {
    case language {
      // djot sends inline code here with no language and no `pre` call.
      // Keep it a bare `code` span so it flows with the surrounding text;
      // fenced blocks without a language get their `pre` wrapper from
      // `pre_component` instead.
      None -> html.code([], children)
      Some(lang) -> {
        // Extract the block's raw source: the djot renderer hands the code
        // over as Lustre text elements, which `element.to_string`
        // HTML-escapes — each child is rendered individually to avoid
        // fragment comment markers — and the entities are unescaped again,
        // `&amp;` last, so `&amp;lt;` round-trips.
        let source =
          children
          |> list.map(element.to_string)
          |> string.join("")
          |> unescape_html
        case lang {
          "github" -> github_embed(source, github_image)
          "youtube" -> youtube_embed(source)
          "ninjas" -> ninjas_embed(source)
          "embed" -> website_embed(source)
          _ ->
            case fence_summary(lang) {
              Some(summary) ->
                html.details([], [
                  html.summary([], [element.text(summary)]),
                  render_code(syntax, lang, source, children),
                ])
              None -> render_code(syntax, lang, source, children)
            }
        }
      }
    }
  }
}

/// One tagged fenced block of code: highlighted when the grammar is
/// known, in its own Night Owl `pre` panel. `pre_component` recognizes
/// the finished panel and leaves it alone.
fn render_code(
  syntax: code.SyntaxHighlightingConfig(Nil),
  lang: String,
  source: String,
  children: List(Element(Nil)),
) -> Element(Nil) {
  let code = case code.highlight(syntax, lang, source) {
    Ok(highlighted) ->
      html.code(
        [attribute.class("language-" <> language_name(lang))],
        highlighted,
      )
    Error(Nil) -> html.code([], children)
  }
  html.pre([], [code])
}

/// blogatto wraps every fenced djot block in a `pre` call — inline code
/// never reaches here. Tagged blocks, summary toggles and embed cards
/// already carry their own full structure from `code_component`; only a
/// bare `code` element (an untagged fence) needs the block panel added.
pub fn pre_component(
  _attributes: Dict(String, String),
  children: List(Element(Nil)),
) -> Element(Nil) {
  case children {
    [child] ->
      case string.starts_with(element.to_string(child), "<code") {
        True -> html.pre([], [child])
        False -> element.fragment(children)
      }
    _ -> element.fragment(children)
  }
}

/// A full OpenGraph embed card — the old site's `tags/embed.html`
/// structure in the site's dashed frame: a text column (site name,
/// title, description) beside the image, the whole card one link. The
/// empty description or image omit their piece, so short fences
/// degrade to valid cards.
fn og_card(
  url: String,
  site: String,
  title: String,
  description: String,
  image: String,
) -> Element(Nil) {
  let body =
    html.span(
      [attribute.class("embed-full__body")],
      [
        html.span([attribute.class("embed-full__site")], [
          element.text(site),
        ]),
        html.span([attribute.class("embed-full__title")], [
          element.text(title),
        ]),
      ]
        |> list.append(case description {
          "" -> []
          description -> [
            html.span([attribute.class("embed-full__description")], [
              element.text(description),
            ]),
          ]
        }),
    )
  let image_element = case image {
    "" -> []
    image -> [
      html.img([
        attribute.class("embed-full__image"),
        attribute.src(image),
        attribute.alt(title),
        attribute.title(url),
      ]),
    ]
  }
  html.a([attribute.class("embed-full"), attribute.href(url)], [
    body,
    ..image_element
  ])
}

/// The fence's pipe-separated fields, trimmed — `a | b | c` parses to
/// three parts; a fence without pipes is a single part.
fn fence_fields(spec: String) -> List(String) {
  spec |> string.split("|") |> list.map(string.trim)
}

/// The nth field of a split fence, or the empty string when the fence
/// carries none — short fences render valid degraded cards.
fn part(fields: List(String), index: Int) -> String {
  case list.drop(fields, index) {
    [value, ..] -> value
    [] -> ""
  }
}

/// The trailing slash off a swept fence's target, if any.
fn strip_trailing_slash(value: String) -> String {
  case string.ends_with(value, "/") {
    True -> string.drop_end(value, 1)
    False -> value
  }
}

/// A GitHub repository's full embed card: the fence carries
/// `owner/repo | description` — the link, title, and site name derive
/// from the repo. The image comes from the injected resolver: a
/// site-local cached PNG in production, its deterministic path in tests.
fn github_embed(
  spec: String,
  github_image: fn(String) -> String,
) -> Element(Nil) {
  let fields = fence_fields(spec)
  let repo = strip_trailing_slash(part(fields, 0))
  og_card(
    "https://github.com/" <> repo,
    "GitHub",
    repo,
    part(fields, 1),
    github_image(repo),
  )
}

/// A YouTube embed: the video's player as a single-element iframe at
/// full content width inside the dashed frame, as the old site's
/// `tags/youtube.html` — `width="100%"`, the old template's allow
/// list, the frame's CSS giving it 16:9 capped at 640px. The fence
/// carries a watch URL, a youtu.be URL, or a bare video id.
fn youtube_embed(video: String) -> Element(Nil) {
  let video_id = extract_youtube_id(string.trim(video))
  element.unsafe_raw_html(
    "",
    "div",
    [attribute.class("embed-video")],
    "<iframe width=\"100%\" src=\"https://www.youtube.com/embed/"
      <> video_id
      <> "\" title=\"YouTube video\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen></iframe>",
  )
}

/// The video id from a watch URL, a youtu.be URL, or a bare id.
fn extract_youtube_id(video: String) -> String {
  case string.split_once(video, "watch?v=") {
    Ok(#(_, id)) -> id
    Error(Nil) ->
      case string.split_once(video, "youtu.be/") {
        Ok(#(_, id)) -> id
        Error(Nil) -> video
      }
  }
}

/// A ninjas.cl blog post's full embed card: the fence carries
/// `slug | Post title | description | image` — the card links the
/// site's post carrying its title, description, and cover.
fn ninjas_embed(spec: String) -> Element(Nil) {
  let fields = fence_fields(spec)
  let slug = part(fields, 0)
  let title = case part(fields, 1) {
    "" -> slug
    title -> title
  }
  og_card(
    "https://ninjas.cl/blog/" <> slug <> "/",
    "Ninjas.cl",
    title,
    part(fields, 2),
    part(fields, 3),
  )
}

/// An external website's full embed card — the static form of the old
/// `{% embed URL %}`: the fence carries `url | title | description |
/// image`, the site name deriving from the URL's host.
fn website_embed(spec: String) -> Element(Nil) {
  let fields = fence_fields(spec)
  let url = part(fields, 0)
  let title = case part(fields, 1) {
    "" -> url
    title -> title
  }
  og_card(url, host_of(url), title, part(fields, 2), part(fields, 3))
}

/// The host of a URL — everything between the scheme and the first
/// slash, or the whole string when neither appears.
fn host_of(url: String) -> String {
  let rest = case string.split_once(url, "://") {
    Ok(#(_, rest)) -> rest
    Error(Nil) -> url
  }
  case string.split_once(rest, "/") {
    Ok(#(host, _)) -> host
    Error(Nil) -> rest
  }
}

/// The bare language token from a fence's info string — everything before
/// the first space or colon, mirroring blogatto's grammar lookup — so an
/// attribute-laden fence like `go {summary="…"}` still classes its code
/// as `language-go`.
fn language_name(lang: String) -> String {
  case string.split_once(lang, " "), string.split_once(lang, ":") {
    Ok(#(name, _)), _ -> name
    _, Ok(#(name, _)) -> name
    _, _ -> lang
  }
}

/// The collapsible summary declared on a fence's info string, if any —
/// djot's attribute form `{summary="…"}`. The value may contain spaces,
/// so it reads to the closing quote.
fn fence_summary(lang: String) -> Option(String) {
  case string.split_once(lang, "summary=\"") {
    Error(Nil) -> None
    Ok(#(_, rest)) ->
      case string.split_once(rest, "\"") {
        Ok(#(summary, _)) ->
          case summary {
            "" -> None
            _ -> Some(summary)
          }
        Error(Nil) -> None
      }
  }
}

/// Unescape HTML entities in a string to recover raw source code from
/// Lustre text elements, which HTML-escape their content via houdini.
/// The `&amp;` entity is unescaped last to avoid double-unescaping
/// sequences like `&amp;lt;`.
fn unescape_html(html: String) -> String {
  html
  |> string.replace("&lt;", "<")
  |> string.replace("&gt;", ">")
  |> string.replace("&quot;", "\"")
  |> string.replace("&#39;", "'")
  |> string.replace("&amp;", "&")
}
