#import "../lib.typ": s, pause, utils, states, pdfpc, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  author: [Authors],
  title: [Title],
  subtitle: [Subtitle],
  date: [Date],
  extra: [Extra],
)

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
  A slide without a title but with #alert[important] infos
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