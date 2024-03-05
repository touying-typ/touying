---
sidebar_position: 2
---

# 开始

在开始之前，请确保您已经安装了 Typst 环境，如果没有，可以使用 [Web App](https://typst.app/) 或 VS Code 的 [Typst LSP](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp) 和 [Typst Preview](https://marketplace.visualstudio.com/items?itemName=mgt19937.typst-preview) 插件。

要使用 Touying，您只需要在文档里加入

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, slides) = utils.methods(s)
#show: init

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/6f15b500-b825-4db1-88ff-34212f43723e)

这很简单，您创建了您的第一个 Touying slides，恭喜！🎉

## 更复杂的例子

事实上，Touying 提供了多种 slides 编写风格，例如上面的例子依靠一级和二级标题来划分新 slide，实际上您也可以使用 `#slide[..]` 的写法，以获得 Touying 提供的更多更强大的功能。

```typst
#import "@preview/touying:0.2.1": *

#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide) = utils.methods(s)
#show: init

// simple animations
#slide[
  a simple #pause *dynamic*

  #pause
  
  slide.

  #meanwhile

  meanwhile #pause with pause.
][
  second #pause pause.
]

// complex animations
#slide(setting: body => {
  set text(fill: blue)
  body
}, repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  in subslide #self.subslide

  test #uncover("2-")[uncover] function

  test #only("2-")[only] function

  #pause

  and paused text.
])

// math equation animations
#slide[
  == Touying Equation

  #touying-equation(`
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  `)

  #meanwhile

  Touying equation is very simple.
]

// multiple pages for one slide
#slide[
  == Multiple Pages for One Slide

  #lorem(200)
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide[
  == Appendix
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/192b13f9-e3fb-4327-864b-fd9084a8ca24)

除此之外，Touying 还提供了很多内置的主题，能够简单地编写精美的 slides，基本上，您只需要在文档顶部加入一行

```
#let s = themes.metropolis.register(s, aspect-ratio: "16-9")
```

即可使用 metropolis 主题。关于更详细的教程，您可以参阅后面的章节。
