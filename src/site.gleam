//// Site identity and the shared chrome of ninjas.cl, plus the views that
//// are not the home page: the post template, the blog index, the /blog
//// redirect, and the 404 page. The home page lives in `ninjas/home`.

import blogatto/post.{type Post}
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import simplifile

pub const production_url = "https://ninjas.cl/"

pub const dev_url = "http://127.0.0.1:3000/"

pub const site_title = "Ninjas.cl"

pub const site_description = "Ninjas es un grupo desarrollador de software experimental de Chile 🇨🇱. Participa en diversos proyectos tecnológicos, tales como videojuegos, software y otras actividades relacionadas. Ninjas.cl fue fundado en 2015 (¡11 años programando ❤️!) por @CLSource."

pub const site_language = "es-CL"

/// Posts per blog index page (`/blog/page/{n}/`).
pub const blog_page_size = 25

/// A language the site's posts are available in: the default language is
/// the human-written Spanish (`index.djot`, `language: None`); every other
/// language is machine translated. Each language carries its own texts
/// for the post pages rendered in it: the machine-translated warning, the
/// staleness warning's template — a `{days}` placeholder stands in for
/// the elapsed day count — the language options row's label, and its
/// OpenGraph locale.
type SiteLanguage {
  SiteLanguage(
    code: String,
    name: String,
    machine_translated: Bool,
    translation_warning: String,
    staleness_warning: String,
    og_locale: String,
    options_label: String,
  )
}

/// The site's default language: the human-written Spanish variant that
/// blogatto reports as `language: None`.
const default_language = SiteLanguage(
  code: "es",
  name: "Español",
  machine_translated: False,
  translation_warning: "",
  staleness_warning: "Este contenido puede estar desactualizado ya que han pasado más de {days} días desde su publicación",
  og_locale: "es_CL",
  options_label: "Idiomas",
)

/// The site's post languages in display order: Spanish first as the
/// default, then the machine-translated options.
const site_languages = [
  default_language,
  SiteLanguage(
    code: "en",
    name: "English",
    machine_translated: True,
    translation_warning: "This page is a machine translation of the original Spanish post, so it may contain translation errors.",
    staleness_warning: "This content may be outdated, as more than {days} days have passed since its publication",
    og_locale: "en_US",
    options_label: "Languages",
  ),
  SiteLanguage(
    code: "ja",
    name: "日本語",
    machine_translated: True,
    translation_warning: "このページは元のスペイン語の投稿を機械翻訳したもので、翻訳の誤りが含まれる可能性があります。",
    staleness_warning: "このコンテンツは公開から{days}日以上が経過しているため、最新ではない可能性があります",
    og_locale: "ja_JP",
    options_label: "言語",
  ),
  SiteLanguage(
    code: "pt",
    name: "Português",
    machine_translated: True,
    translation_warning: "Esta página é uma tradução automática da publicação original em espanhol e pode conter erros de tradução.",
    staleness_warning: "Este conteúdo pode estar desatualizado, já que mais de {days} dias se passaram desde sua publicação",
    og_locale: "pt_BR",
    options_label: "Idiomas",
  ),
]

/// The Win95 Regional Settings icon that leads every language options
/// row's label — the era's own "international" indicator, ahead of the
/// page language's word for languages.
pub const languages_icon = "/icons/win95/Intl101_32x32_4.png"

/// The Win95 document-and-pencil icon that leads the footer's copyright
/// line — the pack's glyph for authorship, the source of a copyright.
pub const copyright_icon = "/icons/win95/FilePencil_32x32_4.png"

/// A post is stale when its date is older than this many days from the
/// build's current day.
const stale_days = 365

/// The OpenGraph locale reported by pages rendered in the default
/// (Spanish) language — the value the home page passes to the shared
/// layout.
pub fn default_og_locale() -> String {
  default_language.og_locale
}

/// Render a single blog post page around the post's rendered contents. The
/// masthead carries the post's header image as its cover, the article's
/// language options link the post's sibling variants, and translated or
/// stale posts show their warnings before the body.
pub fn post_template(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  page(
    title: post.title <> " — " <> site_title,
    description: post.description,
    url: post.url,
    language: post_page_language(post.language),
    og_locale: language_config(post.language).og_locale,
    body: [
      masthead(
        nav: nav_labels,
        home_url: "/",
        on_home: False,
        cover: option.Some(featured_image(post)),
        children: [],
      ),
      html.main([attribute.id("main")], [
        html.article([], [
          html.h1([], title_with_icon(post_icon_url(post), post.title)),
          html.p([attribute.class("post-meta")], [
            icon("/icons/win95/Timedate_32x32_4.png"),
            element.text(" "),
            html.time([], [element.text(format_date(post.date))]),
          ]),
          post_tags(post),
          html.p([attribute.class("post-description")], [
            html.em([], linkified_text(post.description)),
          ]),
          language_options(post, all_posts),
          ..list.append(post_warnings(post), [
            html.div([attribute.class("post-body")], post.contents),
          ])
        ]),
        post_navigation(post, all_posts),
        random_posts_section(post, all_posts),
      ]),
      site_footer(copyright_rights_es, back_to_top),
    ],
  )
}

/// Every string the blog index pages render in their language: the
/// language's identity — its code (the route segment of its index), its
/// display name, its html lang value, and its OpenGraph locale — plus
/// the visible copy: the panel heading, the page title's template with
/// its `{page}` placeholder, the meta description, the panel intro, the
/// pagination buttons with their navigation aria label, the options
/// row's label, and the navbar labels in the page's language. The Spanish
/// record is the reference copy and the other records translate it,
/// following the site's convention for translated variants.
type BlogIndexText {
  BlogIndexText(
    code: String,
    name: String,
    lang: String,
    og_locale: String,
    heading: String,
    title: String,
    description: String,
    intro: String,
    previous: String,
    next: String,
    nav_aria: String,
    options_label: String,
    nav: NavLabels,
  )
}

/// The Spanish blog index — the site's default language, human-written.
/// The reference copy every other language translates: the strings the
/// index page rendered before the language versions, with the page
/// number riding the title's `{page}` placeholder.
const spanish_index_text = BlogIndexText(
  code: "es",
  name: "Español",
  lang: site_language,
  og_locale: "es_CL",
  heading: "Blog",
  title: "Blog, página {page}",
  description: "Todas las entradas del blog de Ninjas.cl, las más recientes primero.",
  intro: "Todas las entradas del blog, las más recientes primero. Cada tarjeta enlaza la entrada y sus traducciones.",
  previous: "Página anterior",
  next: "Página siguiente",
  nav_aria: "Navegación de páginas",
  options_label: "Idiomas",
  nav: nav_labels,
)

