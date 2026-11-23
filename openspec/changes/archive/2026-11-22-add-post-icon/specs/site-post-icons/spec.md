# Spec Delta

## Purpose

Defines the per-post title icon: the djot frontmatter key that declares it,
how the value resolves against the site's static icon packs, the newspaper
fallback, and every title site that renders it.

## ADDED Requirements

### Requirement: Posts declare their title icon in frontmatter
A post MAY declare an `icon` frontmatter key naming one of the site's static icon files. The value SHALL resolve against `static/icons/`: a bare filename searches the win95 pack first and then the macos9 pack; a subdirectory-qualified name (`win95/Star_32x32_4.png`) and a `/icons/`-prefixed path resolve directly.

#### Scenario: A bare win95 filename resolves
- **WHEN** a post declares `icon: Bulb_32x32_4.png`
- **THEN** the post's title icon is `/icons/win95/Bulb_32x32_4.png`

#### Scenario: A bare macos9 filename resolves
- **WHEN** a post declares `icon: 1.png`
- **THEN** the post's title icon is `/icons/macos9/1.png`

#### Scenario: A qualified name resolves directly
- **WHEN** a post declares `icon: win95/Star_32x32_4.png`
- **THEN** the post's title icon is `/icons/win95/Star_32x32_4.png`

#### Scenario: An /icons-prefixed path is tolerated
- **WHEN** a post declares `icon: /icons/macos9/5.png`
- **THEN** the post's title icon is `/icons/macos9/5.png`

### Requirement: The newspaper icon is the fallback
A post whose `icon` frontmatter is absent, empty, or names a file that does not exist under `static/icons/` SHALL fall back to the newspaper icon `/icons/win95/Mailnews8_32x32_4.png` — the icon every post title uses today — so a missing or mistyped value never renders a broken image.

#### Scenario: No icon declared
- **WHEN** a post carries no `icon` frontmatter key
- **THEN** the post's title icon is `/icons/win95/Mailnews8_32x32_4.png`

#### Scenario: An unknown filename falls back
- **WHEN** a post declares `icon: NoSuchIcon_32x32_4.png`
- **THEN** the post's title icon is `/icons/win95/Mailnews8_32x32_4.png`

#### Scenario: An empty value falls back
- **WHEN** a post declares `icon:` with an empty value
- **THEN** the post's title icon is `/icons/win95/Mailnews8_32x32_4.png`

### Requirement: The post's icon leads its title on every page
The resolved title icon SHALL lead the post's title through the shared inline icon presentation — decorative beside the text, empty alt — wherever the title renders: the post page's article title, the blog index entry cards, the home page's featured post row, and the posts lists — both the home's "Más entradas" list and the post page's "Otras entradas" random list, which render through the same entry presentation.

#### Scenario: The post page title carries the icon
- **WHEN** a post page is rendered for a post that declares `icon: Bulb_32x32_4.png`
- **THEN** the article's title leads with `/icons/win95/Bulb_32x32_4.png`

#### Scenario: The index entry card title carries the icon
- **WHEN** a blog index page lists a post that declares `icon: Bulb_32x32_4.png`
- **THEN** the entry card's title leads with `/icons/win95/Bulb_32x32_4.png`

#### Scenario: The featured post title carries the icon
- **WHEN** a home page's featured post declares `icon: Bulb_32x32_4.png`
- **THEN** the featured row's linked title leads with `/icons/win95/Bulb_32x32_4.png`

#### Scenario: The star lists' entries carry their icons
- **WHEN** a home page renders its "Más entradas" list, or a post page renders its "Otras entradas" list, with listed posts that declare icons
- **THEN** each listed entry's linked title leads with that post's resolved icon

### Requirement: Translated variants repeat the default's icon
Every language variant of a post that declares an `icon` SHALL declare the same value in its own frontmatter — the same convention the variants already follow for `slug` — so every language's page of the post shows the icon.

#### Scenario: All variants repeat the icon
- **WHEN** a post's default variant declares an `icon` value
- **THEN** the post's English, Japanese, and Portuguese variants declare the same value
