---
sidebar_position: 5
---

# Aqua 主题

这个主题由 [@pride7](https://github.com/pride7) 制作，它的美丽背景为使用 Typst 的可视化功能制作的矢量图形。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.0": *
#import themes.aqua: *

#show: aqua-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `header`: 显示在页眉的内容，默认为 `utils.display-current-heading()`，也可以传入形如 `self => self.info.title` 的函数。
- `footer`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display()`。

并且 Aqua 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Aqua 默认使用了

```typst
config-colors(
  primary: rgb("#003F88"),
  primary-light: rgb("#2159A5"),
  primary-lightest: rgb("#F2F4F8"),
  neutral-lightest: rgb("#FFFFFF"),
)
```

颜色主题，你可以通过 `config-colors()` 对其进行修改。

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
  composer: components.side-by-side,
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


## 示例

```example
#import "@preview/touying:0.7.0": *
#import themes.aqua: *

#show: aqua-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()

= The Section

== Slide Title

#lorem(40)

#focus-slide[
  Another variant with primary color in background...
]

== Summary

#slide(self => [
  #align(center + horizon)[
    #set text(size: 3em, weight: "bold", fill: self.colors.primary)
    THANKS FOR ALL
  ]
])
```

