---
sidebar_position: 3
---

# Dewdrop 主题

![image](https://github.com/touying-typ/touying/assets/34951714/23a8a9be-1f7c-43f7-88d4-40604dd6b01b)

这个主题的灵感来自 Zhibo Wang 创作的 [BeamerTheme](https://github.com/zbowang/BeamerTheme)，由 [OrangeX4](https://github.com/OrangeX4) 改造而来。

这个主题拥有优雅美观的 navigation，包括 `sidebar` 和 `mini-slides` 两种模式。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(
  s,
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
  // navigation: "sidebar",
  // navigation: none,
)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `navigation`: 导航栏样式，可以是 `"sidebar"`、`"mini-slides"` 和 `none`，默认为 `"sidebar"`。
- `sidebar`: 侧边导航栏设置，默认为 `(width: 10em)`。
- `mini-slides`: mini-slides 设置，默认为 `(height: 2em, x: 2em, section: false, subsection: true)`。
  - `height`: mini-slides 高度，默认为 `2em`。
  - `x`: mini-slides 的 x 轴 padding，默认为 `2em`。
  - `section`: 是否显示 section 之后，subsection 之前的 slides，默认为 `false`。
  - `subsection`: 是否根据 subsection 分割 mini-slides，设置为 `false` 挤压为一行，默认为 `true`。
- `footer`: 展示在页脚的内容，默认为 `[]`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `states.slide-counter.display() + " / " + states.last-slide-number`。
- `primary`: primary 颜色，默认为 `rgb("#0c4842")`。
- `alpha`: 透明度，默认为 `70%`。

并且 Dewdrop 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Dewdrop 默认使用了

```typst
#let s = (s.methods.colors)(
  self: s,
  neutral-darkest: rgb("#000000"),
  neutral-dark: rgb("#202020"),
  neutral-light: rgb("#f3f3f3"),
  neutral-lightest: rgb("#ffffff"),
  primary: primary,
)
```

颜色主题，你可以通过 `#let s = (s.methods.colors)(self: s, ..)` 对其进行修改。

## slide 函数族

Dewdrop 主题提供了一系列自定义 slide 函数：

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
  // Dewdrop theme
  footer: auto,
)[
  ...
]
```
默认拥有导航栏和页脚的普通 slide 函数，页脚为您设置的页脚。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary`。


## 特殊函数

```typst
#d-outline(enum-args: (:), list-args: (:), cover: true)
```

显示当前的目录，`cover` 参数用于指定是否要隐藏处于 inactive 状态的 sections。

---

```typst
#d-sidebar()
```

内部函数，用于显示侧边栏。

---

```typst
#d-mini-slides()
```

内部函数，用于显示 mini-slides。


## `slides` 函数

`slides` 函数拥有参数

- `title-slide`: 默认为 `true`。
- `outline-slide`: 默认为 `true`。
- `outline-title`: 默认为 `[Outline]`。

可以通过 `#show: slides.with(..)` 的方式设置。

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(s, aspect-ratio: "16-9", footer: [Dewdrop])
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, slides, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/09ddfb40-4f97-4062-8261-23f87690c33e)


## 示例

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.dewdrop.register(
  s,
  aspect-ratio: "16-9",
  footer: [Dewdrop],
  navigation: "mini-slides",
  // navigation: "sidebar",
  // navigation: none,
)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
// #let s = (s.methods.appendix-in-outline)(self: s, false)
#let (init, slide, title-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide()

#slide[
  == Outline
  
  #touying-outline(cover: false)
]

#slide(section: [Section A])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection A.1])[
  == Title

  A slide with equation:

  $ x_(n+1) = (x_n + a/x_n) / 2 $
]

#slide(subsection: [Subsection A.2])[
  == Important

  A slide without a title but with *important* infos
]

#slide(section: [Section B])[
  == Outline
  
  #touying-outline()
]

#slide(subsection: [Subsection B.1])[
  == Another Subsection

  #lorem(80)
]

#focus-slide[
  Wake up!
]

// simple animations
#slide(subsection: [Subsection B.2])[
  == Dynamic

  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide(section: [Appendix])[
  == Outline
  
  #touying-outline()
]

#slide[
  appendix
]
```

