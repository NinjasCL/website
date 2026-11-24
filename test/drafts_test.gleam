import ninjas/drafts

pub fn draft_slug_is_derived_from_the_title_test() {
  assert drafts.slug_from_title("Hola, Mundo!") == Ok("hola-mundo")
  assert drafts.slug_from_title("¿Cómo se hace un vídeo en JavaScript?")
    == Ok("como-se-hace-un-video-en-javascript")
}

pub fn draft_slug_rejects_titles_without_usable_words_test() {
  assert drafts.slug_from_title("¡¡¡") == Error(drafts.InvalidSlug(""))
}

pub fn draft_slug_accepts_explicit_lowercase_slugs_test() {
  assert drafts.validate_slug("mi-post-123") == Ok("mi-post-123")
  assert drafts.validate_slug("  mi-post  ") == Ok("mi-post")
}

pub fn draft_slug_rejects_unsafe_explicit_slugs_test() {
  assert drafts.validate_slug("Mi-Post") == Error(drafts.InvalidSlug("Mi-Post"))
  assert drafts.validate_slug("../otro") == Error(drafts.InvalidSlug("../otro"))
  assert drafts.validate_slug("-inicio") == Error(drafts.InvalidSlug("-inicio"))
  assert drafts.validate_slug("fin-") == Error(drafts.InvalidSlug("fin-"))
}

pub fn draft_arguments_accept_a_title_and_optional_slug_test() {
  assert drafts.preview_from_arguments(["mi-post"]) == Ok("mi-post")
  assert drafts.create_from_arguments([])
    == Error(drafts.InvalidArguments("usage: task draft -- \"Title\" [slug]"))
  assert drafts.create_from_arguments(["a", "b", "c"])
    == Error(drafts.InvalidArguments("usage: task draft -- \"Title\" [slug]"))
}

pub fn draft_path_is_always_inside_the_drafts_directory_test() {
  assert drafts.draft_path("mi-post") == "./drafts/mi-post"
}
