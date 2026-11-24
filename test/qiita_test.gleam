import gleam/http
import gleam/list
import gleam/option
import gleam/string
import qiita
import simplifile

const sample_source = "---\ntitle: \"Prueba \\\"Qiita\\\"\"\nslug: prueba-qiita\ndate: 2026-11-16 00:00:00 -03:00\ntags: gleam, ninjas.cl\n---\n\n## *Título* con _énfasis_\n\nTexto con `código_con_guion` y valor_como_este y 2 * 3.\n\n```go {summary=\"Mostrar solución\"}\npackage main\n```\n\n![Portada](/blog/prueba-qiita/cover-1280x720.png)\n"

fn source_with_date(date: String) -> String {
  string.replace(sample_source, "2026-11-16 00:00:00 -03:00", date)
}

fn create_post(root: String, slug: String, date: String) -> String {
  let directory = root <> "/" <> slug
  let assert Ok(Nil) = simplifile.create_directory_all(directory)
  let assert Ok(Nil) =
    simplifile.write(directory <> "/index-ja.djot", source_with_date(date))
  directory
}

pub fn qiita_metadata_is_read_from_the_japanese_source_test() {
  let assert Ok(metadata) = qiita.parse_metadata("index-ja.djot", sample_source)

  assert metadata.title == "Prueba \"Qiita\""
  assert metadata.slug == "prueba-qiita"
  assert metadata.last_updated_at == "2026-11-16T03:00:00Z"
  assert metadata.tags == ["gleam", "ninjas.cl"]
}

pub fn qiita_metadata_defaults_the_date_to_utc_test() {
  let source =
    "---\ntitle: Sin zona\ndate: 2025-01-15 00:00:00\nslug: sin-zona\n---\n\nHola\n"
  let assert Ok(metadata) = qiita.parse_metadata("index-ja.djot", source)

  assert metadata.last_updated_at == "2025-01-15T00:00:00Z"
  assert metadata.tags == ["ninjas.cl"]
}

pub fn qiita_rejects_a_source_without_frontmatter_test() {
  assert qiita.parse_metadata("index-ja.djot", "# Sin frontmatter")
    == Error(qiita.MissingFrontmatter("index-ja.djot"))
}

pub fn qiita_command_defaults_to_generating_the_latest_post_test() {
  assert qiita.parse_command([]) == Ok(qiita.Run(qiita.Generate, qiita.Latest))
}

pub fn qiita_command_accepts_generate_as_an_explicit_mode_test() {
  assert qiita.parse_command(["--generate"])
    == Ok(qiita.Run(qiita.Generate, qiita.Latest))
  assert qiita.parse_command(["--generate", "mi-entrada"])
    == Ok(qiita.Run(qiita.Generate, qiita.Selected("mi-entrada")))
}

pub fn qiita_command_accepts_a_single_post_test() {
  assert qiita.parse_command(["mi-entrada"])
    == Ok(qiita.Run(qiita.Generate, qiita.Selected("mi-entrada")))
}

pub fn qiita_command_accepts_the_catalog_option_test() {
  assert qiita.parse_command(["--all"])
    == Ok(qiita.Run(qiita.Generate, qiita.All))
}

pub fn qiita_command_accepts_publication_as_a_separate_mode_test() {
  assert qiita.parse_command(["--publish"])
    == Ok(qiita.Run(qiita.Publish, qiita.Latest))
  assert qiita.parse_command(["--publish", "--all"])
    == Ok(qiita.Run(qiita.Publish, qiita.All))
}

pub fn qiita_command_rejects_conflicting_modes_test() {
  let assert Error(qiita.InvalidArguments(reason)) =
    qiita.parse_command(["--generate", "--publish"])

  assert reason == "Choose either generation or publication, not both"
}

pub fn qiita_command_rejects_unknown_options_test() {
  let assert Error(qiita.InvalidArguments(reason)) =
    qiita.parse_command(["--nope"])

  assert reason == "Unknown option: --nope"
}

pub fn qiita_command_rejects_the_removed_dry_run_option_test() {
  let assert Error(qiita.InvalidArguments(reason)) =
    qiita.parse_command(["--dry-run"])

  assert reason == "Unknown option: --dry-run"
}

pub fn qiita_djot_emphasis_becomes_markdown_test() {
  let markdown = qiita.djot_to_markdown("*Negrita* y _cursiva_.")

  assert markdown == "**Negrita** y *cursiva*."
}

pub fn qiita_djot_leaves_code_spans_and_identifiers_alone_test() {
  let markdown =
    qiita.djot_to_markdown(
      "`codigo_con_guion` y valor_como_este y 2 * 3 y **ya_markdown**.",
    )

  assert markdown
    == "`codigo_con_guion` y valor_como_este y 2 * 3 y **ya_markdown**."
}

