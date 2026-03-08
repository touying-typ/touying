---
sidebar_position: 5
---

# Page Layout

## Basic Concepts

To create stylish slides using Typst, it's essential to understand Typst's page model correctly. If you're not concerned with customizing page styles, you can choose to skip this section. However, it's still recommended to go through it.

Let's illustrate Typst's default page model through a specific example.

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

We need to distinguish the following concepts:

1. **Model:** Typst has a model similar to the CSS Box Model, divided into Margin, Padding, and Content. However, padding is not a property of `set page(..)` but is obtained by manually adding `#pad(..)`.
2. **Margin:** Margins are the edges of the page, divided into top, bottom, left, and right. They are the core of Typst's page model, and all other properties are influenced by margins, especially Header and Footer. Header and Footer are actually located within the Margin.
4. **Header:** The Header is the content at the top of the page, divided into container and innerbox. We can observe that the edge of the header container and padding does not align but has some space in between, which is actually `header-ascent: 30%`, where the percentage is relative to the margin-top. Additionally, we notice that the header innerbox is actually located at the bottom left corner of the header container, meaning innerbox defaults to `#set align(left + bottom)`.
5. **Footer:** The Footer is the content at the bottom of the page, similar to the Header but in the opposite direction.
6. **Place:** The `place` function enables absolute positioning relative to the parent container without affecting other elements inside the parent container. It allows specifying `alignment`, `dx`, and `dy`, making it suitable for placing decorative elements like logos.

Therefore, to apply Typst to create slides, we only need to set:

```typst
#set page(
  margin: (x: 4em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
)
```

However, we still need to address how the header occupies the entire page width. Here, we use negative padding to achieve this. For instance:

```example
#let container = rect.with(stroke: (dash: "dashed"), height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(fill: rgb("#d0d0d0"))
#let margin = (x: 4em, y: 2em)

// negative padding for header and footer
#let negative-padding = pad.with(x: -margin.x, y: 0em)

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  margin: margin,
  header: negative-padding[#container[#align(top)[#innerbox(width: 100%)[Header]]]],
  header-ascent: 0em,
  footer: negative-padding[#container[#align(bottom)[#innerbox(width: 100%)[Footer]]]],
  footer-descent: 0em,
)

#place(top + right)[↑Margin→]
#container[
  #container[
    #innerbox[Content]
  ]
]
```

## Page Management

In Typst, using the `set page(..)` command to modify page parameters results in the creation of a new page, rather than modifying the current one. Therefore, Touying opts to maintain a `self.page` member variable.

For example, the previous example can be rewritten as:

```typst
#show: default-theme.with(
  config-page(
    margin: (x: 4em, y: 2em),
    header: align(top)[Header],
    footer: align(bottom)[Footer],
    header-ascent: 0em,
    footer-descent: 0em,
  ),
)
```

Touying will automatically detect the value of `margin.x` and determine whether to apply negative padding to the header if `config-common(zero-margin-header: true)` is set, which is equivalent to `self.zero-margin-header = true`.

Similarly, if you are not satisfied with the style of the header or footer of a particular theme, you can also modify it through:

```typst
config-page(footer: [Custom Footer])
```

:::warning[Warning]

Therefore, you should not use the `set page(..)` command yourself, as it will be reset by Touying.

:::

With this approach, we can also query the current page parameters in real-time using `self.page`, which is very useful for functions that need to obtain the page margins or the current page background color, such as `transparent-cover`. This is somewhat equivalent to context get rule, and in practice, it is more convenient to use.

## Page Columnization

If you need to divide a page into two or three columns, you can use the `composer` feature provided by the default `slide` function in Touying. The simplest example is as follows:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  First column.
][
  Second column.
]
```

If you need to change the way columns are divided, you can modify the `composer` parameter of `slide`, where the default parameter is `components.side-by-side.with(columns: auto, gutter: 1em)`. If we want the left column to take up the remaining width, we can use:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(composer: (1fr, auto))[
  First column.
][
  Second column.
]
```