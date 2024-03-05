#import "../lib.typ": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
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

#set text(font: "Fira Sans", weight: "light", size: 20pt)

#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
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
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.slides(s)

= Appendix

#slide[
  Appendix.
]