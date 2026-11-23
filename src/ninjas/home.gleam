//// The Ninjas.cl home page.
////
//// Everything the home page owns lives in this module — the hero, the
//// marquee, and the about, posts, projects, books, games, and banner-wall
//// sections — in each of the site's languages, so the home page can be
//// modified on its own. The shared chrome it renders through (the page
//// layout, the masthead and navbar, the footer, the icon helpers) stays
//// in `site.gleam`. Every string the page renders travels in a `HomeText`
//// record, one per language: the Spanish original is the reference copy,
//// and the English, Japanese, and Portuguese records translate it.

import blogatto/post.{type Post}
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import site

/// Every string the home page renders in its language: the head fields
/// that declare the page's language — the language code and display
/// name, the html lang value, the og locale, the page's absolute URL and
/// route path, and the translated site description — plus the visible
/// copy: the hero tagline, the marquee, the navbar labels, the section
/// titles and intros, the about paragraphs, the posts-section labels,
/// the showcase button labels, the caption templates with their month
/// names, the options row's label, and the back-to-top label — plus the
/// copyright line's rights clause in the home's language: Spanish on the
/// default home, the English line on the English home, and the Japanese
/// and Portuguese homes' own clauses.
pub type HomeText {
  HomeText(
    code: String,
    name: String,
    lang: String,
    og_locale: String,
    url: String,
    path: String,
    description: String,
    options_label: String,
    nav: site.NavLabels,
    tagline: String,
    marquee: String,
    about_title: String,
    about_p1: String,
    about_p2: String,
    about_p3_open: String,
    about_p3_close: String,
    posts_title: String,
    posts_intro: String,
    featured_heading: String,
    read_button: String,
    more_heading: String,
    view_all_button: String,
    empty_note: String,
    projects_title: String,
    projects_intro: String,
    books_title: String,
    books_intro: String,
    games_title: String,
    games_intro: String,
    view_button: String,
    code_button: String,
    caption_year: String,
    caption_month_year: String,
    month_names: List(String),
    back_to_top: String,
    copyright_rights: String,
  )
}

/// The Spanish home — the site's default language, human-written. The
/// reference copy every other language translates: byte-for-byte the
/// strings the page rendered before the languages split, except the
/// showcase buttons' single-word labels ("Ver", "Código") — the owner's
/// revision of the former bilingual "Ver / View" and "Código / Code".
pub const spanish_text = HomeText(
  code: "es",
  name: "Español",
  lang: "es-CL",
  og_locale: "es_CL",
  url: site.production_url,
  path: "/",
  description: "Ninjas es un grupo desarrollador de software experimental de Chile 🇨🇱. Participa en diversos proyectos tecnológicos, tales como videojuegos, software y otras actividades relacionadas. Ninjas.cl fue fundado en 2015 (¡11 años programando ❤️!) por @CLSource.",
  options_label: "Idiomas",
  nav: site.NavLabels(
    home: "Inicio",
    blog: "Blog",
    about: "Nosotros",
    projects: "Proyectos",
    books: "Libros",
    games: "Juegos",
    aria_label: "Navegación principal",
  ),
  tagline: "Software de 🇨🇱 con ❤️",
  marquee: "★ Bienvenido a Ninjas.cl · software artesanal desde Chile · experimentos, videojuegos y código desde 2015 ★",
  about_title: "Sobre nosotros",
  about_p1: "Ninjas es un grupo experimental de desarrollo de software de Chile 🇨🇱 fundado por @CLSource. Participamos en proyectos de videojuegos, software y otras actividades relacionadas.",
  about_p2: "Nos gusta crear artefactos hermosos y pensados en las personas. Valoramos lo humano en los proyectos tecnológicos.",
  about_p3_open: "Ninjas.cl nació el 2015. Puedes encontrarnos en ",
  about_p3_close: ".",
  posts_title: "Entradas del blog",
  posts_intro: "Un pequeño jardín para registrar nuestros experimentos, ideas y proyectos. De tonterías pasajeras a aplicaciones completas.",
  featured_heading: "Entrada destacada",
  read_button: "Leer entrada",
  more_heading: "Más entradas",
  view_all_button: "Ver Todos",
  empty_note: "Todavía no hay entradas publicadas.",
  projects_title: "Proyectos",
  projects_intro: "Algunos de nuestros proyectos actuales: aplicaciones móviles, comunidades y desarrollo tecnológico.",
  books_title: "Libros",
  books_intro: "Libros que escribimos con la esperanza de que sean útiles. Puedes leerlos en línea de forma gratuita o comprar el PDF para apoyar el contenido.",
  games_title: "Juegos",
  games_intro: "Nos encanta jugar y también hacer juegos. Aquí hay algunos experimentos hechos con distintas tecnologías.",
  view_button: "Ver",
  code_button: "Código",
  caption_year: "Desde {year}",
  caption_month_year: "Desde {month} {year}",
  month_names: [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto",
    "Septiembre", "Octubre", "Noviembre", "Diciembre",
  ],
  back_to_top: "^ volver arriba ^",
  copyright_rights: site.copyright_rights_es,
)

