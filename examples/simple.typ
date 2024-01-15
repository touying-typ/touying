#import "../lib.typ": s, pause, meanwhile, utils, states, pdfpc, themes

#let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
#let s = (s.methods.enable-transparent-cover)(self: s)
// #let s = (s.methods.enable-handout-mode)(self: s)
#let (init, slide, title-slide, centered-slide, focus-slide) = utils.methods(s)
#show: init

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

#slide[
  == First slide

  #lorem(20)
]

#focus-slide[
  _Focus!_

  This is very important.
]

#centered-slide(section: [Let's start a new section!])

#slide[
  == Dynamic slide
  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]