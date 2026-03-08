---
sidebar_position: 4
---

# Global Settings and Configuration

Touying uses a set of `config-*` functions to configure every aspect of a presentation. Pass them to the theme `#show:` call, and Touying merges them into a single `self` state object that is available to headers, footers, slide functions, and animation helpers.

## Configuration Overview

| Function | What it controls |
|----------|-----------------|
| `config-info(…)` | Title, author, date, institution, logo |
| `config-colors(…)` | Color palette |
| `config-common(…)` | Global feature flags (handout, frozen-counters, …) |
| `config-page(…)` | Typst page settings (margin, fill, paper, …) |
| `config-methods(…)` | Slide functions and init hook |

All of them can be combined in a single `with(…)` call:

```typst
#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [My Talk], author: [Alice]),
  config-colors(primary: blue),
  config-common(handout: false),
)
```

Or combined with `utils.merge-dicts`:

```typst
#slide(
  config: utils.merge-dicts(
    config-colors(primary: red),
    config-page(fill: black),
  ),
)[Content]
```

## `config-info` — Document Metadata

```typst
config-info(
  title: [Presentation Title],
  subtitle: [Optional Subtitle],
  author: [Author Name],
  date: datetime.today(),
  institution: [University / Company],
  logo: image("logo.png"),   // or emoji.school, or any content
)
```

All fields are optional. Access them inside slide functions via `self.info.title`, `self.info.author`, etc.

The `date` field accepts:
- A `datetime` value — formatted automatically.
- Any `content` — displayed as-is.

Change the date display format:

```typst
config-common(datetime-format: "[year]-[month]-[day]")
// or
config-common(datetime-format: "[month repr:long] [day], [year]")
```

## `config-colors` — Color Palette

Every theme defines a default color palette. You can override any color:

```typst
config-colors(
  primary: rgb("#005bac"),
  secondary: rgb("#ff6b35"),
  neutral-lightest: white,
  neutral-darkest: black,
)
```

The standard color slots used across themes:

| Slot | Typical use |
|------|------------|
| `primary` | Accent color, headings, progress bars |
| `secondary` | Secondary accent |
| `tertiary` | Tertiary accent |
| `neutral-lightest` | Slide background |
| `neutral-light` | Subtle highlights |
| `neutral-dark` | Muted text |
| `neutral-darkest` | Main body text |

Access the current colors in slide functions with `self.colors.primary`, etc.

## `config-common` — Feature Flags

`config-common` is the most frequently used configuration function. Here are its most useful options:

### Slide Level

```typst
config-common(slide-level: 2)  // default for most themes
```

Controls how deep headings go before creating a new slide.

### Handout Mode

```typst
config-common(handout: true)
```

Renders only the last subslide of each animated slide. Ideal for distributing slides to an audience.

```typst
// Show first subslide in handout mode
config-common(handout: true, handout-subslides: 1)
```

### Frozen Counters

Stop theorem/equation counters from resetting between subslides:

```typst
config-common(frozen-counters: (theorem-counter,))
```

Without this, if you use `#pause` on a slide with a theorem, the theorem number may change between subslides.

### Subslide Preamble

Add a title to each subslide automatically (useful for themes that don't add one by default):

```typst
config-common(
  subslide-preamble: self => text(
    1.2em,
    weight: "bold",
    utils.display-current-heading(depth: self.slide-level),
  ),
)
```

### List and Enum Formatting

```typst
// Force non-tight spacing (equivalent to tight: false)
config-common(nontight-list-enum-and-terms: true)

// Scale list item text
config-common(scale-list-items: 0.85)

// Show/hide list markers when covered by #pause
config-common(show-hide-set-list-marker-none: true)
```

### Bibliography as Footnotes

```typst
config-common(
  bibliography-as-footnote: bibliography(title: none, "refs.bib"),
)
```

This moves all bibliography entries to footnote-style citations on each slide.

### Speaker Notes Display

```typst
// Show speaker notes on a second screen (right)
config-common(show-notes-on-second-screen: right)

// Full-screen notes mode with slide thumbnail
config-common(show-only-notes: true)
```

### Preamble

Run arbitrary Typst code before every slide — useful for initialising packages like Codly:

```typst
config-common(preamble: {
  // called before each slide
  codly(zebra-fill: none)
})
```

## `config-page` — Page Parameters

Wraps Typst's `set page(…)` settings:

```typst
config-page(
  paper: "presentation-16-9",   // or "presentation-4-3"
  margin: (x: 4em, y: 2em),
  fill: rgb("#ffffff"),
  header: align(top)[Custom Header],
  footer: align(bottom)[Custom Footer],
  header-ascent: 0em,
  footer-descent: 0em,
)
```

## `config-methods` — Slide Hooks

Override the functions used by the theme engine:

```typst
config-methods(
  // Change how content is covered (hidden) during animations
  cover: utils.semi-transparent-cover.with(alpha: 85%),

  // Custom alert (bold + primary color)
  alert: utils.alert-with-primary-color,

  // Run code before the first slide
  init: (self: none, body) => {
    set text(font: "Fira Sans", size: 20pt)
    body
  },
)
```

## Global Styles

Set Typst `set` and `show` rules anywhere before or after the theme `#show:` call:

```typst
#show: my-theme.with(…)

// These apply to all slides
#set text(font: "Libertinus Serif")
#set par(justify: true)
#show strong: set text(fill: red)
```

You can also place them inside `config-methods(init: …)` to access `self` (e.g., for theme colors):

```typst
config-methods(
  init: (self: none, body) => {
    set text(fill: self.colors.neutral-darkest)
    show heading: set text(fill: self.colors.primary)
    body
  },
)
```

## Per-Slide Configuration Override

Every `#slide` function accepts a `config:` argument that overrides global settings for that slide only:

```typst
#slide(
  config: utils.merge-dicts(
    config-colors(primary: orange),
    config-page(fill: luma(95%)),
  ),
)[
  This slide has an orange accent and a grey background.
]
```
