---
sidebar_position: 7
---

# 多文件架构

Touying 有着如同原生 Typst 文档一般简洁的语法，以及繁多的可自定义配置项，却也仍能够维持着实时的增量编译性能，因此很适合用来编写大型 slides。

如果你需要写一个较大的 slides，例如一个几十页几百页的课程讲义，你也可以尝试一下 Touying 的多文件架构。


## 配置和内容分离

一个最简单的 Touying 多文件架构包括三个文件：全局配置文件 `globals.typ`、主入口文件 `main.typ` 和存放内容的 `content.typ` 文件。

分成三个文件是由于要让 `main.typ` 和 `content.typ` 均可以引入 `globals.typ`，从而避免循环引用。

`globals.typ` 可以用于存放一些全局的自定义函数，以及对 Touying 主题进行初始化：

```typst
// globals.typ
#import "@preview/touying:0.4.2": *

#let s = themes.university.register(aspect-ratio: "16-9")
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#let (slide, empty-slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)

// as well as some utility functions
```

`main.typ` 作为项目的主入口，通过导入 `globals.typ` 应用 show rules，以及通过 `#include` 置入 `content.typ`。

```typst
// main.typ
#import "/globals.typ": *

#show: init
#show strong: alert
#show: slides

#include "content.typ"
```

`content.typ` 便是用于书写具体内容的文件了。

```typst
// content.typ
#import "/globals.typ": *

= The Section

== Slide Title

Hello, Touying!

#focus-slide[
  Focus on me.
]
```


## 多章节

要实现多章节也十分简单，只需要新建一个 `sections` 目录，并将上面的 `content.typ` 文件移动至 `sections.typ` 目录即可，例如

```typst
// main.typ
#import "/globals.typ": *

#show: init
#show strong: alert
#show: slides

#include "sections/content.typ"
// #include "sections/another-section.typ"
```

和

```typst
// sections/content.typ
#import "/globals.typ": *

= The Section

== Slide Title

Hello, Touying!

#focus-slide[
  Focus on me.
]
```

这样，您就掌握了如何使用 Touying 实现大型 slides 的多文件架构。