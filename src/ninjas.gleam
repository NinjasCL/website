import blogatto
import blogatto/error
import gleam/int
import gleam/io
import ninjas/blog
import ninjas/extra_pages
import ninjas/manifest
import site

pub fn main() {
  case blogatto.build(blog.new(site.production_url)) {
    Ok(Nil) -> finish_build()
    Error(err) -> io.println("Build failed: " <> error.describe_error(err))
  }
}

fn finish_build() -> Nil {
  case extra_pages.write_not_found() {
    Ok(Nil) ->
      case manifest.update_post_dates("./blog", "./website-manifest.json") {
        Ok(count) ->
          io.println(
            "Site built successfully!. Recorded "
            <> int.to_string(count)
            <> " post dates.",
          )
        Error(error) ->
          io.println("Build failed: " <> manifest.describe_error(error))
      }
    Error(write_error) -> io.println("Build failed: " <> write_error)
  }
}
