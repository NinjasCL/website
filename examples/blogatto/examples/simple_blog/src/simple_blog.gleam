//// A simple blog example demonstrating the full Blogatto build pipeline.
////
//// Builds a static blog with a homepage listing articles, two markdown
//// blog posts, an RSS feed, a sitemap, and a robots.txt file.
////
//// Run with `gleam run` from the `examples/simple_blog` directory.

import blogatto
import blogatto/error
import gleam/io
import simple_blog/blog

pub fn main() {
  let cfg = blog.config()

  // Build the site
  case blogatto.build(cfg) {
    Ok(Nil) -> io.println("Site built successfully in ./dist")
    Error(err) -> io.println("Build failed: " <> error.describe_error(err))
  }
}
