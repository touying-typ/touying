---
sidebar_position: 1
---

# Simple Theme

![image](https://github.com/touying-typ/touying/assets/34951714/83d5295e-f961-4ffd-bc56-a7049848d408)

This theme originates from [Polylux](https://polylux.dev/book/themes/gallery/simple.html), created by Andreas Kröpelin.

Considered a relatively straightforward theme, you can use it to create simple slides and freely incorporate features you like.

## Initialization

You can initialize it using the following code:

```typst
#import "@preview/touying:0.4.1": *

#let s = themes.simple.register(aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, centered-slide, focus-slide) = utils.slides(s)
#show: slides
```

The `register` function takes the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3," defaulting to "16-9."
- `footer`: Content displayed in the footer, defaulting to `[]`, or it can be passed as a function like `self => self.info.author`.
- `footer-right`: Content displayed on the right side of the footer, defaulting to `states.slide-counter.display() + " / " + states.last-slide-number`.
- `background`: Background color, defaulting to white.
- `foreground`: Text color, defaulting to black.
- `primary`: Theme color, defaulting to `aqua.darken(50%)`.

## Slide Function Family

The Simple theme provides a variety of custom slide functions:

```typst
#centered-slide(section: ..)[
  ...
]
```

A slide with content centered, and the `section` parameter can be used to create a new section.

---

```typst
#title-slide[
  ...
]
```

Similar to `centered-slide`, this is provided for consistency with Polylux syntax.

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // simple theme args
  footer: auto,
)[
  ...
]
```

A default slide with headers and footers, where the header corresponds to the current section, and the footer is what you set.

---

```typst
#focus-slide(foreground: ..., background: ...)[
  ...
]
```

Used to draw attention, it optionally accepts a foreground color (defaulting to `white`) and a background color (defaulting to `auto`, i.e., `self.colors.primary`).

## `slides` Function

The `slides` function has the following parameter:

- `slide-level`: Defaults to `1`.

You can set it using `#show: slides.with(..)`.

And the function of automatically adding `new-section-slide` can be turned off by `#(s.methods.touying-new-section-slide = none)`.

```typst
#import "@preview/touying:0.4.1": *

#let s = themes.simple.register(aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, centered-slide, focus-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/2c599bd1-6250-497f-a65b-f19ae02a16cb)


## Example

```typst
#import "@preview/touying:0.4.1": *

#let s = themes.simple.register(aspect-ratio: "16-9", footer: [Simple slides])
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, centered-slide, focus-slide) = utils.slides(s)
#show: slides

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

== First slide

#slide[
  #lorem(20)
]

#focus-slide[
  _Focus!_

  This is very important.
]

= Let's start a new section!

== Dynamic slide

#slide[
  Did you know that...

  #pause

  ...you can see the current section at the top of the slide?
]
```

