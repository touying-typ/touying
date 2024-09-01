#import "../lib.typ": *
#import themes.aqua: *

#show: aqua-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [标题],
    subtitle: [副标题],
    author: [作者],
    date: datetime.today(),
    institution: [机构],
  ),
)

#set text(lang: "zh")

#title-slide()

#outline-slide()

= 第一节

== 小标题

#slide[
  #lorem(40)
]

#slide[
  #lorem(40)
]

== 总结

#slide(self => [
  #align(center + horizon)[
    #set text(size: 3em, weight: "bold", self.colors.primary)

    THANKS FOR ALL

    敬请指正！
  ]
])