/// The English home — a machine-translation-quality translation of the
/// Spanish reference copy, following the site's convention for
/// translated variants.
pub const english_text = HomeText(
  code: "en",
  name: "English",
  lang: "en",
  og_locale: "en_US",
  url: site.production_url
    <> "en/",
  path: "/en/",
  description: "Ninjas is an experimental software developer group from Chile 🇨🇱. It takes part in various technology projects, such as videogames, software, and other related activities. Ninjas.cl was founded in 2015 (11 years programming ❤️!) by @CLSource.",
  options_label: "Languages",
  nav: site.NavLabels(
    home: "Home",
    blog: "Blog",
    about: "About us",
    projects: "Projects",
    books: "Books",
    games: "Games",
    aria_label: "Main navigation",
  ),
  tagline: "Software from 🇨🇱 with ❤️",
  marquee: "★ Welcome to Ninjas.cl · artisan software from Chile · experiments, videogames and code since 2015 ★",
  about_title: "About us",
  about_p1: "Ninjas is an experimental software development group from Chile 🇨🇱 founded by @CLSource. We take part in videogame, software, and other related projects.",
  about_p2: "We like creating beautiful artifacts designed with people in mind. We value the human side in technology projects.",
  about_p3_open: "Ninjas.cl was born in 2015. You can find us on ",
  about_p3_close: ".",
  posts_title: "Blog posts",
  posts_intro: "A small garden to record our experiments, ideas, and projects. From passing follies to complete applications.",
  featured_heading: "Featured post",
  read_button: "Read post",
  more_heading: "More posts",
  view_all_button: "View all",
  empty_note: "No posts have been published yet.",
  projects_title: "Projects",
  projects_intro: "Some of our current projects: mobile apps, communities, and technology development.",
  books_title: "Books",
  books_intro: "Books we write in the hope they are useful. You can read them online for free or buy the PDF to support the content.",
  games_title: "Games",
  games_intro: "We love playing and also making games. Here are some experiments made with different technologies.",
  view_button: "View",
  code_button: "Code",
  caption_year: "Since {year}",
  caption_month_year: "Since {month} {year}",
  month_names: [
    "January", "February", "March", "April", "May", "June", "July", "August",
    "September", "October", "November", "December",
  ],
  back_to_top: "^ back to top ^",
  copyright_rights: site.copyright_rights_en,
)

/// The Japanese home — a machine-translation-quality translation of the
/// Spanish reference copy, following the site's convention for
/// translated variants.
pub const japanese_text = HomeText(
  code: "ja",
  name: "日本語",
  lang: "ja",
  og_locale: "ja_JP",
  url: site.production_url
    <> "ja/",
  path: "/ja/",
  description: "Ninjasはチリ🇨🇱の実験的なソフトウェア開発グループです。ビデオゲーム、ソフトウェア、その他の関連活動など、さまざまな技術プロジェクトに参加しています。Ninjas.clは2015年に@CLSourceによって設立されました(❤️を込めて11年間プログラミング!)。",
  options_label: "言語",
  nav: site.NavLabels(
    home: "ホーム",
    blog: "ブログ",
    about: "私たちについて",
    projects: "プロジェクト",
    books: "書籍",
    games: "ゲーム",
    aria_label: "メインナビゲーション",
  ),
  tagline: "🇨🇱から ❤️ を込めたソフトウェア",
  marquee: "★ Ninjas.clへようこそ · チリからの職人ソフトウェア · 2015年からの実験、ビデオゲームとコード ★",
  about_title: "私たちについて",
  about_p1: "Ninjasは@CLSourceが設立したチリ🇨🇱の実験的なソフトウェア開発グループです。ビデオゲーム、ソフトウェア、その他の関連プロジェクトに参加しています。",
  about_p2: "美しく、人のことを考えたアーティファクトを作るのが好きです。技術プロジェクトにおいて人間らしさを大切にしています。",
  about_p3_open: "Ninjas.clは2015年に誕生しました。私たちは",
  about_p3_close: "で見つけられます。",
  posts_title: "ブログ記事",
  posts_intro: "私たちの実験、アイデア、プロジェクトを記録する小さな庭。通りすがりの戯れから完全なアプリケーションまで。",
  featured_heading: "注目の記事",
  read_button: "記事を読む",
  more_heading: "他の記事",
  view_all_button: "すべて見る",
  empty_note: "まだ公開された記事はありません。",
  projects_title: "プロジェクト",
  projects_intro: "現在のプロジェクトのいくつか:モバイルアプリ、コミュニティ、技術開発。",
  books_title: "書籍",
  books_intro: "役に立つことを願って書いた本。オンラインで無料で読むことも、コンテンツを支援するためにPDFを購入することもできます。",
  games_title: "ゲーム",
  games_intro: "遊ぶのもゲームを作るのも大好きです。さまざまな技術で作った実験をいくつか紹介します。",
  view_button: "見る",
  code_button: "コード",
  caption_year: "{year}年から",
  caption_month_year: "{year}年{month}から",
  month_names: [
    "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月",
  ],
  back_to_top: "^ 上に戻る ^",
  copyright_rights: "すべての権利と左派を保全",
)