/// The English blog index — a machine-translation-quality translation
/// of the Spanish reference copy, following the site's convention for
/// translated variants.
const english_index_text = BlogIndexText(
  code: "en",
  name: "English",
  lang: "en",
  og_locale: "en_US",
  heading: "Blog",
  title: "Blog, page {page}",
  description: "All the Ninjas.cl blog posts, the most recent first.",
  intro: "All the blog posts, the most recent first. Each card links the post and its translations.",
  previous: "Previous page",
  next: "Next page",
  nav_aria: "Page navigation",
  options_label: "Languages",
  nav: NavLabels(
    home: "Home",
    blog: "Blog",
    about: "About us",
    projects: "Projects",
    books: "Books",
    games: "Games",
    aria_label: "Main navigation",
  ),
)

/// The Japanese blog index — a machine-translation-quality translation
/// of the Spanish reference copy, following the site's convention for
/// translated variants.
const japanese_index_text = BlogIndexText(
  code: "ja",
  name: "日本語",
  lang: "ja",
  og_locale: "ja_JP",
  heading: "ブログ",
  title: "ブログ、ページ{page}",
  description: "Ninjas.clのブログ記事をすべて、新しいものから順に。",
  intro: "ブログ記事をすべて、新しいものから順に。各カードは記事とその翻訳にリンクします。",
  previous: "前のページ",
  next: "次のページ",
  nav_aria: "ページナビゲーション",
  options_label: "言語",
  nav: NavLabels(
    home: "ホーム",
    blog: "ブログ",
    about: "私たちについて",
    projects: "プロジェクト",
    books: "書籍",
    games: "ゲーム",
    aria_label: "メインナビゲーション",
  ),
)

/// The Portuguese blog index — a machine-translation-quality
/// translation of the Spanish reference copy, following the site's
/// convention for translated variants.
const portuguese_index_text = BlogIndexText(
  code: "pt",
  name: "Português",
  lang: "pt",
  og_locale: "pt_BR",
  heading: "Blog",
  title: "Blog, página {page}",
  description: "Todas as postagens do blog do Ninjas.cl, as mais recentes primeiro.",
  intro: "Todas as postagens do blog, as mais recentes primeiro. Cada cartão vincula a postagem e suas traduções.",
  previous: "Página anterior",
  next: "Próxima página",
  nav_aria: "Navegação de páginas",
  options_label: "Idiomas",
  nav: NavLabels(
    home: "Início",
    blog: "Blog",
    about: "Sobre nós",
    projects: "Projetos",
    books: "Livros",
    games: "Jogos",
    aria_label: "Navegação principal",
  ),
)

/// The index copy for a language code: the Spanish reference for the default
/// and unknown codes, a translated record for each language variant. Shared by
/// the index pages and their landing fallbacks so both speak the same language.
fn blog_index_text(code: String) -> BlogIndexText {
  case code {
    "en" -> english_index_text
    "ja" -> japanese_index_text
    "pt" -> portuguese_index_text
    _ -> spanish_index_text
  }
}

/// The route path of an index page in a language: the default pages at
/// `blog/page/{n}/`, a language version at `blog/{lang}/page/{n}/`.
fn blog_index_path(code: String, page_number: Int) -> String {
  case code {
    "es" -> "blog/page/" <> int.to_string(page_number) <> "/"
    code -> "blog/" <> code <> "/page/" <> int.to_string(page_number) <> "/"
  }
}

/// The blog index page n in the site's default language — the route view
/// for `/blog/page/{n}/`: the default-language posts, newest first,
/// `blog_page_size` per page, each entry an embed-style card linking
/// the post, with the language options row linking the translated
/// indexes.
pub fn blog_index_view(
  page_number: Int,
) -> fn(List(Post(Nil))) -> Element(Nil) {
  fn(posts) { blog_index_page(blog_index_text("es"), page_number, posts) }
}

/// The blog index page n in a translated language — the route view for
/// `/blog/{lang}/page/{n}/`: that language's variants, newest first,
/// the page's own copy in its language. An unknown code falls back to
/// the default language, so a stray route can never break the render.
pub fn language_blog_index_view(
  code: String,
  page_number: Int,
) -> fn(List(Post(Nil))) -> Element(Nil) {
  fn(posts) { blog_index_page(blog_index_text(code), page_number, posts) }
}

/// The blog index page n in the page text's language: that language's
/// posts — the default-language posts for Spanish, the language's
/// translated variants for a language version — newest first,
/// `blog_page_size` per page, each entry an embed-style card — the
/// post's header image covering the card's whole height on the right,
/// its date and title led by the post page's calendar icon and the
/// post's own title icon on the left, with tags and links to the post's other-language
/// variants below — linking the post, the language options row under
/// the intro, and the pagination linking the same language's pages.
fn blog_index_page(
  text: BlogIndexText,
  page_number: Int,
  posts: List(Post(Nil)),
) -> Element(Nil) {
  let language_posts =
    posts
    |> list.filter(fn(post) {
      case text.code {
        "es" -> post.language == option.None
        code -> post.language == option.Some(code)
      }
    })
    |> list.sort(fn(a, b) { timestamp.compare(b.date, a.date) })
  let total_pages = blog_page_total(list.length(language_posts))
  let entries =
    language_posts
    |> list.drop({ page_number - 1 } * blog_page_size)
    |> list.take(blog_page_size)
  page(
    title: string.replace(text.title, "{page}", int.to_string(page_number))
      <> " — "
      <> site_title,
    description: text.description,
    url: production_url <> blog_index_path(text.code, page_number),
    language: text.lang,
    og_locale: text.og_locale,
    body: [
      masthead(
        nav: text.nav,
        home_url: "/",
        on_home: False,
        cover: option.None,
        children: [],
      ),
      html.main([attribute.id("main")], [
        html.section([attribute.id("blog"), attribute.class("rs-panel")], [
          html.h2(
            [attribute.class("rs-panel__title")],
            list.append(
              title_with_icon("/icons/win95/Notepad_32x32_4.png", text.heading),
              [element.text(" "), feed_link(text.code)],
            ),
          ),
          html.p([], [element.text(text.intro)]),
          index_language_options(text, page_number),
          html.div(
            [],
            list.map(entries, fn(post) { blog_entry_card(post, posts) }),
          ),
          pagination_nav(text, page_number, total_pages),
        ]),
      ]),
      site_footer(copyright_rights_es, back_to_top),
    ],
  )
}

