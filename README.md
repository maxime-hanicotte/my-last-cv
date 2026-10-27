# my-last-cv

A Ruby gem and command-line tool that generates a styled PDF CV from Markdown.

## Requirements

Ruby 3.0 or later.

## Installation

```bash
bundle add my-last-cv
bundle install
```

For local development, install the project's dependencies:

```bash
bundle install
```

## Generate a CV

```bash
bundle exec my_last_cv path/to/cv.md output/cv.pdf
```

The output directory is created automatically. The CLI uses the bundled Inter and
Lora fonts. Start from [`sample/cv.md`](sample/cv.md) to create your document.

## Markdown format

Use YAML front matter for contact information, a level-one heading for the name,
level-two headings for sections, and level-three headings for entries within a
section:

```markdown
---
title: "Ruby developer"
email: "jane@example.com"
phone: "+33 6 12 34 56 78"
linkedin: "https://www.linkedin.com/in/janedoe"
github: "https://github.com/janedoe"
website: "https://janedoe.dev"
location: "Paris, France"
---

# Jane Doe
Short professional introduction displayed below the header.

## Experience
### Senior Developer — Example Corp
Introductory paragraph for this role.
- Built and maintained Ruby applications.
- Mentored other developers.

## Skills
- Ruby
- PostgreSQL
```

Supported front-matter contact keys are `name`, `title`, `email`, `phone`,
`linkedin`, `github`, `website`, and `location`. They are rendered with icons.

Text immediately below the main heading becomes the introduction. Section and
entry content can contain paragraphs and bullet lists. A `###` entry without a
preceding `##` section is placed in a section named `Divers`.

## Inline Markdown support

Contact fields, paragraphs, and bullet items support:

- `**bold**`
- `*italic*`
- `` `code` ``
- `[links](https://example.com)`

Escape Markdown punctuation with a backslash when it should remain literal, for
example `\*not italic\*`.

## Ruby API and styling

```ruby
require "my_last_cv"

style = MyLastCV::Style.new(
  header_font: "Inter",
  header_size: 22,
  section_font: "Inter",
  section_size: 12,
  body_font: "Lora",
  body_size: 10,
  page_options: { margin: 36 },
  accent_color: "1F7AE0"
)

MyLastCV.generate("cv.md", "output/cv.pdf", style: style)
```

`MyLastCV::Style` defaults to Helvetica, sizes `18`, `12`, and `10`, a page
margin of `48`, and a black accent color (`000000`). `page_options` is passed to
`Prawn::Document`, so Prawn page settings such as `page_size` and `layout` can
also be supplied.

## Custom fonts

Inter and Lora are bundled with the gem. To override them, provide a directory
containing `Inter-Regular.ttf`, `Inter-Bold.ttf`, `Lora-Regular.ttf`, and
`Lora-Bold.ttf`:

```ruby
MyLastCV::Style.new(fonts_dir: "/path/to/fonts")
```

Alternatively, set `MY_LAST_CV_FONTS_DIR=/path/to/fonts`. Font directories are
resolved in this order: `fonts_dir`, `MY_LAST_CV_FONTS_DIR`, `./fonts`, then the
fonts bundled with the gem.

## Development

```bash
bundle exec rake spec
```
