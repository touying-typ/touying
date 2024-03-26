---
sidebar_position: 2
---

# Metropolis 主题

![image](https://github.com/touying-typ/touying/assets/34951714/383ceb22-f696-4450-83a6-c0f17e4597e1)


这个主题的灵感来自 Matthias Vogelgesang 创作的 [Metropolis beamer](https://github.com/matze/mtheme) 主题，由 [Enivex](https://github.com/Enivex) 改造而来。

这个主题美观大方，很适合日常使用，并且你最好在电脑上安装 Fira Sans 和 Fira Math 字体，以取得最佳效果。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `header`: 显示在页眉的内容，默认为 `states.current-section-title`，也可以传入形如 `self => self.info.title` 的函数。
- `footer`: 展示在页脚的内容，默认为 `[]`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `states.slide-counter.display() + " / " + states.last-slide-number`。
- `footer-progress`: 是否显示 slide 底部的进度条，默认为 `true`。

并且 Metropolis 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Metropolis 默认使用了

```typst
#let s = (s.methods.colors)(
  self: s,
  neutral-lightest: rgb("#fafafa"),
  primary-dark: rgb("#23373b"),
  secondary-light: rgb("#eb811b"),
  secondary-lighter: rgb("#d6c6b7"),
)
```

颜色主题，你可以通过 `#let s = (s.methods.colors)(self: s, ..)` 对其进行修改。

## slide 函数族

Metropolis 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(extra: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `extra` 参数，显示额外的信息。

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // metropolis theme
  title: auto,
  footer: auto,
  align: horizon,
)[
  ...
]
```
默认拥有标题和页脚的普通 slide 函数，其中 `title` 默认为当前 section title，页脚为您设置的页脚。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary-dark`。

---

```typst
#new-section-slide(short-title: auto, title)
```
用给定标题开启一个新的 section。


## `slides` 函数

`slides` 函数拥有参数

- `title-slide`: 默认为 `true`。
- `outline-slide`: 默认为 `true`。
- `slide-level`: 默认为 `1`。

可以通过 `#show: slides.with(..)` 的方式设置。

PS: 其中 outline title 可以通过 `#(s.outline-title = [Outline])` 的方式修改。

以及可以通过 `#(s.methods.touying-new-section-slide = none)` 的方式关闭自动加入 `new-section-slide` 的功能。

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/4ab45ee6-09f7-498b-b349-e889d6e42e3e)


## 示例

```typst
#import "@preview/touying:0.3.3": *

#let s = themes.metropolis.register(aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
#show strong: alert

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide) = utils.slides(s)
#show: slides

= First Section

#slide[
  A slide without a title but with some *important* information.
]

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

#slide[
  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

#slide[
  A simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, empty-slide) = utils.slides(s)

= Appendix

#slide[
  Appendix.
]
```