pub fn qiita_djot_converts_next_to_japanese_text_test() {
  let markdown = qiita.djot_to_markdown("しばらくぶりに、*Ninjas.cl* は再び。これは*重要*です。")

  assert markdown == "しばらくぶりに、**Ninjas.cl** は再び。これは**重要**です。"
}

pub fn qiita_djot_drops_fence_attributes_test() {
  let markdown =
    qiita.djot_to_markdown(
      "```go {summary=\"Mostrar solución\"}\npackage main\n```",
    )

  assert markdown == "```go\npackage main\n```"
}

pub fn qiita_source_to_toml_carries_both_field_sets_test() {
  let assert Ok(content) =
    qiita.source_to_toml("./blog/prueba-qiita/index-ja.djot", sample_source)

  // Qiita item fields: the API expects these names verbatim.
  assert content |> string.contains("title = \"Prueba \\\"Qiita\\\"\"")
  assert content |> string.contains("private = true")
  assert content |> string.contains("tweet = false")
  assert content |> string.contains("coediting = false")
  assert content |> string.contains("slide = false")
  assert content |> string.contains("group_url_name = \"\"\n")
  assert content |> string.contains("organization_url_name = \"\"\n")
  assert content |> string.contains("posting_campaign_uuid = \"\"\n")
  assert content |> string.contains("agreed_posting_campaign_term = false\n")
  assert content |> string.contains("qiita_item_id = \"\"\n")
  assert content
    |> string.contains(
      "tags = [{ name = \"gleam\", versions = [] }, { name = \"ninjas.cl\", versions = [] }]",
    )
  // Tracking fields for this site's publisher flow.
  assert content |> string.contains("language = \"ja\"")
  assert content
    |> string.contains("last_updated_at = \"2026-11-16T03:00:00Z\"")
  assert content |> string.contains("slug = \"prueba-qiita\"")
  assert content
    |> string.contains(
      "source_url = \"https://ninjas.cl/blog/ja/prueba-qiita/\"",
    )
  // The body is Markdown, not djot, and site-root paths are absolute.
  assert content |> string.contains("## **Título** con *énfasis*")
  assert content |> string.contains("```go\n")
  assert string.contains(content, "{summary=") == False
  assert content
    |> string.contains(
      "![Portada](https://ninjas.cl/blog/prueba-qiita/cover-1280x720.png)",
    )
}

pub fn qiita_toml_escapes_the_body_string_test() {
  let source =
    "---\ntitle: Comillas\ndate: 2026-01-01 00:00:00 +00:00\nslug: comillas\n---\n\nDice \"hola\" y usa \\backslash.\n"
  let assert Ok(content) = qiita.source_to_toml("index-ja.djot", source)

  assert content |> string.contains("Dice \\\"hola\\\" y usa \\\\backslash.")
}

pub fn qiita_publisher_toml_is_parsed_for_publication_test() {
  let assert Ok(content) =
    qiita.source_to_toml("./blog/prueba-qiita/index-ja.djot", sample_source)
  let assert Ok(item) = qiita.parse_publisher_toml(content)

  assert item.title == "Prueba \"Qiita\""
  assert item.body |> string.contains("## **Título** con *énfasis*")
  assert item.tags |> list.length == 2
  assert item.private
  assert item.item_id == option.None
}

pub fn qiita_publish_request_creates_a_new_item_test() {
  let assert Ok(content) =
    qiita.source_to_toml("./blog/prueba-qiita/index-ja.djot", sample_source)
  let assert Ok(item) = qiita.parse_publisher_toml(content)
  let assert Ok(request) = qiita.publish_request(item, "secret-token")

  assert request.method == http.Post
  assert request.url == "https://qiita.com/api/v2/items"
  assert request.body |> string.contains("\"private\":true")
  assert request.body |> string.contains("\"tweet\":false")
  assert request.body |> string.contains("\"coediting\":false")
  assert request.body |> string.contains("\"slide\":false")
  assert request.body
    |> string.contains("\"agreed_posting_campaign_term\":false")
  assert request.body
    |> string.contains("\"tags\":[{\"name\":\"gleam\",\"versions\":[]}")
  assert request.body |> string.contains("\"language\"") == False
  assert request.body |> string.contains("\"qiita_item_id\"") == False
}

pub fn qiita_publish_request_updates_an_existing_item_test() {
  let assert Ok(content) =
    qiita.source_to_toml("./blog/prueba-qiita/index-ja.djot", sample_source)
  let with_id =
    string.replace(
      content,
      "qiita_item_id = \"\"",
      "qiita_item_id = \"abc123\"",
    )
  let assert Ok(item) = qiita.parse_publisher_toml(with_id)
  let assert Ok(request) = qiita.publish_request(item, "secret-token")

  assert request.method == http.Patch
  assert request.url == "https://qiita.com/api/v2/items/abc123"
}

