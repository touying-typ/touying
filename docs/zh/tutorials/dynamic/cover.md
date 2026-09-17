---
sidebar_position: 4
---

# Cover 函数

正如您已经了解的那样，`uncover` 和 `#pause` 均会使用 `cover` 函数对不显示的内容进行遮盖。那么，这里的 `cover` 函数究竟是什么呢？


## 默认 Cover 函数：`hide`

`cover` 函数是保存在 `self.methods.cover` 的一个方法，后续 `uncover` 和 `#pause` 均会在这里取出 `cover` 函数来使用。

默认的 `cover` 函数是 [hide](https://typst.app/docs/reference/layout/hide/) 函数，这个函数能将内部的内容更改为不可见的，且不会影响布局。它是按下文所述的方式写入配置的。


## 更新 Cover 函数

有的情况下，您想用您自己的 `cover` 函数，那么您可以通过

```typst
config-methods(cover: utils.hiding-cover)
```

方法来设置您自己的 `cover` 函数。

关于自己编写的方法需要满足什么，请参阅下方的[编写你自己的 Cover 函数](#编写你自己的-cover-函数)。


## Alpha 与颜色变化 Cover 函数

Touying 提供了半透明化的 Cover 函数，只需设置

```typst
config-methods(cover: utils.alpha-changing-cover)
```

即可开启。你可以通过 `.with(alpha: 30%)` 添加 `alpha: ..` 参数来调节透明度。

你也可以试试它的同类 `utils.color-changing-cover`，它会把所有颜色都改成指定的那一种。


:::tip[原理]

`utils.alpha-changing-cover` 的工作方式是将遇到的所有颜色的 alpha 值降低。由于需要在每一层嵌套的样式或上下文中访问 Typst 的 context，这可能会有一定的性能开销。

如果你发现项目编译变慢，可以尝试切换到 `utils.color-changing-cover`。

这两种方法并不能改变所有显示的颜色。图片或平铺等内容无法被干预。因此，两种方法都使用了 `fallback-hide`，通过 `utils.semi-transparent-cover` 叠加一个灰色半透明矩形来模拟相同效果。不再推荐把该函数当作主要的 semi-transparent-cover 使用，因为它存在若干已知但不会修复的问题。

:::

### 遮盖带填充的图形

自带背景填充的元素通常不应被重新着色：图形和其上的文字会被强制成同一种颜色，文字将无法辨认。设想一张图片变成了一个灰色矩形。
因此 `utils.color-changing-cover` 可以转而把带填充的元素交给备用叠加层处理，这由 `fallback-for-filled: true`（默认值）控制。将其关闭即可像其余内容一样对它们重新着色，使整张幻灯片统一变灰：

```typst
config-methods(cover: utils.color-changing-cover.with(fallback-for-filled: false))
```

`utils.alpha-changing-cover` 没有该参数——降低透明度只会让图形变淡，而不会使它与其内容混为一色。

## 编写你自己的 Cover 函数

Cover 函数以具名参数接收 `self`，以位置参数接收待遮盖的内容，并返回遮盖后的内容：

```typst
#let my-cover(self: none, body) = block(hide(body))

config-methods(cover: my-cover)
```

### 声明你的方法做了什么

Touying 需要知道你的方法是**移除**或**隐藏**所遮盖的内容，还是仅仅**改变其样式**，因为这会改变被遮盖脚注的渲染方式：

- 移除内容的方法绝不能生成真实的脚注——脚注条目会出现在分隔线下方，而它所属的内容却仍被隐藏。因此 Touying 会改为绘制一个占位标记，并保留相同的宽度。
- 仅改变样式的方法则应当生成真实的脚注，并让它与其余内容一同被淡化。

所以，当被询问 `utils.cover-kind-query` 时，请作出回答：

```typst
#let my-cover(self: none, body) = if self == utils.cover-kind-query {
  "hide"
} else {
  block(hide(body))
}
```

如果你的方法会移除或隐藏内容，返回 `"hide"`；如果只是改变样式，返回 `"recolour"`；如果是在内容之上绘制，返回 `"paint"`。

Touying 自带的每个方法都会作出回答，包括通过 `.with(..)` 重新配置过的方法。未作回答的方法只能根据其返回值来推测，这能识别出直接的 `hide`，却识别不出被 `block` 或 `place` 包裹的 `hide`——这正是值得多写这一行来声明的原因。

### 遮盖图表标题

如果你回答了 `"recolour"`，Touying 还可能把 `utils.cover-caption-query` 作为 `self` 传给你。图表标题无法通过遮盖你所收到的内容来遮盖：其 `Figure 1:` 前缀与编号是在排版阶段生成的，并不属于这部分内容，因此它们会保持未遮盖；而直接遮盖 caption 元素本身又会把它变成块级元素，从而另起一行。请改为返回一个包裹住所收内容的 `show figure.caption` 规则：

```typst
#let my-cover(self: none, body) = if self == utils.cover-kind-query {
  "recolour"
} else if self == utils.cover-caption-query {
  show figure.caption: set text(fill: gray)
  body
} else {
  text(fill: gray, body)
}
```

隐藏或覆盖绘制的方法不会被询问——对它们而言，图表标题会像其他内容一样被整体遮盖。

### 自定义脚注标记

请使用 `config-common(footnote-style: ..)`，也就是你原本会传给 `show footnote: ..` 的那个函数。Touying 会将其安装为 `show footnote: footnote-style`，并同样用它来绘制上文提到的占位标记，从而让真实脚注与占位标记在视觉上保持一致。而你自己编写的 `show footnote: it => ..` 规则只会作用于真实的、已显示的脚注，不会作用于占位标记。
