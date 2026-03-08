---
sidebar_position: 6
---

# 常见问题

从 GitHub Issues、Typst 论坛和日常使用中收集的常见问题与解答。

## 一般问题

### Touying 是什么？与 Polylux 或 Beamer 有什么不同？

Touying 是类似于 LaTeX Beamer 的 Typst 演示文稿包。

- 相较于 **Polylux** — Touying 提供 `#pause` 和 `#meanwhile` 而不依赖 `counter` 或 `locate`，编译性能更好。Touying 还通过 `config-*` 函数提供全局配置，使主题创建更简便。
- 相较于 **Beamer** — Touying 编译速度为毫秒级而非秒级，语法也更加简洁。
- 相较于 **Markdown 幻灯片** — Touying（通过 Typst）拥有完整的排版控制：自定义页眉、页脚、布局、数学公式、代码块等。

### Touying 需要哪个 Typst 版本？

Touying 0.6.2 需要 **Typst 0.12.0** 或更高版本（见 `typst.toml`）。本地编译时始终使用对应版本。

### 如何安装 Touying？

无需安装！只需在 `.typ` 文件顶部添加导入：

```typst
#import "@preview/touying:0.6.2": *
#import themes.simple: *
```

Typst CLI 或 Web App 会自动下载该包。

---

## 动画

### `#pause` 产生额外空白页——怎么回事？

这通常发生在 `#pause` 出现在幻灯片内容末尾时。引擎尝试在标记处分割但找不到后续内容，生成空的最后一个子幻灯片。解决方法：删除末尾的 `#pause`，或确保每个 `#pause` 后都有内容。

### `#pause` 在 `grid` 或 `table` 中不起作用

Touying 支持在 `grid` 和 `table` 中使用 `#pause`。确保你使用的是 Touying 0.5.0 或更高版本。如果仍有问题，切换到回调风格：

```typst
#slide(repeat: 3, self => [
  #let (uncover,) = utils.methods(self)
  #grid(
    columns: 2,
    [左列],
    uncover("2-")[右列在第 2 张出现],
  )
])
```

### `#meanwhile` 在 CeTZ 中不起作用

这是在 v0.6.2 中修复的 Bug。更新到最新版本：

```typst
#import "@preview/touying:0.6.2": *
```

### `#pause` 后列表/枚举标记仍然可见

默认的 `cover` 函数使用 Typst 的 `hide`，它保留文本布局——包括列表标记。启用标记隐藏变通方案：

```typst
config-common(show-hide-set-list-marker-none: true)
```

或完全替换遮盖函数：

```typst
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```

### 如何在 CeTZ / Fletcher 中使用动画？

使用 `touying-reducer` 绑定：

```typst
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)
```

然后在绘图命令中使用 `(pause,)` 元组：

```typst
#cetz-canvas({
  import cetz.draw: *
  rect((0, 0), (5, 5))
  (pause,)
  circle((2.5, 2.5), radius: 1)
})
```

### 定理编号在子幻灯片之间变化

这是因为 Touying 分别渲染每个子幻灯片，定理计数器会重置。使用 `frozen-counters` 修复：

```typst
// 对于 theorion 包：
config-common(frozen-counters: (theorem-counter,))
```

### 如何在讲义模式中只显示某个子幻灯片？

```typst
config-common(handout: true, handout-subslides: 1)  // 第一个子幻灯片
config-common(handout: true, handout-subslides: (1, 3))  // 第 1 和第 3 个
```

---

## 布局与样式

### 如何更改幻灯片背景颜色？

所有幻灯片使用 `config-page(fill: …)`：

```typst
#show: my-theme.with(
  config-page(fill: rgb("#1e1e2e")),
)
```

单张幻灯片：

```typst
#slide(config: config-page(fill: blue.lighten(80%)))[
  蓝色背景。
]
```

### 如何更改字体？

使用标准 Typst `set text` 规则：

```typst
#show: metropolis-theme.with(…)
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
```

或使用 `config-methods(init: …)` 访问主题颜色：

```typst
config-methods(
  init: (self: none, body) => {
    set text(font: "思源黑体", fill: self.colors.neutral-darkest)
    body
  },
)
```

### 如何垂直居中幻灯片内容？

```typst
// 单张幻灯片（metropolis 主题有 align 参数）：
#slide(align: center + horizon)[居中内容。]

// 所有幻灯片，使用 init 方法：
config-methods(
  init: (self: none, body) => {
    show: std.align.with(center + horizon)
    body
  },
)
```

### 如何删除页眉/页脚？

```typst
// 仅删除页眉
config-page(header: none)

// 仅删除页脚
config-page(footer: none)

// 单张幻灯片
#slide(config: utils.merge-dicts(
  config-page(header: none, footer: none),
))[…]
```

### 如何在标题页隐藏幻灯片编号？

