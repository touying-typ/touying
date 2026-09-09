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

如果您的自定义方法会真正地隐藏内容（包括脚注），请设置 `config-common(cover-hides-footnote: true)`。


## Alpha 变化 Cover 函数

Touying 提供了 Alpha 变化 Cover 函数的支持，只需要加入

```typst
config-methods(cover: utils.alpha-changing-cover)
```

即可开启，其中你可以通过 `alpha: ..` 参数调节透明度。


:::tip[原理]

`utils.alpha-changing-cover` 的工作方式是将遇到的所有颜色的 alpha 值降低。由于需要在每一层嵌套的样式或上下文中访问 Typst 的 context，这可能会有一定的性能开销。

如果你发现项目编译变慢，可以尝试切换到 `utils.color-changing-cover`，它会将所有内容变为灰色。

这两种方法并不能改变所有显示的颜色。图片或平铺等内容无法被干预。因此，两种方法都使用了一个备用的 hide 机制，通过 `utils.semi-transparent-rect` 叠加一个灰色半透明矩形来模拟相同效果。不再推荐将该函数作为默认选项，因为它存在若干已知但不会修复的问题。

:::

## 脚注与 Cover 函数

`cover-hides-footnote` 默认为 `auto`：只有 Touying 自带的默认 `cover` 方法会被当作「真正隐藏内容」，其余方法一律按「仅改变视觉效果」处理。这个判断决定了被 `#pause` 遮盖的脚注如何渲染：

- 真正隐藏内容的 cover 方法不能生成真实的脚注，否则在内容尚未显示时，脚注条目就已经出现在分隔线下方了。因此 Touying 会改为绘制一个占位标记，以保留同样的宽度。
- 仅改变视觉效果的 cover 方法（例如 `alpha-changing-cover` 和 `color-changing-cover`）会生成真实的脚注，只是和其余被遮盖的内容一样被淡化。

由于 Typst 无法检查任意 `cover` 函数的行为，`auto` 只能通过身份来识别 Touying 自带的默认方法。所以如果您自定义的 `cover` 方法同样会真正隐藏内容，请显式地设置 `config-common(cover-hides-footnote: true)`。

如果您想自定义脚注标记的样式，请使用 `config-common(footnote-style: ..)`，也就是您原本会传给 `show footnote: ..` 的那个函数。Touying 会把它安装为 `show footnote: footnote-style`，并同时用它来绘制上面提到的占位标记，从而让真实脚注和占位标记保持一致。