/// The index pages' language options row: every language's index linked
/// like the posts' options row — the current language as plain text
/// marked as the current page, every other language linking its
/// same-numbered index page — so each index is reachable from the
/// others and switching languages keeps the reader's page position.
fn index_language_options(
  text: BlogIndexText,
  page_number: Int,
) -> Element(Nil) {
  let entries =
    [
      spanish_index_text,
      english_index_text,
      japanese_index_text,
      portuguese_index_text,
    ]
    |> list.map(fn(other) {
      case other.code == text.code {
        True ->
          html.span([attribute.aria_current("page")], [
            element.text(other.name),
          ])
        False ->
          html.a(
            [attribute.href("/" <> blog_index_path(other.code, page_number))],
            [element.text(other.name)],
          )
      }
    })
  html.p([attribute.class("post-languages")], [
    icon(languages_icon),
    element.text(" " <> text.options_label <> ": "),
    ..join_with_sep(entries)
  ])
}

/// The total number of index pages for a language's post count: whole
/// pages of `blog_page_size` posts, always at least one page.
fn blog_page_total(post_count: Int) -> Int {
  int.max({ post_count + blog_page_size - 1 } / blog_page_size, 1)
}

/// One index entry: the embed-card look — the date led by the post
/// page's calendar icon and the title by the post's own title icon, the
/// description under them, and the post's header image as a right
/// column covering the card's whole height — all one link to the
/// post — framed together with a meta row carrying the post's tags
/// and the links to its translations. Anchors cannot nest, so the
/// meta row sits below the link inside the frame.
fn blog_entry_card(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  html.article([attribute.class("blog-entry")], [
    html.a(
      [
        attribute.class("embed-full blog-entry__main"),
        attribute.href(post.url),
      ],
      [
        html.span([attribute.class("embed-full__body")], [
          html.span([attribute.class("embed-full__site")], [
            icon("/icons/win95/Timedate_32x32_4.png"),
            element.text(" " <> format_date(post.date)),
          ]),
          html.span(
            [attribute.class("embed-full__title")],
            title_with_icon(post_icon_url(post), post.title),
          ),
          html.span([attribute.class("embed-full__description")], [
            element.text(post.description),
          ]),
        ]),
        html.img([
          attribute.class("embed-full__image"),
          attribute.src(featured_image(post)),
          attribute.alt(post.title),
        ]),
      ],
    ),
    html.div([attribute.class("blog-entry__meta")], [
      post_tags(post),
      blog_entry_languages(post, all_posts),
    ]),
  ])
}

/// The card's translation links: one per sibling variant the post ships
/// in every other language — each labeled with its language name and
/// linking the variant's page, resolved by slug exactly like the post
/// page's language options row. The entry's own language needs no link:
/// the card itself links it, so the default index links the English,
/// Japanese, and Portuguese variants while a translated index links the
/// Spanish original beside the other translations.
fn blog_entry_languages(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  let variants =
    all_posts
    |> list.filter(fn(other) { other.slug == post.slug })
  let translations =
    site_languages
    |> list.filter(fn(language) {
      language.code != language_config(post.language).code
    })
    |> list.filter_map(fn(language) {
      find_variant(language.code, variants)
      |> option.map(fn(variant) {
        html.a([attribute.href(variant.url)], [element.text(language.name)])
      })
      |> option.to_result(Nil)
    })
  case translations {
    [] -> html.div([], [])
    _ ->
      html.p(
        [attribute.class("blog-entry__languages")],
        join_with_sep(translations),
      )
  }
}

/// The index page's pagination navigation: the same retrostrap buttons
/// and the same rotated Win95 pointing hand the post pages use, labeled
/// in the page's language, with the page counter between them — the old
/// blog page's `Next ⏭️` / `1 / 7` grammar. The first page links only the
/// next page, the last only the previous one, and every link stays
/// inside the page's language: the default pages link `/blog/page/{n}/`,
/// a language version links its own `/blog/{lang}/page/{n}/`.
fn pagination_nav(
  text: BlogIndexText,
  page_number: Int,
  total_pages: Int,
) -> Element(Nil) {
  html.nav(
    [attribute.class("post-nav"), attribute.aria_label(text.nav_aria)],
    list.flatten([
      case page_number > 1 {
        True -> [
          html.a(
            [
              attribute.class("rs-btn rs-btn--icon rs-btn--large"),
              attribute.href("/" <> blog_index_path(text.code, page_number - 1)),
            ],
            [
              html.img([
                attribute.class("post-nav__hand post-nav__hand--left"),
                attribute.src("/icons/win95/Msow10_32x32_4.png"),
                attribute.alt(""),
              ]),
              element.text(text.previous),
            ],
          ),
        ]
        False -> []
      },
      [
        html.span([attribute.class("blog-pages")], [
          element.text(
            int.to_string(page_number) <> " / " <> int.to_string(total_pages),
          ),
        ]),
      ],
      case page_number < total_pages {
        True -> [
          html.a(
            [
              attribute.class("rs-btn rs-btn--icon rs-btn--large"),
              attribute.href("/" <> blog_index_path(text.code, page_number + 1)),
            ],
            [
              html.img([
                attribute.class("post-nav__hand post-nav__hand--right"),
                attribute.src("/icons/win95/Msow10_32x32_4.png"),
                attribute.alt(""),
              ]),
              element.text(text.next),
            ],
          ),
        ]
        False -> []
      },
    ]),
  )
}

/// A blog landing fallback: the old site's URL contract in each language —
/// a meta-refresh straight to that language's first index page, with a plain
/// link for clients that skip it, so the canonical URL resolves without a
/// duplicate copy of the list. Apache serves the real redirect first; this
/// page covers hosts that ignore the shipped `.htaccess`.
pub fn blog_redirect_view(code: String) -> Element(Nil) {
  let text = blog_index_text(code)
  let target = "/" <> blog_index_path(text.code, 1)

  html.html([attribute.lang(text.lang)], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.title([], text.heading <> " — " <> site_title),
      html.meta([
        attribute.attribute("http-equiv", "Refresh"),
        attribute.content("0; url=" <> target),
      ]),
      html.meta([
        attribute.name("description"),
        attribute.content(text.description),
      ]),
    ]),
    html.body([], [
      element.text("🐸 "),
      html.a([attribute.href(target)], [element.text(text.heading)]),
    ]),
  ])
}

