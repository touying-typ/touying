---
sidebar_position: 2
---

# Metropolis 主题

![image](https://github.com/touying-typ/touying/assets/34951714/a1b34b11-6797-42fd-b50f-477a0d672ba2)

这个主题的灵感来自 Matthias Vogelgesang 创作的 [Metropolis beamer](https://github.com/matze/mtheme) 主题，由 [Enivex](https://github.com/Enivex) 改造而来。

这个主题美观大方，很适合日常使用，并且你最好在电脑上安装 Fira Sans 和 Fira Math 字体，以取得最佳效果。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
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
  margin: (top: 3em, bottom: 1em, left: 0em, right: 0em),
  padding: 2em,
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
- `outline-title`: 默认为 `[Table of contents]`。

可以通过 `#show: slides.with(..)` 的方式设置。

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
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
#import "@preview/touying:0.2.1": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide, title-slide, new-section-slide, focus-slide, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#title-slide(extra: [Extra])

#slide(title: [Table of contents])[
  #touying-outline()
]

#slide(title: [A long long long long long long long long long long long long long long long long long long long long long long long long Title])[
  A slide with some maths:
  $ x_(n+1) = (x_n + a/x_n) / 2 $

  #lorem(200)
]

#new-section-slide[First section]

#slide[
  A slide without a title but with *important* infos
]

#new-section-slide[Second section]

#focus-slide[
  Wake up!
]

// simple animations
#slide[
  a simple #pause dynamic slide with #alert[alert]

  #pause
  
  text.
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide, new-section-slide) = utils.methods(s)

#new-section-slide[Appendix]

#slide[
  appendix
]
```

