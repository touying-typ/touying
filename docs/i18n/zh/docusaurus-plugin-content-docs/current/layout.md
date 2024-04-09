---
sidebar_position: 5
---

# 页面布局

## 基础概念

要想使用 Typst 制作一个样式美观的 slides，正确理解 Typst 的页面模型是必须的，如果你不关心自定义页面样式，你可以选择跳过这部分，否则还是推荐看一遍这部分。

下面我们通过一个具体的例子来说明 Typst 的默认页面模型。

```typst
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

![image](https://github.com/touying-typ/touying/assets/34951714/70d48053-c777-4253-a9ca-ada360b5a987)

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

```typst
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

![image](https://github.com/touying-typ/touying/assets/34951714/d74896f4-90e7-4b36-a5a9-9c44307eb192)

## 页面管理

由于 Typst 中使用 `set page(..)` 命令来修改页面参数，会导致创建一个新的页面，而不能修改当前页面，因此 Touying 选择维护一个 `s.page-args` 成员变量和一个 `s.padding` 成员变量，只在 Touying 自己创建新 slide 时才会自己应用这些参数，因此用户只需要关注 `s.page-args` 和 `s.padding` 即可。

例如，上面的例子就可以改成

```typst
#(s.page-args += (
  margin: (x: 4em, y: 2em),
  header: align(top)[Header],
  footer: align(bottom)[Footer],
  header-ascent: 0em,
  footer-descent: 0em,
))
```

Touying 会自动检测 `margin.x` 的值，并且判断如果 `self.full-header == true`，就会自动为 header 加入负填充。

同理，如果你对某个主题的 header 或 footer 样式不满意，你也可以通过

```typst
#(s.page-args.footer = [Custom Footer])
```

这样方式进行更换。不过需要注意的是，如果这样更换了页面参数，你需要将其放在 `#let (slide, empty-slide) = utils.slides(s)` 之前，否则就需要重新调用 `#let (slide, empty-slide) = utils.slides(s)`。

:::warning[警告]

因此，你不应该自己使用 `set page(..)` 命令，而是应该修改 `s` 内部的 `s.page-args` 成员变量。

:::

借助这种方式，我们也可以通过 `s.page-args` 实时查询当前页面的参数，这对一些需要获取页边距或当前页面背景颜色的函数很有用，例如 `transparent-cover`。这里就部分等价于 context get rule，而且实际上用起来会更方便。

## 应用：添加 Logo

为 slides 添加一个 Logo 是及其普遍，但是又及其多变的一个需求。其中的难点在于，所需要的 Logo 大小和位置往往因人而异。因此，Touying 的主题大部分都不包含 Logo 的配置选项。但借助本章节提到的页面布局的概念，我们知道可以在 header 或 footer 中使用 `place` 函数来放置 Logo 图片。

例如，我们决定给 metropolis 主题加入 GitHub 的图标，我们可以这样实现：

```typst
#import "@preview/touying:0.4.0": *
#import "@preview/octique:0.1.0": *

#let s = themes.metropolis.register(aspect-ratio: "16-9")
#(s.page-args.header = self => {
  // display the original header
  utils.call-or-display(self, s.page-args.header)
  // place logo to top-right
  place(top + right, dx: -0.5em, dy: 0.3em)[
    #octique("mark-github", color: rgb("#fafafa"), width: 1.5em, height: 1.5em)
  ]
})
#let (init, slide) = utils.methods(s)
#show: init

#slide(title: [Title])[
  Logo example.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/055d77e7-5087-4248-b969-d8ef9d50c54b)

其中 `utils.call-or-display(self, body)` 可以用于显示 `body` 为 content 或 `body` 为形如 `self => content` 形式的回调函数。

## 页面分栏

如果你需要将页面分为两栏或三栏，你可以使用 Touying `slide` 函数默认提供的 `compose` 功能，最简单的示例如下：

```typst
#slide[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/a39f88a2-f1ba-4420-8f78-6a0fc644704e)

如果你需要更改分栏的方式，可以修改 `slide` 的 `composer` 参数，其中默认的参数是 `utils.side-by-side.with(columns: auto, gutter: 1em)`，如果我们要让左边那一栏占据剩余宽度，可以使用

```typst
#slide(composer: (1fr, auto))[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc)

