//// Qiita publisher export for the Ninjas.cl blog.
////
//// Generation and publication are separate modes. By default (also selected
//// with `--generate`) the command only writes `qiita.toml` beside the Japanese
//// source of the most recently updated post. Pass a post slug to select one
//// post, `--all` for the whole catalog, or `--publish` to send the generated
//// file to Qiita. Publication reads `QIITA_TOKEN` from `.env` and creates a
//// new item unless the TOML already has a `qiita_item_id`, in which case it
//// updates that item.

import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import simplifile
import site
import tom

pub type Error {
  CouldNotListBlog(reason: simplifile.FileError)
  CouldNotRead(path: String, reason: simplifile.FileError)
  CouldNotWrite(path: String, reason: simplifile.FileError)
  MissingFrontmatter(path: String)
  MissingField(path: String, field: String)
  InvalidDate(path: String, raw: String)
  InvalidArguments(reason: String)
  PostNotFound(directory: String)
  NoJapanesePosts(directory: String)
  QiitaFileNotFound(path: String)
  InvalidQiitaFile(path: String, reason: String)
  MissingToken
  InvalidRequestUrl(reason: String)
  RequestFailed(reason: String)
  QiitaRejected(status: Int, body: String)
  InvalidQiitaResponse(reason: String)
}

/// What the command was asked to do.
pub type Command {
  Run(action: Action, selection: Selection)
  Help
}

/// Generation only writes the local file; publication sends it to Qiita.
pub type Action {
  Generate
  Publish
}

/// A single post, the latest post, or the whole catalog.
pub type Selection {
  Latest
  Selected(post: String)
  All
}

/// A `qiita.toml` file loaded for publication.
type PublisherFile {
  PublisherFile(directory: String, path: String, content: String)
}

/// The Qiita item represented by a generated `qiita.toml` file.
pub type PublisherItem {
  PublisherItem(
    title: String,
    body: String,
    tags: List(PublisherTag),
    private: Bool,
    tweet: Bool,
    coediting: Bool,
    slide: Bool,
    group_url_name: Option(String),
    organization_url_name: Option(String),
    posting_campaign_uuid: Option(String),
    agreed_posting_campaign_term: Bool,
    item_id: Option(String),
  )
}

pub type PublisherTag {
  PublisherTag(name: String, versions: List(String))
}

/// The HTTP call made for one item. Keeping it as data makes publication
/// testable without contacting Qiita.
pub type PublishRequest {
  PublishRequest(method: http.Method, url: String, body: String)
}

/// The frontmatter fields needed to publish one Japanese post variant.
pub type Metadata {
  Metadata(
    title: String,
    slug: String,
    last_updated_at: String,
    tags: List(String),
  )
}

/// A post that has a Japanese source, kept together so selecting and writing
/// never has to read the same file twice.
type Candidate {
  Candidate(
    directory: String,
    source_path: String,
    source: String,
    metadata: Metadata,
  )
}

/// Internal record for a matched emphasis or strong delimiter pair.
type DelimiterMatch {
  DelimiterMatch(
    position: Int,
    delimiter: String,
    before: String,
    inner: String,
    after: String,
  )
}

/// Gleam strings are binaries, while Erlang's argument list and `os:getenv/1`
/// return charlists. The shim converts them at the boundary so this module
/// stays in Gleam.
@external(erlang, "qiita_ffi", "arguments")
fn command_line_arguments() -> List(String)

@external(erlang, "qiita_ffi", "environment")
fn environment(name: String) -> String

pub fn main() -> Nil {
  case command_line_arguments() |> parse_command {
    Ok(Help) -> print_usage()
    Ok(Run(action, selection)) ->
      case run("./blog", action, selection) {
        Ok(count) -> io.println(describe_success(action, count))
        Error(error) -> report_error(error)
      }
    Error(error) -> {
      report_error(error)
      print_usage()
    }
  }
}

fn describe_success(action: Action, count: Int) -> String {
  case action {
    Generate -> "Wrote " <> int.to_string(count) <> " qiita.toml file(s)."
    Publish -> "Published " <> int.to_string(count) <> " Qiita item(s)."
  }
}

fn report_error(error: Error) -> Nil {
  io.println("Qiita command failed: " <> describe_error(error))
}

fn print_usage() -> Nil {
  io.println(
    "Usage: gleam run -m qiita [OPTIONS] [POST]\n"
    <> "\n"
    <> "  POST       Generate one post by slug or path (defaults to the latest)\n"
    <> "  --generate Generate only; never call Qiita (the default)\n"
    <> "  --publish  Send the generated qiita.toml to Qiita\n"
    <> "  --all      Apply the selected mode to the whole catalog\n"
    <> "  --help     Show this message\n"
    <> "\n"
    <> "Publication reads QIITA_TOKEN from .env, or from the environment when the\n"
    <> "file has no token. Use `--` before any option so Gleam passes it to the\n"
    <> "command, e.g. `... -- --publish --all`.",
  )
}

type ParsedCommand {
  ParsedCommand(action: Option(Action), selection: Option(String), all: Bool)
}

/// Parse the command line into an explicit action. Generation is the default;
/// publication is always opt-in. With no post argument the command uses the
/// most recent post, and the catalog is only used with `--all`.
pub fn parse_command(arguments: List(String)) -> Result(Command, Error) {
  do_parse_command(
    arguments,
    ParsedCommand(action: option.None, selection: option.None, all: False),
  )
}

