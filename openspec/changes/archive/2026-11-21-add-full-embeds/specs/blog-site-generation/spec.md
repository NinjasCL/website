# Spec Delta

## MODIFIED Requirements

### Requirement: Content tags render as embed components
A fenced content block whose info string is `github`, `youtube`, `ninjas`, or `embed` SHALL render as its embed instead of a code panel: a full OpenGraph card (site name, title, description, and image, the whole card one link) for `github`, `ninjas`, and external-website `embed` fences, and a full-width YouTube player for `youtube` fences.

#### Scenario: The GitHub fence renders a repository card
- **WHEN** a post carries a ```` ```github ```` fence with `owner/repo | description`
- **THEN** the page renders a full embed card linking `https://github.com/owner/repo`, carrying the repository name as its title, the given description as its text, the site name GitHub, and the repository's social card image (`https://opengraph.githubassets.com/1/owner/repo`) as its image

#### Scenario: The YouTube fence renders a player
- **WHEN** a post carries a ```` ```youtube ```` fence with a watch URL, a youtu.be URL, or a bare video id
- **THEN** the page renders the video's embedded YouTube player at full content width, 16:9 and at most 640px tall, inside the site's dashed frame, with the old template's allow list (`accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share`)

#### Scenario: The ninjas fence renders a blog post card
- **WHEN** a post carries a ```` ```ninjas ```` fence with `slug | Post title | description | image`
- **THEN** the page renders a full embed card linking `https://ninjas.cl/blog/slug/`, carrying the given title, description, and image, with the site name Ninjas.cl

#### Scenario: The embed fence renders a full external-website card
- **WHEN** a post carries a ```` ```embed ```` fence with `url | title | description | image`
- **THEN** the page renders a full embed card linking the given URL, carrying the given title, description, and image, with the site name derived from the URL's host

#### Scenario: Real code keeps its panel
- **WHEN** a fenced block carries a code language (or none)
- **THEN** it still renders inside the Night Owl code panel, with highlighting and the `{summary}` toggle behavior unchanged in substance
