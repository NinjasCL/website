import blogatto/dev
import blogatto/error
import gleam/io
import ninjas/blog
import site

pub fn main() -> Nil {
  case
    blog.new(site.dev_url)
    |> dev.new()
    |> dev.build_command("gleam run -m dev")
    |> dev.live_reload(True)
    |> dev.port(3000)
    |> dev.start()
  {
    Ok(Nil) -> io.println("Dev server stopped.")
    Error(err) ->
      io.println_error("Dev server error: " <> error.describe_error(err))
  }
}
