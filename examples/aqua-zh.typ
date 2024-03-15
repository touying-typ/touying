#import "../lib.typ": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "zh")
#let s = (s.methods.info)(
  self: s,
  title: [标题],
  subtitle: [副标题],
  author: [作者],
  date: datetime.today(),
  institution: [机构],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides

= 第一节

== 小标题

#slide[
  #lorem(40)
]

#slide[
  #lorem(40)
]

== 总结

#align(center + horizon)[
  #set text(size: 3em, weight: "bold", s.colors.primary)

  THANKS FOR ALL

  敬请指正！
]