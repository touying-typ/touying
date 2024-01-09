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