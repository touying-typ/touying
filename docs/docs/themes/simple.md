---
sidebar_position: 1
---

# Simple Theme

![image](https://github.com/touying-typ/touying/assets/34951714/83d5295e-f961-4ffd-bc56-a7049848d408)

This theme is derived from [Polylux](https://polylux.dev/book/themes/gallery/simple.html), created by Andreas Kröpelin.

Considered a relatively simple theme, you can use it to create straightforward slides and easily incorporate features you like.

## Initialization

You can initialize the Simple theme using the following code:

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, centered-slide, focus-slide) = utils.methods(s)
#show: init
```

The `register` function takes parameters such as:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3," with the default being "16-9."
- `footer`: Content to be displayed in the footer, with the default being `[]`. You can also pass a function like `self => self.info.author`.
- `footer-right`: Content to be displayed on the right side of the footer, with the default being `states.slide-counter.display() + " / " + states.last-slide-number`.
- `background`: Background color, with the default being white.
- `foreground`: Text color, with the default being black.
- `primary`: Theme color, with the default being `aqua.darken(50%)`.

## Slide Function Family

The Simple theme provides a series of custom slide functions:

```typst
#centered-slide(section: ..)[
  ...
]
```
A slide with content centered on the slide. The `section` parameter can be used to create a new section.

---

```typst
#title-slide[
  ...
]
```
Similar to `centered-slide`, this is just for consistency with Polylux syntax.

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
This is the default ordinary slide function with a header and footer. The header is set to the current section, and the footer is as per your settings.

---

```typst
#focus-slide(foreground: ..., background: ...)[
  ...
]
```
Used to draw attention. It optionally accepts a foreground color (default is `white`) and a background color (default is `auto`, i.e., `self.colors.primary`).

## `slides` Function

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, centered-slide, focus-slide) = utils.methods(s)
#show: init

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
#import "@preview/touying:0.2.1": *

#let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, centered-slide, focus-slide) = utils.methods(s)
#show: init

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

#slide[
  == First slide

  #lorem(20)
]

#focus-slide[
  _Focus!_

  This is very important.
]

#centered-slide(section: [Let's start a new section!])

#slide[
  == Dynamic slide
  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]
```

