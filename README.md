# Touying

Touying (投影 in chinese, /tóuyǐng/, meaning projection) is a is a package for creating presentation slides in Typst.

Compared to Polylux, it employs a more object-oriented writing style, capable of simulating a mutable global singleton. Additionally, Touying does not rely on `locate` and `counter` for implementing `#pause`, thus offering better performance, albeit with certain limitations.

**Warning: It is under development, and the interface may change at any time.**

## Dynamic slides

```typst
#import "../lib.typ": s, methods, pause, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let (init, slide) = methods(s)
#show: init

// simple animations
#slide[
  a simple #pause dynamic

  #pause
  
  slide.
]

// complex animations
#slide(setting: body => {
  set text(fill: blue)
  body
}, repeat: 3, self => [
  #let (uncover, only) = methods(self)

  #place(only(1)[#box()<jump-here>])

  in subslide #self.subslide, #link(<jump-here>)[jump to first subslide].

  test #uncover(2)[uncover] function

  test #only(2)[only] function

  #pause

  and paused text.
])

// multiple pages for one slide
#slide[
  #lorem(200)

  test multiple pages
]

// appendix by freezing last-slide-number
#let (appendix,) = methods(s)
#let s = appendix()
#let (slide,) = methods(s)

#slide[
  appendix
]
```


## Themes

```typst
#import "../lib.typ": s, methods, pause, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = methods(s)
#show: init

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  author: [Authors],
  title: "Title",
  subtitle: "Subtitle",
  date: "Date",
  extra: "Extra"
)

#slide(title: "Table of contents")[
  #touying-outline()
]

#slide(title: "Slide title")[
  A slide with some maths:
  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

#new-section-slide[First section]

#slide[
  A slide without a title but with #alert[important] infos
]

#new-section-slide[Second section]

#focus-slide[
  Wake up!
]

#new-section-slide([Appendix])

// appendix by freezing last-slide-number
#let (appendix,) = methods(s)
#let s = appendix()
#let (slide,) = methods(s)

#slide[
  appendix
]
```