# Spec Delta

## ADDED Requirements

### Requirement: Featured images use standardized local cover derivatives
Each post's `featured_image` SHALL resolve to a local 1280x720 raster image stored beside that post's original image. The derivative SHALL fill the 16:9 frame from the image's center, preserving the source's aspect ratio without adding letterbox bars, and the original image SHALL remain available for inline use.

#### Scenario: A post has a featured image
- **WHEN** a post declares a `featured_image`
- **THEN** the declared path points to a local 1280x720 image in that post's directory
- **AND** the image is a center-filled crop of the post's original image

#### Scenario: The original image stays intact
- **WHEN** a post's original image is optimized and its cover derivative is created
- **THEN** inline images in the post body still reference the original, uncropped image

#### Scenario: The fallback is unchanged
- **WHEN** a post has no `featured_image`
- **THEN** the featured figure still falls back to the verbatim static Ninjas logo

#### Scenario: A vector source becomes a raster cover
- **WHEN** a post's original featured image is an SVG
- **THEN** its local cover derivative is a rasterized PNG at 1280x720 while the SVG original remains unchanged