/// The site language for a post variant: blogatto's default language
/// (`None`) maps to the Spanish entry, a variant's code to its own entry,
/// and an unknown code falls back to the default so a stray variant can
/// never break the render.
fn language_config(language: option.Option(String)) -> SiteLanguage {
  case language {
    option.None -> default_language
    option.Some(code) ->
      site_languages
      |> list.find(fn(lang) { lang.code == code })
      |> result.unwrap(default_language)
  }
}

/// The html lang attribute for a post page: the site's default value for
/// the Spanish variant, the variant's language code for a translation.
fn post_page_language(language: option.Option(String)) -> String {
  case language {
    option.None -> site_language
    option.Some(code) -> code
  }
}

/// The post page's language options row: one entry per sibling variant of
/// the post — the current language as plain text marked as the current
/// page, every other entry linking to its variant's URL — in the site's
/// declared language order. Rendered only when the post has more than one
/// variant; a lone variant has nothing to switch to.
fn language_options(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  let variants =
    all_posts
    |> list.filter(fn(other) { other.slug == post.slug })
  case list.length(variants) > 1 {
    False -> html.div([], [])
    True ->
      html.p([attribute.class("post-languages")], [
        icon(languages_icon),
        element.text(
          " " <> language_config(post.language).options_label <> ": ",
        ),
        ..join_with_sep(language_option_entries(post, site_languages, variants))
      ])
  }
}

/// The options row's entries, one per declared language that has a variant
/// of the post: the current variant's language renders as plain text with
/// the current-page marker, the others as links to their variant's URL.
fn language_option_entries(
  post: Post(Nil),
  languages: List(SiteLanguage),
  variants: List(Post(Nil)),
) -> List(Element(Nil)) {
  case languages {
    [] -> []
    [language, ..rest] ->
      case find_variant(language.code, variants) {
        option.None -> language_option_entries(post, rest, variants)
        option.Some(variant) -> {
          let entry = case post.language == variant.language {
            True ->
              html.span([attribute.aria_current("page")], [
                element.text(language.name),
              ])
            False ->
              html.a([attribute.href(variant.url)], [
                element.text(language.name),
              ])
          }
          [entry, ..language_option_entries(post, rest, variants)]
        }
      }
  }
}

/// The post's variant for a language code, if the post ships one — the
/// default variant (`language: None`) matching the declared "es" entry.
fn find_variant(
  code: String,
  variants: List(Post(Nil)),
) -> option.Option(Post(Nil)) {
  variants
  |> list.find(fn(variant) { language_config(variant.language).code == code })
  |> option.from_result
}

/// Interleave the options row's entries with " · " separators — shared by
/// the posts' language options row and the home pages' own.
pub fn join_with_sep(entries: List(Element(Nil))) -> List(Element(Nil)) {
  case entries {
    [] | [_] -> entries
    [first, ..rest] -> [first, element.text(" · "), ..join_with_sep(rest)]
  }
}

/// The post page's warnings, translation first: the machine-translated
/// notice on non-default variants, then the staleness notice when the
/// post's date is older than a year from the build's current day — both
/// worded in the rendered page's language.
fn post_warnings(post: Post(Nil)) -> List(Element(Nil)) {
  let language = language_config(post.language)
  let translation = case language.machine_translated {
    True -> [warning_box(language.translation_warning)]
    False -> []
  }
  let days = days_since(post.date)
  let staleness = case days > stale_days {
    True -> [warning_box(staleness_message(language, days))]
    False -> []
  }
  list.append(translation, staleness)
}

/// The pinned staleness warning in the page's language: the elapsed days
/// stand in for the template's `{days}` placeholder.
fn staleness_message(language: SiteLanguage, days: Int) -> String {
  language.staleness_warning
  |> string.replace(each: "{days}", with: int.to_string(days))
}

/// One post warning: the pack's warning icon leading the message.
fn warning_box(message: String) -> Element(Nil) {
  html.p([attribute.class("post-warning")], [
    icon("/icons/win95/Warning_32x32_4.png"),
    element.text(" " <> message),
  ])
}

/// Days between the post's date — its last update, which authors bump on
/// revision — and the build's current day.
fn days_since(date: timestamp.Timestamp) -> Int {
  let elapsed_seconds =
    timestamp.difference(date, timestamp.system_time())
    |> duration.to_seconds
  float.truncate(elapsed_seconds /. 86_400.0)
}

/// The post page's navigation to the adjacent entries in the newest-first
/// post list: "Anterior" links the previous entry (the newer post) and
/// "Siguiente" the next one (the older post) — the direction the home
/// list reads — each resolved to the reader's current language variant. A
/// post without neighbors renders no navigation at all.
fn post_navigation(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  let #(previous, next) = post_neighbors(post, all_posts)
  case previous, next {
    option.None, option.None -> html.div([], [])
    _, _ ->
      html.nav(
        [
          attribute.class("post-nav"),
          attribute.aria_label("Navegación de entradas"),
        ],
        list.flatten([
          case previous {
            option.Some(neighbor) -> [
              html.a(
                [
                  attribute.class("rs-btn rs-btn--icon rs-btn--large"),
                  attribute.href(neighbor.url),
                ],
                [
                  html.img([
                    attribute.class("post-nav__hand post-nav__hand--left"),
                    attribute.src("/icons/win95/Msow10_32x32_4.png"),
                    attribute.alt(""),
                  ]),
                  element.text("Anterior: " <> neighbor.title),
                ],
              ),
            ]
            option.None -> []
          },
          case next {
            option.Some(neighbor) -> [
              html.a(
                [
                  attribute.class("rs-btn rs-btn--icon rs-btn--large"),
                  attribute.href(neighbor.url),
                ],
                [
                  element.text("Siguiente: " <> neighbor.title),
                  html.img([
                    attribute.class("post-nav__hand post-nav__hand--right"),
                    attribute.src("/icons/win95/Msow10_32x32_4.png"),
                    attribute.alt(""),
                  ]),
                ],
              ),
            ]
            option.None -> []
          },
        ]),
      )
  }
}

/// The post's adjacent entries in the newest-first default-language list,
/// each resolved to the page's own language variant: the previous entry
/// (the newer post) and the next one (the older post).
fn post_neighbors(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> #(option.Option(Post(Nil)), option.Option(Post(Nil))) {
  walk_neighbors(post, default_language_posts(all_posts), all_posts, [])
}

