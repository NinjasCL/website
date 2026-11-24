//// Build one draft into ./.preview with the production post engine.

import blogatto
import blogatto/error
import gleam/io
import ninjas/blog
import ninjas/drafts
import site

pub fn main() {
  case drafts.command_line_arguments() |> drafts.preview_from_arguments {
    Error(error) -> io.println_error(drafts.describe_error(error))
    Ok(slug) ->
      case blogatto.build(blog.preview(site.dev_url, drafts.draft_path(slug))) {
        Ok(Nil) -> io.println("Preview built in ./.preview for draft: " <> slug)
        Error(error) ->
          io.println_error(
            "Preview build failed: " <> error.describe_error(error),
          )
      }
  }
}