/// The Portuguese home — a machine-translation-quality
/// translation of the Spanish reference copy, following the site's
/// convention for translated variants.
pub const portuguese_text = HomeText(
  code: "pt",
  name: "Português",
  lang: "pt",
  og_locale: "pt_BR",
  url: site.production_url
    <> "pt/",
  path: "/pt/",
  description: "O Ninjas é um grupo desenvolvedor de software experimental do Chile 🇨🇱. Participa de diversos projetos tecnológicos, como videogames, software e outras atividades relacionadas. O Ninjas.cl foi fundado em 2015 (11 anos programando ❤️!) por @CLSource.",
  options_label: "Idiomas",
  nav: site.NavLabels(
    home: "Início",
    blog: "Blog",
    about: "Sobre nós",
    projects: "Projetos",
    books: "Livros",
    games: "Jogos",
    aria_label: "Navegação principal",
  ),
  tagline: "Software do 🇨🇱 com ❤️",
  marquee: "★ Bem-vindo ao Ninjas.cl · software artesanal do Chile · experimentos, videogames e código desde 2015 ★",
  about_title: "Sobre nós",
  about_p1: "O Ninjas é um grupo experimental de desenvolvimento de software do Chile 🇨🇱 fundado por @CLSource. Participamos em projetos de videogames, software e outras atividades relacionadas.",
  about_p2: "Gostamos de criar artefatos bonitos e pensados nas pessoas. Valorizamos o humano nos projetos tecnológicos.",
  about_p3_open: "O Ninjas.cl nasceu em 2015. Você pode nos encontrar no ",
  about_p3_close: ".",
  posts_title: "Postagens do blog",
  posts_intro: "Um pequeno jardim para registrar nossos experimentos, ideias e projetos. De bobagens passageiras a aplicações completas.",
  featured_heading: "Postagem destacada",
  read_button: "Ler entrada",
  more_heading: "Mais entradas",
  view_all_button: "Ver todos",
  empty_note: "Ainda não há postagens publicadas.",
  projects_title: "Projetos",
  projects_intro: "Alguns dos nossos projetos atuais: aplicações móveis, comunidades e desenvolvimento tecnológico.",
  books_title: "Livros",
  books_intro: "Livros que escrevemos com a esperança de que sejam úteis. Você pode lê-los on-line gratuitamente ou comprar o PDF para apoiar o conteúdo.",
  games_title: "Jogos",
  games_intro: "Adoramos jogar e também fazer jogos. Aqui estão alguns experimentos feitos com diferentes tecnologias.",
  view_button: "Ver",
  code_button: "Código",
  caption_year: "Desde {year}",
  caption_month_year: "Desde {month} {year}",
  month_names: [
    "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto",
    "Setembro", "Outubro", "Novembro", "Dezembro",
  ],
  back_to_top: "^ voltar ao topo ^",
  copyright_rights: "Todos os direitos e esquerdos preservados",
)

/// A card used by the projects, books and games showcases on the home
/// page. `icon` is the inline /icons image that leads the title — empty
/// string means the title keeps its own text (like the 🥷 Ninjas.cl
/// card). `description` carries the card's copy in every site language
/// and `started` the date the caption renders per language.
type ShowcaseItem {
  ShowcaseItem(
    title: String,
    icon: String,
    description: CardText,
    image: String,
    image_alt: String,
    started: Started,
    view_url: String,
    code_url: String,
  )
}

/// A showcase card's copy in each site language — the Spanish original
/// beside its translations, so a card's description travels with the
/// card it belongs to instead of a separate translation table.
type CardText {
  CardText(es: String, en: String, ja: String, pt: String)
}

/// The card copy for a page's language: the Spanish original for the
/// default, the language's own translation for a variant.
fn card_text(code: String, text: CardText) -> String {
  case code {
    "en" -> text.en
    "ja" -> text.ja
    "pt" -> text.pt
    _ -> text.es
  }
}

/// When a showcase item started: a month and year, or a bare year —
/// rendered from the page language's caption templates.
type Started {
  Year(Int)
  MonthYear(Int, Int)
}

/// Every retro banner GIF shipped in /static/banners, paired with a short alt
/// describing its message. The banners are readable text art, so they carry
/// meaningful alt even though they render as plain decorative images — no
/// links, per the site owner's choice.
const banners: List(#(String, String)) = [
  #("firefoxget.gif", "Get Firefox"),
  #("getflashplayer.gif", "Get Flash Player"),
  #("getmsgplus.gif", "MSN Messenger Plus!"),
  #("github.gif", "GitHub"),
  #("gnubanner.gif", "GNU's Not Unix"),
  #("hotgraphics.gif", "Hot Graphics"),
  #("hotmail2.gif", "Hotmail"),
  #("htmlval2.gif", "Valid HTML"),
  #("ie4_2.gif", "Internet Explorer 4"),
  #("iframsuc.gif", "iframes"),
  #("linux.gif", "Linux"),
  #("macfriendly.gif", "Mac friendly"),
  #("microsoft_stop.gif", "Microsoft stop"),
  #("mozilla3.gif", "Mozilla"),
  #("netbsd2.gif", "NetBSD"),
  #("netscape-now-1996.gif", "Netscape Now! 1996"),
  #("No-AI-green.gif", "No AI"),
  #("notepad-logo3.gif", "Made with Notepad"),
  #("phpnuke2.gif", "PHP-Nuke"),
  #("proweb_teal.gif", "Proweb"),
  #("rss-button.gif", "RSS"),
  #("sun.gif", "Sun Microsystems"),
  #("ubuntu-88x31.gif", "Ubuntu"),
  #("valid-css.gif", "Valid CSS"),
  #("valid-html20.gif", "Valid HTML 2.0"),
  #("valid-xhtml10-2.gif", "Valid XHTML 1.0"),
  #("w96_button.gif", "Windows 96"),
  #("win95.gif", "Windows 95"),
  #("winamp4.gif", "Winamp"),
  #("winrar4.gif", "WinRAR"),
  #("winxp.gif", "Windows XP"),
  #("winzip3.gif", "WinZip"),
  #("Y2K.gif", "Y2K"),
]

