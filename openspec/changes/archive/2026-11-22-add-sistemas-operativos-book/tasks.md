# Tasks

## 1. Cover asset

- [x] 1.1 Center-crop and resample `static/img/niklas-konig-1cTFuvI14J4-unsplash.jpg` to 640×961 (the size of `elixir-fullstack.jpg`) without distortion; verify with `sips -g pixelWidth -g pixelHeight` and confirm the file remains a valid JPEG.

## 2. Book card

- [x] 2.1 Add the "Conceptos de Sistemas Operativos" `ShowcaseItem` at the head of `books_section` in `src/ninjas/home.gleam` with the book site URL, source repository URL, `/img/niklas-konig-1cTFuvI14J4-unsplash.jpg`, the alt text "Foto de Niklas König en Unsplash", a July 2025 caption, and the two-line summary in all four `CardText` languages; verify the rendered home view contains the title, both links, the image, and the alt text with `gleam test`.

## 3. Tests and verification

- [x] 3.1 Extend `test/ninjas_test.gleam` with the new image path, alt text, and both URLs, and update the showcase card/button counts from fourteen/twenty-eight to fifteen/thirty; verify with `gleam test`.
- [x] 3.2 Run `gleam format src test`, `gleam format --check src test`, `gleam test`, and `openspec validate add-sistemas-operativos-book` so CI checks and the change artifacts pass.

## Workflow follow-up

- Sync the delta specs into the main specs and archive the change after verification.
