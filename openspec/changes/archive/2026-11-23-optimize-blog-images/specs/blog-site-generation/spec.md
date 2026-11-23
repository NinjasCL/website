# Spec Delta

## ADDED Requirements

### Requirement: Post images are served from local files

All images referenced by a post SHALL be stored under that post's directory in the content source, whether originally local or downloaded from an external host. Generated pages SHALL reference those local paths only.

#### Scenario: A remote cover is localized
- **WHEN** a post's `featured_image` points to an external image URL
- **THEN** the image is stored in that post's directory and `featured_image` points to the local path
- **AND** the generated page requests the image from the site, not the external host

#### Scenario: A remote inline image is localized
- **WHEN** a post body contains an inline external image reference
- **THEN** the image is stored in that post's directory and the inline reference points to the local file

#### Scenario: Repeat runs do not re-download
- **WHEN** the optimization task runs again after an image has been localized
- **THEN** the existing local image is reused without another network request

### Requirement: Post images are optimized once

The optimization task SHALL optimize each image under the content directory at most once per content hash and SHALL record optimized content hashes in the root-level `optimize-manifest.json`. An image whose current hash is already recorded SHALL be left unchanged.

#### Scenario: First run optimizes an image
- **WHEN** an unrecorded image is found under the content directory
- **THEN** the task optimizes it and records its new content hash in the root manifest

#### Scenario: Later runs skip optimized images
- **WHEN** the task encounters an image whose hash is recorded as optimized
- **THEN** the task leaves the file bytes unchanged and does not re-encode it

#### Scenario: A changed image is optimized again
- **WHEN** a recorded image's bytes change so its hash no longer matches the manifest
- **THEN** the task optimizes the changed image and updates the manifest

### Requirement: Static assets stay verbatim

Files under the static asset directory SHALL NOT be optimized, resized, renamed, or rewritten by the optimization task, and SHALL reach generated output byte-for-byte unchanged.

#### Scenario: Static images are untouched
- **WHEN** the optimization task completes
- **THEN** every file under `static/` has the same bytes it had before the task ran

#### Scenario: Static images reach the site unchanged
- **WHEN** the site is generated after optimization
- **THEN** files copied from `static/` into the output directory are byte-identical to their sources
