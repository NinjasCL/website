# Spec Delta

## ADDED Requirements

### Requirement: The blog post title and date lead with icons
The blog post's presentation SHALL lead its title with the newspaper icon and its date with the calendar icon — on the home page's featured post row and on the post page's article alike — through the shared inline icon presentation: decorative icons beside their text, empty alt, served from the reorganized Win95 pack at `/icons/win95/`.

#### Scenario: Featured post title and date on the home page
- **WHEN** the home page is rendered with at least one post
- **THEN** the featured post's title leads with the newspaper icon (`/icons/win95/Mailnews8_32x32_4.png`) and its post-meta date leads with the calendar icon (`/icons/win95/Timedate_32x32_4.png`)

#### Scenario: Post page title and date
- **WHEN** a post page is rendered from the post template
- **THEN** the post's title leads with the newspaper icon and its post-meta date leads with the calendar icon, matching the featured post's presentation
