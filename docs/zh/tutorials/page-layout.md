---
sidebar_position: 3
---

# 页面布局

Touying 让你完全控制每张幻灯片的布局——边距、页眉、页脚、列和背景。本教程介绍 Typst 的页面模型在演示文稿中的应用，以及 Touying 如何在此基础上构建。

## Typst 的页面模型

Typst 将页面分为四个区域：**边距**、**页眉**、**页脚**和**内容**。如果你想自定义幻灯片的外观，理解这个模型非常重要。

```example
#let container = rect.with(height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(stroke: (dash: "dashed"))

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  header: container[#innerbox[页眉]],
  header-ascent: 30%,
  footer: container[#innerbox[页脚]],
  footer-descent: 30%,
)

#place(top + right)[边距→]
#container[
  #container[
    #innerbox[内容]
  ]
]
```

要点：

- **边距** — 四边的空白区域。
- **页眉** — 渲染在顶部边距内。`header-ascent` 控制其从内容区域向上浮动的距离。
- **页脚** — 渲染在底部边距内。`footer-descent` 控制其从内容区域向下沉的距离。
- **`#place`** — 在页面内绝对定位，不影响正常流。适合放置 logo 和装饰元素。

## Touying 的页面管理

在纯 Typst 中，每次 `set page(…)` 调用都会创建一个**新页面**。Touying 改为维护一个 `self.page` 字典，在每张幻灯片上应用一次，因此你不需要直接调用 `set page(…)`。

通过 `config-page(…)` 配置页面：

```typst
#show: my-theme.with(
  config-page(
    margin: (x: 4em, y: 2em),
    header: align(top)[我的页眉],
    footer: align(bottom)[我的页脚],
    header-ascent: 0em,
    footer-descent: 0em,
  ),
)
```

:::warning

在 Touying 文档中永远不要使用 `set page(…)` — Touying 会在每张幻灯片上重置它。

:::

也可以为单张幻灯片覆盖页面配置：

```typst
#slide(
  config: config-page(fill: black),
)[
  深色背景幻灯片。
]
```

## 列（并排布局）

`#slide` 函数接受 `composer` 参数用于多列布局。传入一个列宽元组：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(composer: (1fr, 1fr))[
  左列。
][
  右列。
]
```

每个额外的内容块（`[…]`）成为一列。`composer` 元组定义宽度：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
// 右列只占其自然宽度
#slide(composer: (1fr, auto))[
  弹性左列。
][
  固定右列。
]
```

## 背景颜色和填充

更改所有幻灯片的背景颜色：

```typst
config-page(fill: rgb("#1e1e2e"))
```

单张幻灯片：

```typst
#slide(config: config-page(fill: gradient.linear(blue, purple)))[
  渐变背景。
]
```

## 宽高比

所有主题在初始化时接受 `aspect-ratio` 参数：

```typst
#show: my-theme.with(aspect-ratio: "16-9")
// 或
#show: my-theme.with(aspect-ratio: "4-3")
```

自定义尺寸，直接传入 `config-page`：

```typst
#show: my-theme.with(
  config-page(width: 254mm, height: 190mm),
)
```

## 工具：`fit-to-width` 和 `fit-to-height`

缩放内容以填充特定宽度或高度而不溢出。适用于页眉中的长标题或大图：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-width(grow: false, 80%)[
    #text(size: 48pt)[非常长的标题必须适应宽度]
  ]
]
```

## 绝对定位元素

使用 Typst 的 `#place(对齐方式, dx, dy)[…]` 放置装饰性叠加层：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  常规内容。

  #place(top + right, dx: -1em, dy: 1em)[
    #text(fill: red)[★ 新内容]
  ]
]
```
