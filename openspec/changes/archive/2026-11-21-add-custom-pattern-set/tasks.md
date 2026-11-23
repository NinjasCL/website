# Tasks

## 1. The custom pattern set

- [x] 1.1 Create `static/patterns/custom/` by moving
  `static/patterns/blossom.png` into it (`custom/blossom.png`), and fix
  the picker: the `static/background.js` array entry becomes
  `"custom/blossom.png"` and the file's comment names the three sets
  (numbered macOS, named Windows 3.1, and the custom set for
  owner-added tiles). The array format the owner introduced stays.
  Verify with `gleam test` once 1.2 lands, or by checking the offered
  entry against the moved file.
- [x] 1.2 Update `background_patterns_match_shipped_files_test` in
  `test/ninjas_test.gleam` for the array format: the offered list is
  the array literal between `[` and `]`, its entries trimmed of quotes
  and whitespace; the shipped comparison reads
  `./static/patterns/custom` alongside `macos9` and `win3.1`, prefixed
  `custom/`, filtering to PNGs. Verify with `gleam test` — the suite
  returns to fully green.

## 2. Verification

- [x] 2.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `gleam test` and confirm the full suite passes.
- [x] 2.3 Run `openspec validate add-custom-pattern-set` and confirm it
  passes.

## Workflow follow-up

- After review, sync/archive the change with the
  `openspec-archive-change` workflow. The pending `add-head-meta` apply
  completes right after — its only outstanding check was this suite
  failure.
