//// Build the site with the local development URL.

import blogatto
import blogatto/error
import gleam/io
import ninjas/blog
import ninjas/extra_pages
import site

pub fn main() {
  case blogatto.build(blog.new(site.dev_url)) {
    Ok(Nil) ->
      case extra_pages.write_not_found() {
        Ok(Nil) -> io.println("[dev] Site built successfully!. ")
        Error(write_error) -> io.println("[dev] Build failed: " <> write_error)
      }
    Error(err) ->
      io.println("[dev] Build failed: " <> error.describe_error(err))
  }
}
