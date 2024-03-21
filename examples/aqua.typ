#import "../lib.typ": *

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

