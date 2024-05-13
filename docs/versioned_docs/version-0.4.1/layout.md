---
sidebar_position: 5
---

# Page Layout

## Basic Concepts

To create stylish slides using Typst, it's essential to understand Typst's page model correctly. If you're not concerned with customizing page styles, you can choose to skip this section. However, it's still recommended to go through it.

Let's illustrate Typst's default page model through a specific example.

```typst
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

![image](https://github.com/touying-typ/touying/assets/34951714/70d48053-c777-4253-a9ca-ada360b5a987)

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

```typst
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

![image](https://github.com/touying-typ/touying/assets/34951714/d74896f4-90e7-4b36-a5a9-9c44307eb192)

## Page Management

Since modifying page parameters using the `set page(..)` command in Typst creates a new page instead of modifying the current one, Touying chooses to maintain a `s.page-args` member variable and a `s.padding` member variable. These parameters are only applied when Touying creates a new slide, so users only need to focus on `s.page-args` and `s.padding`.

For example, the previous example can be modified as follows:

```typst
#(s.page-args += (
  margin: (x: 4em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
))
```

Touying automatically detects the value of `margin.x` and adds negative padding to the header if `self.full-header == true`.

Similarly, if you're unsatisfied with the header or footer style of a particular theme, you can change it using:

```typst
#(s.page-args.footer = [Custom Footer])
```

However, it's essential to note that if you change page parameters in this way, you need to place it before `#let (slide, empty-slide) = utils.slides(s)`, or you'll have to call `#let (slide, empty-slide) = utils.slides(s)` again.

:::warning[Warning]

Therefore, you should not use the `set page(..)` command directly but instead modify the `s.page-args` member variable internally.

:::

This approach also allows us to query the current page parameters in real-time using `s.page-args`, which is useful for functions that need to obtain margins or the current page's background color, such as `transparent-cover`. This is partially equivalent to context get rule and is actually more convenient to use.

## Application: Adding a Logo

Adding a logo to slides is a very common but also a very versatile requirement. The difficulty lies in the fact that the required size and position of the logo often vary from person to person. Therefore, most of Touying's themes do not include configuration options for logos. But with the concepts of page layout mentioned in this section, we know that we can use the `place` function in the header or footer to place a logo image.

For example, suppose we decide to add the GitHub icon to the metropolis theme. We can implement it like this:

```typst
#import "@preview/touying:0.4.1": *
#import "@preview/octique:0.1.0": *

#let s = themes.metropolis.register(aspect-ratio: "16-9")
#(s.page-args.header = self => {
  // display the original header
  utils.call-or-display(self, s.page-args.header)
  // place logo at the top-right
  place(top + right, dx: -0.5em, dy: 0.3em)[
    #octique("mark-github", color: rgb("#fafafa"), width: 1.5em, height: 1.5em)
  ]
})
#let (init, slide) = utils.methods(s)
#show: init

#slide(title: [Title])[
  Logo example.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/055d77e7-5087-4248-b969-d8ef9d50c54b)

Here, `utils.call-or-display(self, body)` can be used to display `body` as content or a callback function in the form `self => content`.

## Page Columns

If you need to divide the page into two or three columns, you can use the `compose` feature provided by the default `slide` function in Touying. The simplest example is as follows:

```typst
#slide[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/a39f88a2-f1ba-4420-8f78-6a0fc644704e)

If you need to change the way columns are composed, you can modify the `composer` parameter of `slide`. The default parameter is `utils.side-by-side.with(columns: auto, gutter: 1em)`. If we want the left column to occupy the remaining width, we can use

```typst
#slide(composer: (1fr, auto))[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc)