/// Render the home page in the given language: a retro masthead, an
/// introduction, the blog posts, and showcases for the projects, books
/// and games behind Ninjas.cl — every string in the page's language,
/// and the posts listed in it.
pub fn view(text: HomeText, posts: List(Post(Nil))) -> Element(Nil) {
  site.page(
    title: site.site_title,
    description: text.description,
    url: text.url,
    language: text.lang,
    og_locale: text.og_locale,
    body: [
      site.masthead(
        nav: text.nav,
        home_url: text.path,
        on_home: True,
        cover: option.None,
        children: [home_hero(text), marquee(text)],
      ),
      html.main([attribute.id("main")], [
        about_section(text),
        posts_section(text, posts),
        projects_section(text),
        books_section(text),
        games_section(text),
        contact_section(),
      ]),
      site.site_footer(text.copyright_rights, text.back_to_top),
    ],
  )
}

/// The home page hero: logo, site title, description and call-to-action links.
fn home_hero(text: HomeText) -> Element(Nil) {
  html.div([attribute.class("hero rs-panel rs-panel--raised")], [
    html.div([attribute.class("rs-cols-2")], [
      html.div([attribute.class("rs-center")], [
        html.img([
          attribute.class("hero__logo"),
          attribute.src("https://ninjas.cl/img/Ninjas.png"),
          attribute.alt("Logo de Ninjas.cl"),
        ]),
      ]),
      html.div([attribute.class("rs-center")], [
        // The title in the Chilean flag's colors — the 🇨🇱 emoji's blue,
        // white, and red through the same banded-gradient technique as
        // retrostrap's rs-rainbow (see .cl-rainbow in static/style.css).
        html.h1([attribute.class("rs-font-10")], [
          html.span([attribute.class("cl-rainbow")], [
            element.text("忍者 開発者 " <> site.site_title),
          ]),
        ]),
        html.p([attribute.class("rs-font-5")], [
          element.text(text.tagline),
        ]),
      ]),
    ]),
    html.p([attribute.class("rs-note")], [element.text(text.description)]),
    home_language_options(text),
  ])
}

/// The home pages' language options row: every home linked like the
/// posts' options row — the current language plain text marked as the
/// current page, the others linking their home routes — so each home is
/// reachable from the others.
fn home_language_options(current: HomeText) -> Element(Nil) {
  let entries =
    [spanish_text, english_text, japanese_text, portuguese_text]
    |> list.map(fn(text) {
      case text.code == current.code {
        True ->
          html.span([attribute.aria_current("page")], [
            element.text(text.name),
          ])
        False -> html.a([attribute.href(text.path)], [element.text(text.name)])
      }
    })
  html.p([attribute.class("post-languages")], [
    site.icon(site.languages_icon),
    element.text(" " <> current.options_label <> ": "),
    ..site.join_with_sep(entries)
  ])
}

/// The scrolling welcome banner under the home hero.
fn marquee(text: HomeText) -> Element(Nil) {
  html.div(
    [
      attribute.class("rs-marquee"),
      attribute.data("rs-marquee-speed", "normal"),
    ],
    [
      html.span([attribute.class("rs-marquee__content")], [
        element.text(text.marquee),
      ]),
    ],
  )
}

fn about_section(text: HomeText) -> Element(Nil) {
  section(
    "about",
    "/icons/win95/D3FlowerBox100_32x32_4.png",
    text.about_title,
    [],
    [
      html.div([attribute.class("about__cols")], [
        html.figure([attribute.class("rs-figure")], [
          html.img([
            attribute.src("/img/camilo.jpg"),
            attribute.alt("Retrato de @CLSource"),
          ]),
          html.figcaption([attribute.class("rs-figure__caption")], [
            element.text("@CLSource — Software Engineer"),
          ]),
        ]),
        html.div([], [
          html.p([], [element.text(text.about_p1)]),
          html.p([], [element.text(text.about_p2)]),
          html.p([], [
            element.text(text.about_p3_open),
            external_link("https://github.com/ninjascl", "GitHub", ""),
            element.text(text.about_p3_close),
          ]),
        ]),
      ]),
    ],
  )
}

/// The posts in the page's language: the default-language posts on the
/// Spanish home, that language's translated variants on a translated
/// home — every post ships all four, so each home's list matches the
/// catalog. The featured pick and the trimmed random sample draw from
/// this pool, so every post link targets that language's variant URL.
fn language_posts(text: HomeText, posts: List(Post(Nil))) -> List(Post(Nil)) {
  list.filter(posts, fn(post) {
    case text.code {
      "es" -> post.language == option.None
      code -> post.language == option.Some(code)
    }
  })
}

fn posts_section(text: HomeText, posts: List(Post(Nil))) -> Element(Nil) {
  section(
    "posts",
    "/icons/win95/Notepad_32x32_4.png",
    text.posts_title,
    [element.text(" "), site.feed_link(text.code)],
    [
      html.p([], [element.text(text.posts_intro)]),
      post_list(text, language_posts(text, posts)),
    ],
  )
}

