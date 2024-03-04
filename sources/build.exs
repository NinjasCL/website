#!/usr/bin/env elixir

Mix.install([:jason])

read_and_parse_json = fn path ->
  "sources/content/#{path}.json"
  |> File.read!()
  |> Jason.decode!(keys: :atoms)
end

bindings = [
  website: read_and_parse_json.("website"),
  books: read_and_parse_json.("books"),
  games: read_and_parse_json.("games"),
  guides: read_and_parse_json.("guides")
]

File.write!(
  "docs/index.html",
  EEx.eval_file(
    "sources/template.html.eex",
    bindings
  ),
  write: true
)
