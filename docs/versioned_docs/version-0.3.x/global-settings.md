---
sidebar_position: 6
---

# Global Settings

## Global Styles

For Touying, global styles refer to set rules or show rules that need to be applied everywhere, such as `#set text(size: 20pt)`.

Themes in Touying encapsulate some of their own global styles, which are placed in `#show: init`. For example, the university theme encapsulates the following:

```typst
self.methods.init = (self: none, body) => {
  set text(size: 25pt)
  show footnote.entry: set text(size: .6em)
  body
}
```

If you are not a theme creator but want to add your own global styles to your slides, you can simply place them after `#show: init` and before `#show: slides`. For example, the metropolis theme recommends adding the following global styles:

```typst
#let s = themes.metropolis.register(s, aspect-ratio: "16-9")
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

// global styles
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides
```

However, note that you should not use `#set page(..)`. Instead, modify `s.page-args` and `s.padding`, for example:

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

## Global Information

Like Beamer, Touying, through an OOP-style unified API design, can help you better maintain global information, allowing you to easily switch between different themes. Global information is a typical example of this.

You can set the title, subtitle, author, date, and institution information for slides using:

```typst
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
```

In subsequent slides, you can access them through `s.info` or `self.info`.

This information is generally used in the title-slide, header, and footer of the theme, for example:

```typst
#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
```

The `date` can accept `datetime` format or `content` format, and the display format for the `datetime` format can be changed using:

```typst
#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")
```

:::tip[Principle]

Here, we will introduce a bit of OOP concept in Touying.

You should know that Typst is a typesetting language that supports incremental rendering, which means Typst caches the results of previous function calls. This requires that Typst consists of pure functions, meaning functions that do not change external variables. Thus, it is challenging to modify a global variable in the true sense, even with the use of `state` or `counter`. This would require the use of `locate` with callback functions to obtain the values inside, and this approach would have a significant impact on performance.

Touying does not use `state` or `counter` and does not violate the principle of pure functions in Typst. Instead, it uses a clever approach in an object-oriented style, maintaining a global singleton `s`. In Touying, an object refers to a Typst dictionary with its own member variables and methods. We agree that methods all have a named parameter `self` for passing the object itself, and methods are placed in the `.methods` domain. With this concept, it becomes easier to write methods to update `info`:

```typst
#let s = (
  info: (:),
  methods: (
    // update info
    info: (self: none, ..args) => {
      self.info += args.named()
      self
    },
  )
)

#let s = (s.methods.info)(self: s, title: [title])

Title is #s.info.title
```

Now you can understand the purpose of the `utils.methods()` function: to bind `self` to all methods of `s` and return it, simplifying the subsequent usage through unpacking syntax.

```typst
#let (init, slides, alert) = utils.methods(s)
```
:::

## State Initialization

In general, the two ways mentioned above are sufficient for adding global settings. However, there are still situations where we need to initialize counters or states. If you place this code before `#show: slides`, a blank page will be created, which is something we don't want to see. In such cases, you can use the `s.methods.append-preamble` method. For example, when using the codly package:

```typst
#import "@preview/touying:0.3.1": *
#import "@preview/codly:0.2.0": *

#let s = themes.simple.register(s, aspect-ratio: "16-9")
#let s = (s.methods.append-preamble)(self: s)[
  #codly(languages: (
    rust: (name: "Rust", icon: "\u{fa53}", color: rgb("#CE412B")),
  ))
]
#let (init, slides) = utils.methods(s)
#show heading.where(level: 2): set block(below: 1em)
#show: init
#show: codly-init.with()

#let (slide,) = utils.slides(s)
#show: slides

#slide[
  == First slide

  #raw(lang: "rust", block: true,
`pub fn main() {
  println!("Hello, world!");
}`.text)
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/0be2fbaf-cc03-4776-932f-259503d5e23a)

Or when configuring Pdfpc:

```typst
// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
))
```