大多数主题的标题幻灯片函数设置 `freeze-slide-counter: true`，这意味着标题页不计入幻灯片编号。如果你仍然看到它，检查你的自定义页脚是否访问了 `utils.slide-counter.display()`，并添加保护：

```typst
footer: self => if not self.freeze-slide-counter {
  context utils.slide-counter.display() + " / " + utils.last-slide-number
}
```

### 如何添加多列布局？

```typst
#slide(composer: (1fr, 1fr))[左列][右列]
#slide(composer: (2fr, 1fr))[宽左列][窄右列]
#slide(composer: (auto, 1fr))[自动宽度][弹性列]
```

### 内容溢出幻灯片——如何修复？

选项：
- 减小字号：在幻灯片内使用 `set text(size: 18pt)`。
- 使用 `utils.fit-to-width` 或 `utils.fit-to-height` 缩放内容。
- 用 `---` 或 `#pagebreak()` 将幻灯片分成多页。
- 调整边距：`config-page(margin: (x: 1em, y: 1em))`。

---

## 主题

### 如何更改主题的主色调？

```typst
#show: metropolis-theme.with(
  config-colors(primary: rgb("#005bac")),
)
```

### 如何在幻灯片上添加 Logo？

```typst
config-info(logo: image("logo.png", width: 2cm))
// 或使用表情符号：
config-info(logo: emoji.school)
```

### 如何修改内置主题的页眉/页脚？

向 `header`/`footer` 参数传入自定义内容或函数：

```typst
#show: simple-theme.with(
  header: self => text(fill: blue)[我的自定义页眉],
  footer: self => [© 2025 我的公司],
)
```

### 如何在页眉中同时显示章节和小节？

```typst
header: self => [
  #utils.display-current-heading(level: 1)   // 章节
  #h(1em) — #h(1em)
  #utils.display-current-heading(level: 2)   // 小节
]
```

### Dewdrop 目录幻灯片在我没有要求时出现了

这发生在 `config-common(new-section-slide-fn: new-section-slide)` 为默认值时。禁用它：

```typst
#show: dewdrop-theme.with(
  config-common(new-section-slide-fn: none),
)
```

或跳过特定章节的自动幻灯片：

```typst
= 我的章节 <touying:skip>
```

### Stargazer 主题：`<touying:skip>` 有什么作用？

`<touying:skip>` 抑制一级标题触发的自动新章节幻灯片。当你希望章节标题出现在目录中但不生成专门的章节幻灯片时很有用。

---

## 演讲者备注与导出

### 如何将演讲者备注导出到 pdfpc？

```sh
typst query --root . my-slides.typ --field value --one "<pdfpc-file>" > my-slides.pdfpc
```

然后用 `pdfpc --notes my-slides.pdfpc` 打开 `my-slides.pdf`。

### 如何在第二块屏幕上显示备注？

```typst
config-common(show-notes-on-second-screen: right)
```

支持的值：`right`、`bottom`、`none`。

---

## 包集成

### 如何在 Touying 中使用 Codly？

在 `config-common(preamble: …)` 中初始化 Codly：

```typst
#import "@preview/codly:1.0.0": *
#show: codly-init.with()

#show: my-theme.with(
  config-common(preamble: {
    codly(languages: (rust: (name: "Rust", color: rgb("#CE412B"))))
  }),
)
```

### 如何在 Touying 中使用 Theorion 定理和 `#pause`？

定理计数器默认在子幻灯片之间重置。冻结它：

```typst
config-common(frozen-counters: (theorem-counter,))
```

### 如何在 Touying 中使用 `#bibliography`？

Typst 0.14 中的一个 Bug 破坏了某些上下文中的参考文献。Touying 0.6.2 包含了修复。将导入版本更新到 `0.6.2`。

脚注风格的引用：

```typst
config-common(
  bibliography-as-footnote: bibliography(title: none, "refs.bib"),
)
```

### 如何在幻灯片中使用带 `#pause` 的数学公式？

在数学块内使用 `pause`（无 `#`）：

```typst
$
  f(x) &= pause x^2 + 1 \
       &= pause (x + 1)(x - 1) + 2
$
```

---

## 多文件与高级用法

### 如何在多文件项目中使用 Touying？

创建一个导入 Touying 和主题的 `globals.typ`，然后在每个文件中导入它：

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *
```

```typst
// main.typ
#import "/globals.typ": *
#show: university-theme.with(…)
#include "content.typ"
```

```typst
// content.typ
#import "/globals.typ": *

= 章节
== 幻灯片
内容。
```

### 如何在附录中停止幻灯片计数器增加？

使用 `#show: appendix`：

```typst
#show: appendix

= 附录

== 补充幻灯片

这不会影响页脚显示的总数。
```

### 在 Touying 文档中可以在任意位置使用 `set` 和 `show` 规则吗？

可以，自 Touying 0.5.0 起。可以在任何位置放置 `set` 和 `show` 规则——在主题 `#show:` 调用前后，或在幻灯片内部。它们将被适当地限定作用域。
