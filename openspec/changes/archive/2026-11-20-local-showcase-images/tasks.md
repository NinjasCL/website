# Tasks

## 1. Local cover assets

- [x] 1.1 Download the four book covers into `static/img/` from their production URLs — `superclubnet.jpg`, `elixir-fullstack.jpg`, `wren-libro.jpg`, `quirquincho.jpg` from `https://ninjas.cl/covers/…` — and verify each file exists, is a real JPEG (`file`), and has a non-trivial size; pause rather than proceed if any download fails.
- [x] 1.2 Confirm the four already-downloaded project logos (`elixircl.png`, `joyofpw.png`, `chaucha.png`, `Ninjas.png`) are valid PNGs via `file static/img/*.png`; they are reused as-is with no re-download.

## 2. Repoint showcase images

- [x] 2.1 Update the eight `image:` fields in `src/site.gleam`: the four "Proyectos" cards to `/img/elixircl.png`, `/img/joyofpw.png`, `/img/chaucha.png`, `/img/Ninjas.png`, and the four "Libros" cards to `/img/superclubnet.jpg`, `/img/elixir-fullstack.jpg`, `/img/wren-libro.jpg`, `/img/quirquincho.jpg`; alts unchanged, and the games cards and hero logo untouched. Verify with the test added in 2.2.
- [x] 2.2 Add a home view test in `test/ninjas_test.gleam` asserting the rendered home page contains the eight local `/img/…` image paths and no longer references the remote substrings unique to proyectos/libros (`avatars.githubusercontent.com`, `raw.githubusercontent.com/ElixirCL`, `ninjas.cl/covers`); verify with `gleam test`.

## 3. Checks

- [x] 3.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate local-showcase-images` and confirm it passes.

## Workflow follow-up

- Optionally eyeball the home page in a browser (`gleam run`): the eight proyectos/libros cards load their images from `/img/…` with no remote image requests in those sections; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive local-showcase-images`.
