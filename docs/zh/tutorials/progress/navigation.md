---
sidebar_position: 2
---

# 导航元素

在较为复杂的幻灯片主题中，加入导航元素是很常见的做法。例如可以参考 [dewdrop 主题](https://touying-typ.github.io/docs/themes/dewdrop)。

## 左右导航

[`lr-navigation`](https://touying-typ.github.io/docs/reference/core/lr-navigation) 可创建可点击的上一页与下一页控件，支持按幻灯片、子幻灯片（物理页面）或两者同时导航。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#show: simple-theme.with(
  footer: self=>[
    #align(center,
      lr-navigation(
        self: self,
        mode: "both",
        show-useless: false,
        nav: (
          filled: sym.triangle.filled,
          stroked: sym.chevron,
        ),
      )
    )
  ],
)
= Navigation Demo
== Slide A
This slide has a pause.
#pause
This appears on the next subslide.
== Slide B
Now the page-level links can jump between full slides.
```

## 迷你幻灯片导航

[`components.mini-slides`](https://touying-typ.github.io/docs/reference/components/mini-slides) 以小圆点的形式显示章节和小节链接，每张幻灯片对应一个圆点。

这种模式非常适合放在页眉中，在不使用完整侧边栏或进度条的情况下提供简洁的进度反馈。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#show: simple-theme.with(
    config-page(
        margin: (top: 4em, bottom: 2em, x: 2em),
        header-ascent: 2em,
    ),
    header: self => components.mini-slides(
        self: self,
        fill: self.colors.primary,
        display-section: true,
        display-subsection: true,
        linebreaks: true,
        short-heading: true,
    ),
)
= Introduction
== Motivation
The mini-slides row updates as you move.
== Scope
Another subsection.
= Methods
== Setup
Current section is highlighted.
```

## 侧边栏导航

Touying 没有提供单独的 `sidebar-navigation` 函数。实际上，侧边栏是通过 [`components.custom-progressive-outline`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline) 构建的，dewdrop 主题正是采用了这种方式。

使用此风格最快捷的方法是启用 dewdrop 内置的侧边栏导航并调整其选项：

```example
#import "@preview/touying:0.7.4": *
#import themes.dewdrop: *
#show: dewdrop-theme.with(
    aspect-ratio: "16-9",
    navigation: "sidebar",
    sidebar: (
        width: 11em,
        filled: false,
        numbered: true,
        indent: .8em,
        short-heading: true,
    ),
)
#outline-slide()
= Part I <touying:skip>
== Problem
Sidebar highlights where you are in the outline.
== Constraints
Indented subsection entries.
= Part II
== Solution
The active section and subsection are emphasized automatically.
```

如果你想自行实现这种方式，可以参考 dewdrop 主题的具体实现。
