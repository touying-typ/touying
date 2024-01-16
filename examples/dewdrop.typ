#import "../lib.typ": s, pause, meanwhile, utils, states, pdfpc, themes

#let s = themes.dewdrop.register(
  s,
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
  // navigation: none,
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
// #let s = (s.methods.appendix-in-outline)(self: s, false)
#let (init, slide, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide()

#slide[
  == Outline
  
  #touying-outline(cover: false)
]

#slide(section: [Section A])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection A.1])[
  == Title

  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $
]

#slide(subsection: [Subsection A.2])[
  == Important

  A slide without a title but with *important* infos
]

#slide(section: [Section B])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection B.1])[
  == Another Subsection

  #lorem(80)
]

#focus-slide[
  Wake up!
]

// simple animations
#slide(subsection: [Subsection B.2])[
  == Dynamic

  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide(section: [Appendix])[
  == Outline
  
  #touying-outline()
]

#slide[
  appendix
]