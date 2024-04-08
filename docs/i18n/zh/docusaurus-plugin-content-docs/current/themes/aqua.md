---
sidebar_position: 5
---

# Aqua 主题

![image](https://github.com/touying-typ/touying/assets/34951714/5f9b3c99-a22a-4f3d-a266-93dd75997593)

这个主题由 [@pride7](https://github.com/pride7) 制作，它的美丽背景为使用 Typst 的可视化功能制作的矢量图形。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `footer`: 展示在页脚右侧的内容，默认为 `states.slide-counter.display()`。
- `lang`: 语言配置，目前只支持 `"en"` 和 `"zh"`，默认为 `"en"`,

并且 Aqua 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Aqua 默认使用了

```typst
#let s = (s.methods.colors)(
  self: s,
  primary: rgb("#003F88"),
  primary-light: rgb("#2159A5"),
  primary-lightest: rgb("#F2F4F8"),
```

颜色主题，你可以通过 `#let s = (s.methods.colors)(self: s, ..)` 对其进行修改。

## slide 函数族

Aqua 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示。

---

```typst
#let outline-slide(self: none, enum-args: (:), leading: 50pt)
```

显示一个大纲页。

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // Aqua theme
  title: auto,
)[
  ...
]
```
默认拥有标题和页脚的普通 slide 函数，其中 `title` 默认为当前 section title。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary`。

---

```typst
#new-section-slide(title)
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
#import "@preview/touying:0.4.0": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/eea4df8d-d9fd-43ac-aaf7-bb459864a9ac)



## 示例

```typst
#import "../lib.typ": *

#let s = themes.aqua.register(aspect-ratio: "16-9", lang: "en")
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

#let (slide, empty-slide, title-slide, outline-slide, focus-slide) = utils.slides(s)
#show: slides

= The Section

== Slide Title

#slide[
  #lorem(40)
]

#focus-slide[
  Another variant with primary color in background...
]

== Summary

#align(center + horizon)[
  #set text(size: 3em, weight: "bold", s.colors.primary)
  THANKS FOR ALL
]
```

