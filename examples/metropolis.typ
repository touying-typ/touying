#import "../lib.typ": s, pause, utils, states, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
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

#slide(title: [Table of contents])[
  #touying-outline()
]

#slide(title: utils.fit-to-width(100%)[A long long long long long long long long long long long long long long long long long long long long long Title])[
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

#new-section-slide[Appendix]

// appendix by freezing last-slide-number
#let (appendix,) = utils.methods(s)
#let s = appendix()
#let (slide,) = utils.methods(s)

#slide[
  appendix
]