---
sidebar_position: 2
---
# 章节工具函数
Touying 会在每张幻灯片中注入不可见的标题，以便你随时可以通过 Typst 的 `query()` 函数查询当前章节信息。
## 显示当前标题
`utils.display-current-heading(level: N)` 返回指定级别最近一个标题的文本内容。大多数主题用它来填充页眉：
```typst
// 在页眉中显示当前章节（第 1 级）
utils.display-current-heading(level: 1)
// 显示当前小节（第 2 级）
utils.display-current-heading(level: 2)
```
`utils.display-current-short-heading(level: N)` 是去除编号的简短变体：
```typst
utils.display-current-short-heading(level: 2)
```
## 在自定义页眉中显示章节名称
你可以在自定义页眉中使用这些工具函数：
```example
#import "@preview/touying:0.7.0": *
#import themes.default: *
#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    header: [
      #text(gray, utils.display-current-heading(level: 2))
      #h(1fr)
      #context utils.slide-counter.display()
    ],
  ),
)
= My Section
== First Slide
Header shows "First Slide" on the right side.
== Second Slide
Header updates automatically.
```
## 渐进式目录

Touying 提供了若干渐进式目录工具函数，以下是最常用的几种。

### 渐进式目录（默认）

[`components.progressive-outline()`](https://touying-typ.github.io/docs/reference/components/progressive-outline) 渲染一个高亮当前章节、灰显其他章节的目录——这是主题演示文稿中的常见模式：
```example
#import "@preview/touying:0.7.0": *
#import themes.dewdrop: *
#show: dewdrop-theme.with(aspect-ratio: "16-9")
= Introduction
== Overview <touying:hidden>
#components.progressive-outline()
= Background
== Slide
Content.
```
[`components.adaptive-columns(outline(...))`](https://touying-typ.github.io/docs/reference/components/adaptive-columns) 是另一种变体，它将标准 [`outline()`](https://typst.app/docs/reference/model/outline/) 包裹在适当数量的列中，使其恰好占满一页。

### 自定义渐进式目录

[`components.custom-progressive-outline()`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline) 允许你为渐进式目录指定各种样式规则，灵活性更强，但需要自行配置所有参数。

```example
#import "@preview/touying:0.7.0": *
#import themes.dewdrop: *
#show: dewdrop-theme.with(aspect-ratio: "16-9")
= Introduction
== Overview <touying:hidden>
#components.custom-progressive-outline(
  level: 1,
  show-past: (true, false),
  show-future: (true, false),
  show-current: (true, true, false),
  vspace: (.5em, .0em),
  numbering: ("1.1",),
  numbered: (true,true),
  title: none,
)
= Background
== Slide
Content.
```

注意，这里需要自行指定所有参数，没有现成的默认样式。部分参数会自动重复，而另一些则不会。如果你不喜欢这种方式，也可以直接通过 `set` 规则修改目录条目。为此，我们提供了一个辅助函数来获取当前章节的上下文信息。

### 章节关系辅助函数

工具函数 [`utils.section-relationship()`](https://touying-typ.github.io/docs/reference/utils/section-relationship) 用于获取当前所在章节与给定目录条目之间的关系，返回值为 (-2, -1, 0, 1, 2) 中的一个整数。

负数表示文档中较早声明的标题，正数表示较晚声明的标题。只有当前标题**及其子标题**的关系值为 `0`。

-1 和 1 保留给与当前章节同属同一顶级标题下的其他标题。结合 `outline.entry.level` 提供的实际层级信息，这些应足以构建任意你想要的目录样式。

示例用法如下：
```example
>>>#import "@preview/touying:0.7.1": *
>>>#import themes.simple: *
>>>#show: simple-theme
>>>#set heading(numbering: "1.1")

= Start
== Start Sub
#lorem(5)
= My content
== My heading
#lorem(5)
---
#{// 正常显示所有顶级标题及当前顶级标题下的所有层级，
  // 未来的同级标题和其他顶级标题显示为半透明，
  // 当前条目加粗，其余条目显示为红色。

  show outline.entry: it => {
    let relationship = utils.section-relationship(it)
    let current = utils.current-heading()
    let alpha = if relationship == -2 or relationship > 0 { 40% } else { 100% }
    let weight = if relationship == 0 and current.level == it.level {
      "bold"
    } else { "regular" }
    if it.level > 1 and calc.abs(relationship) > 1 {
      text(fill: red, it) //通常这里填 `none`。
    } else {
      text(fill: utils.update-alpha(text.fill, alpha), weight: weight, it)
    }
  }
  outline(title: none)
}
---
=== Subsubheading
#lorem(3)

== Another heading
#lorem(5)

= Next Top Level

== Subsection
#lorem(5)
```