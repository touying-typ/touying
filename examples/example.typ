#import "../lib.typ": s, methods, pause

#let (init, touying-slide) = methods(s)

#show: init

#touying-slide(self => [
  #let (uncover, only) = methods(self)

  abc #uncover(2)[uncover] yes

  #pause

  test
])