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
- `header-height`: Height of the top blue header bar, default is `2.5em`.
- `navigation-symbols`: Whether to show Beamer navigation symbols above the footer on the right, default is `true`.
- `align`: Default content alignment, `horizon + left`. Vertically centered frames use Beamer's larger bottom stretch; pass `top + left` for top-aligned content.
- `font-size`: Base text size, default is `24pt`.
- `sans-math`: Use sans-serif math letters, as in Beamer, default is `true`. Set `false` to retain Typst's usual math variant.
- `logo`: Bottom-right logo content or a function receiving `self`; defaults to `self => self.info.logo`. Pass `none` to hide it.
- `block-shadow`, `title-shadow`: Whether blocks and the title panel cast shadows, both default to `true`.
- `section-outline-title`: Title of automatic section outline slides; defaults to the localized outline title.
- `footer-left`: Content for the leftmost footer block (author by default).
- `footer-right`: Content for the middle footer block (title by default).
- `footer-date`: Content for the rightmost footer block (date by default).
- `font`: Font family for text, default is `auto`.
- `title-font`, `small-font`: Optional fonts for frame/title-panel/block headings and footer/institution text, respectively. Both default to `auto`, inheriting the body font.

Each level-one heading (`= Section`) automatically creates a section slide with a progressive outline. Both outline variants use the same numbered spheres and linked blue text, without dot leaders or page numbers. The current section retains its normal appearance and other sections fade by `80%`. Ordinary outline slides show sections only by default; use `outline-slide(depth: 2)` to include slide headings. Use `config-common(new-section-slide-fn: none)` to disable automatic section slides, or `config-common(new-section-slide-fn: new-section-slide.with(alpha: 40%))` to change the fade.

The navigation groups link to physical pages, logical frames, subsection/slide headings, sections, and the beginning/end of the document. Destinations are clamped at the first and last pages. The final back/search/forward symbols are decorative: Typst cannot emit PDF viewer history or search actions. Setting `navigation-symbols: false` removes the complete symbol row.

For typography close to Beamer's Computer Modern Sans, install Latin Modern and select its optical variants explicitly:

```typst
#show: madrid-theme.with(
  font: "Latin Modern Sans",
  title-font: "Latin Modern Sans 12",
  small-font: "Latin Modern Sans 8",
  // Other configuration...
)
```

Fonts are supplied by the user, as in other Touying themes. `font: auto` preserves the surrounding document's font. Pass `--font-path /path/to/fonts` to the Typst CLI when the fonts are not installed system-wide. Size logos relative to the text, for example `config-info(logo: image("logo.svg", height: 2.6em))`, so they retain the same visual proportion when the paper size changes.

## Color Theme

The Madrid theme uses the classic Beamer Madrid colors by default:

```typst
config-colors(
  primary: rgb("#3333b3"),
  primary-light: rgb("#e9e9f3"),
  alert: rgb("#ff0000"),
  alert-light: rgb("#f9e5e5"),
  example: rgb("#008000"),
  example-light: rgb("#e5efe5"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

The theme parameters `primary-light`, `alert-light`, and `example-light` default to `auto`: their block-body colors derive from the corresponding base color at theme initialization. Block headers use a 25% darker shade of the base color; inline `#alert[...]` uses the alert color itself. To override a palette on an individual slide, pass its base and light colors through `config-colors(...)`.

## Blocks

The Madrid theme provides Beamer-style rounded blocks:

- `#cblock(title: [Title])[Body]` (or `#tblock(...)`): Standard block with primary color header.
- `#alert-block(title: [Title])[Body]`: Alert block with red accent header.
- `#example-block(title: [Title])[Body]`: Example block with green accent header.

## Slide Function Family

- `#title-slide(config: (:), extra: none, numbered: true, ..args)`: Displays the presentation title in a rounded blue block with author and institution below. The frame is counted by default; set `numbered: false` to exclude it. Named metadata such as `date:` overrides the presentation metadata for this slide.
- `#outline-slide(config: (:), title: utils.i18n-outline-title, numbered: true, depth: 1, ..args)`: Displays a table of contents / outline slide. `numbered: false` replaces numbered spheres with unnumbered bullets.
- `#slide(...)`: Default slide function with Madrid header banner and three-part footer bar.
- `#new-section-slide(config: (:), level: 1, numbered: true, alpha: 80%, title: auto, body)`: Progressive outline slide that highlights the current section. `alpha` controls how much other sections fade; `title: auto` reads `section-outline-title` from the theme.
- `#focus-slide[Body]`: Full-bleed slide with primary background to focus the audience's attention.

## Speaker Notes

Madrid defines its own `notes` function styled with Madrid colors and registers it with `config-common(notes-fn: notes)`.
