import gleam/list
import gleam/string
import ninjas/manifest
import simplifile

const root = "./build/manifest_test"

const blog = "./build/manifest_test/blog"

const manifest_path = "./build/manifest_test/website-manifest.json"

fn reset() -> Nil {
  let _ = simplifile.delete(root)
  let assert Ok(Nil) = simplifile.create_directory_all(blog)
  let assert Ok(Nil) =
    simplifile.write(
      manifest_path,
      "{\n"
        <> "  \"version\": 1,\n"
        <> "  \"images\": {},\n"
        <> "  \"downloads\": {},\n"
        <> "  \"covers\": {},\n"
        <> "  \"ftp\": {\n"
        <> "    \"files\": {\n"
        <> "      \"index.html\": \"cached-hash\"\n"
        <> "    }\n"
        <> "  }\n"
        <> "}\n",
    )
  Nil
}

fn write_post(slug: String, date: String) -> Nil {
  let assert Ok(Nil) = simplifile.create_directory_all(blog <> "/" <> slug)
  let assert Ok(Nil) =
    simplifile.write(
      blog <> "/" <> slug <> "/index.djot",
      "---\n"
        <> "title: Test post\n"
        <> "slug: "
        <> slug
        <> "\n"
        <> "date: "
        <> date
        <> "\n"
        <> "description: A test post\n"
        <> "---\n\n"
        <> "Body.\n",
    )
  Nil
}

pub fn post_dates_are_recorded_newest_first_test() {
  reset()
  write_post("older", "2024-01-01 00:00:00 +00:00")
  write_post("newer", "2024-06-02 23:30:00 -03:00")
  let assert Ok(2) = manifest.update_post_dates(blog, manifest_path)
  let assert Ok(content) = simplifile.read(manifest_path)

  assert string.contains(
    content,
    "  \"posts\": {\n"
      <> "    \"newer\": \"2024-06-03T02:30:00Z\",\n"
      <> "    \"older\": \"2024-01-01T00:00:00Z\"\n"
      <> "  },",
  )
  assert string.contains(
    content,
    "  \"latest_post\": {\n"
      <> "    \"slug\": \"newer\",\n"
      <> "    \"date\": \"2024-06-03T02:30:00Z\"\n"
      <> "  },",
  )
  assert string.contains(content, "\"index.html\": \"cached-hash\"")
}

pub fn updating_post_dates_is_idempotent_test() {
  reset()
  write_post("only", "2025-05-05 12:00:00 +00:00")
  let assert Ok(1) = manifest.update_post_dates(blog, manifest_path)
  let assert Ok(first) = simplifile.read(manifest_path)
  let assert Ok(1) = manifest.update_post_dates(blog, manifest_path)
  let assert Ok(second) = simplifile.read(manifest_path)

  assert first == second
  assert list.length(string.split(first, "  \"posts\": {")) == 2
  assert list.length(string.split(first, "  \"latest_post\": {")) == 2
}

pub fn invalid_post_date_is_reported_test() {
  reset()
  write_post("broken", "not-a-date")
  case manifest.update_post_dates(blog, manifest_path) {
    Error(_) -> Nil
    Ok(_) -> panic as "an invalid date should fail the manifest update"
  }
}
