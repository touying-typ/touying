#import "../lib.typ": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides.with(title-slide: false)

#title-slide(authors: ([Author A], [Author B]))

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