pub fn qiita_publish_request_requires_a_token_test() {
  let assert Ok(content) =
    qiita.source_to_toml("./blog/prueba-qiita/index-ja.djot", sample_source)
  let assert Ok(item) = qiita.parse_publisher_toml(content)

  assert qiita.publish_request(item, "") == Error(qiita.MissingToken)
}

pub fn qiita_dotenv_entries_are_parsed_test() {
  let dotenv =
    "# comment\nFTP_USER=ninjas\nexport QIITA_TOKEN=\"secret-token\"\nOTHER=value\n"

  assert qiita.dotenv_value(dotenv, "QIITA_TOKEN")
    == option.Some("secret-token")
  assert qiita.dotenv_value(dotenv, "OTHER") == option.Some("value")
  assert qiita.dotenv_value(dotenv, "MISSING") == option.None
}

pub fn qiita_token_prefers_dotenv_over_the_environment_test() {
  assert qiita.token_from_sources("QIITA_TOKEN=dotenv-token\n", "env-token")
    == Ok("dotenv-token")
  assert qiita.token_from_sources("QIITA_TOKEN=\n", "env-token")
    == Ok("env-token")
  assert qiita.token_from_sources("", "env-token") == Ok("env-token")
  assert qiita.token_from_sources("", "") == Error(qiita.MissingToken)
}

pub fn qiita_publish_response_yields_the_item_id_test() {
  assert qiita.item_id_from_response("{\"id\":\"c686397e4a0f4f11683d\"}")
    == Ok("c686397e4a0f4f11683d")
}

pub fn qiita_item_id_is_stored_once_test() {
  let original = "title = \"x\"\nqiita_item_id = \"\"\n"
  let stored = qiita.apply_item_id(original, option.None, "abc123")

  assert string.contains(stored, "qiita_item_id = \"abc123\"")
  assert qiita.apply_item_id(stored, option.Some("abc123"), "other") == stored
  assert string.contains(
    qiita.apply_item_id("title = \"x\"\n", option.None, "abc123"),
    "qiita_item_id = \"abc123\"",
  )
}

pub fn qiita_export_all_writes_one_file_per_japanese_post_test() {
  let root = "./build/qiita-test-all"
  let _ = simplifile.delete(root)
  let first = create_post(root, "una-entrada", "2026-11-16 00:00:00 -03:00")
  let second = create_post(root, "otra-entrada", "2025-01-15 00:00:00 +00:00")

  let assert Ok(2) = qiita.generate(root, qiita.All)
  let assert Ok(True) = simplifile.is_file(first <> "/qiita.toml")
  let assert Ok(True) = simplifile.is_file(second <> "/qiita.toml")

  let assert Ok(Nil) = simplifile.delete(root)
  Nil
}

pub fn qiita_export_selected_writes_only_that_post_test() {
  let root = "./build/qiita-test-selected"
  let _ = simplifile.delete(root)
  let first = create_post(root, "una-entrada", "2026-11-16 00:00:00 -03:00")
  let second = create_post(root, "otra-entrada", "2025-01-15 00:00:00 +00:00")

  let assert Ok(1) = qiita.generate(root, qiita.Selected("una-entrada"))
  let assert Ok(True) = simplifile.is_file(first <> "/qiita.toml")
  let assert Ok(False) = simplifile.is_file(second <> "/qiita.toml")

  let assert Ok(Nil) = simplifile.delete(root)
  Nil
}

pub fn qiita_export_selected_accepts_a_source_path_test() {
  let root = "./build/qiita-test-path"
  let _ = simplifile.delete(root)
  let post = create_post(root, "una-entrada", "2026-11-16 00:00:00 -03:00")

  let assert Ok(1) =
    qiita.generate(root, qiita.Selected("una-entrada/index-ja.djot"))
  let assert Ok(True) = simplifile.is_file(post <> "/qiita.toml")

  let assert Ok(Nil) = simplifile.delete(root)
  Nil
}

pub fn qiita_export_without_a_selection_uses_the_latest_post_test() {
  let root = "./build/qiita-test-latest"
  let _ = simplifile.delete(root)
  let older = create_post(root, "antigua", "2020-01-01 00:00:00 +00:00")
  let newer = create_post(root, "reciente", "2026-11-16 00:00:00 -03:00")

  let assert Ok(1) = qiita.generate(root, qiita.Latest)
  let assert Ok(False) = simplifile.is_file(older <> "/qiita.toml")
  let assert Ok(True) = simplifile.is_file(newer <> "/qiita.toml")

  let assert Ok(Nil) = simplifile.delete(root)
  Nil
}

pub fn qiita_export_reports_a_missing_post_test() {
  let root = "./build/qiita-test-missing"
  let _ = simplifile.delete(root)
  let assert Ok(Nil) = simplifile.create_directory_all(root)

  assert qiita.generate(root, qiita.Selected("no-existe"))
    == Error(qiita.PostNotFound(root <> "/no-existe"))

  let assert Ok(Nil) = simplifile.delete(root)
  Nil
}
