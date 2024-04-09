---
sidebar_position: 5
---

# Page Layout

## Basic Concepts

To create aesthetically pleasing slides using Typst, it is essential to understand Typst's page model correctly. If you don't care about customizing the page style, you can choose to skip this section. However, it is still recommended to go through this part.

Here, we illustrate Typst's default page model with a specific example.

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
#let padding = (x: 2em, y: 2em)

#place(top + right)[Margin→]
#container[
  #place[Padding]
  #pad(..padding)[
    #container[
      #innerbox[Content]
    ]
  ]
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/6cbb1092-c733-41b6-a15d-822ce970ef13)

We need to distinguish the following concepts:

1. **Model:** Typst has a model similar to the CSS Box Model, divided into Margin, Padding, and Content. However, padding is not a property of `set page(..)` but is obtained manually by adding `#pad(..)`.
2. **Margin:** Margins, including top, bottom, left, and right, are the core of Typst's page model. Other properties are influenced by margins, especially Header and Footer, which are actually inside the Margin.
3. **Padding:** Used to add additional space between Margin and Content.
4. **Header:** The Header is the content at the top of the page, divided into container and innerbox. We can notice that the edge of the header container and padding does not align but has a certain gap. This gap is actually `header-ascent: 30%`, and the percentage is relative to margin-top. Also, we notice that the header innerbox is actually located at the bottom left corner of the header container, meaning the innerbox defaults to `#set align(left + bottom)`.
5. **Footer:** The Footer is the content at the bottom of the page, divided into container and innerbox. We can notice that the edge of the footer container and padding does not align but has a certain gap. This gap is actually `footer-descent: 30%`, and the percentage is relative to margin-bottom. Also, we notice that the footer innerbox is actually located at the top left corner of the footer container, meaning the innerbox defaults to `#set align(left + top)`.
6. **Place:** The `place` function can achieve absolute positioning, relative to the parent container, without affecting other elements within the parent container. It can take parameters like `alignment`, `dx`, and `dy`, making it suitable for placing decorative elements such as logos.

Therefore, to apply Typst to create slides, we only need to set

```typst
#set page(
  margin: (x: 0em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
)
#let padding = (x: 4em, y: 0em)
```

For example, we have

```typst
#let container = rect.with(stroke: (dash: "dashed"), height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(fill: rgb("#d0d0d0"))

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  margin: (x: 0em, y: 2em),
  header: container[#align(top)[#innerbox(width: 100%)[Header]]],
  header-ascent: 0em,
  footer: container[#align(bottom)[#innerbox(width: 100%)[Footer]]],
  footer-descent: 0em,
)
#let padding = (x: 4em, y: 0em)

#place(top + right)[↑Margin]
#container[
  #place[Padding]
  #pad(..padding)[
    #container[
      #innerbox[Content]
    ]
  ]
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/6127d231-86f3-4262-b7c6-b199d47ae12b)

## Page Management

Since using the `set page(..)` command in Typst to modify page parameters creates a new page and cannot modify the current one, Touying chooses to maintain an `s.page-args` member variable and an `s.padding` member variable. Touying applies these parameters only when creating new slides, so users only need to focus on `s.page-args` and `s.padding`.

For example, the previous example can be transformed into

```typst
#(s.page-args += (
  margin: (x: 0em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
))
#(s.padding += (x: 4em, y: 0em))
```

Similarly, if you are not satisfied with the header or footer style of a theme, you can use

```typst
#(s.page-args.footer = [Custom Footer])
```

to replace it. However, please note that if you replace the page parameters in this way, you need to place it before `#let (slide,) = utils.slides(s)`, or you need to call `#let (slide,) = utils.slides(s)` again.

:::warning[Warning]

Therefore, you should not use the `set page(..)` command on your own; instead, you should modify the `s.page-args` member variable internally.

:::

In this way, we can also query the current page parameters in real-time through `s.page-args`. This is useful for some functions that need to get margin or the current page's background color, such as `transparent-cover`. This is partly equivalent to the context get rule, and it is actually more convenient to use.

## Application: Adding a Logo

Adding a logo to slides is a very common but also a very versatile requirement. The difficulty lies in the fact that the required size and position of the logo often vary from person to person. Therefore, most of Touying's themes do not include configuration options for logos. But with the concepts of page layout mentioned in this section, we know that we can use the `place` function in the header or footer to place a logo image.

For example, suppose we decide to add the GitHub icon to the metropolis theme. We can implement it like this:

```typst
#import "@preview/touying:0.3.1": *
#import "@preview/octique:0.1.0": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9")
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
#slide(composer: utils.side-by-side.with(columns: (1fr, auto), gutter: 1em))[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc)

