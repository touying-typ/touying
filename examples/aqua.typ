#import "../lib.typ": *

#let store = themes.aqua.register(store, aspect-ratio: "16-9")

#let store = (store.methods.info)(
  self: store, 
  title: [An Instruction to Typst-Beamer],
  author: [Author],
  date: datetime.today(),
)
#let (init, slides) = utils.methods(store)
#show: init

#let (slide, title-slide, outline-slide, new-section-slide) = utils.slides(store) 
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
  #set text(size: 3em, weight: "bold", store.colors.primary)
  THANKS FOR ALL
]