fn projects_section(text: HomeText) -> Element(Nil) {
  section("projects", "/icons/win95/Bulb_32x32_4.png", text.projects_title, [], [
    html.p([], [element.text(text.projects_intro)]),
    html.div([attribute.class("rs-cols-2")], [
      showcase_card(
        text,
        ShowcaseItem(
          title: "Elixir Chile 🇨🇱",
          icon: "/icons/win95/Regwiz117_32x32_4.png",
          description: CardText(
            es: "La comunidad chilena del lenguaje Elixir. Documentación, eventos y proyectos de ejemplo para expandir Elixir.",
            en: "The Chilean community of the Elixir language. Documentation, events, and example projects to expand Elixir.",
            ja: "Elixir言語のチリコミュニティ。ドキュメント、イベント、Elixirを広めるためのサンプルプロジェクト。",
            pt: "A comunidade chilena da linguagem Elixir. Documentação, eventos e projetos de exemplo para expandir o Elixir.",
          ),
          image: "/img/elixircl.png",
          image_alt: "Logo de Elixir Chile",
          started: MonthYear(3, 2022),
          view_url: "https://elixircl.github.io",
          code_url: "https://github.com/elixircl/",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "🛸 Jasonelle",
          icon: "",
          description: CardText(
            es: "Un framework pequeño y acogedor para aplicaciones de iOS 🍎 y Android 🤖. Usa un WebView que sirve como puente hacia las funciones nativas del dispositivo.",
            en: "A small and cozy framework for iOS 🍎 and Android 🤖 apps. It uses a WebView that serves as a bridge to the device's native functions.",
            ja: "iOS 🍎 と Android 🤖 アプリのための小さくて快適なフレームワーク。デバイスのネイティブ機能への橋渡しとしてWebViewを使用します。",
            pt: "Um framework pequeno e acolhedor para aplicações de iOS 🍎 e Android 🤖. Usa um WebView que serve como ponte para as funções nativas do dispositivo.",
          ),
          image: "/img/jasonelle.png",
          image_alt: "Logo de Jasonelle",
          started: MonthYear(11, 2018),
          view_url: "https://jasonelle.com",
          code_url: "https://github.com/jasonelle/",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Joy of ProcessWire",
          icon: "/icons/win95/Fastboot101_32x32_4.png",
          description: CardText(
            es: "Un lugar para nuestros experimentos e ideas con el CMS/CMF ProcessWire.",
            en: "A place for our experiments and ideas with the ProcessWire CMS/CMF.",
            ja: "CMS/CMFのProcessWireを使った実験とアイデアの場所。",
            pt: "Um lugar para nossos experimentos e ideias com o CMS/CMF ProcessWire.",
          ),
          image: "/img/joyofpw.png",
          image_alt: "Logo de The Joy of ProcessWire",
          started: MonthYear(2, 2014),
          view_url: "https://joyofpw.github.io/",
          code_url: "https://github.com/joyofpw",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Proyecto Chaucha",
          icon: "/icons/win95/Quartz100_32x32_4.png",
          description: CardText(
            es: "Educamos sobre blockchain y criptomonedas mediante Chaucha y los proyectos que la utilizan.",
            en: "We teach about blockchain and cryptocurrencies through Chaucha and the projects that use it.",
            ja: "Chauchaとそれを利用するプロジェクトを通じて、ブロックチェーンと暗号通貨について学べます。",
            pt: "Educamos sobre blockchain e criptomoedas por meio da Chaucha e dos projetos que a utilizam.",
          ),
          image: "/img/chaucha.png",
          image_alt: "Logo de Proyecto Chaucha",
          started: MonthYear(8, 2017),
          view_url: "https://chaucha.cl/",
          code_url: "https://github.com/proyecto-chaucha/",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "🥷 Ninjas.cl",
          icon: "",
          description: CardText(
            es: "La casa de la locura dev: videojuegos, librerías, sitios y otras rarezas hechas con cariño.",
            en: "The home of dev madness: videogames, libraries, sites, and other oddities made with love.",
            ja: "開発者の狂気の家:ビデオゲーム、ライブラリ、サイト、その他の愛を込めて作られた珍品。",
            pt: "A casa da loucura dev: videogames, bibliotecas, sites e outras raridades feitas com carinho.",
          ),
          image: "/img/Ninjas.png",
          image_alt: "Logo de Ninjas.cl",
          started: Year(2015),
          view_url: "https://ninjas.cl/",
          code_url: "https://github.com/ninjascl",
        ),
      ),
    ]),
  ])
}

