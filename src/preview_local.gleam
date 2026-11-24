//// Preview one draft with blogatto's live-reloading development server.

import blogatto/dev
import blogatto/error
import gleam/io
import ninjas/blog
import ninjas/drafts
import site

pub fn main() {
  case drafts.command_line_arguments() |> drafts.preview_from_arguments {
    Error(error) -> io.println_error(drafts.describe_error(error))
    Ok(slug) ->
      case
        blog.preview(site.dev_url, drafts.draft_path(slug))
        |> dev.new()
        |> dev.build_command("gleam run -m preview -- " <> slug)
        |> dev.live_reload(True)
        |> dev.port(4000)
        |> dev.start()
      {
        Ok(Nil) -> io.println("Preview server stopped.")
        Error(error) ->
          io.println_error(
            "Preview server error: " <> error.describe_error(error),
          )
      }
  }
}
