#import "../lib.typ": s, methods, pause, themes

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
#let (init, slide) = methods(s)
#show: init

// simple animations
#slide[
  a simple #pause dynamic

  #pause
  
  slide.
]

// complex animations
#slide(setting: body => {
  set text(fill: blue)
  body
}, repeat: 3, self => [
  #let (uncover, only) = methods(self)

  #place(only(1)[#box()<jump-here>])

  in subslide #self.subslide, #link(<jump-here>)[jump to first subslide].

  test #uncover(2)[uncover] function

  test #only(2)[only] function

  #pause

  and paused text.
])

// multiple pages for one slide
#slide[
  #lorem(200)

  test multiple pages
]

// appendix with freeze-last-slide-number
#let (freeze-last-slide-number,) = methods(s)
#let s = freeze-last-slide-number()
#let (slide,) = methods(s)

#slide[
  appendix
]