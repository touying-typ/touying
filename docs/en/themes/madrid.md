---
sidebar_position: 8
---

# Madrid Theme

The Madrid theme recreates the classic LaTeX Beamer Madrid theme for Touying, featuring 3D spherical bullet points ("beamer balls"), rounded colored blocks, and a distinctive three-part footer bar displaying author, presentation title, and date / slide counter.

## Initialization

You can initialize it with the following code:

```typst
#import "@preview/touying:0.8.0": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()
```

The `madrid-theme` function accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides ("16-9" or "4-3"), default is `"16-9"`.
- `title`: The content displayed in the top header banner, default is `self => utils.display-current-heading(depth: self.slide-level)`.
- `subtitle`: Optional subtitle displayed below the slide title in the header banner.
- `header`: Custom slide header override, default is `auto`.
- `footer`: Custom slide footer override, default is `auto`.
- `header-height`: Height of the top blue header bar, default is `2.2em`.
- `navigation-symbols`: Whether to show decorative Beamer navigation symbols above the footer on the right, default is `false`.
- `footer-left`: Content for the leftmost footer block (author by default).
- `footer-right`: Content for the middle footer block (title by default).
- `footer-date`: Content for the rightmost footer block (date by default).
- `font`: Font family for text, default is `auto`.

## Color Theme

The Madrid theme uses the classic Beamer Madrid colors by default:

```typst
config-colors(
  primary: rgb("#3333b3"),
  primary-light: rgb("#e8ebfa"),
  alert: rgb("#cc0000"),
  alert-light: rgb("#fae8e8"),
  example: rgb("#008000"),
  example-light: rgb("#e8fae8"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

## Blocks

The Madrid theme provides Beamer-style rounded blocks:

- `#cblock(title: [Title])[Body]` (or `#tblock(...)`): Standard block with primary color header.
- `#alert-block(title: [Title])[Body]`: Alert block with red accent header.
- `#example-block(title: [Title])[Body]`: Example block with green accent header.

## Slide Function Family

- `#title-slide(config: (:), extra: none, ..args)`: Displays the presentation title in a rounded blue block with author and institution below.
- `#outline-slide(config: (:), title: utils.i18n-outline-title, ..args)`: Displays a table of contents / outline slide.
- `#slide(...)`: Default slide function with Madrid header banner and three-part footer bar.
- `#new-section-slide(config: (:), level: 1, numbered: true, body)`: Slide separating major sections.
- `#focus-slide[Body]`: Full-bleed slide with primary background to focus the audience's attention.

## Speaker Notes

Madrid defines its own `notes` function styled with Madrid colors and registers it with `config-common(notes-fn: notes)`.
