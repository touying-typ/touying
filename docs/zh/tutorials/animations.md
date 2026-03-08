---
sidebar_position: 2
---

# 动画

Touying 的动画系统从单个幻灯片定义创建多个*子幻灯片*。每个子幻灯片是一个单独的 PDF 页面，PDF 查看器或演示工具通过翻页来模拟动画效果。

## `#pause` — 逐步展示

`#pause` 是最简单的动画工具。`#pause` 标记之后的所有内容在前面的子幻灯片上隐藏，在下一个子幻灯片上显示：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  步骤一。

  #pause

  步骤二。

  #pause

  步骤三。
]
```

`#pause` 也可以内联使用：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  我知道 #pause 答案 #pause 是 42。
]
```

### 列表中的 `#pause`

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  - 第一项
  #pause
  - 第二项
  #pause
  - 第三项
]
```

### 数学公式中的 `#pause`

在 `$…$` 数学表达式内使用 `pause`（无 `#`）：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  $
    f(x) &= pause x^2 + 2x + 1 \
         &= pause (x + 1)^2
  $
]
```

## `#meanwhile` — 并行轨道

`#meanwhile` 重置子幻灯片计数器，用于应与幻灯片其他位置的 `#pause` 序列同步出现的内容。可以理解为两列同步动画：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  左：A

  #pause

  左：B

  #meanwhile

  右：1

  #pause

  右：2
]
```

子幻灯片 1 同时显示"左：A / 右：1"，子幻灯片 2 同时显示"左：B / 右：2"。

## `#uncover` — 保留空间

`#uncover(子幻灯片, 内容)` 仅在指定子幻灯片上显示内容。在其他子幻灯片上内容被*遮盖*（不可见但仍占用空间）：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  始终可见。

  #uncover("2-")[从第 2 个子幻灯片起可见。]

  #uncover("2-3")[第 2 和 3 个子幻灯片可见。]

  #uncover(2)[仅在第 2 个子幻灯片可见。]
]
```

**子幻灯片选择器语法：**

| 选择器 | 含义 |
|--------|------|
| `1` | 仅第 1 个子幻灯片 |
| `"2-"` | 第 2 个及之后 |
| `"2-4"` | 第 2 到 4 个 |
| `"1,3"` | 第 1 和第 3 个 |

## `#only` — 不保留空间

`#only(子幻灯片, 内容)` 仅在指定子幻灯片上显示内容，但在其他子幻灯片上**不**保留空间——内容从布局中物理消失：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  始终在这里。

  #only("2-")[第 1 个子幻灯片上不占用空间。]
]
```

## `#alternatives` — 交替内容

`#alternatives[…][…][…]` 在每个子幻灯片上显示不同的内容块，自动适应最宽/最高的变体：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (alternatives,) = utils.methods(self)

  答案是 #alternatives[也许][可能][肯定]正确的。
])
```

其他参数：`start: 2`（从第 2 个子幻灯片开始）、`repeat-last: true`（重复最后一项）、`position: center + horizon`（对齐方式）。

## 回调风格 — 完全控制

标记风格函数（`#uncover`、`#only`、`#alternatives`）有一个限制：它们不能嵌套在某些 Typst 布局上下文中。**回调风格**在任何地方都有效。

将函数 `self => …` 作为幻灯片内容传入，然后从 `self` 中提取方法：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  第 #self.subslide 个子幻灯片，共 3 个。

  #uncover("2-")[从第 2 张开始展示。]

  #only(3)[仅在第 3 张显示。]

  获胜者是 #alternatives[Alice][Bob][Carol]。
])
```

:::info

使用回调风格时必须手动设置 `repeat: N`，因为 Touying 无法自动推断需要多少个子幻灯片。

:::

## 遮盖函数

当 `#pause` 或 `#uncover` 隐藏内容时，它使用*遮盖函数*来实现。默认是 Typst 内置的 `hide`，它保留布局空间。你可以更改它：

```typst
// 使用半透明叠加层代替
config-methods(cover: utils.semi-transparent-cover.with(alpha: 85%))
```

```typst
// 隐藏列表/枚举标记的有效变通方案
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```

## `#effect` — 在范围内应用样式

`#effect` 在指定子幻灯片上对内容应用 Typst 函数：

```typst
#effect(text.with(fill: red), "2-")[从第 2 个子幻灯片起文字变红。]
```

## `#item-by-item` — 逐项动画

`#item-by-item` 逐步展示列表或枚举项：

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #item-by-item[
    - 第一项
    - 第二项
    - 第三项
  ]
]
```

## 讲义模式

讲义模式只渲染每个动画幻灯片的*最后一个*子幻灯片，生成适合分发的每个逻辑幻灯片一页的文档：

```typst
#show: my-theme.with(
  config-common(handout: true),
)
```

你也可以控制讲义模式中显示哪个子幻灯片：

```typst
// 显示第一个子幻灯片而不是最后一个
config-common(handout-subslides: 1)

// 显示第 1 和第 3 个子幻灯片
config-common(handout-subslides: (1, 3))
```

## `touying-recall` — 重用幻灯片

在文档任意位置重播之前定义的幻灯片：

```typst
== 原始幻灯片 <my-slide>

一些带有 #pause 动画的内容。

// 稍后…
== 回顾

#touying-recall(<my-slide>)
```
