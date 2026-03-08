---
sidebar_position: 1
---

# 幻灯片结构

在 Touying 中，你可以像编写任何 Typst 文档一样构建演示文稿——使用标题、文本和函数调用。本教程介绍标题如何创建幻灯片、可以选择的两种编码风格，以及如何控制分页和章节结构。

## 标题创建幻灯片

Touying 自动将 Typst 标题转换为幻灯片。标题触发新幻灯片的深度取决于主题的 `slide-level` 设置。

大多数主题默认使用 `slide-level: 2`，这意味着：

| 标题级别 | 角色 |
|----------|------|
| `= …` | 创建新的**章节幻灯片** |
| `== …` | 创建新的**内容幻灯片** |
| `=== …` | 在当前幻灯片内创建**子标题** |

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= 第一章

== 第一张幻灯片

你好，Touying！

== 第二张幻灯片

再次问候！
```

某些主题（如 Dewdrop）使用三级标题。你可以随时通过以下方式覆盖：

```typst
#show: some-theme.with(config-common(slide-level: 3))
```

## 简单风格与块风格

Touying 支持两种编写幻灯片内容的方式。

### 简单风格

直接在标题下编写内容。`#pause` 和其他动画标记可以在内容流的任何地方使用：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= 标题

== 幻灯片

第一行。

#pause

第二行，稍后显示。
```

### 块风格

将幻灯片内容包裹在 `#slide[…]` 中。这可以访问额外的参数和特殊幻灯片类型：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= 标题

== 幻灯片

#slide[
  第一行。

  #pause

  第二行，稍后显示。
]
```

**为什么使用块风格？**

1. 很多时候我们需要特殊的 `slide` 函数，如 `#focus-slide`、`#title-slide`、`#centered-slide`；
2. 不同主题的 `#slide[…]` 可能有更多参数；
3. 只有 `slide` 函数才能使用回调风格内容块来实现 `#only` 和 `#uncover` 的复杂动画效果；
4. 结构更清晰，通过识别 `#slide[…]` 块可以轻松区分分页效果。

## 使用 `---` 分页

在简单风格中，单独一行的 `---` 会插入 `#pagebreak()` 并开始新幻灯片，同时保持当前标题：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== 长幻灯片

第一页内容。

---

第二页内容（相同标题）。
```

## 空幻灯片

`#empty-slide[]` 创建没有页眉和页脚的幻灯片——适合全屏图片或空白间隔：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== 普通幻灯片

常规内容。

#empty-slide[
  #align(center + horizon)[
    #text(size: 2em)[全屏插页]
  ]
]
```

## 特殊标题标签

你可以在标题上附加特殊标签来控制其行为：

| 标签 | 效果 |
|------|------|
| `<touying:hidden>` | 幻灯片完全不可见（不渲染） |
| `<touying:skip>` | 跳过该标题的自动章节幻灯片 |
| `<touying:unnumbered>` | 不计入幻灯片编号 |
| `<touying:unoutlined>` | 从 `outline()` 中排除 |
| `<touying:unbookmarked>` | 不生成 PDF 书签 |
| `<touying:handout>` | 仅在讲义模式下显示 |

示例——隐藏目录幻灯片使其不计入编号：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))
#show: simple-theme.with(aspect-ratio: "16-9")

= 简介

== 目录 <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

== 动机

一些动机内容。
```

## 章节与导航

### 幻灯片级别

`slide-level` 配置控制多少级标题会创建新幻灯片：

```typst
// 三级标题都创建幻灯片
#show: my-theme.with(config-common(slide-level: 3))
```

### 目录

使用原生 Typst `outline()` 显示目录。用 `components.adaptive-columns` 包裹以避免长目录溢出：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))
#show: simple-theme.with(aspect-ratio: "16-9")

= 第一章

== 目录 <touying:hidden>

#components.adaptive-columns(outline(indent: 1em))

== 第一张幻灯片

一些内容。

= 第二章

== 另一张幻灯片

更多内容。
```

### 渐进式目录

某些主题支持突出显示当前章节的渐进式目录：

```typst
// 在支持的主题中可用（如 dewdrop）
#components.progressive-outline()

// 可自定义的变体
#components.custom-progressive-outline(
  alpha: 60%,
  level: 2,
)
```

### 标题编号

使用标准 Typst `set heading` 规则为标题添加编号。`numbly` 包使混合格式编号变得简单：

```typst
#import "@preview/numbly:0.1.0": numbly
#set heading(numbering: numbly("{1}.", default: "1.1"))
```

## 禁用自动章节幻灯片

默认情况下，许多主题在遇到一级标题时会调用 `new-section-slide-fn`，创建专门的章节标题幻灯片。要禁用此功能：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
)

= 章节（无自动幻灯片）

== 第一张幻灯片

内容。
```

## 附录

使用 `#show: appendix` 标记附录的开始。这会冻结幻灯片计数器，使附录幻灯片不影响页脚显示的总数：

```typst
#show: appendix

= 附录

== 补充材料

这些幻灯片不会影响"X / Y"幻灯片计数器。
```