fn books_section(text: HomeText) -> Element(Nil) {
  section("books", "/icons/win95/HelpBook_32x32_4.png", text.books_title, [], [
    html.p([], [element.text(text.books_intro)]),
    html.div([attribute.class("rs-cols-2")], [
      showcase_card(
        text,
        ShowcaseItem(
          title: "Conceptos de Sistemas Operativos",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "Un recorrido práctico por los conceptos de sistemas operativos: kernel, procesos, concurrencia, sincronización y sistemas de archivos. Incluye ejemplos en Ada y Elixir y proyectos como un minishell y un servidor de videojuegos.",
            en: "A hands-on tour of operating system concepts: the kernel, processes, concurrency, synchronization, and file systems. Includes Ada and Elixir examples and projects like a minishell and a game server.",
            ja: "カーネル、プロセス、並行処理、同期、ファイルシステムなど、オペレーティングシステムの概念を実践的に解説。AdaとElixirの例題と、ミニシェルやゲームサーバーのプロジェクトも収録。",
            pt: "Um percurso prático pelos conceitos de sistemas operacionais: kernel, processos, concorrência, sincronização e sistemas de arquivos. Inclui exemplos em Ada e Elixir e projetos como um minishell e um servidor de jogos.",
          ),
          image: "/img/niklas-konig-1cTFuvI14J4-unsplash.jpg",
          image_alt: "Foto de Niklas König en Unsplash",
          started: MonthYear(7, 2025),
          view_url: "https://ninjascl.github.io/sistemas-operativos/",
          code_url: "https://github.com/NinjasCL/sistemas-operativos",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Robótica con Elixir",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "Un libro con proyectos entretenidos para realizar con ESP32 y AtomVM.",
            en: "A book with fun projects to build with ESP32 and AtomVM.",
            ja: "ESP32とAtomVMで作れる楽しいプロジェクトが載った本。",
            pt: "Um livro com projetos divertidos para realizar com ESP32 e AtomVM.",
          ),
          image: "/img/emilipothese-FTfjMijq-Ws-unsplash.jpg",
          image_alt: "Foto de Emilipothèse en Unsplash",
          started: MonthYear(4, 2025),
          view_url: "https://elixircl.github.io/elixir-robotics/",
          code_url: "https://github.com/elixircl/elixir-robotics",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Super Club Net",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "Una breve introducción a HTML, CSS y JavaScript con ejemplos de videojuegos de Nintendo 64.",
            en: "A brief introduction to HTML, CSS, and JavaScript with Nintendo 64 videogame examples.",
            ja: "NINTENDO 64のビデオゲームの例を使った、HTML、CSS、JavaScriptの簡単な紹介。",
            pt: "Uma breve introdução a HTML, CSS e JavaScript com exemplos de videogames do Nintendo 64.",
          ),
          image: "/img/superclubnet.jpg",
          image_alt: "Portada de Super Club Net",
          started: MonthYear(6, 2024),
          view_url: "https://ninjas.cl/books/superclubnet/",
          code_url: "https://codeberg.org/ninjas/superclubnet",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Elixir Full Stack",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "Los conceptos necesarios para ser un desarrollador Full-Stack web y móvil con Elixir.",
            en: "The concepts you need to be a Full-Stack web and mobile developer with Elixir.",
            ja: "Elixirでウェブとモバイルのフルスタック開発者になるために必要な概念。",
            pt: "Os conceitos necessários para ser um desenvolvedor Full-Stack web e mobile com Elixir.",
          ),
          image: "/img/elixir-fullstack.jpg",
          image_alt: "Portada de Elixir Full Stack",
          started: MonthYear(3, 2024),
          view_url: "https://ninjas.cl/books/elixir-fullstack/",
          code_url: "https://github.com/elixircl/elixir-fullstack",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Wren Libro",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "El lenguaje orientado a objetos de Bob Nystrom, con proyectos de ejemplo.",
            en: "Bob Nystrom's object-oriented language, with example projects.",
            ja: "Bob Nystromのオブジェクト指向言語とサンプルプロジェクト。",
            pt: "A linguagem orientada a objetos de Bob Nystrom, com projetos de exemplo.",
          ),
          image: "/img/wren-libro.jpg",
          image_alt: "Portada de Wren Libro",
          started: MonthYear(12, 2021),
          view_url: "https://ninjas.cl/books/wren-libro/",
          code_url: "https://github.com/ninjascl/wren-libro",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Las Aventuras de Quirquincho",
          icon: "/icons/win95/Fpeditor128_32x32_4.png",
          description: CardText(
            es: "Un cómic para principiantes que explica cómo funcionan las criptomonedas y el blockchain.",
            en: "A comic for beginners that explains how cryptocurrencies and blockchain work.",
            ja: "暗号通貨とブロックチェーンの仕組みを説明する初心者向けコミック。",
            pt: "Um quadrinho para iniciantes que explica como funcionam as criptomoedas e o blockchain.",
          ),
          image: "/img/quirquincho.jpg",
          image_alt: "Portada de Las Aventuras de Quirquincho",
          started: MonthYear(3, 2018),
          view_url: "https://archive.org/details/quirquincho",
          code_url: "https://github.com/proyecto-chaucha/aventuras-quirquincho",
        ),
      ),
    ]),
  ])
}

