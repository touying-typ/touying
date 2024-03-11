#import "../lib.typ": *

#let s = themes.aqua.register(s, aspect-ratio: "16-9")

#let s = (s.methods.info)(
  self: s, 
  title: [An Instruction to Typst-Beamer],
  author: [Author],
  date: datetime.today(),
)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, title-slide, outline-slide, new-section-slide) = utils.slides(s) 
#show: slides

= Title Slide

#slide[
  = How to make Typst-Beamer?
  #lorem(80)
]

= Content Slide

== Test for grid

#grid(
  columns: (1fr, 1fr),
  column-gutter: 50pt,
  row-gutter: 20pt,
  [Feature 1], [Feature 2],
  [#lorem(20)], [#lorem(20)],
)

== Summary

#align(center + horizon)[
  #set text(size: 3em, weight: "bold", s.colors.primary)
  THANKS FOR ALL
]

