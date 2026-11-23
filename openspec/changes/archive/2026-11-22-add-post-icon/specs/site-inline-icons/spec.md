# Spec Delta

## MODIFIED Requirements

### Requirement: The blog post title and date lead with icons
The blog post's presentation SHALL lead its title with the post's own title icon — the post's declared `icon` frontmatter value, or the newspaper icon as its fallback (see `site-post-icons`) — and its date with the calendar icon — on the home page's featured post row and on the post page's article alike — through the shared inline icon presentation: decorative icons beside their text, empty alt, served from the site's static icon assets.

#### Scenario: Featured post title and date on the home page
- **WHEN** the home page is rendered with at least one post
- **THEN** the featured post's title leads with that post's icon — its declared value, or the newspaper icon (`/icons/win95/Mailnews8_32x32_4.png`) when it declares none — and its post-meta date leads with the calendar icon (`/icons/win95/Timedate_32x32_4.png`)

#### Scenario: Post page title and date
- **WHEN** a post page is rendered from the post template
- **THEN** the post's title leads with the post's own icon — its declared value, or the newspaper fallback — and its post-meta date leads with the calendar icon, matching the featured post's presentation
