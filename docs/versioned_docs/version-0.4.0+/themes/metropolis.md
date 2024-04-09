---
sidebar_position: 2
---

# Metropolis Theme

![image](https://github.com/touying-typ/touying/assets/34951714/383ceb22-f696-4450-83a6-c0f17e4597e1)

This theme draws inspiration from Matthias Vogelgesang's [Metropolis beamer](https://github.com/matze/mtheme) theme and has been modified by [Enivex](https://github.com/Enivex).

The Metropolis theme is elegant and suitable for everyday use. It is recommended to have Fira Sans and Fira Math fonts installed on your computer for the best results.

## Initialization

You can initialize it using the following code:

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
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
- `header`: Content displayed in the header, defaulting to `states.current-section-title`, or it can be passed as a function like `self => self.info.title`.
- `footer`: Content displayed in the footer, defaulting to `[]`, or it can be passed as a function like `self => self.info.author`.
- `footer-right`: Content displayed on the right side of the footer, defaulting to `states.slide-counter.display() + " / " + states.last-slide-number`.
- `footer-progress`: Whether to show the progress bar at the bottom of the slide, defaulting to `true`.

The Metropolis theme also provides an `#alert[..]` function, which you can use with `#show strong: alert` using the `*alert text*` syntax.

## Color Theme

Metropolis uses the following default color theme:

```typst
#let s = (s.methods.colors)(
  self: s,
  neutral-lightest: rgb("#fafafa"),
  primary-dark: rgb("#23373b"),
  secondary-light: rgb("#eb811b"),
  secondary-lighter: rgb("#d6c6b7"),
)
```

You can modify this color theme using `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

The Metropolis theme provides a variety of custom slide functions:

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
  // metropolis theme
  title: auto,
  footer: auto,
  align: horizon,
)[
  ...
]
```

A default slide with headers and footers, where the title defaults to the current section title, and the footer is what you set.

---

```typst
#focus-slide[
  ...
]
```

Used to draw attention, with the background color set to `self.colors.primary-dark`.

---

```typst
#new-section-slide(short-title: auto, title)
```

Creates a new section with the given title.

## `slides` Function

The `slides` function has the following parameters:

- `title-slide`: Defaults to `true`.
- `outline-slide`: Defaults to `true`.
- `slide-level`: Defaults to `1`.

You can set these using `#show: slides.with(..)`.

PS: You can modify the outline title using `#(s.outline-title = [Outline])`.

And the function of automatically adding `new-section-slide` can be turned off by `#(s.methods.touying-new-section-slide = none)`.

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/4ab45ee6-09f7-498b-b349-e889d6e42e3e)


## Example

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
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

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides

= First Section

#slide[
  A slide without a title but with some *important* information.
]

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

#slide[
  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

#slide[
  A simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, empty-slide) = utils.slides(s)

= Appendix

#slide[
  Appendix.
]
```

