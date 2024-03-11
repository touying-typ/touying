#import "../lib.typ": *

#let s = themes.aqua.register(
  s, 
  aspect-ratio: "16-9",
  aqua-lang: "en",  // ["en", "zh"]  "zh" for Chinese users.
)

#let s = (s.methods.info)(
  self: s, 
  title: [An Instruction to Typst-Beamer],
  author: [Author],
  date: datetime.today(),
)
#let (init, slides) = utils.methods(s)
#show: init

#set text(font: "Microsoft YaHei") // "Microsoft YaHei" is recommended.
#let (slide, title-slide, outline-slide, new-section-slide, end-slide) = utils.slides(s) 
#show: slides


#outline-slide(leading:100pt)


#new-section-slide[
  Title Slide
]


= Content Slide
== 01 Tite Slide
#slide[
  = How to make Typst-Beamer?
  #lorem(80)
]

== Test for grid
#grid(
  columns: (1fr,1fr),
  column-gutter: 50pt,
  row-gutter: 20pt,
  [Feature 1],[Feature 2],
  [#lorem(20)],[#lorem(20)]
)



#end-slide()


