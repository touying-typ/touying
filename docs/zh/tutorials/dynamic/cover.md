---
sidebar_position: 4
---

# Cover 函数

正如您已经了解的那样，`uncover` 和 `#pause` 均会使用 `cover` 函数对不显示的内容进行遮盖。那么，这里的 `cover` 函数究竟是什么呢？


## 默认 Cover 函数：`hide`

`cover` 函数是保存在 `s.methods.cover` 的一个方法，后续 `uncover` 和 `#pause` 均会在这里取出 `cover` 函数来使用。

默认的 `cover` 函数是 [hide](https://typst.app/docs/reference/layout/hide/) 函数，这个函数能将内部的内容更改为不可见的，且不会影响布局。


## 更新 Cover 函数

有的情况下，您想用您自己的 `cover` 函数，那么您可以通过

```typst
config-methods(cover: (self: none, body) => hide(body))
```

方法来设置您自己的 `cover` 函数。


## hack: 处理 enum 和 list

你会发现现有的 cover 函数无法隐藏 enum 和 list 的 mark，参考 [这里](https://github.com/touying-typ/touying/issues/10)，因此你可以进行 hack：

```typst
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```


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