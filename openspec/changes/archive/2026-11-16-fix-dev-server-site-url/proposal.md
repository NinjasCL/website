# Proposal

## Why

The development server rebuilds the site through the production entrypoint, so every generated absolute URL points at `https://ninjas.cl/`. That makes local link testing inaccurate and can send local navigation to the live site. Production builds should keep using the Ninjas.cl URL, while development builds should use the local server URL.

## What Changes

- Make the shared blogatto configuration accept the site URL instead of hardcoding the production URL.
- Add explicit production and development site URL constants.
- Add a development build entrypoint that generates the site with the local URL.
- Configure the dev server to use the local site URL and rebuild through the development build entrypoint.
- Keep the production build entrypoint on `https://ninjas.cl/`.
- Add tests for both configurations and document the URL split.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `blog-dev-server`: the dev server uses the same site structure as production but with `http://127.0.0.1:3000/` as the site URL.
- `blog-site-generation`: production site generation continues to use `https://ninjas.cl/` as the site URL.

## Impact

- `src/site.gleam`, `src/blog.gleam`, `src/website.gleam`, and `src/dev.gleam`.
- A new development build entrypoint in `src/`.
- `test/website_test.gleam` and `README.md`.
- No new dependencies; this uses the existing blogatto `config` and `dev` APIs.
- Out of scope: changing the dev host or port, deployment configuration, content changes, or adding a new environment-variable mechanism.