/// Walk the newest-first default list around the current post's entry —
/// matched by slug, since the page being rendered may itself be a
/// variant — collecting the entries just before and after it.
fn walk_neighbors(
  post: Post(Nil),
  defaults: List(Post(Nil)),
  all_posts: List(Post(Nil)),
  seen: List(Post(Nil)),
) -> #(option.Option(Post(Nil)), option.Option(Post(Nil))) {
  case defaults {
    [] -> #(option.None, option.None)
    [current, ..rest] ->
      case current.slug == post.slug {
        True -> {
          let previous = case seen, rest {
            [newer, ..], _ -> #(
              option.Some(in_language(newer, post.language, all_posts)),
              case rest {
                [older, ..] ->
                  option.Some(in_language(older, post.language, all_posts))
                [] -> option.None
              },
            )
            _, [older, ..] -> #(
              option.None,
              option.Some(in_language(older, post.language, all_posts)),
            )
            _, _ -> #(option.None, option.None)
          }
          previous
        }
        False -> walk_neighbors(post, rest, all_posts, [current, ..seen])
      }
  }
}

/// The neighbor's variant in the page's language — the completeness
/// mandate ships every variant, and the neighbor's default entry is the
/// fallback so navigation never dead-ends.
fn in_language(
  neighbor: Post(Nil),
  language: option.Option(String),
  all_posts: List(Post(Nil)),
) -> Post(Nil) {
  case language {
    option.None -> neighbor
    option.Some(code) ->
      all_posts
      |> list.find(fn(candidate) {
        candidate.slug == neighbor.slug
        && candidate.language == option.Some(code)
      })
      |> result.unwrap(neighbor)
  }
}

/// The post page's random-entries section: up to five other posts, picked
/// fresh at build time from the default-language catalog — the current
/// post and its navigation neighbors (the previous and next entries,
/// already on the page as buttons) excluded — each resolved to the
/// reader's language, in the home list's own presentation. An empty pool
/// renders no section at all.
fn random_posts_section(
  post: Post(Nil),
  all_posts: List(Post(Nil)),
) -> Element(Nil) {
  let #(previous, next) = post_neighbors(post, all_posts)
  let excluded =
    [post.slug]
    |> list.append(case previous {
      option.Some(neighbor) -> [neighbor.slug]
      option.None -> []
    })
    |> list.append(case next {
      option.Some(neighbor) -> [neighbor.slug]
      option.None -> []
    })
  let others =
    all_posts
    |> default_language_posts
    |> list.filter(fn(other) { !list.contains(excluded, other.slug) })
  case shuffle(others) |> list.take(5) {
    [] -> html.div([], [])
    picks ->
      html.section([attribute.class("rs-panel post-others")], [
        html.h2(
          [attribute.class("rs-panel__title")],
          title_with_icon("/icons/win95/Notepad_32x32_4.png", "Otras entradas"),
        ),
        html.ul(
          [attribute.class("rs-list rs-list--stars")],
          list.map(picks, fn(picked) {
            post_item(in_language(picked, post.language, all_posts))
          }),
        ),
      ])
  }
}

/// A random integer in `1..max`, from the Erlang runtime's own `rand`
/// module — the same direct-FFI pattern `gleam_time` uses for the clock,
/// with no new dependency. `rand` seeds itself, so every build's
/// random-entries list is fresh.
@external(erlang, "rand", "uniform")
fn random_uniform(max: Int) -> Int

