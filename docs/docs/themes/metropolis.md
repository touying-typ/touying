---
sidebar_position: 2
---

# Metropolis Theme

![image](https://github.com/touying-typ/touying/assets/34951714/a1b34b11-6797-42fd-b50f-477a0d672ba2)

This theme is inspired by the [Metropolis beamer](https://github.com/matze/mtheme) theme created by Matthias Vogelgesang and transformed by [Enivex](https://github.com/Enivex).

The Metropolis theme is elegant and suitable for daily use. For the best results, it is recommended to install the Fira Sans and Fira Math fonts on your computer.

## Initialization

You can initialize the Metropolis theme using the following code:

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
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
```

The `register` function takes parameters such as:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3," with the default being "16-9."
- `header`: Content to be displayed in the header, with the default being `states.current-section-title`. You can also pass a function like `self => self.info.title`.
- `footer`: Content to be displayed in the footer, with the default being `[]`. You can also pass a function like `self => self.info.author`.
- `footer-right`: Content to be displayed on the right side of the footer, with the default being `states.slide-counter.display() + " / " + states.last-slide-number`.
- `footer-progress`: Whether to show the progress bar at the bottom of the slide, with the default being `true`.

The Metropolis theme also provides an `#alert[..]` function that you can use with the `#show strong: alert` syntax.

## Color Themes

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

You can modify the color theme using `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

Metropolis theme provides a series of custom slide functions:

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
  // metropolis theme
  title: auto,
  footer: auto,
  align: horizon,
  margin: (top: 3em, bottom: 1em, left: 0em, right: 0em),
  padding: 2em,
)[
  ...
]
```
This is the default ordinary slide function with a title and footer according to your settings. The `title` is set to the current section title by default, and the footer is as per your settings.

---

```typst
#focus-slide[
  ...
]
```

Used to draw attention. The background color is `self.colors.primary-dark`.

---

```typst
#new-section-slide(short-title: auto, title)
```

Opens a new section with the given title.

## `slides` Function

The `slides` function has parameters:

- `title-slide`: Default is `true`.
- `outline-slide`: Default is `true`.
- `outline-title`: Default is `[Table of contents]`.

You can set these using `#show: slides.with(..)`.

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
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
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide(extra: [Extra])

#slide(title: [Table of contents])[
  #touying-outline()
]

#slide(title: [A long long long long long long long long long long long long long long long long long long long long long long long long Title])[
  A slide with some maths:
  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

#new-section-slide[First section]

#slide[
  A slide without a title but with *important* infos
]

#new-section-slide[Second section]

#focus-slide[
  Wake up!
]

// simple animations
#slide[
  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, new-section-slide) = utils.methods(s)

#new-section-slide[Appendix]

#slide[
  appendix
]
```

