---
sidebar_position: 1
---

# 幻灯片计数器与进度

Touying 提供了一组计数器和工具函数，用于追踪和显示演示文稿的播放进度。

## 幻灯片计数器

`utils.slide-counter` 是 Typst 主计数器，每张幻灯片时递增。

```typst
// 显示当前幻灯片编号
#context utils.slide-counter.display()
```

注意使用 `.display()` 而不是 `.get()`：`.get()` 返回的是计数器的**数组**形式，直接放进内容里会渲染成 `(1,)`。

在自定义页脚中使用：

```example
#import "@preview/touying:0.7.4": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    footer: context [Slide #utils.slide-counter.display()],
  ),
)

= Section

== First Slide

Content here.

== Second Slide

More content.
```

## 幻灯片总数

`utils.last-slide-number` 保存**附录之前**最后一张幻灯片的编号。这通常用作"第 X / Y 页"页脚中的分母：

```typst
#context [#utils.slide-counter.display() / #utils.last-slide-number]
```

这里 `#context` 后面必须跟一个内容块。如果写成 `#context utils.slide-counter.display() + " / " + utils.last-slide-number`，在 markup 模式下 `#context` 只会绑定到第一个表达式，后面的 `+ " / " + utils.last-slide-number` 会被当作普通文本原样输出。

## 进度条

`utils.touying-progress` 提供一个 0.0 至 1.0 的比例值，表示当前在演示文稿中的进度：

```typst
#utils.touying-progress(ratio => {
  // ratio 是一个介于 0.0 和 1.0 之间的浮点数
  box(width: ratio * 100%, height: 4pt, fill: primary)
})
```

metropolis 和 aqua 主题的进度条即以此方式实现。

## 附录与冻结计数器

`appendix` show 规则只冻结**分母**，即 `utils.last-slide-number`（幻灯片总数），使附录幻灯片不改变页脚中显示的总数。幻灯片计数器 `utils.slide-counter` 仍然继续递增，因此附录中的页脚会显示形如 `5 / 3` 的编号：

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme

= Main Section

== Introduction

The slide count increments normally here.

== Second Slide

Still counting.

#show: appendix

= Appendix

== Backup Slide

The denominator still shows the count from the last main slide,
while the slide number itself keeps advancing.
```

如果你希望某张幻灯片完全不参与计数（幻灯片编号和总数都不递增），请使用 `config-common(freeze-slide-counter: true)`。Touying 自带的主题正是用它来让标题页、章节页和 `focus-slide` 不占用幻灯片编号的：

```typst
#slide(config: config-common(freeze-slide-counter: true))[
  This slide does not advance the slide counter.
]
```
