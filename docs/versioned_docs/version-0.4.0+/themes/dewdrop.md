---
sidebar_position: 3
---

# Dewdrop Theme

![image](https://github.com/touying-typ/touying/assets/34951714/0b5b2bb2-c6ec-45c0-9cea-0af2ed896bba)

This theme takes inspiration from Zhibo Wang's [BeamerTheme](https://github.com/zbowang/BeamerTheme) and has been modified by [OrangeX4](https://github.com/OrangeX4).

The Dewdrop theme features an elegantly designed navigation, including two modes: `sidebar` and `mini-slides`.

## Initialization

You can initialize it using the following code:

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.dewdrop.register(
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
  // navigation: "sidebar",
  // navigation: none,
)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides
```

The `register` function takes the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3," defaulting to "16-9."
- `navigation`: The navigation bar style, which can be `"sidebar"`, `"mini-slides"`, or `none`, defaulting to `"sidebar"`.
- `sidebar`: Sidebar navigation settings, defaulting to `(width: 10em)`.
- `mini-slides`: Mini-slides settings, defaulting to `(height: 2em, x: 2em, section: false, subsection: true)`.
  - `height`: The height of mini-slides, defaulting to `2em`.
  - `x`: Padding on the x-axis for mini-slides, defaulting to `2em`.
  - `section`: Whether to display slides after the section and before the subsection, defaulting to `false`.
  - `subsection`: Whether to split mini-slides based on subsections or compress them into one line, defaulting to `true`.
- `footer`: Content displayed in the footer, defaulting to `[]`, or it can be passed as a function like `self => self.info.author`.
- `footer-right`: Content displayed on the right side of the footer, defaulting to `states.slide-counter.display() + " / " + states.last-slide-number`.
- `primary`: Primary color, defaulting to `rgb("#0c4842")`.
- `alpha`: Transparency, defaulting to `70%`.

The Dewdrop theme also provides an `#alert[..]` function, which you can use with `#show strong: alert` using the `*alert text*` syntax.

## Color Theme

Dewdrop uses the following default color theme:

```typst
#let s = (s.methods.colors)(
  self: s,
  neutral-darkest: rgb("#000000"),
  neutral-dark: rgb("#202020"),
  neutral-light: rgb("#f3f3f3"),
  neutral-lightest: rgb("#ffffff"),
  primary: primary,
)
```

You can modify this color theme using `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

The Dewdrop theme provides a variety of custom slide functions:

```typst
#title-slide(extra: none, ..args)
```

`title-slide` reads information from `self.info` for display, and you can also pass in an `extra` parameter to display additional information.

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // Dewdrop theme
  footer: auto,
)[
  ...
]
```

A default slide with navigation and footer, where the footer is what you set.

---

```typst
#focus-slide[
  ...
]
```

Used to draw attention, with the background color set to `self.colors.primary`.

## Special Functions

```typst
#d-outline(enum-args: (:), list-args: (:), cover: true)
```

Displays the current table of contents. The `cover` parameter specifies whether to hide sections in an inactive state.

---

```typst
#d-sidebar()
```

An internal function used to display the sidebar.

---

```typst
#d-mini-slides()
```

An internal function used to display mini-slides.

## `slides` Function

The `slides` function has the following parameters:

- `title-slide`: Defaults to `true`.
- `outline-slide`: Defaults to `true`.
- `slide-level`: Defaults to `2`.

You can set these using `#show: slides.with(..)`.

PS: You can modify the outline title using `#(s.outline-title = [Outline])`.

And the function of automatically adding `new-section-slide` can be turned off by `#(s.methods.touying-new-section-slide = none)`.

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.dewdrop.register(aspect-ratio: "16-9", footer: [Dewdrop])
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/09ddfb40-4f97-4062-8261-23f87690c33e)


## Example

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.dewdrop.register(
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
  // navigation: none,
)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides

= Section A

== Subsection A.1

#slide[
  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $
]

== Subsection A.2

#slide[
  A slide without a title but with *important* infos
]

= Section B

== Subsection B.1

#slide[
  #lorem(80)
]

#focus-slide[
  Wake up!
]

== Subsection B.2

#slide[
  We can use `#pause` to #pause display something later.

  #pause
  
  Just like this.

  #meanwhile
  
  Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, empty-slide) = utils.slides(s)

= Appendix

=== Appendix

#slide[
  Please pay attention to the current slide number.
]
```

