//// Extra output pages that blogatto's route system cannot express.
////
//// `config.route/2` always writes `<route>/index.html`, so a root-level
//// `404.html` — the static-host error-page convention (GitHub Pages,
//// Netlify, Cloudflare Pages) — cannot be a route. These pages render
//// from the site views and are written to the output directory by the
//// build entrypoints after a successful `blogatto.build`. The path below
//// matches the output directory configured in `ninjas/blog`.

import gleam/result
import lustre/element
import simplifile
import site

/// Write the not-found page to the output root as `404.html`.
pub fn write_not_found() -> Result(Nil, String) {
  let content = element.to_document_string(site.not_found_view())

  "./dist/404.html"
  |> simplifile.write(content)
  |> result.map_error(simplifile.describe_error)
}
