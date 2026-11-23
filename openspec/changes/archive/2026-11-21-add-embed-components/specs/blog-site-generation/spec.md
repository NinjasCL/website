# Spec Delta

## ADDED Requirements

### Requirement: Content tags render as embed components
A fenced content block whose info string is `github`, `youtube`, or `ninjas` SHALL render as its embed instead of a code panel: a GitHub card linking the repository, a YouTube player for the video, and a card linking the site's blog post carrying its title.

#### Scenario: The GitHub fence renders a repository card
- **WHEN** a post carries a ```` ```github ```` fence with an owner/repo
- **THEN** the page renders an embed card linking `https://github.com/owner/repo`, showing the repository name

#### Scenario: The YouTube fence renders a player
- **WHEN** a post carries a ```` ```youtube ```` fence with a watch URL, a youtu.be URL, or a bare video id
- **THEN** the page renders the video's embedded YouTube player

#### Scenario: The ninjas fence renders a blog post card
- **WHEN** a post carries a ```` ```ninjas ```` fence with a slug and title
- **THEN** the page renders an embed card linking the site's blog post, carrying the given title

#### Scenario: Real code keeps its panel
- **WHEN** a fenced block carries a code language (or none)
- **THEN** it still renders inside the Night Owl code panel, with highlighting and the `{summary}` toggle behavior unchanged in substance
