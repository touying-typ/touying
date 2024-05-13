---
sidebar_position: 6
---

# 全局设置

## 全局样式

对 Touying 而言，全局样式即为需要应用到所有地方的 set rules 或 show rules，例如 `#set text(size: 20pt)`。

其中，Touying 的主题会封装一些自己的全局样式，他们会被放在 `#show: init` 中，例如 university 主题就封装了

```typst
self.methods.init = (self: none, body) => {
  set text(size: 25pt)
  show footnote.entry: set text(size: .6em)
  body
}
```

如果你并非一个主题制作者，而只是想给你的 slides 添加一些自己的全局样式，你可以简单地将它们放在 `#show: init` 之后，以及 `#show: slides` 之前，例如 metropolis 主题就推荐你自行加入以下全局样式：

```typst
#let s = themes.metropolis.register(aspect-ratio: "16-9")
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

// global styles
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides
```

但是注意，你不应该使用 `#set page(..)`，而是应该修改 `s.page-args` 和 `s.padding`，例如

```typst
#(s.page-args += (
  margin: (x: 0em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
))
#(s.padding += (x: 4em, y: 0em))
```


## 全局信息

就像 Beamer 一样，Touying 通过 OOP 风格的统一 API 设计，能够帮助您更好地维护全局信息，让您可以方便地在不同的主题之间切换，全局信息就是一个很典型的例子。

你可以通过

```typst
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
```

分别设置 slides 的标题、副标题、作者、日期和机构信息。在后续，你就可以通过 `s.info` 或 `self.info` 这样的方式访问它们。

这些信息一般会在主题的 `title-slide`、`header` 和 `footer` 被使用到，例如 `#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)`。

其中 `date` 可以接收 `datetime` 格式和 `content` 格式，并且 `datetime` 格式的日期显示格式，可以通过

```typst
#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")
```

的方式更改。

:::tip[原理]

在这里，我们会稍微引入一点 Touying 的 OOP 概念。

您应该知道，Typst 是一个支持增量渲染的排版语言，也就是说，Typst 会缓存之前的函数调用结果，这就要求 Typst 里只有纯函数，即无法改变外部变量的函数。因此我们很难真正意义上地像 LaTeX 那样修改一个全局变量。即使是使用 `state` 或 `counter`，也需要使用 `locate` 与回调函数来获取里面的值，且实际上这种方式会对性能有很大的影响。

Touying 并没有使用 `state` 和 `counter`，也没有违反 Typst 纯函数的原则，而是使用了一种巧妙的方式，并以面向对象风格的代码，维护了一个全局单例 `s`。在 Touying 中，一个对象指拥有自己的成员变量和方法的 Typst 字典，并且我们约定方法均有一个命名参数 `self` 用于传入对象自身，并且方法均放在 `.methods` 域里。有了这个理念，我们就不难写出更新 `info` 的方法了：

```
#let s = (
  info: (:),
  methods: (
    // update info
    info: (self: none, ..args) => {
      self.info += args.named()
      self
    },
  )
)

#let s = (s.methods.info)(self: s, title: [title])

Title is #s.info.title
```

这样，你也能够理解 `utils.methods()` 函数的用途了：将 `self` 绑定到 `s` 的所有方法上并返回，并通过解包语法简化后续的使用。

```typst
#let (init, slides, alert) = utils.methods(s)
```
:::


## 状态初始化

一般而言，上面的两种方式就已经足够用于加入全局设置了，但是仍然会有部分情况，我们需要初始化 counters 或 states。如果将这些代码放在 `#show: slides` 之前，就会创建一个空白页，这是我们不想看见的，因此这时候我们就可以使用 `s.methods.append-preamble` 方法。例如在使用 codly 包的时候：

```typst
#import "@preview/touying:0.4.1": *
#import "@preview/codly:0.2.0": *

#let s = themes.simple.register(aspect-ratio: "16-9")
#let s = (s.methods.append-preamble)(self: s)[
  #codly(languages: (
    rust: (name: "Rust", icon: "\u{fa53}", color: rgb("#CE412B")),
  ))
]
#let (init, slides) = utils.methods(s)
#show heading.where(level: 2): set block(below: 1em)
#show: init
#show: codly-init.with()

#let (slide, empty-slide) = utils.slides(s)
#show: slides

#slide[
  == First slide

  #raw(lang: "rust", block: true,
`pub fn main() {
  println!("Hello, world!");
}`.text)
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/0be2fbaf-cc03-4776-932f-259503d5e23a)


又或者是进行 Pdfpc 的配置的时候：

```typst
// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
))
```