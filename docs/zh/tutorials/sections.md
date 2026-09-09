---
sidebar_position: 2
---

# 节与小节

## 结构

与 Beamer 相同，Touying 同样有着 section 和 subsection 的概念。

一般而言，1 级、2 级和 3 级标题分别用来对应 section、subsection 和 subsubsection，例如 dewdrop 主题。

```example
#import "@preview/touying:0.7.4": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Section

== Subsection

=== Title

Hello, Touying!
```

但是很多时候我们并不需要 subsection，因此也会使用 1 级和 2 级标题来分别对应 section 和 title，例如 university 主题。

```example
#import "@preview/touying:0.7.4": *
#import themes.university: *

#show: university-theme.with(aspect-ratio: "16-9")

= Section

== Title

Hello, Touying!
```

实际上，我们可以通过 `config-common` 函数的 `slide-level` 参数来控制这里的行为。`slide-level` 代表着嵌套结构的复杂度，从 0 开始计算。例如 `#show: university-theme.with(config-common(slide-level: 2))` 等价于 `section` 和 `subsection` 都会创建新 slide；而 `#show: university-theme.with(config-common(slide-level: 3))` 等价于 `section`，`subsection` 和 `subsubsection` 都会创建新 slide。


## 编号

为了给节与小节加入编号，我们只需要使用

```typst
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")
```

即可设置默认编号为 `1.1`，且 section 对应的编号为 `1.`。


## 目录

在 Touying 中显示目录很简单：

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: simple-theme.with(aspect-ratio: "16-9")

= Section

== Subsection

#components.adaptive-columns(outline(indent: 1em))
```

其中 `outline(indent: 1em)` 是 Typst 的原生目录函数。而 `#components.adaptive-columns()` 函数可以让目录尽可能只占据一个页面，即它会自适应分别设置 `#columns(1, body)` 或者 `#columns(2, body)`，以此类推。

如果你需要一个可以显示当前进度的 `outline` 函数，你可以考虑使用 `#components.progressive-outline()` 或 `#components.custom-progressive-outline()`，就像 dewdrop 主题那样。
或者通过操控 `outline.entry` 元素自行编写，对于某些特定效果，你可能需要用到 `#utils.section-relationship`。

## 特殊标题标签

Touying 识别标题上的特殊标签以控制幻灯片行为。它们分为两类：一类只改变标题自身的呈现方式，另一类按输出模式过滤内容。

### 标题本身的显示方式

这一类标签只影响标题自身，**不会**让幻灯片消失：带标签的标题下面的内容照常渲染，并且照常计入幻灯片计数器。

| 标签 | 效果 |
|------|------|
| `<touying:skip>` | 该标题不创建新的章节幻灯片；标题本身照常渲染、照常编号。 |
| `<touying:hidden>` | 与 `skip` 一样不创建章节幻灯片，并且额外对该标题设置 `numbering: none`、`outlined: false`、`bookmarked: false`，即不编号、不进入 `outline()`、不生成 PDF 书签。 |
| `<touying:unnumbered>` | 对该标题设置 `numbering: none`，即不参与标题编号。与幻灯片计数器无关。 |
| `<touying:unoutlined>` | 该标题从 `outline()` 中排除。 |
| `<touying:unbookmarked>` | 不为该标题生成 PDF 书签。 |

:::warning[警告]

`<touying:hidden>` 并不会抑制幻灯片。带该标签的标题不会生成章节幻灯片，但它下面的内容仍然是一张正常的幻灯片，仍然占据页码。同样地，`<touying:unnumbered>` 只影响标题编号，不会阻止幻灯片计数器递增。

:::

### 按输出模式过滤

另一类标签用于按输出模式过滤，命中时整段内容（标题下的幻灯片，或带标签的 `#slide[..]` 块）会被完全跳过：

| 标签 | 效果 |
|------|------|
| `<touying:presentation>` | 仅在演示模式（`handout: false`）下渲染。 |
| `<touying:handout>` | 仅在讲义模式（`handout: true`）下渲染。 |
| `<touying:slides>` | 仅在幻灯片输出中渲染，即 `<touying:presentation-handout>` 的简写。 |
| `<touying:article>` | 仅在 article 模式下渲染。 |

这些关键字可以用连字符组合，含义是「或」，例如 `<touying:handout-presentation>`（等价于 `<touying:slides>`）或 `<touying:presentation-article>`（演示模式和 article 模式下都渲染，讲义模式下跳过）。

标签既可以写在标题上，也可以写在整张幻灯片上：

```typst
== Only in the handout <touying:handout>

#slide[Only in the presentation] <touying:presentation>
```

:::note[注意]

模式过滤目前只在幻灯片输出中生效。在 article 模式下这些标签不会过滤任何内容，所有带标签的内容都会渲染。如果你需要在 article 模式下区分内容，请使用 `#article-only[..]`、`#slides-only[..]`、`#presentation-only[..]` 这些函数。

:::

示例——使用 `<touying:hidden>` 让目录页的标题不参与编号、不进入目录、不生成 PDF 书签（这张幻灯片本身仍会渲染）：

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: simple-theme.with(aspect-ratio: "16-9")

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= First Section

== Slide One

Content.
```

## 附录

`appendix` 函数会冻结**分母**，也就是 `utils.last-slide-number`（幻灯片总数），使附录幻灯片不影响页脚中显示的总数。幻灯片计数器 `utils.slide-counter` 仍然继续递增，因此附录中的页脚会显示形如 `4 / 2` 的编号。

如果你希望连幻灯片编号本身也不再递增，请改用 `config-common(freeze-slide-counter: true)`。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme

= Main Section

== Introduction

Main content here. Check the slide number in the footer.

#show: appendix

= Appendix

== Appendix Slide

The denominator is frozen at the last main-section slide; the slide number keeps advancing.
```
