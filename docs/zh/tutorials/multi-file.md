---
sidebar_position: 6
---

# 多文件架构

对于小型演示文稿，单个 `.typ` 文件完全够用。对于更长的演讲——课程讲义、系列课程或会议论文——Touying 简洁的语法和增量编译使多文件布局变得既实用又有吸引力。

## 三文件模式

最常见的多文件布局将关注点分离到三个文件：

```
globals.typ   ← 导入、自定义辅助函数、主题注册
main.typ      ← show 规则、文档元数据、#include 内容
content.typ   ← 实际幻灯片内容
```

### `globals.typ`

存放 `main.typ` 和 `content.typ` 都需要的内容，不会造成循环导入：

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly

// 自定义辅助函数
#let emph-box(body) = box(
  stroke: 1pt + blue,
  inset: 0.5em,
  radius: 0.25em,
  body,
)
```

### `main.typ`

入口点。应用 show 规则并包含内容：

```typst
// main.typ
#import "/globals.typ": *

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [我的课程],
    subtitle: [第一讲],
    author: [张教授],
    date: datetime.today(),
    institution: [某某大学],
    logo: emoji.school,
  ),
)

#include "content.typ"
```

### `content.typ`

纯内容——无主题样板：

```typst
// content.typ
#import "/globals.typ": *

#title-slide()

= 简介

== 动机

#lorem(40)

#emph-box[这是一个重要注意事项。]

#focus-slide[
  核心思想
]
```

## 多章节文件

对于有多个章节的课程，将内容拆分为每节一个文件：

```
main.typ
globals.typ
sections/
  intro.typ
  methods.typ
  results.typ
  conclusion.typ
```

`main.typ` 按顺序包含它们：

```typst
// main.typ
#import "/globals.typ": *

#show: university-theme.with(…)

#include "sections/intro.typ"
#include "sections/methods.typ"
#include "sections/results.typ"
#include "sections/conclusion.typ"
```

## 共享配置

如果多个入口文件需要相同的设置（如演示文件和讲义文件），将配置放在 `globals.typ` 中并导入：

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *

#let base-config = (
  aspect-ratio: "16-9",
  config-info(title: [我的演讲], author: [Alice]),
)
```

```typst
// handout.typ
#import "/globals.typ": *

#show: university-theme.with(..base-config, config-common(handout: true))
#include "content.typ"
```

## 绝对导入路径

在深层嵌套文件中使用 `#import` 或 `#include` 时，使用以项目根目录为锚点的绝对路径以避免路径解析问题：

```typst
// 在任何文件深度都有效
#import "/globals.typ": *
```

Typst CLI 和 Tinymist 都将 `/` 解析为 `--root` 目录。使用以下方式设置根目录：

```sh
typst compile --root . main.typ
```

## 大型幻灯片集的建议

- 保持 `globals.typ` 精简——它被每个文件导入，每次重新编译时都会被解析。
- 避免在共享辅助函数中使用 `counter` 和复杂的 `context` 计算；Touying 的动画引擎已经高效管理子幻灯片计数器。
- 在章节开头或结尾想要可选分页时，使用 `#pagebreak(weak: true)` 代替硬分页。
