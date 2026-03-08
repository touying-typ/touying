---
sidebar_position: 1
---

# 快速上手

## 什么是 Touying？

[Touying](https://github.com/touying-typ/touying) 是为 [Typst](https://typst.app/) 开发的功能强大的演示文稿包，灵感来自 LaTeX Beamer。它让你能够使用简洁的纯文本语法编写幻灯片——无需拖放操作。使用 Touying 你可以获得：

- **快速编译** — 增量渲染将反馈时间保持在毫秒级，而非秒级。
- **内容/样式分离** — 使用 Typst 标记编写内容，主题负责外观。
- **丰富的动画** — `#pause`、`#meanwhile`、`#uncover`、`#only` 等功能。
- **内置主题** — 六个精心设计的主题开箱即用。
- **可扩展性** — 无缝集成 CeTZ、Fletcher、Codly、Pinit 等其他 Typst 包。

> **术语说明：** 本文档中 *slides* 指幻灯片集，*slide* 指单张幻灯片，*subslide* 指动画幻灯片中的一个步骤。

## 配置你的环境

你可以在浏览器中或本地编写 Touying 演示文稿。

### 方式一 — Typst Web App（无需安装）

访问 [typst.app](https://typst.app/)，创建一个新项目，开始输入即可。Touying 可直接从 Typst Universe 包注册表获取——无需安装。

### 方式二 — VS Code + Tinymist（推荐本地使用）

1. 安装 [VS Code](https://code.visualstudio.com/)。
2. 从 VS Code 应用市场安装 [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) 扩展。
3. 打开或创建 `.typ` 文件。Tinymist 为 Touying 函数提供实时预览、自动补全和悬停文档。

### 方式三 — Typst CLI

安装 [Typst CLI](https://github.com/typst/typst/releases) 并从命令行编译：

```sh
typst compile slides.typ
```

使用 `typst watch slides.typ` 可在保存时自动重新编译。

## 你的第一个演示文稿

在新的 `.typ` 文件中添加以下内容：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= 我的第一个演讲

== 介绍

你好，Touying！

#pause

你好，Typst！
```

就这样——你刚刚创建了一个带有动画展示效果的两页幻灯片！🎉

**发生了什么？**

| 行 | 作用 |
|------|-------------|
| `#import "@preview/touying:0.6.2": *` | 导入 Touying 包 |
| `#import themes.simple: *` | 导入 Simple 主题 |
| `#show: simple-theme.with(...)` | 激活主题及其默认设置 |
| `= 我的第一个演讲` | 创建章节幻灯片（一级标题） |
| `== 介绍` | 创建内容幻灯片（二级标题） |
| `#pause` | 将内容分成两个子幻灯片（动画展示） |

## 更完整的示例

下面是一个使用 University 主题的更丰富的演示文稿，展示了动画、多列布局、CeTZ 图表和定理：

```example
#import "@preview/touying:0.6.2": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

// 将 CeTZ 和 Fletcher 绑定到 Touying 的动画引擎
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: [我的演讲],
    subtitle: [副标题],
    author: [作者],
    date: datetime.today(),
    institution: [大学],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== 目录 <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= 动画

== 暂停与同步

使用 `#pause` 逐步展示内容。

#pause

这出现在第二个子幻灯片。

#meanwhile

使用 `#meanwhile` 使这一列重新开始。

#pause

这与上面的内容同步出现。

= 定理

== 欧几里得定理

#theorem(title: "欧几里得")[
  素数有无穷多个。
]

#pause

#proof[
  假设只有有限个素数 $p_1, dots, p_n$。则 $p_1 dots p_n + 1$ 有一个不在列表中的素因子——矛盾。
]

= 布局

== 两列布局

#slide(composer: (1fr, 1fr))[
  左列内容。

  - 要点 A
  - 要点 B
][
  右列内容。

  - 要点 C
  - 要点 D
]
```

## 选择主题

Touying 提供六个内置主题：

| 主题 | 风格 |
|-------|-------|
| `simple` | 简洁、极简 |
| `metropolis` | 受流行的 Beamer Metropolis 主题启发 |
| `dewdrop` | 导航栏风格 |
| `university` | 学术风格，支持机构品牌 |
| `aqua` | 明亮现代 |
| `stargazer` | 深色/彩色学术风格 |

每个主题的导入和激活方式相同：

```typst
#import "@preview/touying:0.6.2": *
#import themes.metropolis: *   // ← 在这里更改主题名称

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [我的演讲], author: [我]),
)

#title-slide()
```

详细文档请参阅[主题](./themes/)部分。

## 下一步

继续阅读**[教程](./tutorials/)**，学习：

- 如何使用标题、章节和幻灯片结构
- 如何使用 `#pause`、`#uncover`、`#only` 等创建动画
- 如何配置字体、颜色和全局设置
- 如何使用演讲者备注和讲义模式
- 如何集成第三方包
- 如何构建自定义主题
