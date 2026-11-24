//// Create a new draft from a title and an optional explicit slug.

import gleam/io
import ninjas/drafts

pub fn main() {
  case drafts.command_line_arguments() |> drafts.create_from_arguments {
    Ok(slug) -> io.println("Created drafts/" <> slug <> "/index.djot")
    Error(error) -> io.println_error(drafts.describe_error(error))
  }
}
