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
#import "@preview/touying:0.6.2": *
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

`components.progressive-outline()` 渲染一个高亮当前章节、灰显其他章节的目录——这是主题演示文稿中的常见模式：

```example
#import "@preview/touying:0.6.2": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Introduction

== Overview <touying:hidden>

#components.progressive-outline()

= Background

== Slide

Content.
```

`components.adaptive-columns(outline(...))` 是另一种变体，它将标准 `outline()` 包裹在适当数量的列中，使其恰好占满一页。