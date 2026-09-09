---
sidebar_position: 9
---

# 演讲者备注

演讲者备注是写给你自己、而不是写给听众看的内容。你把它写在它所属的那张幻灯片旁边，而 Touying 会保证它不会出现在幻灯片本身里。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#show: simple-theme

== Photosynthesis

#align(horizon+center, text(size: 2em)[Light in, sugar out.])

#speaker-note[
  - Recap respiration from the previous section.
  - Time check: we should be at the 10 minute mark.
]
```

备注不会在幻灯片上留下任何痕迹。并且同一张幻灯片上可以写多个 `speaker-note[]`，它们会被自动收集到同一张备注页里。

演讲者备注的存在，主要是为了喂给演示工具 —— Touying 已经适配好的两个是
[pdfpc](../external/pdfpc.md) 和 [pympress](../external/pympress.md)。下面这几种机制中你需要哪一种，
取决于你使用的是哪个演示工具。

## 备注去往何处

一条备注有三个可能的去处，它们彼此独立 —— 在同一份文档里，你可以只用其中一个，也可以用两个，或者三个都用。

| 去处 | 如何启用 | 谁来读取 |
| --- | --- | --- |
| pdfpc 文件 | 默认开启（`enable-pdfpc: true`） | [pdfpc](../external/pdfpc.md)，通过一个 `.pdfpc` 附属文件 |
| 第二屏幕 | `config-common(show-notes-on-second-screen: ..)` | [pympress](../external/pympress.md) 以及任何双屏查看器 |
| 演讲者视图 | `config-common(show-only-notes: true)` | 你自己，或者能够同步两份 PDF 的工具 |

第一种是元数据，在 PDF 中不可见，可以导出为一个 `.pdfpc` 文件。另外两种会改变 PDF *本身所包含的内容*，
因此它们是关于视觉输出本身的选择。

## 第二屏幕

`show-notes-on-second-screen` 会把页面沿某一侧加倍，例如向右；并把该幻灯片收集到的备注放进多出来的那一半里。幻灯片保持自己原有的尺寸，因此左半边仍然是一张正常的幻灯片 —— 你把这半边全屏投影出去，自己看另外半边。

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-notes-on-second-screen: right),
)
```

`top`、`bottom`、`left` 和 `right` 均可使用。默认值是 `none`，即任何一侧都不显示备注。

这正是 [pympress](../external/pympress.md) 所期待的版式：它把幻灯片那一半显示在投影仪上，
把备注那一半显示在你自己的屏幕上，其间不涉及任何附属文件。那个页面上有一个完整的示例，
以及效果截图。

`config-page(background: ..)` 属于幻灯片，只会覆盖幻灯片自己的那一半。备注那一半的样式是单独设置的 —— 参见 [面板样式](#面板样式)。

## 演讲者视图

`show-only-notes: true` 会把页面上的内容对调。备注成为页面的主体内容，而整张幻灯片被缩成角落里的一个预览。

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-only-notes: true),
)
```

关于它，有两点很容易搞错。

**它不会丢掉任何东西。** 页数与一次正常编译完全相同，子幻灯片也包含在内 —— 每一页都还在，只是显示的是备注而不是幻灯片。因此演讲者版导出的第 7 页，正好对应幻灯片的第 7 页，这也正是两者能够并排使用的原因。

**它是第二次导出，而不是一种你用来演讲的模式。** 你从同一份源文件产出两个 PDF：一个正常的给投影仪，另一个打开了这个开关，作为演讲者版。Touying 没有为它内置命令行开关，所以如果你不想在两次编译之间手动改文件，就自己加一道判断：

```typst
#let notes-export = sys.inputs.at("notes", default: none) != none

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-only-notes: notes-export),
)
```

```sh
typst compile slides.typ slides.pdf
typst compile slides.typ --input notes=true notes.pdf
```

## 把备注限制在部分子幻灯片上

默认情况下，备注会跟随它所在位置的 pause 状态，和普通内容完全一样：写在 `#pause` 之后的备注，只会从那张子幻灯片开始出现。`subslide:` 可以覆盖这个行为。

```typst
// only on subslide 2
#speaker-note(subslide: 2)[Mention the caveat here.]

// on every subslide, regardless of where it sits
#speaker-note(subslide: none)[Keep an eye on the clock.]
```

备注的正文本身也可以包含 `#pause`，从而让备注随着子幻灯片逐步展开。

## 给 pdfpc 使用的 Markdown 备注

pdfpc 会把备注当作 Markdown 来渲染。`mode` 控制 Touying 如何把一条备注序列化进 pdfpc 文件 —— 无论哪种方式，你写的都仍然是普通的 Typst：

```typst
#speaker-note(mode: "md")[
  - a bullet
  - *bold*
]
```

在 `mode: "typ"`（默认值）下，那个 `*bold*` 会被原样写成 `*bold*`；而在 `mode: "md"` 下它会变成 `**bold**`，这正是 pdfpc 所期待的形式。标题、链接和强调也按同样的方式转换。

## 导出给 pdfpc

在 `enable-pdfpc: true`（默认值）下，Touying 会把每一条备注连同幻灯片结构一起，
记录进文档的 pdfpc 元数据中。把它写成 PDF 旁边的一个 `.pdfpc` 文件，
pdfpc 的备注、overlay 结构和计时就都来自于此。

产生这个文件有两种方式 —— 编译之后执行一次 `typst query`，或者在 bundle 导出时使用
`#pdfpc.bundle-assets()`，后者不需要第二条命令。两者都在 [pdfpc](../external/pdfpc.md)
页面上有介绍，那里还说明了用于设置演讲时长、倒计时和幻灯片切换效果的 `#pdfpc.config(..)`。

那个页面同样记录了 `#pdfpc.speaker-note(..)`，这是 Touying 为兼容
[Polylux](https://polylux.dev/book/external/pdfpc.html) 而保留的更底层的调用。它会把一个原始字符串
直接写进元数据，并不接受上面介绍的那些参数，因此除非你是在移植已有的幻灯片，否则请优先使用
`#speaker-note[..]`。两者最终会落到同一个地方：同一张幻灯片上的多条备注会被拼接进该幻灯片的条目里。

## 面板样式

显示备注的那个面板 —— 无论是第二屏幕还是 only-notes 视图 —— 都是由主题绘制的，通过一个放进 `config-common(notes-fn: ..)` 的 `notes` 函数。每个内置主题都设置了它，因此备注看起来会和主题的其余部分保持一致。

没有主题时的默认值是 `touying-notes`，它负责版式，而把样式留给你：`header`、`header-fill`、`fill`、`note-setting` 和 `preview-setting`。如何为你自己的主题写一个，参见 [创建自己的主题](build-your-own-theme.md)。
