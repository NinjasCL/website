//// Shared helpers for the draft workflow.
////
//// Drafts live in `drafts/` instead of `blog/`, so they stay outside every
//// production consumer: blogatto, Qiita, feeds, the manifest, pagination,
//// and the image optimizer. This module owns the two conventions that make
//// that workflow predictable: a slug generated from the title when none is
//// supplied, and a path that always points at one draft directory.

import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import simplifile
import str

pub type Error {
  InvalidArguments(reason: String)
  InvalidSlug(slug: String)
  DraftAlreadyExists(slug: String)
  CouldNotPrepareDirectory(path: String, reason: simplifile.FileError)
  CouldNotWrite(path: String, reason: simplifile.FileError)
}

/// Gleam strings are binaries, while Erlang's argument list is a charlist.
/// The shim converts each argument at the boundary so this module stays typed.
@external(erlang, "drafts_ffi", "arguments")
pub fn command_line_arguments() -> List(String)

/// Create a draft directory with a Spanish djot source. An explicit slug is
/// used as-is after validation; without one the slug comes from the title.
pub fn create(
  title: String,
  explicit_slug: Option(String),
) -> Result(String, Error) {
  use clean_title <- result.try(validate_title(title))
  let raw_slug = case explicit_slug {
    option.None -> str.slugify(clean_title)
    option.Some(slug) -> string.trim(slug)
  }
  use slug <- result.try(validate_slug(raw_slug))

  let directory = draft_path(slug)
  use _ <- result.try(case simplifile.is_directory(directory) {
    Ok(True) -> Error(DraftAlreadyExists(slug))
    Ok(False) -> Ok(Nil)
    Error(reason) -> Error(CouldNotPrepareDirectory(directory, reason))
  })
  use _ <- result.try(
    simplifile.create_directory_all(directory)
    |> result.map_error(fn(reason) {
      CouldNotPrepareDirectory(directory, reason)
    }),
  )

  let source = directory <> "/index.djot"
  use _ <- result.try(
    simplifile.write(source, frontmatter(clean_title, slug, now()))
    |> result.map_error(fn(reason) { CouldNotWrite(source, reason) }),
  )
  Ok(slug)
}

/// Create a draft from `title` plus an optional explicit slug.
pub fn create_from_arguments(arguments: List(String)) -> Result(String, Error) {
  case arguments {
    [title] -> create(title, option.None)
    [title, slug] -> create(title, option.Some(slug))
    _ -> Error(InvalidArguments("usage: task draft -- \"Title\" [slug]"))
  }
}

/// Resolve the one draft slug accepted by the preview commands.
pub fn preview_from_arguments(
  arguments: List(String),
) -> Result(String, Error) {
  case arguments {
    [slug] -> validate_slug(slug)
    _ -> Error(InvalidArguments("usage: task draft.preview -- <slug>"))
  }
}

/// The directory holding all of a draft's djot variants and local assets.
pub fn draft_path(slug: String) -> String {
  "./drafts/" <> slug
}

/// Turn a title into a URL-safe slug, folding accents into ASCII.
pub fn slug_from_title(title: String) -> Result(String, Error) {
  use clean_title <- result.try(validate_title(title))
  str.slugify(clean_title) |> validate_slug
}

/// Accept only simple lowercase directory names. This keeps CLI arguments
/// from escaping `drafts/` and keeps generated URLs stable.
pub fn validate_slug(slug: String) -> Result(String, Error) {
  let clean_slug = string.trim(slug)
  let graphemes = string.to_graphemes(clean_slug)
  let allowed = string.to_graphemes(allowed_slug_characters)
  let valid = case graphemes {
    [] -> False
    characters ->
      list.all(characters, fn(character) {
        list.any(allowed, fn(candidate) { candidate == character })
      })
  }
  case
    valid
    && !string.starts_with(clean_slug, "-")
    && !string.ends_with(clean_slug, "-")
  {
    True -> Ok(clean_slug)
    False -> Error(InvalidSlug(slug))
  }
}

pub fn describe_error(error: Error) -> String {
  case error {
    InvalidArguments(reason) -> reason
    InvalidSlug(slug) ->
      "invalid slug '"
      <> slug
      <> "': use lowercase letters, digits, and hyphens"
    DraftAlreadyExists(slug) -> "draft already exists: drafts/" <> slug
    CouldNotPrepareDirectory(path, reason) ->
      "could not prepare " <> path <> ": " <> simplifile.describe_error(reason)
    CouldNotWrite(path, reason) ->
      "could not write " <> path <> ": " <> simplifile.describe_error(reason)
  }
}

const allowed_slug_characters = "abcdefghijklmnopqrstuvwxyz0123456789-"

fn validate_title(title: String) -> Result(String, Error) {
  let clean_title = string.trim(title)
  case
    clean_title == ""
    || string.contains(clean_title, "\n")
    || string.contains(clean_title, "\r")
  {
    True -> Error(InvalidArguments("title must be a single non-empty line"))
    False -> Ok(clean_title)
  }
}

fn frontmatter(title: String, slug: String, date: String) -> String {
  "---\n"
  <> "title: "
  <> title
  <> "\n"
  <> "slug: "
  <> slug
  <> "\n"
  <> "date: "
  <> date
  <> "\n"
  <> "description: Descripción pendiente.\n"
  <> "featured_image: /img/Ninjas.png\n"
  <> "tags: general\n"
  <> "---\n\n"
  <> "Escribe aquí el contenido en djot.\n"
}

/// Blogatto's frontmatter parser accepts `YYYY-MM-DD HH:MM:SS +00:00`, not
/// RFC3339 with fractional seconds, so the generated date uses that format.
fn now() -> String {
  let #(date, time) =
    timestamp.system_time()
    |> timestamp.to_calendar(calendar.utc_offset)

  int.to_string(date.year)
  <> "-"
  <> pad(date.month |> calendar.month_to_int)
  <> "-"
  <> pad(date.day)
  <> " "
  <> pad(time.hours)
  <> ":"
  <> pad(time.minutes)
  <> ":"
  <> pad(time.seconds)
  <> " +00:00"
}

fn pad(value: Int) -> String {
  case value < 10 {
    True -> "0" <> int.to_string(value)
    False -> int.to_string(value)
  }
}