/// A Fisher–Yates shuffle: pick a random entry, recurse on the rest.
pub fn shuffle(entries: List(a)) -> List(a) {
  case entries {
    [] -> []
    [only] -> [only]
    _ ->
      case take_at(entries, random_uniform(list.length(entries)) - 1) {
        Ok(#(picked, rest)) -> [picked, ..shuffle(rest)]
        // Unreachable — the index is always in range — but returning the
        // list beats crashing a build over randomness.
        Error(Nil) -> entries
      }
  }
}

/// The entry at `index` and the list without it.
fn take_at(entries: List(a), index: Int) -> Result(#(a, List(a)), Nil) {
  case entries, index {
    [], _ -> Error(Nil)
    [first, ..rest], 0 -> Ok(#(first, rest))
    [first, ..rest], _ ->
      case take_at(rest, index - 1) {
        Ok(#(picked, remaining)) -> Ok(#(picked, [first, ..remaining]))
        Error(Nil) -> Error(Nil)
      }
  }
}

/// The not-found page's message: the page's main heading and its meta
/// description.
const not_found_message = "La página que buscabas está en otro castillo"

/// The not-found (404) page: the shared navbar, the Sad Mac and its
/// message in one sunken panel, and the site footer. The page treats
/// itself as a non-home page — the navbar's section links point at the
/// home page and "Inicio" carries no current-page marker. Shipped at the
/// output root as `404.html`, the static-host error-page convention.
pub fn not_found_view() -> Element(Nil) {
  page(
    title: "404 — " <> site_title,
    description: not_found_message,
    url: production_url <> "404.html",
    language: site_language,
    og_locale: default_language.og_locale,
    body: [
      masthead(
        nav: nav_labels,
        home_url: "/",
        on_home: False,
        cover: option.None,
        children: [],
      ),
      html.main([attribute.id("main")], [
        html.section([attribute.class("rs-panel rs-panel--sunken")], [
          html.div([attribute.class("rs-center")], [
            html.figure([attribute.class("rs-figure")], [
              html.img([
                attribute.src("/img/sad_mac.png"),
                attribute.alt("Mac triste"),
              ]),
            ]),
            html.h1([], [element.text(not_found_message)]),
          ]),
        ]),
      ]),
      site_footer(copyright_rights_es, back_to_top),
    ],
  )
}

/// Format a post timestamp as a calendar date (`YYYY-MM-DD`).
pub fn format_date(date: timestamp.Timestamp) -> String {
  let #(date, _time) = timestamp.to_calendar(date, calendar.utc_offset)
  int.to_string(date.year)
  <> "-"
  <> pad(date.month |> calendar.month_to_int)
  <> "-"
  <> pad(date.day)
}

fn pad(number: Int) -> String {
  number
  |> int.to_string
  |> string.pad_start(to: 2, with: "0")
}

/// The navbar's labels in the rendered page's language: the six link
/// labels plus the navigation region's aria-label. The default home,
/// the default blog index, and the remaining non-home pages render the
/// Spanish `nav_labels`; each translated home and blog index passes its
/// own.
pub type NavLabels {
  NavLabels(
    home: String,
    blog: String,
    about: String,
    projects: String,
    books: String,
    games: String,
    aria_label: String,
  )
}

/// The site's Spanish navbar labels — the default every non-home page
/// and the default home render.
pub const nav_labels = NavLabels(
  home: "Inicio",
  blog: "Blog",
  about: "Nosotros",
  projects: "Proyectos",
  books: "Libros",
  games: "Juegos",
  aria_label: "Navegación principal",
)

/// The back-to-top link's Spanish label — the default the non-home
/// pages and the default home render.
pub const back_to_top = "^ volver arriba ^"

/// The copyright line's rights clause in the site's Spanish: the
/// translation of the former English-only line, mirroring its
/// "preserved" as "preservados" and carrying the rights/lefts wordplay
/// as derechos/izquierdos.
pub const copyright_rights_es = "Todos los derechos e izquierdos preservados"

/// The English rights clause the translated homes keep.
pub const copyright_rights_en = "All rights and lefts preserved"

/// The site masthead chrome: the shared navbar plus the hero elements chosen
/// by the page, styled as a classic web masthead. `nav` carries the labels
/// in the rendered page's language and `home_url` the current home's URL —
/// the navbar's home-link target, marked the current page when `on_home`.
/// `cover` fills the masthead's whole area with a background image — the
/// single post template's header image — instead of adding hero elements;
/// `option.None` renders the plain masthead.
pub fn masthead(
  nav nav: NavLabels,
  home_url home_url: String,
  on_home on_home: Bool,
  cover cover: option.Option(String),
  children children: List(Element(Nil)),
) -> Element(Nil) {
  let attributes = case cover {
    option.Some(image) -> [
      attribute.id("masthead"),
      attribute.class("masthead masthead--cover"),
      attribute.style("background-image", "url(" <> image <> ")"),
    ]
    option.None -> [attribute.id("masthead"), attribute.class("masthead")]
  }
  html.header(attributes, [site_nav(nav, home_url, on_home), ..children])
}

/// The primary navigation, shared by every page, labeled in the rendered
/// page's language. Section links stay in-page anchors on the home pages;
/// from anywhere else they point at the default home page so they keep
/// resolving.
fn site_nav(nav: NavLabels, home_url: String, on_home: Bool) -> Element(Nil) {
  let home_attributes = case on_home {
    True -> [attribute.href(home_url), attribute.aria_current("page")]
    False -> [attribute.href(home_url)]
  }
  html.nav(
    [
      attribute.class("rs-navbar"),
      attribute.aria_label(nav.aria_label),
    ],
    [
      html.a(
        home_attributes,
        title_with_icon("/icons/win95/Desktop_32x32_4.png", nav.home),
      ),
      html.a(
        [attribute.href("/blog")],
        title_with_icon("/icons/win95/Notepad_32x32_4.png", nav.blog),
      ),
      html.a(
        [attribute.href(section_link(on_home, "about"))],
        title_with_icon("/icons/win95/D3FlowerBox100_32x32_4.png", nav.about),
      ),
      html.a(
        [attribute.href(section_link(on_home, "projects"))],
        title_with_icon("/icons/win95/Bulb_32x32_4.png", nav.projects),
      ),
      html.a(
        [attribute.href(section_link(on_home, "books"))],
        title_with_icon("/icons/win95/HelpBook_32x32_4.png", nav.books),
      ),
      html.a(
        [attribute.href(section_link(on_home, "games"))],
        title_with_icon("/icons/win95/Winmine1_32x32_4.png", nav.games),
      ),
    ],
  )
}

/// Home page sections are in-page anchors on the home page and home-prefixed
/// fragments everywhere else.
fn section_link(on_home: Bool, id: String) -> String {
  case on_home {
    True -> "#" <> id
    False -> "/#" <> id
  }
}

/// The post page's tags row: the frontmatter `tags` field — a
/// comma-separated string in the post's `extras` — split, trimmed, and
/// rendered as one rounded label per tag, led by the Bookmark icon
/// (the Win95 replacement for the old site's 🏷️). Posts without tags
/// render no row at all.
fn post_tags(post: Post(Nil)) -> Element(Nil) {
  let tags =
    post.extras
    |> dict.get("tags")
    |> result.unwrap("")
    |> string.split(",")
    |> list.map(string.trim)
    |> list.filter(fn(tag) { tag != "" })
  case tags {
    [] -> html.div([], [])
    _ ->
      html.p([attribute.class("post-tags")], [
        icon("/icons/win95/Bookmark_32x32_4.png"),
        element.text(" "),
        ..list.map(tags, fn(tag) {
          html.span([attribute.class("post-tag")], [element.text(tag)])
        })
      ])
  }
}

/// The default-language posts — the human-written Spanish entries. The
/// machine-translated variants are options on each post's own page, not
/// duplicate entries in the home list.
pub fn default_language_posts(posts: List(Post(Nil))) -> List(Post(Nil)) {
  list.filter(posts, fn(post) { post.language == option.None })
}

/// The copyright line's end year: the build's current year, read through
/// the same clock path as `format_date`, so the line stays current on every
/// regeneration.
fn current_year() -> String {
  let #(copyright_date, _time) =
    timestamp.to_calendar(timestamp.system_time(), calendar.utc_offset)
  int.to_string(copyright_date.year)
}

/// The site footer, trimmed to its essentials: the copyright line — led
/// by the authorship icon, its rights clause in the page's language, the
/// "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix verbatim — and the
/// back-to-top link, labeled in the rendered page's language. The former
/// decorative chrome — the Chile WebRing bar, the "Desde 2015" line, and
/// the 88×31 badge buttons — is gone; the banner wall at #contact carries
/// the retro flourish now.
pub fn site_footer(rights: String, top_label: String) -> Element(Nil) {
  html.footer([attribute.class("rs-footer")], [
    html.p([], [
      icon(copyright_icon),
      element.text(
        " Copyright 🥷🏽 Ninjas.cl © 2015–" <> current_year() <> " · " <> rights,
      ),
    ]),
    html.a([attribute.class("rs-top"), attribute.href("#masthead")], [
      element.text(top_label),
    ]),
  ])
}

/// A decorative inline icon from the site's /icons Win95 pack, rendered
/// beside text; empty alt because the adjacent text carries the meaning.
pub fn icon(path: String) -> Element(Nil) {
  html.img([
    attribute.class("site-icon"),
    attribute.src(path),
    attribute.alt(""),
  ])
}

/// The children of a labeled element that leads with its matching inline
/// icon: the icon plus its label when a path is given, the label alone
/// otherwise (the label text may itself keep an emoji, like 🥷).
pub fn title_with_icon(icon_path: String, label: String) -> List(Element(Nil)) {
  case icon_path {
    "" -> [element.text(label)]
    path -> [icon(path), element.text(" " <> label)]
  }
}

/// The path of a language's Atom feed: the root feed for the default Spanish
/// language, a nested feed for a translation. Unknown codes fall back to the
/// default feed, like the site's other language resolution.
pub fn atom_feed_path(code: String) -> String {
  case code {
    "en" -> "/en/atom.xml"
    "ja" -> "/ja/atom.xml"
    "pt" -> "/pt/atom.xml"
    _ -> "/atom.xml"
  }
}

/// The syndication feed's icon link, shared by the blog index's title and the
/// home page's blog posts header: the page language's Atom feed behind the
/// same image.
pub fn feed_link(code: String) -> Element(Nil) {
  html.a([attribute.class("blog-feed"), attribute.href(atom_feed_path(code))], [
    html.img([
      attribute.src("/img/feed.svg"),
      attribute.alt("Feed Atom RSS"),
    ]),
  ])
}

/// A plain-prose paragraph's content with its bare http(s) URLs linked:
/// each URL's run becomes an anchor whose href and visible text are the
/// URL — mirroring the djot autolinks of the post body — and the prose
/// around it renders as text. Used where a description renders as
/// standalone prose (the post page's description paragraph and the home
/// featured row); inside a link, or as an attribute value, the raw
/// string is used instead.
pub fn linkified_text(text: String) -> List(Element(Nil)) {
  case take_next_url(text) {
    option.None -> [element.text(text)]
    option.Some(#(before, url, after)) -> [
      element.text(before),
      html.a([attribute.href(url)], [element.text(url)]),
      ..linkified_text(after)
    ]
  }
}

/// The first bare URL in a prose string, as
/// #(text-before, url, text-after) — no URL when the string holds none.
fn take_next_url(text: String) -> option.Option(#(String, String, String)) {
  take_next_url_scan(text, "")
}

/// The scan walks one grapheme at a time, carrying the text seen so far.
/// A scheme run only counts as a URL at the text's start or after a
/// space — single-line prose never glues a URL to a word — so a
/// mid-word scheme keeps its plain text.
fn take_next_url_scan(
  text: String,
  before: String,
) -> option.Option(#(String, String, String)) {
  let starts_url =
    string.starts_with(text, "https://") || string.starts_with(text, "http://")
  let at_word_start = before == "" || string.ends_with(before, " ")
  case starts_url && at_word_start {
    True ->
      case string.split_once(text, " ") {
        Ok(#(run, rest)) ->
          option.Some(split_url_tail(before, run, " " <> rest))
        Error(Nil) -> option.Some(split_url_tail(before, text, ""))
      }
    False ->
      case string.pop_grapheme(text) {
        Ok(#(grapheme, rest)) -> take_next_url_scan(rest, before <> grapheme)
        Error(Nil) -> option.None
      }
  }
}

/// A URL run's trailing characters that belong to the prose — the
/// punctuation marks, or a `)` closing no `(` inside the URL — move back
/// out of the link, into the after-text.
fn split_url_tail(
  before: String,
  run: String,
  after: String,
) -> #(String, String, String) {
  let #(url, tail) = trim_url_tail(run)
  #(before, url, tail <> after)
}

/// The URL with its trailing prose characters peeled off, and those
/// characters in their original order.
fn trim_url_tail(url: String) -> #(String, String) {
  case trailing_prose_grapheme(url) {
    Ok(grapheme) -> {
      let #(trimmed, tail) = trim_url_tail(string.drop_end(url, 1))
      #(trimmed, grapheme <> tail)
    }
    Error(Nil) -> #(url, "")
  }
}

/// The URL's final grapheme when it must stay outside the link: one of
/// the punctuation marks, or a `)` without a matching `(` inside the
/// URL.
fn trailing_prose_grapheme(url: String) -> Result(String, Nil) {
  case list.find([".", ",", ";", ":", "!", "?"], string.ends_with(url, _)) {
    Ok(grapheme) -> Ok(grapheme)
    Error(Nil) ->
      case string.ends_with(url, ")") && unbalanced_close_paren(url) {
        True -> Ok(")")
        False -> Error(Nil)
      }
  }
}

/// Whether the URL holds more `)` than `(`.
fn unbalanced_close_paren(url: String) -> Bool {
  { string.split(url, "(") |> list.length }
  < { string.split(url, ")") |> list.length }
}

/// The post's header image: its own featured image from the frontmatter, or
/// the Ninjas logo as the placeholder so both the home page's featured row
/// and the post masthead's cover always render.
pub fn featured_image(post: Post(Nil)) -> String {
  post.featured_image |> option.unwrap("/img/Ninjas.png")
}

/// The newspaper icon that led every post's title before the `icon`
/// frontmatter key existed — the fallback a post without an icon of its
/// own keeps rendering.
const default_post_icon = "/icons/win95/Mailnews8_32x32_4.png"

/// The post's title icon: the frontmatter `icon` value resolved against
/// the site's static icon packs — a bare filename searched in the win95
/// pack and then the macos9 pack, a qualified `win95/…`/`macos9/…` path
/// (a leading `/icons/` is tolerated) resolved as given. An absent,
/// empty, or unknown value falls back to the newspaper icon, so a
/// mistyped name never renders a broken image.
pub fn post_icon_url(post: Post(Nil)) -> String {
  case dict.get(post.extras, "icon") {
    Ok(value) -> resolve_icon(value) |> option.unwrap(default_post_icon)
    Error(Nil) -> default_post_icon
  }
}

/// The resolved `/icons/…` URL for a frontmatter `icon` value: the first
/// of the as-given, win95, and macos9 candidates that names a file under
/// `static/icons`, or no icon when the value is empty, escapes the packs
/// with `..`, or matches no file.
fn resolve_icon(value: String) -> option.Option(String) {
  let value =
    value
    |> string.trim
    |> strip_icons_prefix
  case value != "" && !string.contains(value, "..") {
    False -> option.None
    True ->
      [value, "win95/" <> value, "macos9/" <> value]
      |> list.find(icon_file_exists)
      |> result.map(fn(found) { "/icons/" <> found })
      |> option.from_result
  }
}

/// A tolerated leading `/icons/` — the icon's rendered form — peeled off,
/// so the same resolution accepts both authoring styles.
fn strip_icons_prefix(value: String) -> String {
  case string.starts_with(value, "/icons/") {
    True -> string.drop_start(value, string.length("/icons/"))
    False -> value
  }
}

/// Whether a candidate names a file in the static icon assets — a
/// filesystem error counts as "not found" so the fallback still renders.
fn icon_file_exists(candidate: String) -> Bool {
  case simplifile.is_file("./static/icons/" <> candidate) {
    Ok(True) -> True
    _ -> False
  }
}

/// One posts-list entry: the linked title led by the post's own title
/// icon with its date — shared by the home page's "Más entradas" list
/// and the post page's random-entries list.
pub fn post_item(post: Post(Nil)) -> Element(Nil) {
  html.li([], [
    html.a(
      [attribute.href(post.url)],
      title_with_icon(post_icon_url(post), post.title),
    ),
    html.small([], [element.text(" — " <> format_date(post.date))]),
  ])
}

/// The site-level structured-data block: a BlogPosting describing the
/// site itself, splicing the Spanish site description. Carried unescaped
/// so the JSON parses inside the script element.
const json_ld = "{
  \"@context\": \"https://schema.org\",
  \"@type\": \"BlogPosting\",
  \"headline\": \"Ninjas Chile (Ninjas.cl)\",
  \"description\": \""
  <> site_description
  <> "\",
  \"datePublished\": \"2026-11-21\",
  \"author\": {
    \"@type\": \"Person\",
    \"name\": \"@CLSource\"
  },
  \"image\": [\"https://ninjas.cl/logo_og.png\"],
  \"publisher\": {
    \"@type\": \"Organization\",
    \"name\": \"Ninjas.cl\",
    \"logo\": {
      \"@type\": \"ImageObject\",
      \"url\": \"https://ninjas.cl/img/Ninjas.png\"
    }
  },
  \"mainEntityOfPage\": {
    \"@type\": \"WebPage\",
    \"@id\": \"https://ninjas.cl/\"
  }
}"

