import blogatto
import blogatto/error
import gleam/io
import ninjas/blog
import ninjas/extra_pages
import site

pub fn main() {
  case blogatto.build(blog.new(site.production_url)) {
    Ok(Nil) ->
      case extra_pages.write_not_found() {
        Ok(Nil) -> io.println("Site built successfully!.")
        Error(write_error) -> io.println("Build failed: " <> write_error)
      }
    Error(err) -> io.println("Build failed: " <> error.describe_error(err))
  }
}
