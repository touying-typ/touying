#import "../lib.typ": *

#let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, title-slide, centered-slide, focus-slide) = utils.slides(s)
#show: slides

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

== First slide

#slide[
  #lorem(20)
]

#focus-slide[
  _Focus!_

  This is very important.
]

= Let's start a new section!

== Dynamic slide

#slide[
  Did you know that...

  #pause

  ...you can see the current section at the top of the slide?
]