fn games_section(text: HomeText) -> Element(Nil) {
  section("games", "/icons/win95/Winmine1_32x32_4.png", text.games_title, [], [
    html.p([], [element.text(text.games_intro)]),
    html.div([attribute.class("rs-cols-2")], [
      showcase_card(
        text,
        ShowcaseItem(
          title: "Rolplay Manual",
          icon: "/icons/win95/Mmsys108_32x32_4.png",
          description: CardText(
            es: "Un manual rescatado del Rolplay de 2002, creado por David (Sevia) en Visual Basic 6.",
            en: "A manual rescued from the 2002 Rolplay, created by David (Sevia) in Visual Basic 6.",
            ja: "David(Sevia)がVisual Basic 6で作成した、2002年のRolplayから救い出されたマニュアル。",
            pt: "Um manual resgatado do Rolplay de 2002, criado por David (Sevia) em Visual Basic 6.",
          ),
          image: "/img/rolplay-manual.png",
          image_alt: "Manual del juego Rolplay",
          started: MonthYear(2, 2024),
          view_url: "https://ninjascl.github.io/rolplus/",
          code_url: "https://github.com/NinjasCL/rolplus",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Profesor Rossa",
          icon: "/icons/win95/Mmsys108_32x32_4.png",
          description: CardText(
            es: "Juega como Profesor Rossa, Guru Guru o Don Carter. Evita el lava y recupera las cintas de video.",
            en: "Play as Profesor Rossa, Guru Guru, or Don Carter. Dodge the lava and recover the video tapes.",
            ja: "プロフェソール・ロッサ、グルグル、またはドン・カーターとしてプレイ。溶岩を避けてビデオテープを取り戻しましょう。",
            pt: "Jogue como Profesor Rossa, Guru Guru ou Don Carter. Evite a lava e recupere as fitas de vídeo.",
          ),
          image: "/img/rossa.gif",
          image_alt: "Captura del juego Profesor Rossa",
          started: MonthYear(3, 2017),
          view_url: "https://www.lexaloffle.com/bbs/?tid=28945",
          code_url: "https://github.com/NinjasCL/rossa",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "¡Qué Chaucha!",
          icon: "/icons/win95/Mmsys108_32x32_4.png",
          description: CardText(
            es: "Aprende blockchain respondiendo preguntas y ayudando a Quirquincho a ganar Chauchas.",
            en: "Learn blockchain by answering questions and helping Quirquincho earn Chauchas.",
            ja: "質問に答えてキルキンチョがチャウチャを獲得するのを助けながら、ブロックチェーンを学びましょう。",
            pt: "Aprenda blockchain respondendo perguntas e ajudando o Quirquincho a ganhar Chauchas.",
          ),
          image: "/img/quechaucha.jpg",
          image_alt: "Pantalla de ¡Qué Chaucha!",
          started: MonthYear(3, 2018),
          view_url: "https://proyecto-chaucha.github.io/quechaucha/",
          code_url: "https://github.com/proyecto-chaucha/quechaucha",
        ),
      ),
      showcase_card(
        text,
        ShowcaseItem(
          title: "Munsta Jump!",
          icon: "/icons/win95/Mmsys108_32x32_4.png",
          description: CardText(
            es: "Un simple juego de saltos monstruosos hecho con Dome Engine para DomeJam 2020.",
            en: "A simple monstrous jumping game made with Dome Engine for DomeJam 2020.",
            ja: "DomeJam 2020のためにDome Engineで作られたシンプルな怪物ジャンプゲーム。",
            pt: "Um simples jogo de saltos monstruosos feito com Dome Engine para o DomeJam 2020.",
          ),
          image: "/img/munstajump.gif",
          image_alt: "Captura del juego Munsta Jump!",
          started: MonthYear(3, 2020),
          view_url: "https://clsource.itch.io/munsta-jump",
          code_url: "https://github.com/NinjasCL/munstajump",
        ),
      ),
    ]),
  ])
}

/// The banner wall that fills the untitled panel at #contact — the former
/// Contacto section, stripped of its title and its navbar link. The wall is
/// the panel's entire body: every shipped banner as a plain, lazy-loaded img
/// with no anchor, caption, or other control. The #contact anchor stays so
/// external deep links keep resolving, though no site navigation targets it.
fn contact_section() -> Element(Nil) {
  html.section([attribute.id("contact"), attribute.class("rs-panel")], [
    html.div([attribute.class("banner-wall")], list.map(banners, banner_img)),
  ])
}

/// One banner image: served from the site's own /banners assets, with its
/// descriptive alt, lazy-loaded since the wall sits at the page bottom.
fn banner_img(banner: #(String, String)) -> Element(Nil) {
  let #(filename, alt) = banner
  html.img([
    attribute.src("/banners/" <> filename),
    attribute.alt(alt),
    attribute.loading("lazy"),
  ])
}

/// A titled retrostrap panel used by each home page section, its title
/// led by the section's matching inline icon and followed by any extra
/// header elements, such as the posts section's feed link.
fn section(
  id id: String,
  icon icon: String,
  title title: String,
  header_extra header_extra: List(Element(Nil)),
  children children: List(Element(Nil)),
) -> Element(Nil) {
  html.section([attribute.id(id), attribute.class("rs-panel")], [
    html.h2(
      [attribute.class("rs-panel__title")],
      list.append(site.title_with_icon(icon, title), header_extra),
    ),
    html.div([], children),
  ])
}

/// A showcase card following the Sobre nosotros structure: the figure
/// fills a left column at natural proportions and the text fills the right
/// one, sharing one row that collapses below the vga breakpoint. Used by
/// every showcase card — proyectos, libros and juegos — its copy, caption,
/// and buttons rendered in the page's language.
fn showcase_card(text: HomeText, item: ShowcaseItem) -> Element(Nil) {
  html.article([attribute.class("rs-panel")], [
    html.div([attribute.class("showcase__cols")], [
      html.figure([attribute.class("rs-figure")], [
        html.img([
          attribute.src(item.image),
          attribute.alt(item.image_alt),
          attribute.loading("lazy"),
        ]),
        html.figcaption([attribute.class("rs-figure__caption")], [
          element.text(started_caption(text, item.started)),
        ]),
      ]),
      html.div([], [
        html.h3([], site.title_with_icon(item.icon, item.title)),
        html.p([], [element.text(card_text(text.code, item.description))]),
        html.p([], [
          external_button(
            item.view_url,
            text.view_button,
            "/icons/win95/Shdocvw257_32x32_8.png",
          ),
          external_button(
            item.code_url,
            text.code_button,
            "/icons/win95/Wscript100_32x32_4.png",
          ),
        ]),
      ]),
    ]),
  ])
}