fn do_parse_command(
  arguments: List(String),
  parsed: ParsedCommand,
) -> Result(Command, Error) {
  case arguments {
    [] -> finish_command(parsed)
    ["--help", ..] | ["-h", ..] -> Ok(Help)
    ["--generate", ..rest] -> choose_action_and_continue(rest, parsed, Generate)
    ["--publish", ..rest] -> choose_action_and_continue(rest, parsed, Publish)
    ["--all", ..rest] ->
      do_parse_command(rest, ParsedCommand(..parsed, all: True))
    [argument, ..rest] ->
      case string.starts_with(argument, "-") {
        True -> Error(InvalidArguments("Unknown option: " <> argument))
        False ->
          case string.trim(argument) == "" {
            True -> Error(InvalidArguments("Post cannot be empty"))
            False ->
              case choose_selection(parsed.selection, argument) {
                Ok(selection) ->
                  do_parse_command(
                    rest,
                    ParsedCommand(..parsed, selection: selection),
                  )
                Error(error) -> Error(error)
              }
          }
      }
  }
}

fn choose_action_and_continue(
  rest: List(String),
  parsed: ParsedCommand,
  next: Action,
) -> Result(Command, Error) {
  case choose_action(parsed.action, next) {
    Ok(action) ->
      do_parse_command(rest, ParsedCommand(..parsed, action: action))
    Error(error) -> Error(error)
  }
}

fn finish_command(parsed: ParsedCommand) -> Result(Command, Error) {
  let action = case parsed.action {
    option.Some(action) -> action
    option.None -> Generate
  }
  case parsed.all, parsed.selection {
    True, option.None -> Ok(Run(action, All))
    False, option.Some(post) -> Ok(Run(action, Selected(post)))
    False, option.None -> Ok(Run(action, Latest))
    True, option.Some(_) ->
      Error(InvalidArguments("Choose a post or --all, not both"))
  }
}

fn choose_action(
  current: Option(Action),
  next: Action,
) -> Result(Option(Action), Error) {
  case current {
    option.None -> Ok(option.Some(next))
    option.Some(existing) if existing == next -> Ok(current)
    option.Some(_) ->
      Error(InvalidArguments(
        "Choose either generation or publication, not both",
      ))
  }
}

fn choose_selection(
  current: Option(String),
  post: String,
) -> Result(Option(String), Error) {
  case current {
    option.None -> Ok(option.Some(post))
    option.Some(_) -> Error(InvalidArguments("Only one post can be selected"))
  }
}

pub fn describe_error(error: Error) -> String {
  case error {
    CouldNotListBlog(reason) ->
      "Could not list the blog directory: " <> simplifile.describe_error(reason)
    CouldNotRead(path, reason) ->
      "Could not read " <> path <> ": " <> simplifile.describe_error(reason)
    CouldNotWrite(path, reason) ->
      "Could not write " <> path <> ": " <> simplifile.describe_error(reason)
    MissingFrontmatter(path) -> path <> " has no frontmatter block"
    MissingField(path, field) -> path <> " is missing " <> field
    InvalidDate(path, raw) -> path <> " has an invalid date: " <> raw
    InvalidArguments(reason) -> reason
    PostNotFound(directory) -> "No Japanese post found at " <> directory
    NoJapanesePosts(directory) ->
      "No post with a Japanese source found in " <> directory
    QiitaFileNotFound(path) -> "No qiita.toml found at " <> path
    InvalidQiitaFile(path, reason) -> path <> " is invalid: " <> reason
    MissingToken -> "QIITA_TOKEN is missing from .env and the environment"
    InvalidRequestUrl(reason) -> "Invalid Qiita endpoint: " <> reason
    RequestFailed(reason) -> "Qiita request failed: " <> reason
    QiitaRejected(status, body) ->
      "Qiita rejected the item with HTTP "
      <> int.to_string(status)
      <> ": "
      <> body
    InvalidQiitaResponse(reason) ->
      "Qiita returned an unexpected response: " <> reason
  }
}

/// Dispatch to the selected mode. Generation never touches the network.
pub fn run(
  blog_directory: String,
  action: Action,
  selection: Selection,
) -> Result(Int, Error) {
  case action {
    Generate -> generate(blog_directory, selection)
    Publish -> publish(blog_directory, selection)
  }
}

/// Generate the selected `qiita.toml` files without sending anything.
pub fn generate(
  blog_directory: String,
  selection: Selection,
) -> Result(Int, Error) {
  case selection {
    Selected(post) ->
      resolve_post_directory(blog_directory, post)
      |> generate_directory
    All -> {
      use candidates <- result.try(load_candidates(blog_directory))
      generate_candidates(candidates)
    }
    Latest -> {
      use candidates <- result.try(load_candidates(blog_directory))
      case most_recent(candidates) {
        Ok(candidate) -> generate_candidate(candidate, 0)
        Error(Nil) -> Error(NoJapanesePosts(blog_directory))
      }
    }
  }
}

