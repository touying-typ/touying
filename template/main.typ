#import "@preview/touying:0.3.2": *

#let s = themes.university.register(aspect-ratio: "16-9")
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

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides


= The Section

== Slide Title

Slide content.