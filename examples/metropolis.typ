#import "../lib.typ": *

#let store = themes.metropolis.register(store, aspect-ratio: "16-9", footer: self => self.info.institution)
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

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, title-slide, new-section-slide, focus-slide) = utils.slides(store)
#show: slides

= First Section

#slide[
  A slide without a title but with some *important* information.
]

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

#slide[
  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

#slide[
  A simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let store = (store.methods.appendix)(self: store)
#let (slide,) = utils.slides(store)

= Appendix

#slide[
  Appendix.
]