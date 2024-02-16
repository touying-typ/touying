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
#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)
#show: init

#title-slide(authors: ("Author A", "Author B"))

#slide(title: [Slide title], section: [The section])[
  #lorem(40)
]

#slide(title: [Slide title], subtitle: emph[What is the problem?])[
  #lorem(40)
]

#focus-slide[
  *Another variant with an image in background...*
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