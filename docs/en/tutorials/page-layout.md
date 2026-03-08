---
sidebar_position: 3
---

# Page Layout

Touying gives you full control over the layout of every slide — margins, headers, footers, columns, and background. This tutorial explains Typst's page model as it applies to presentations, and shows how Touying builds on it.

## Typst's Page Model

Typst divides a page into four regions: **margin**, **header**, **footer**, and **content**. Understanding this model is important if you want to customise the appearance of your slides.

```example
#let container = rect.with(height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(stroke: (dash: "dashed"))

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  header: container[#innerbox[Header]],
  header-ascent: 30%,
  footer: container[#innerbox[Footer]],
  footer-descent: 30%,
)

#place(top + right)[Margin→]
#container[
  #container[
    #innerbox[Content]
  ]
]
```

Key points:

- **Margin** — empty space around all four edges.
- **Header** — rendered inside the top margin. `header-ascent` controls how far it floats up from the content area.
- **Footer** — rendered inside the bottom margin. `footer-descent` controls how far it sinks from the content area.
- **`#place`** — absolute positioning within the page, does not affect normal flow. Great for logos and decorative elements.

## Touying's Page Management

In plain Typst, each `set page(…)` call creates a **new page** with those settings. Touying instead maintains a `self.page` dictionary that it applies once per slide, so you never call `set page(…)` directly.

Configure the page through `config-page(…)`:

```typst
#show: my-theme.with(
  config-page(
    margin: (x: 4em, y: 2em),
    header: align(top)[My Header],
    footer: align(bottom)[My Footer],
    header-ascent: 0em,
    footer-descent: 0em,
  ),
)
```

:::warning

Never use `set page(…)` in a Touying document — Touying will reset it every slide.

:::

You can also override the page config for a single slide:

```typst
#slide(
  config: config-page(fill: black),
)[
  Dark background slide.
]
```

## Full-Width Headers and Footers

By default the header and footer are constrained to the content width. To make them span the full page width, Touying automatically applies *negative padding* when `config-common(zero-margin-header: true)` (the default for most themes):

```typst
config-common(zero-margin-header: true, zero-margin-footer: true)
```

Themes handle this automatically — you only need to know about it when building a custom theme.

## Columns (Side-by-Side Layouts)

The `#slide` function accepts a `composer` parameter for multi-column layouts. Pass a sequence of column widths as a tuple:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(composer: (1fr, 1fr))[
  Left column.
][
  Right column.
]
```

Each extra content block (`[…]`) becomes a column. The `composer` tuple defines the widths:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
// Right column takes only its natural width
#slide(composer: (1fr, auto))[
  Flexible left.
][
  Fixed right.
]
```

Touying uses `components.side-by-side` internally. The default is equal-width columns:

```typst
// equivalent to composer: (1fr, 1fr, 1fr) for three bodies
#slide[col 1][col 2][col 3]
```

## Background Color and Fill

Change the background colour for all slides:

```typst
config-page(fill: rgb("#1e1e2e"))
```

For a single slide:

```typst
#slide(config: config-page(fill: gradient.linear(blue, purple)))[
  Gradient background.
]
```

## Aspect Ratio

All themes accept an `aspect-ratio` parameter at initialisation:

```typst
#show: my-theme.with(aspect-ratio: "16-9")
// or
#show: my-theme.with(aspect-ratio: "4-3")
```

For a custom size, pass `config-page` directly:

```typst
#show: my-theme.with(
  config-page(width: 254mm, height: 190mm),
)
```

## Utility: `fit-to-width` and `fit-to-height`

Scale content to fill a specific width or height without overflow. Useful for long titles in headers or large figures:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-width(grow: false, 80%)[
    #text(size: 48pt)[Very long title that must fit]
  ]
]
```

Parameters for `fit-to-width(grow, shrink, width, body)`:
- `grow: true` — enlarge content if it is smaller than `width`.
- `shrink: true` — shrink content if it overflows `width`.

`fit-to-height` works analogously.

## Placing Elements Absolutely

Use Typst's `#place(alignment, dx, dy)[…]` for decorative overlays:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Regular content.

  #place(top + right, dx: -1em, dy: 1em)[
    #text(fill: red)[★ NEW]
  ]
]
```