/// A selector may be a plain slug, a post path, or a path to the Japanese
/// source itself. All three resolve to the post directory.
fn resolve_post_directory(blog_directory: String, selector: String) -> String {
  let selector = string.trim(selector)
  let source_suffix = "/index-ja.djot"
  let without_source = case string.ends_with(selector, source_suffix) {
    True -> string.drop_end(selector, string.length(source_suffix))
    False -> selector
  }
  let directory = case string.ends_with(without_source, "/") {
    True -> string.drop_end(without_source, 1)
    False -> without_source
  }

  case string.split_once(directory, "/") {
    Ok(#("blog", rest)) -> blog_directory <> "/" <> rest
    Ok(_) -> directory
    Error(Nil) -> blog_directory <> "/" <> directory
  }
}

fn generate_directory(directory: String) -> Result(Int, Error) {
  let source_path = directory <> "/index-ja.djot"
  use exists <- result.try(
    simplifile.is_file(source_path)
    |> result.map_error(fn(reason) { CouldNotRead(source_path, reason) }),
  )
  case exists {
    False -> Error(PostNotFound(directory))
    True -> {
      use source <- result.try(
        simplifile.read(source_path)
        |> result.map_error(fn(reason) { CouldNotRead(source_path, reason) }),
      )
      use content <- result.try(source_to_toml(source_path, source))
      use Nil <- result.try(write_qiita_file(directory, content))
      Ok(1)
    }
  }
}

/// Collect every post that ships a Japanese source. Posts without one are
/// skipped, so a partially migrated catalog can still export the rest.
fn load_candidates(blog_directory: String) -> Result(List(Candidate), Error) {
  use entries <- result.try(
    simplifile.read_directory(blog_directory)
    |> result.map_error(CouldNotListBlog),
  )
  use candidates <- result.try(
    list.try_fold(entries, [], fn(acc, entry) {
      let directory = blog_directory <> "/" <> entry
      use is_directory <- result.try(
        simplifile.is_directory(directory)
        |> result.map_error(fn(reason) { CouldNotRead(directory, reason) }),
      )
      case is_directory {
        False -> Ok(acc)
        True -> load_candidate(directory, acc)
      }
    }),
  )
  Ok(list.reverse(candidates))
}

fn load_candidate(
  directory: String,
  candidates: List(Candidate),
) -> Result(List(Candidate), Error) {
  let source_path = directory <> "/index-ja.djot"
  use exists <- result.try(
    simplifile.is_file(source_path)
    |> result.map_error(fn(reason) { CouldNotRead(source_path, reason) }),
  )
  case exists {
    False -> Ok(candidates)
    True -> {
      use source <- result.try(
        simplifile.read(source_path)
        |> result.map_error(fn(reason) { CouldNotRead(source_path, reason) }),
      )
      use metadata <- result.try(parse_metadata(source_path, source))
      Ok([
        Candidate(
          directory: directory,
          source_path: source_path,
          source: source,
          metadata: metadata,
        ),
        ..candidates
      ])
    }
  }
}

fn generate_candidates(candidates: List(Candidate)) -> Result(Int, Error) {
  list.try_fold(candidates, 0, fn(count, candidate) {
    use Nil <- result.try(write_qiita_file(
      candidate.directory,
      toml_for(candidate),
    ))
    Ok(count + 1)
  })
}

fn generate_candidate(candidate: Candidate, count: Int) -> Result(Int, Error) {
  use Nil <- result.try(write_qiita_file(
    candidate.directory,
    toml_for(candidate),
  ))
  Ok(count + 1)
}

/// Publish the generated files without regenerating them. An item is created
/// the first time it is published and updated from then on, using the item id
/// stored back in the TOML file.
pub fn publish(
  blog_directory: String,
  selection: Selection,
) -> Result(Int, Error) {
  let dotenv = case simplifile.read("./.env") {
    Ok(content) -> content
    Error(_) -> ""
  }
  use token <- result.try(token_from_sources(dotenv, environment("QIITA_TOKEN")))
  use directories <- result.try(selected_directories(blog_directory, selection))
  list.try_fold(directories, 0, fn(count, directory) {
    use file <- result.try(load_publisher_file(directory))
    use item <- result.try(parse_publisher_file(file))
    use item_id <- result.try(send_item(item, token))
    use Nil <- result.try(remember_item_id(file, item.item_id, item_id))
    Ok(count + 1)
  })
}

/// Read a token from `.env` first, falling back to the process environment.
/// A blank `.env` value is ignored so an exported token can still be used.
pub fn token_from_sources(
  dotenv: String,
  environment_token: String,
) -> Result(String, Error) {
  let file_token = case dotenv_value(dotenv, "QIITA_TOKEN") {
    option.Some(value) -> {
      let token = string.trim(value)
      case token == "" {
        True -> option.None
        False -> option.Some(token)
      }
    }
    option.None -> option.None
  }
  case file_token {
    option.Some(token) -> Ok(token)
    option.None ->
      case string.trim(environment_token) == "" {
        True -> Error(MissingToken)
        False -> Ok(string.trim(environment_token))
      }
  }
}

/// Parse one `KEY=value` entry from dotenv content. Comments, `export`
/// prefixes, and matching single or double quotes are supported.
pub fn dotenv_value(content: String, key: String) -> Option(String) {
  case
    list.find_map(string.split(content, "\n"), fn(line) {
      let trimmed = string.trim(line)
      case trimmed == "" || string.starts_with(trimmed, "#") {
        True -> Error(Nil)
        False -> {
          let entry = case string.starts_with(trimmed, "export ") {
            True -> string.drop_start(trimmed, 7)
            False -> trimmed
          }
          case string.split_once(entry, "=") {
            Ok(#(name, value)) -> {
              case string.trim(name) == key {
                True -> Ok(strip_quotes(string.trim(value)))
                False -> Error(Nil)
              }
            }
            Error(Nil) -> Error(Nil)
          }
        }
      }
    })
  {
    Ok(value) -> option.Some(value)
    Error(Nil) -> option.None
  }
}

fn selected_directories(
  blog_directory: String,
  selection: Selection,
) -> Result(List(String), Error) {
  case selection {
    Selected(post) -> Ok([resolve_post_directory(blog_directory, post)])
    All -> {
      use candidates <- result.try(load_candidates(blog_directory))
      Ok(list.map(candidates, fn(candidate) { candidate.directory }))
    }
    Latest -> {
      use candidates <- result.try(load_candidates(blog_directory))
      use candidate <- result.try(
        most_recent(candidates)
        |> result.map_error(fn(_) { NoJapanesePosts(blog_directory) }),
      )
      Ok([candidate.directory])
    }
  }
}

fn load_publisher_file(directory: String) -> Result(PublisherFile, Error) {
  let path = directory <> "/qiita.toml"
  use exists <- result.try(
    simplifile.is_file(path)
    |> result.map_error(fn(reason) { CouldNotRead(path, reason) }),
  )
  case exists {
    False -> Error(QiitaFileNotFound(path))
    True -> {
      use content <- result.try(
        simplifile.read(path)
        |> result.map_error(fn(reason) { CouldNotRead(path, reason) }),
      )
      Ok(PublisherFile(directory: directory, path: path, content: content))
    }
  }
}

fn parse_publisher_file(file: PublisherFile) -> Result(PublisherItem, Error) {
  parse_publisher_toml(file.content)
  |> result.map_error(fn(reason) { InvalidQiitaFile(file.path, reason) })
}

/// Read a generated file into the subset of the Qiita item API that this
/// publisher uses. Missing optional fields get the same defaults as generation.
pub fn parse_publisher_toml(content: String) -> Result(PublisherItem, String) {
  use document <- result.try(
    tom.parse(content)
    |> result.map_error(describe_toml_parse_error),
  )
  use title <- result.try(required_toml_string(document, "title", "title"))
  use body <- result.try(required_toml_string(document, "body", "body"))
  use tag_values <- result.try(
    tom.get_array(document, ["tags"])
    |> result.map_error(describe_toml_get_error),
  )
  use tags <- result.try(list.try_map(tag_values, parse_toml_tag))
  use private <- result.try(optional_toml_bool(document, "private", False))
  use tweet <- result.try(optional_toml_bool(document, "tweet", False))
  use coediting <- result.try(optional_toml_bool(document, "coediting", False))
  use slide <- result.try(optional_toml_bool(document, "slide", False))
  use group_url_name <- result.try(optional_toml_string(
    document,
    "group_url_name",
  ))
  use organization_url_name <- result.try(optional_toml_string(
    document,
    "organization_url_name",
  ))
  use posting_campaign_uuid <- result.try(optional_toml_string(
    document,
    "posting_campaign_uuid",
  ))
  use agreed_posting_campaign_term <- result.try(optional_toml_bool(
    document,
    "agreed_posting_campaign_term",
    False,
  ))
  use item_id <- result.try(optional_toml_string(document, "qiita_item_id"))

  Ok(PublisherItem(
    title: title,
    body: body,
    tags: tags,
    private: private,
    tweet: tweet,
    coediting: coediting,
    slide: slide,
    group_url_name: group_url_name,
    organization_url_name: organization_url_name,
    posting_campaign_uuid: posting_campaign_uuid,
    agreed_posting_campaign_term: agreed_posting_campaign_term,
    item_id: item_id,
  ))
}

fn required_toml_string(
  document: Dict(String, tom.Toml),
  key: String,
  label: String,
) -> Result(String, String) {
  case tom.get_string(document, [key]) {
    Ok(value) -> Ok(value)
    Error(error) -> Error(label <> ": " <> describe_toml_get_error(error))
  }
}

fn optional_toml_string(
  document: Dict(String, tom.Toml),
  key: String,
) -> Result(Option(String), String) {
  case tom.get_string(document, [key]) {
    Ok(value) ->
      Ok(case value == "" {
        True -> option.None
        False -> option.Some(value)
      })
    Error(tom.NotFound(_)) -> Ok(option.None)
    Error(error) -> Error(key <> ": " <> describe_toml_get_error(error))
  }
}

fn optional_toml_bool(
  document: Dict(String, tom.Toml),
  key: String,
  default: Bool,
) -> Result(Bool, String) {
  case tom.get_bool(document, [key]) {
    Ok(value) -> Ok(value)
    Error(tom.NotFound(_)) -> Ok(default)
    Error(error) -> Error(key <> ": " <> describe_toml_get_error(error))
  }
}

fn parse_toml_tag(value: tom.Toml) -> Result(PublisherTag, String) {
  case value {
    tom.Table(fields) | tom.InlineTable(fields) -> {
      use name <- result.try(required_toml_string(fields, "name", "tag name"))
      use versions <- result.try(optional_toml_strings(fields, "versions"))
      Ok(PublisherTag(name: name, versions: versions))
    }
    other -> Error("tag must be a table, got " <> describe_toml_value(other))
  }
}

fn optional_toml_strings(
  document: Dict(String, tom.Toml),
  key: String,
) -> Result(List(String), String) {
  case tom.get_array(document, [key]) {
    Ok(values) ->
      list.try_map(values, fn(value) {
        case value {
          tom.String(item) -> Ok(item)
          other ->
            Error(
              key <> " must contain strings, got " <> describe_toml_value(other),
            )
        }
      })
    Error(tom.NotFound(_)) -> Ok([])
    Error(error) -> Error(key <> ": " <> describe_toml_get_error(error))
  }
}

fn describe_toml_parse_error(error: tom.ParseError) -> String {
  case error {
    tom.Unexpected(got, expected) ->
      "unexpected " <> got <> "; expected " <> expected
    tom.KeyAlreadyInUse(key) -> "duplicate key " <> string.join(key, ".")
  }
}

fn describe_toml_get_error(error: tom.GetError) -> String {
  case error {
    tom.NotFound(key) -> "missing " <> string.join(key, ".")
    tom.WrongType(key, expected, got) ->
      string.join(key, ".") <> " should be " <> expected <> " but was " <> got
  }
}

fn describe_toml_value(value: tom.Toml) -> String {
  case value {
    tom.Int(_) -> "an integer"
    tom.Float(_) -> "a float"
    tom.Infinity(_) -> "an infinity"
    tom.Nan(_) -> "a NaN"
    tom.Bool(_) -> "a boolean"
    tom.String(_) -> "a string"
    tom.Date(_) -> "a date"
    tom.Time(_) -> "a time"
    tom.DateTime(..) -> "a date-time"
    tom.Array(_) -> "an array"
    tom.ArrayOfTables(_) -> "an array of tables"
    tom.Table(_) -> "a table"
    tom.InlineTable(_) -> "an inline table"
  }
}

/// Build the item request from a parsed file. An existing item id switches the
/// request from creation to update.
pub fn publish_request(
  item: PublisherItem,
  token: String,
) -> Result(PublishRequest, Error) {
  case string.trim(token) == "" {
    True -> Error(MissingToken)
    False -> {
      let id = option.unwrap(item.item_id, "")
      let update = id != ""
      let method = case update {
        True -> http.Patch
        False -> http.Post
      }
      let path = case update {
        True -> "/api/v2/items/" <> id
        False -> "/api/v2/items"
      }
      Ok(PublishRequest(
        method: method,
        url: "https://qiita.com" <> path,
        body: encode_item(item),
      ))
    }
  }
}

fn encode_item(item: PublisherItem) -> String {
  let fields = [
    #("body", json.string(item.body)),
    #("title", json.string(item.title)),
    #("tags", json.array(from: item.tags, of: encode_tag)),
    #("private", json.bool(item.private)),
    #("tweet", json.bool(item.tweet)),
    #("coediting", json.bool(item.coediting)),
    #("slide", json.bool(item.slide)),
  ]
  let optional_fields =
    list.flatten([
      encode_optional_string("group_url_name", item.group_url_name),
      encode_optional_string(
        "organization_url_name",
        item.organization_url_name,
      ),
      encode_optional_string(
        "posting_campaign_uuid",
        item.posting_campaign_uuid,
      ),
      [
        #(
          "agreed_posting_campaign_term",
          json.bool(item.agreed_posting_campaign_term),
        ),
      ],
    ])
  json.object(list.append(fields, optional_fields)) |> json.to_string
}

