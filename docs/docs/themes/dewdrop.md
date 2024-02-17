---
sidebar_position: 3
---

# Dewdrop Theme

![image](https://github.com/touying-typ/touying/assets/34951714/23a8a9be-1f7c-43f7-88d4-40604dd6b01b)

This theme is inspired by [BeamerTheme](https://github.com/zbowang/BeamerTheme) created by Zhibo Wang and transformed by [OrangeX4](https://github.com/OrangeX4).

The Dewdrop theme features an elegant and aesthetic navigation, including `sidebar` and `mini-slides` modes.

## Initialization

You can initialize the Dewdrop theme using the following code:

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(
  s,
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
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert
```

The `register` function takes parameters such as:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3," with the default being "16-9."
- `navigation`: Style of the navigation bar, which can be "sidebar," "mini-slides," or `none`, with the default being "sidebar."
- `sidebar`: Settings for the sidebar navigation, with the default being `(width: 10em)`.
- `mini-slides`: Settings for mini-slides, with the default being `(height: 2em, x: 2em, section: false, subsection: true)`.
- `footer`: Content to be displayed in the footer, with the default being `[]`. You can also pass a function like `self => self.info.author`.
- `footer-right`: Content to be displayed on the right side of the footer, with the default being `states.slide-counter.display() + " / " + states.last-slide-number`.
- `primary`: Primary color, with the default being `rgb("#0c4842")`.
- `alpha`: Transparency, with the default being `70%`.

The Dewdrop theme also provides an `#alert[..]` function that you can use with the `#show strong: alert` syntax.

## Color Themes

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

You can modify the color theme using `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

Dewdrop theme provides a series of custom slide functions:

```typst
#title-slide(extra: none, ..args)
```

The `title-slide` reads information from `self.info` for display. You can also pass an `extra` parameter to display additional information.

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

This is the default ordinary slide function with a navigation bar and footer according to your settings.

---

```typst
#focus-slide[
  ...
]
```

Used to draw attention. The background color is `self.colors.primary`.

## Special Functions

```typst
#d-outline(enum-args: (:), list-args: (:), cover: true)
```

Displays the current outline. The `cover` parameter specifies whether to hide sections that are inactive.

---

```typst
#d-sidebar()
```

An internal function for displaying the sidebar.

---

```typst
#d-mini-slides()
```

An internal function for displaying mini-slides.

## `slides` Function

The `slides` function has parameters:

- `title-slide`: Default is `true`.
- `outline-slide`: Default is `true`.
- `outline-title`: Default is `[Outline]`.

You can set these using `#show: slides.with(..)`.

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(s, aspect-ratio: "16-9", footer: [Dewdrop])
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

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
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(
  s,
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
#let s = (s.methods.enable-transparent-cover)(self: s)
// #let s = (s.methods.appendix-in-outline)(self: s, false)
#let (init, slide, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide()

#slide[
  == Outline
  
  #touying-outline(cover: false)
]

#slide(section: [Section A])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection A.1])[
  == Title

  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $
]

#slide(subsection: [Subsection A.2])[
  == Important

  A slide without a title but with *important* infos
]

#slide(section: [Section B])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection B.1])[
  == Another Subsection

  #lorem(80)
]

#focus-slide[
  Wake up!
]

// simple animations
#slide(subsection: [Subsection B.2])[
  == Dynamic

  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide(section: [Appendix])[
  == Outline
  
  #touying-outline()
]

#slide[
  appendix
]
```

