# Spec Delta

## Purpose

Provide a local development server for the Ninjas.cl blog that reuses the production build configuration, watches source and content files, rebuilds automatically, and serves the generated site with live reload.

## ADDED Requirements

### Requirement: Build and dev server share configuration
The system SHALL use the same blogatto site configuration for production builds and for the development server.

#### Scenario: Build uses shared configuration
- **WHEN** the production build entrypoint runs
- **THEN** it generates the site from the same site URL, output directory, static directory, post paths, routes, and templates used by the dev server

### Requirement: Dev server serves the generated site
The system SHALL start a local HTTP server from a dedicated development entrypoint and serve the site from the configured output directory.

#### Scenario: Home page is served locally
- **WHEN** the development entrypoint is started and the initial build completes
- **THEN** a request for `/` returns the generated home page from the configured output directory

#### Scenario: Post page is served locally
- **WHEN** a post exists in the configured post source
- **THEN** a request for that post's route returns the generated post page

### Requirement: Dev server watches and rebuilds
The development server SHALL watch Gleam source files, configured post directories, and the configured static directory, and rebuild the site when watched files change.

#### Scenario: Content change triggers rebuild
- **WHEN** a watched post or asset file changes while the dev server is running
- **THEN** the server rebuilds the site using the configured build command and serves the updated output

#### Scenario: Rebuild failure preserves the last successful site
- **WHEN** a rebuild command fails
- **THEN** the dev server remains running and continues serving the last successful build

### Requirement: Dev server supports live reload
The development server SHALL enable live reload by default so connected browsers refresh after a successful rebuild.

#### Scenario: HTML response includes reload support
- **WHEN** the dev server serves an HTML page with live reload enabled
- **THEN** the response includes the blogatto live-reload client and exposes the reload event stream endpoint

### Requirement: Dev server command is documented
The project documentation SHALL describe how to start the development server and the local URL it serves.

#### Scenario: Reader can start the dev server
- **WHEN** a reader follows the documented development command
- **THEN** the dev server starts and the documentation identifies the local URL to open
