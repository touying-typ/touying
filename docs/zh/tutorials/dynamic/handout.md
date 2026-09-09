---
sidebar_position: 6
---

# 讲义模式

讲义模式将每张逻辑幻灯片的所有动画子幻灯片合并为单页，便于生成可打印或可分发的演示文稿版本。

## 启用讲义模式

```typst
config-common(handout: true)
```

将其放在主题设置中：

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: true),
)

= Title

== Animated Slide

First item.

#pause

Second item (won't generate a separate page in handout mode).

#pause

Third item.
```

默认情况下，讲义模式只保留每张幻灯片的**最后一个**子幻灯片。

## 使用 `export-mode` 切换

`config-common(handout: true)` 需要修改源文件。如果你不想改动源文件，可以改用 `export-mode`：

```typst
config-common(export-mode: "handout")
```

它还可以直接在命令行上传入，这样导出讲义时完全不需要改动源文件：

```bash
typst compile slides.typ --input export-mode=handout handout.pdf
```

`export-mode` 的取值为 `"slides"`（默认）、`"presentation"`、`"handout"` 和 `"article"`。`"handout"` 会设置 `handout: true`，`"presentation"` 会设置 `handout: false`，而 `"article"` 则会进入 article（文章）模式，把幻灯片渲染成连续的文章。

## 选择保留哪个子幻灯片

你可以使用 `handout-subslides` 指定讲义输出中保留特定的子幻灯片：

```typst
// 只保留第一个子幻灯片（适用于"之前"快照）
config-common(handout: true, handout-subslides: 1)

// 保留第一个和最后一个子幻灯片
config-common(handout: true, handout-subslides: (1, -1))

// 用字符串表示范围（与 `only`/`uncover` 语法相同）
config-common(handout: true, handout-subslides: "1-2")
```

## 仅在讲义中显示的幻灯片

使用 `<touying:handout>` 标签创建**仅在讲义模式下**显示、在正常演示时隐藏的幻灯片：

```typst
== Extra Notes for Handout <touying:handout>

This slide is included when `handout: true` but invisible otherwise.
```

## 仅在某一模式下显示的内容

`<touying:handout>` 标签作用于整张幻灯片。如果只想控制局部内容出现在哪种模式下，可以使用下面三个行内标记：

| 标记 | 出现在 |
|---|---|
| `#handout-only[..]` | 仅讲义模式 |
| `#presentation-only[..]` | 仅演示模式（即 `handout: false`） |
| `#slides-only[..]` | 讲义模式和演示模式，但不出现在 article 模式 |

```typst
#handout-only[这段文字只在讲义中出现。]

#presentation-only[这段文字只在演示时出现。]

#slides-only[_现场演示——请参见代码仓库。_]
```

被隐藏时内容会被完全移除，不会保留空间。这三个标记的正文自身也可以包含分页元素（标题、`#pagebreak()`、单独一行的 `---`），在该内容确实可见的模式下，它们的行为与没有这层包装时完全一致。在 article 模式下，这三个标记的内容都会被整体去掉。

## 工作流建议

一种常见的工作流是：演示时保持 `handout: false`（默认值），导出分发用的 PDF 时切换为 `handout: true`：

```typst
// 演示时
#show: my-theme.with(config-common(handout: false))

// 构建讲义 PDF 时
#show: my-theme.with(config-common(handout: true))
```

如果不想改动源文件，也可以用上面提到的 `--input export-mode=handout` 直接导出讲义。