/// The structured-data script: the JSON block rendered verbatim —
/// `element.text` would escape the quotes and break the JSON inside the
/// raw-text script element.
fn json_ld_script() -> Element(Nil) {
  element.unsafe_raw_html(
    "",
    "script",
    [attribute.type_("application/ld+json")],
    json_ld,
  )
}

/// The shared page layout every view renders through: the full head suite
/// — identity metas, the OpenGraph/Twitter mirrors, the structured-data
/// block, the fonts, and the stylesheets — around the given body.
pub fn page(
  title title: String,
  description description: String,
  url url: String,
  language language: String,
  og_locale og_locale: String,
  body body: List(Element(Nil)),
) -> Element(Nil) {
  html.html([attribute.lang(language), attribute.data("rs-theme", "cosmic")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1.0"),
      ]),
      html.title([], title),
      html.meta([
        attribute.name("description"),
        attribute.content(description),
      ]),
      html.meta([
        attribute.name("generator"),
        attribute.content("https://github.com/veeso/blogatto"),
      ]),
      html.meta([
        attribute.name("keywords"),
        attribute.content(
          "ninjas, ninja, ninjas chile, software, chile, camilo, castro, chileno, desarrollo, informática, chilena, sistemas, soluciones",
        ),
      ]),
      html.meta([
        attribute.name("robots"),
        attribute.content("index,follow"),
      ]),
      html.meta([
        attribute.name("usage-rights"),
        attribute.content("CC-BY-NC-ND"),
      ]),
      html.link([
        attribute.type_("text/plain"),
        attribute.rel("author"),
        attribute.href("/humans.txt"),
      ]),
      html.link([
        attribute.rel("apple-touch-icon"),
        attribute.sizes("180x180"),
        attribute.href("/apple-touch-icon.png"),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.type_("image/png"),
        attribute.sizes("32x32"),
        attribute.href("/favicon-32x32.png"),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.type_("image/png"),
        attribute.sizes("16x16"),
        attribute.href("/favicon-16x16.png"),
      ]),
      html.link([
        attribute.rel("manifest"),
        attribute.href("/site.webmanifest"),
      ]),
      html.meta([
        attribute.attribute("property", "og:type"),
        attribute.content("website"),
      ]),
      html.meta([
        attribute.attribute("property", "og:url"),
        attribute.content(url),
      ]),
      html.meta([
        attribute.attribute("property", "og:title"),
        attribute.content(title),
      ]),
      html.meta([
        attribute.attribute("property", "og:description"),
        attribute.content(description),
      ]),
      html.meta([
        attribute.attribute("property", "og:image"),
        attribute.content("https://ninjas.cl/logo_og.png"),
      ]),
      html.meta([
        attribute.attribute("property", "og:locale"),
        attribute.content(og_locale),
      ]),
      html.meta([
        attribute.name("twitter:card"),
        attribute.content("summary_large_image"),
      ]),
      html.meta([
        attribute.name("twitter:url"),
        attribute.content(url),
      ]),
      html.meta([
        attribute.name("twitter:title"),
        attribute.content(title),
      ]),
      html.meta([
        attribute.name("twitter:description"),
        attribute.content(description),
      ]),
      html.meta([
        attribute.name("twitter:image"),
        attribute.content("https://ninjas.cl/logo_og.png"),
      ]),
      json_ld_script(),
      // The JetBrains Mono loading trio, per the Google Fonts pattern:
      // warm connections to both font hosts, then the font stylesheet —
      // display=swap, so text never blocks on the font — before the
      // site's own stylesheets.
      html.link([
        attribute.rel("preconnect"),
        attribute.href("https://fonts.googleapis.com"),
      ]),
      html.link([
        attribute.rel("preconnect"),
        attribute.href("https://fonts.gstatic.com"),
        attribute.crossorigin(""),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href(
          "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap",
        ),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/retrostrap.min.css"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/cosmic.css"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/style.css"),
      ]),
      html.script([attribute.src("/background.js")], ""),
    ]),
    html.body([], [
      html.a([attribute.class("rs-skip"), attribute.href("#main")], [
        element.text("Saltar al contenido →"),
      ]),
      html.div(
        [attribute.class("rs-page rs-container rs-container--wide")],
        body,
      ),
    ]),
  ])
}
