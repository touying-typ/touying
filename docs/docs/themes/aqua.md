---
sidebar_position: 5
---

# Aqua Theme

![image](https://github.com/touying-typ/touying/assets/34951714/5f9b3c99-a22a-4f3d-a266-93dd75997593)

This theme is created by [@pride7](https://github.com/pride7), featuring beautiful backgrounds made with Typst's visualization capabilities.

## Initialization

You can initialize it with the following code:

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides
```

Where `register` takes parameters:

- `aspect-ratio`: The aspect ratio of slides, either "16-9" or "4-3", default is "16-9".
- `footer`: Content shown on the right side of the footer, default is `states.slide-counter.display()`.
- `lang`: Language configuration, currently supports `"en"` and `"zh"`, default is `"en"`.

Aqua theme also provides an `#alert[..]` function, which you can utilize with `#show strong: alert` using `*alert text*` syntax.

## Color Themes

Aqua by default uses:

```typst
#let s = (s.methods.colors)(
  self: s,
  primary: rgb("#003F88"),
  primary-light: rgb("#2159A5"),
  primary-lightest: rgb("#F2F4F8"),
```

color themes, which you can modify by `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

Aqua theme offers a series of custom slide functions:

```typst
#title-slide(..args)
```

`title-slide` will read information from `self.info` for display.

---

```typst
#let outline-slide(self: none, enum-args: (:), leading: 50pt)
```

Display an outline slide.

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // Aqua theme
  title: auto,
)[
  ...
]
```

A default ordinary slide function with title and footer, where `title` defaults to the current section title.

---

```typst
#focus-slide[
  ...
]
```

Used to draw the audience's attention. The background color is `self.colors.primary`.

---

```typst
#new-section-slide(title)
```

Start a new section with the given title.

## `slides` Function

The `slides` function has parameters:

- `title-slide`: Default is `true`.
- `outline-slide`: Default is `true`.
- `slide-level`: Default is `1`.

They can be set via `#show: slides.with(..)`.

PS: The outline title can be modified via `#(s.outline-title = [Outline])`.

Additionally, you can disable the automatic inclusion of `new-section-slide` functionality by `#(s.methods.touying-new-section-slide = none)`.

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/eea4df8d-d9fd-43ac-aaf7-bb459864a9ac)

## Example

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides

= The Section

== Slide Title

#slide[
  #lorem(40)
]

#focus-slide[
  Another variant with primary color in background...
]

== Summary

#align(center + horizon)[
  #set text(size: 3em, weight: "bold", s.colors.primary)
  THANKS FOR ALL
]
```