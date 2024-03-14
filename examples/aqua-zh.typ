#import "../lib.typ": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "zh")

#let s = (s.methods.info)(
  self: s, 
  title: [An Instruction to Typst-Beamer],
  author: [Author],
  date: datetime.today(),
)
#let (init, slides) = utils.methods(s)
#show: init

#set text(font: "Microsoft YaHei") // "Microsoft YaHei" is recommended.
#let (slide, title-slide, outline-slide, new-section-slide) = utils.slides(s) 
#show: slides

= 制作一个标题页

#slide[
  = Typst Beamer 如何做？
  欢迎阅读 Typst 的中文文档！Typst 是为科学写作而诞生的基于标记的排版系统。 它被设计之初就是作为一种替代品，用于替代像 LaTeX 这样的高级工具，又或者是像 Word 和 Google Docs 这样的简单工具。 我们对 Typst 的目标是构建一个功能强大的排版工具，并且让用户可以愉快地使用它。 

  本文档分为两部分：一个适合初学者的教程，其通过实际用例介绍 Typst；以及一个全面的参考，以解释 Typst 的所有概念和功能。

  我们还邀请您加入我们为 Typst 建立的社区。Typst 仍是一个非常年轻的项目，因此我们非常希望能够得到您的反馈。
]

= 制作一个目录页

== 标题2

#grid(
  columns: (1fr,1fr),
  column-gutter: 50pt,
  row-gutter: 20pt,
  [属性 1], [属性 2],
  [#lorem(20)], [#lorem(20)],
)


== Summary

#align(center + horizon)[
  #set text(size: 3em, weight: "bold", s.colors.primary)

  THANKS FOR ALL

  敬请指正！
]