fn encode_optional_string(
  key: String,
  value: Option(String),
) -> List(#(String, json.Json)) {
  case value {
    option.Some(content) -> [#(key, json.string(content))]
    option.None -> []
  }
}

fn encode_tag(tag: PublisherTag) -> json.Json {
  json.object([
    #("name", json.string(tag.name)),
    #("versions", json.array(from: tag.versions, of: json.string)),
  ])
}

fn send_item(item: PublisherItem, token: String) -> Result(String, Error) {
  use request_data <- result.try(publish_request(item, token))
  use base <- result.try(
    request.to(request_data.url)
    |> result.map_error(fn(_) { InvalidRequestUrl(request_data.url) }),
  )
  let http_request =
    base
    |> request.set_method(request_data.method)
    |> request.set_body(request_data.body)
    |> request.set_header("authorization", "Bearer " <> token)
    |> request.set_header("content-type", "application/json")
    |> request.set_header("accept", "application/json")
  use response <- result.try(
    httpc.dispatch(httpc.configure() |> httpc.timeout(30_000), http_request)
    |> result.map_error(fn(error) { RequestFailed(describe_http_error(error)) }),
  )
  case response.status {
    200 | 201 -> item_id_from_response(response.body)
    status -> Error(QiitaRejected(status, response.body))
  }
}

/// Read the remote item id from a Qiita response. It is stored back in the
/// TOML file so later publications update the same item.
pub fn item_id_from_response(body: String) -> Result(String, Error) {
  use id <- result.try(
    json.parse(body, decode.field("id", decode.string, decode.success))
    |> result.map_error(fn(_) {
      InvalidQiitaResponse("could not read the item id")
    }),
  )
  case id == "" {
    True -> Error(InvalidQiitaResponse("the item id was empty"))
    False -> Ok(id)
  }
}

fn describe_http_error(error: httpc.HttpError) -> String {
  case error {
    httpc.InvalidUtf8Response -> "the response was not UTF-8"
    httpc.FailedToConnect(ip4: _, ip6: _) -> "could not connect to Qiita"
    httpc.ResponseTimeout -> "the request timed out"
  }
}

/// Decide how a returned item id changes a TOML document. An existing id is
/// preserved so a later publication never overwrites the remote mapping.
pub fn apply_item_id(
  content: String,
  existing: Option(String),
  item_id: String,
) -> String {
  case existing {
    option.Some(_) -> content
    option.None -> set_toml_string_field(content, "qiita_item_id", item_id)
  }
}

fn remember_item_id(
  file: PublisherFile,
  existing: Option(String),
  item_id: String,
) -> Result(Nil, Error) {
  let updated = apply_item_id(file.content, existing, item_id)
  case updated == file.content {
    True -> Ok(Nil)
    False -> write_qiita_file(file.directory, updated)
  }
}

fn set_toml_string_field(
  content: String,
  key: String,
  value: String,
) -> String {
  let prefix = key <> " = "
  let lines = string.split(content, "\n")
  let found = list.any(lines, fn(line) { string.starts_with(line, prefix) })
  let updated =
    list.map(lines, fn(line) {
      case string.starts_with(line, prefix) {
        True -> prefix <> toml_string(value)
        False -> line
      }
    })
  case found {
    True -> string.join(updated, "\n")
    False -> content <> key <> " = " <> toml_string(value) <> "\n"
  }
}

/// Dates are normalized to the same UTC RFC 3339 shape, so lexical order is
/// chronological order.
fn most_recent(candidates: List(Candidate)) -> Result(Candidate, Nil) {
  case candidates {
    [] -> Error(Nil)
    [first, ..rest] ->
      Ok(
        list.fold(rest, first, fn(current, candidate) {
          case
            string.compare(
              candidate.metadata.last_updated_at,
              current.metadata.last_updated_at,
            )
          {
            order.Gt -> candidate
            order.Eq | order.Lt -> current
          }
        }),
      )
  }
}

fn write_qiita_file(directory: String, content: String) -> Result(Nil, Error) {
  let output_path = directory <> "/qiita.toml"
  simplifile.write(output_path, content)
  |> result.map_error(fn(reason) { CouldNotWrite(output_path, reason) })
}

/// Convert one Japanese djot source into the contents of a `qiita.toml` file.
pub fn source_to_toml(path: String, source: String) -> Result(String, Error) {
  use metadata <- result.try(parse_metadata(path, source))
  Ok(toml_for_metadata(metadata, source))
}

fn toml_for(candidate: Candidate) -> String {
  toml_for_metadata(candidate.metadata, candidate.source)
}

fn toml_for_metadata(metadata: Metadata, source: String) -> String {
  let markdown =
    body(source)
    |> djot_to_markdown
    |> absolutize_local_paths
  render_toml(metadata, markdown)
}

/// Render the export document. The Qiita item fields are flat so publication
/// can lift them straight into a request; the tracking fields describe where
/// the text came from and which remote item it maps to.
pub fn render_toml(metadata: Metadata, markdown: String) -> String {
  let rendered_tags =
    metadata.tags
    |> list.map(fn(tag) {
      "{ name = " <> toml_string(tag) <> ", versions = [] }"
    })
    |> string.join(", ")
  let source_url = site.production_url <> "blog/ja/" <> metadata.slug <> "/"

  "# Generated by `gleam run -m qiita`; edit the djot source instead.\n"
  <> "title = "
  <> toml_string(metadata.title)
  <> "\n"
  <> "body = \"\"\"\n"
  <> toml_multiline_string(markdown)
  <> "\"\"\"\n"
  <> "language = \"ja\"\n"
  <> "last_updated_at = "
  <> toml_string(metadata.last_updated_at)
  <> "\n"
  <> "slug = "
  <> toml_string(metadata.slug)
  <> "\n"
  <> "source_url = "
  <> toml_string(source_url)
  <> "\n"
  <> "private = true\n"
  <> "tweet = false\n"
  <> "coediting = false\n"
  <> "slide = false\n"
  <> "group_url_name = \"\"\n"
  <> "organization_url_name = \"\"\n"
  <> "posting_campaign_uuid = \"\"\n"
  <> "agreed_posting_campaign_term = false\n"
  <> "qiita_item_id = \"\"\n"
  <> "tags = ["
  <> rendered_tags
  <> "]\n"
}

/// Parse just the fields the export needs. The frontmatter syntax is the
/// same flat `key: value` form blogatto reads, so no YAML dependency is
/// needed here.
pub fn parse_metadata(path: String, source: String) -> Result(Metadata, Error) {
  use parts <- result.try(
    split_source(source)
    |> result.replace_error(MissingFrontmatter(path)),
  )
  let #(raw_frontmatter, _) = parts
  use fields <- result.try(parse_frontmatter(path, raw_frontmatter))
  use title <- result.try(required_field(fields, "title", path))
  use slug <- result.try(required_field(fields, "slug", path))
  use raw_date <- result.try(required_field(fields, "date", path))
  use last_updated_at <- result.try(
    normalize_date(raw_date)
    |> result.replace_error(InvalidDate(path, raw_date)),
  )
  let tags = case dict.get(fields, "tags") {
    Ok(raw) -> non_empty_tags(raw)
    Error(Nil) -> ["ninjas.cl"]
  }

  Ok(Metadata(
    title: title,
    slug: slug,
    last_updated_at: last_updated_at,
    tags: tags,
  ))
}

fn parse_frontmatter(
  path: String,
  raw: String,
) -> Result(Dict(String, String), Error) {
  let lines =
    raw
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" && !string.starts_with(line, "#") })
  list.try_fold(lines, dict.new(), fn(fields, line) {
    case parse_line(line) {
      Ok(#(key, value)) -> Ok(dict.insert(fields, key, value))
      Error(Nil) -> Error(MissingField(path, line))
    }
  })
}

fn parse_line(line: String) -> Result(#(String, String), Nil) {
  case string.split_once(line, ":") {
    Ok(#(key, value)) ->
      Ok(#(string.trim(key), strip_quotes(string.trim(value))))
    Error(Nil) -> Error(Nil)
  }
}

fn strip_quotes(value: String) -> String {
  case string.first(value), string.last(value) {
    Ok("\""), Ok("\"") ->
      value
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.replace("\\\"", "\"")
    Ok("'"), Ok("'") -> value |> string.drop_start(1) |> string.drop_end(1)
    _, _ -> value
  }
}

fn split_source(source: String) -> Result(#(String, String), Nil) {
  case string.starts_with(source, "---\n") {
    False -> Error(Nil)
    True ->
      case string.split_once(string.drop_start(source, 4), "\n---\n") {
        Ok(parts) -> Ok(parts)
        Error(Nil) -> Error(Nil)
      }
  }
}

fn body(source: String) -> String {
  case split_source(source) {
    Ok(#(_, content)) -> string.trim(content)
    Error(Nil) -> string.trim(source)
  }
}

fn required_field(
  fields: Dict(String, String),
  name: String,
  path: String,
) -> Result(String, Error) {
  case dict.get(fields, name) {
    Ok(value) ->
      case value == "" {
        True -> Error(MissingField(path, name))
        False -> Ok(value)
      }
    Error(Nil) -> Error(MissingField(path, name))
  }
}

/// Blogatto stores dates in `YYYY-MM-DD HH:MM:SS +HH:MM` form and treats the
/// frontmatter `date` as the last update. Qiita expects RFC 3339, so the
/// offset is folded into UTC before it is written out.
fn normalize_date(raw: String) -> Result(String, Nil) {
  use input <- result.try(rfc3339_input(raw))
  use parsed <- result.try(timestamp.parse_rfc3339(input))
  Ok(timestamp.to_rfc3339(parsed, calendar.utc_offset))
}

fn rfc3339_input(raw: String) -> Result(String, Nil) {
  case string.split_once(raw, " ") {
    Error(Nil) -> Error(Nil)
    Ok(#(date, time_and_zone)) ->
      case string.split_once(time_and_zone, " ") {
        Ok(#(time, offset)) -> Ok(date <> "T" <> time <> offset)
        Error(Nil) -> Ok(date <> "T" <> time_and_zone <> "+00:00")
      }
  }
}

fn non_empty_tags(raw: String) -> List(String) {
  let tags =
    raw
    |> string.split(",")
    |> list.map(string.trim)
    |> list.filter(fn(tag) { tag != "" })
  case list.is_empty(tags) {
    True -> ["ninjas.cl"]
    False -> tags
  }
}

/// Convert djot's inline and fence syntax to the Markdown Qiita accepts.
/// Fenced code is kept byte-for-byte apart from the info string, where djot
/// attributes such as `{summary="..."}` are dropped because Qiita has no
/// equivalent toggle.
pub fn djot_to_markdown(body: String) -> String {
  body
  |> string.split("\n")
  |> convert_lines(False, [])
  |> list.reverse
  |> string.join("\n")
}

fn convert_lines(
  lines: List(String),
  in_code_block: Bool,
  acc: List(String),
) -> List(String) {
  case lines {
    [] -> acc
    [line, ..rest] ->
      case is_fence(line) {
        True ->
          case in_code_block {
            True -> convert_lines(rest, False, [line, ..acc])
            False -> convert_lines(rest, True, [normalize_fence(line), ..acc])
          }
        False ->
          case in_code_block {
            True -> convert_lines(rest, True, [line, ..acc])
            False ->
              convert_lines(rest, False, [djot_to_markdown_line(line), ..acc])
          }
      }
  }
}

fn is_fence(line: String) -> Bool {
  string.starts_with(line, "```") || string.starts_with(line, "~~~")
}

fn normalize_fence(line: String) -> String {
  let marker = case string.starts_with(line, "```") {
    True -> "```"
    False -> "~~~"
  }
  let info =
    line
    |> string.drop_start(string.length(marker))
    |> string.trim
  case string.split(info, " ") |> list.filter(fn(part) { part != "" }) {
    [language, ..] -> marker <> language
    [] -> marker
  }
}

fn djot_to_markdown_line(line: String) -> String {
  convert_delimiters(line)
}

/// Djot writes strong as `*text*` and emphasis as `_text_`; Markdown swaps
/// those spellings. Only pairs outside code spans are converted, and an
/// opener never starts in the middle of an ASCII identifier, which leaves
/// snake_case names and arithmetic alone.
fn convert_delimiters(text: String) -> String {
  let star = find_delimiter(text, "*")
  let underscore = find_delimiter(text, "_")
  let chosen = case star, underscore {
    Ok(star_match), Ok(underscore_match) ->
      case star_match.position <= underscore_match.position {
        True -> Ok(star_match)
        False -> Ok(underscore_match)
      }
    Ok(match), Error(Nil) -> Ok(match)
    Error(Nil), Ok(match) -> Ok(match)
    Error(Nil), Error(Nil) -> Error(Nil)
  }

  case chosen {
    Ok(match) -> {
      let marker = case match.delimiter {
        "*" -> "**"
        "_" -> "*"
        other -> other
      }
      match.before
      <> marker
      <> convert_delimiters(match.inner)
      <> marker
      <> convert_delimiters(match.after)
    }
    Error(Nil) -> text
  }
}

fn find_delimiter(
  text: String,
  delimiter: String,
) -> Result(DelimiterMatch, Nil) {
  find_opener(string.to_graphemes(text), [], delimiter)
}

fn find_opener(
  chars: List(String),
  before: List(String),
  delimiter: String,
) -> Result(DelimiterMatch, Nil) {
  case chars {
    [] -> Error(Nil)
    ["`", ..] -> {
      let #(span, rest) = skip_code_span(chars)
      find_opener(rest, [span, ..before], delimiter)
    }
    [char, ..rest] if char == delimiter -> {
      let #(run, remaining) = take_run(char, chars)
      case string.length(run) {
        1 ->
          case is_opener(before, rest, delimiter) {
            True ->
              case find_closer(rest, [], delimiter) {
                Ok(#(inner, after)) ->
                  Ok(DelimiterMatch(
                    position: string.length(string.concat(list.reverse(before))),
                    delimiter: delimiter,
                    before: string.concat(list.reverse(before)),
                    inner: string.concat(inner),
                    after: string.concat(after),
                  ))
                Error(Nil) -> find_opener(rest, [char, ..before], delimiter)
              }
            False -> find_opener(rest, [char, ..before], delimiter)
          }
        _ -> find_opener(remaining, [run, ..before], delimiter)
      }
    }
    [char, ..rest] -> find_opener(rest, [char, ..before], delimiter)
  }
}

fn find_closer(
  chars: List(String),
  inner: List(String),
  delimiter: String,
) -> Result(#(List(String), List(String)), Nil) {
  case chars {
    [] -> Error(Nil)
    ["`", ..] -> {
      let #(span, rest) = skip_code_span(chars)
      find_closer(rest, [span, ..inner], delimiter)
    }
    [char, ..rest] if char == delimiter -> {
      let #(run, remaining) = take_run(char, chars)
      case string.length(run) {
        1 ->
          case is_closer(inner, rest, delimiter) {
            True -> Ok(#(list.reverse(inner), rest))
            False -> find_closer(rest, [char, ..inner], delimiter)
          }
        _ -> find_closer(remaining, [run, ..inner], delimiter)
      }
    }
    [char, ..rest] -> find_closer(rest, [char, ..inner], delimiter)
  }
}

/// Runs of more than one delimiter are left alone: a line that already uses
/// Markdown's `**strong**` must not be converted a second time.
fn take_run(char: String, chars: List(String)) -> #(String, List(String)) {
  case chars {
    [next, ..rest] if next == char -> {
      let #(run, remaining) = take_run(char, rest)
      #(next <> run, remaining)
    }
    [] -> #("", chars)
    [_, ..] -> #("", chars)
  }
}

fn is_opener(
  before: List(String),
  rest: List(String),
  delimiter: String,
) -> Bool {
  // ASCII identifiers and URLs may hold `_` without marking emphasis, but
  // Japanese prose often puts a delimiter right after a letter. Only ASCII
  // word characters block an opener; CJK letters and punctuation do not.
  let previous_ok = case last_char(before) {
    Ok(char) -> !is_ascii_word_char(char)
    Error(Nil) -> True
  }
  let next_ok = case rest {
    [char, ..] -> !is_whitespace(char) && char != delimiter
    [] -> False
  }
  previous_ok && next_ok
}

fn is_closer(
  inner: List(String),
  rest: List(String),
  delimiter: String,
) -> Bool {
  let previous_ok = case last_char(inner) {
    Ok(char) -> !is_whitespace(char) && char != delimiter
    Error(Nil) -> False
  }
  let next_ok = case rest {
    [char, ..] -> char != delimiter
    [] -> True
  }
  previous_ok && next_ok
}

/// Chunks are accumulated in reverse, so the most recent text is the head.
fn last_char(chunks: List(String)) -> Result(String, Nil) {
  case chunks {
    [] -> Error(Nil)
    [chunk, ..] -> string.last(chunk)
  }
}

fn is_whitespace(char: String) -> Bool {
  string.trim(char) == ""
}

fn is_ascii_word_char(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] ->
      is_ascii_word_codepoint(string.utf_codepoint_to_int(codepoint))
    _ -> False
  }
}

fn is_ascii_word_codepoint(codepoint: Int) -> Bool {
  { codepoint >= 48 && codepoint <= 57 }
  || { codepoint >= 65 && codepoint <= 90 }
  || { codepoint >= 97 && codepoint <= 122 }
}

fn skip_code_span(chars: List(String)) -> #(String, List(String)) {
  let #(ticks, after_opening) = take_ticks(chars)
  do_skip_code_span(after_opening, ticks, ticks)
}

fn take_ticks(chars: List(String)) -> #(String, List(String)) {
  case chars {
    ["`", ..rest] -> {
      let #(ticks, remaining) = take_ticks(rest)
      #("`" <> ticks, remaining)
    }
    _ -> #("", chars)
  }
}

fn do_skip_code_span(
  chars: List(String),
  ticks: String,
  acc: String,
) -> #(String, List(String)) {
  case chars {
    [] -> #(acc <> ticks, [])
    ["`", ..] -> {
      let #(candidate, remaining) = take_ticks(chars)
      case candidate == ticks {
        True -> #(acc <> candidate, remaining)
        False -> do_skip_code_span(remaining, ticks, acc <> candidate)
      }
    }
    [char, ..rest] -> do_skip_code_span(rest, ticks, acc <> char)
  }
}

/// Qiita cannot resolve site-root asset paths, so make them absolute using
/// the production URL. Markdown destinations are the only place the site
/// emits such paths.
fn absolutize_local_paths(markdown: String) -> String {
  string.replace(markdown, "](/", "](" <> site.production_url)
}

fn toml_string(value: String) -> String {
  "\"" <> escape_basic(value) <> "\""
}

fn escape_basic(value: String) -> String {
  value
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char {
      "\"" -> "\\\""
      "\\" -> "\\\\"
      "\n" -> "\\n"
      "\r" -> "\\r"
      "\t" -> "\\t"
      other -> other
    }
  })
  |> string.concat
}

/// Newlines stay literal inside a TOML multiline basic string. Quotes and
/// backslashes are escaped so a body can never close the string early or
/// turn a line ending into a continuation.
fn toml_multiline_string(value: String) -> String {
  value
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char {
      "\"" -> "\\\""
      "\\" -> "\\\\"
      "\r" -> "\\r"
      other -> other
    }
  })
  |> string.concat
}
