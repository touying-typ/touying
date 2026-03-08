---
sidebar_position: 4
---

# 页面布局

## 基础概念

要想使用 Typst 制作一个样式美观的 slides，正确理解 Typst 的页面模型是必须的，如果你不关心自定义页面样式，你可以选择跳过这部分，否则还是推荐看一遍这部分。

下面我们通过一个具体的例子来说明 Typst 的默认页面模型。

```example
#let container = rect.with(height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(stroke: (dash: "dashed"))

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  header: container[#innerbox[Header]],
  header-ascent: 30%,
  footer: container[#innerbox[Footer]],
  footer-descent: 30%,
)

#place(top + right)[Margin→]
#container[
  #container[
    #innerbox[Content]
  ]
]
```

我们需要区分以下概念：

1. **Model:** Typst 拥有与 CSS Box Model 类似的模型，分为 Margin、Padding 和 Content，但其中 padding 并非 `set page(..)` 的属性，而是我们手动添加 `#pad(..)` 得到的。
2. **Margin:** 页边距，分为上下左右四个方向，是 Typst 页面模型的核心，其他属性都会受到页边距的影响，尤其是 Header 和 Footer。Header 和 Footer 实际上是位于 Margin 内部。
4. **Header:** Header 是页面顶部的内容，又分为 container 和 innerbox。我们可以注意到 header container 和 padding 的边缘并不贴合，而是也有一定的空隙，这个空隙实际上就是 `header-ascent: 30%`，而这里的百分比是相对于 margin-top 而言的。并且，我们注意到 header innerbox 实际上位于 header container 左下角，也即 innerbox 实际上默认有属性 `#set align(left + bottom)`。
5. **Footer:** Footer 是页面底部的内容，与 Header 类似，只不过方向相反。
6. **Place:** `place` 函数可以实现绝对定位，在不影响父容器内其他元素的情况下，相对于父容器来定位，并且可以传入 `alignment`、`dx` 和 `dy`，很适合用来放置一些修饰元素，例如 Logo 之类的图片。

因此，要将 Typst 应用到制作 slides 上，我们只需要设置

```typst
#set page(
  margin: (x: 4em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
)
```

即可。但是我们还需要解决 header 如何占据整个页面宽度的问题，在这里我们使用 negative padding 实现，例如我们有

```example
#let container = rect.with(stroke: (dash: "dashed"), height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(fill: rgb("#d0d0d0"))
#let margin = (x: 4em, y: 2em)

// negative padding for header and footer
#let negative-padding = pad.with(x: -margin.x, y: 0em)

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  margin: margin,
  header: negative-padding[#container[#align(top)[#innerbox(width: 100%)[Header]]]],
  header-ascent: 0em,
  footer: negative-padding[#container[#align(bottom)[#innerbox(width: 100%)[Footer]]]],
  footer-descent: 0em,
)

#place(top + right)[↑Margin→]
#container[
  #container[
    #innerbox[Content]
  ]
]
```

## 页面管理

由于 Typst 中使用 `set page(..)` 命令来修改页面参数，会导致创建一个新的页面，而不能修改当前页面，因此 Touying 选择维护一个 `self.page` 成员变量。

例如，上面的例子就可以改成

```typst
config-page(
  margin: (x: 4em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
)
```

Touying 会自动检测 `margin.x` 的值，并且判断如果设置 `config-common(zero-margin-header: true)` 也即 `self.zero-margin-header == true`，就会自动为 header 加入负填充。

同理，如果你对某个主题的 header 或 footer 样式不满意，你也可以通过

```typst
config-page(footer: [Custom Footer])
```

:::warning[警告]

因此，你不应该自己使用 `set page(..)` 命令，因为会被 Touying 重置。

:::

借助这种方式，我们也可以通过 `self.page` 实时查询当前页面的参数，这对一些需要获取页边距或当前页面背景颜色的函数很有用，例如 `transparent-cover`。这里就部分等价于 context get rule，而且实际上用起来会更方便。


## 页面分栏

如果你需要将页面分为两栏或三栏，你可以使用 Touying `slide` 函数默认提供的 `composer` 功能，最简单的示例如下：

```example
#slide[
  First column.
][
  Second column.
]
```

如果你需要更改分栏的方式，可以修改 `slide` 的 `composer` 参数，其中默认的参数是 `components.side-by-side.with(columns: auto, gutter: 1em)`，如果我们要让左边那一栏占据剩余宽度，可以使用

```example
#slide(composer: (1fr, auto))[
  First column.
][
  Second column.
]
```

