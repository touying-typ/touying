#import "../lib.typ": s, methods, pause

#let (init, touying-slide) = methods(s)

#show: init

// animations
#touying-slide(self => [
  #let (uncover, only) = methods(self)

  abc #uncover(2)[uncover] yes

  #pause

  test
])

// multiple pages
#touying-slide([

  #lorem(200)

  test
])

// appendix
#let (freeze-last-slide-number,) = methods(s)
#let s = freeze-last-slide-number()
#let (touying-slide,) = methods(s)

#touying-slide([
  appendix
])