#import "../lib.typ": s, pause, meanwhile, utils, states, pdfpc, themes

#let s = themes.university.register(s, aspect-ratio: "16-9")
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

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides.with(title-slide: false)

#title-slide(authors: ("Author A", "Author B"))

= The Section

== Slide Title

#slide[
  #lorem(40)
]

#slide(subtitle: emph[What is the problem?])[
  #lorem(40)
]

#focus-slide[
  *Another variant with primary color in background...*
]

#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]

#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)