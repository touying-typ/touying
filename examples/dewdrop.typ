#import "../lib.typ": s, pause, meanwhile, utils, states, pdfpc, themes

#let s = themes.dewdrop.register(
  s,
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
// #let s = (s.methods.enable-handout-mode)(self: s)
#let (init, slide, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide()

#slide[
  == Outline
  
  #touying-outline()
]

#slide[
  A slide with some maths:
  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

#slide[
  A slide without a title but with *important* infos
]

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
#let (slide,) = utils.methods(s)

#slide[
  appendix
]