/// A card's "since" caption in the page's language: the year-only or
/// month-and-year template with its placeholders filled — "Desde Marzo
/// 2022", "Since March 2022", "2022年3月から", "Desde Março 2022".
fn started_caption(text: HomeText, started: Started) -> String {
  case started {
    Year(year) ->
      text.caption_year
      |> string.replace("{year}", int.to_string(year))
    MonthYear(month, year) ->
      text.caption_month_year
      |> string.replace("{month}", month_name(text, month))
      |> string.replace("{year}", int.to_string(year))
  }
}

/// The month's name in the page's language, from its month-name list.
fn month_name(text: HomeText, month: Int) -> String {
  case list.drop(text.month_names, month - 1) {
    [name, ..] -> name
    [] -> ""
  }
}

fn external_link(
  url: String,
  label: String,
  icon_path: String,
) -> Element(Nil) {
  html.a(
    [attribute.href(url), attribute.target("_blank"), attribute.rel("noopener")],
    site.title_with_icon(icon_path, label),
  )
}

/// A showcase card action button: an enlarged retrostrap icon-button —
/// `rs-btn--icon` flexes the matching /icons icon beside the label.
fn external_button(url: String, label: String, icon: String) -> Element(Nil) {
  html.a(
    [
      attribute.class("rs-btn rs-btn--icon rs-btn--large"),
      attribute.href(url),
      attribute.target("_blank"),
      attribute.rel("noopener"),
    ],
    [
      html.img([attribute.src(icon), attribute.alt("")]),
      element.text(label),
    ],
  )
}

/// The posts section's list: one entry featured and the rest listed.
/// The featured entry is a build-time random pick among the page
/// language's posts — the same `rand`-powered shuffle the post pages'
/// random-entries list uses, so every build spotlights a fresh post —
/// and "Más entradas" lists up to ten of the remaining entries, a
/// fresh random sample each build.
fn post_list(text: HomeText, posts: List(Post(Nil))) -> Element(Nil) {
  case list.first(site.shuffle(posts)) {
    Error(Nil) ->
      html.p([attribute.class("rs-note")], [element.text(text.empty_note)])
    Ok(featured) ->
      html.div([], [
        html.h3(
          [],
          site.title_with_icon(
            "/icons/win95/Star_32x32_4.png",
            text.featured_heading,
          ),
        ),
        featured_post(text, featured),
        more_posts(
          text,
          list.filter(posts, fn(post) { post.slug != featured.slug }),
        ),
      ])
  }
}

/// The featured post follows the Sobre nosotros structure: its figure
/// fills a left column (the post's featured image, or the Ninjas logo
/// placeholder) at natural proportions, with the text and the large
/// icon-button on the right. The title link leads with the post's own
/// title icon and the date with the calendar icon.
fn featured_post(text: HomeText, post: Post(Nil)) -> Element(Nil) {
  let date = site.format_date(post.date)
  html.article([attribute.class("rs-panel rs-panel--sunken")], [
    html.div([attribute.class("post__cols")], [
      html.figure([attribute.class("rs-figure")], [
        html.img([
          attribute.src(site.featured_image(post)),
          attribute.alt("Imagen destacada de " <> post.title),
        ]),
      ]),
      html.div([], [
        html.h3([], [
          html.a(
            [attribute.href(post.url)],
            site.title_with_icon(site.post_icon_url(post), post.title),
          ),
        ]),
        html.p([attribute.class("post-meta")], [
          site.icon("/icons/win95/Timedate_32x32_4.png"),
          element.text(" "),
          html.time([attribute.datetime(date)], [element.text(date)]),
        ]),
        html.p([], site.linkified_text(post.description)),
        html.a(
          [
            attribute.class("rs-btn rs-btn--icon rs-btn--large"),
            attribute.href(post.url),
          ],
          site.title_with_icon(
            "/icons/win95/Progman25_32x32_4.png",
            text.read_button,
          ),
        ),
      ]),
    ]),
  ])
}

/// The "Más entradas" remainder: up to ten of the entries left after
/// the featured one — a fresh random sample at each build, the same
/// `rand`-powered shuffle the featured pick uses — in the compact star
/// list, with the heading led by the stack-of-documents icon. The
/// view-all button follows whenever the list renders, linking the blog
/// index — the full catalog stays one click away, trimmed or not.
fn more_posts(text: HomeText, posts: List(Post(Nil))) -> Element(Nil) {
  case posts {
    [] -> html.div([], [])
    _ ->
      html.div([], [
        html.h3(
          [],
          site.title_with_icon(
            "/icons/win95/Files_32x32_4.png",
            text.more_heading,
          ),
        ),
        html.ul(
          [attribute.class("rs-list rs-list--stars")],
          site.shuffle(posts)
            |> list.take(10)
            |> list.map(site.post_item),
        ),
        html.a(
          [
            attribute.class("rs-btn rs-btn--icon rs-btn--large"),
            attribute.href("/blog"),
          ],
          site.title_with_icon(
            "/icons/win95/Shdocvw257_32x32_8.png",
            text.view_all_button,
          ),
        ),
      ])
  }
}
