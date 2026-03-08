---
sidebar_position: 4
---

# 全局设置与配置

Touying 使用一组 `config-*` 函数来配置演示文稿的各个方面。将它们传递给主题的 `#show:` 调用，Touying 会将它们合并到一个 `self` 状态对象中，该对象可供页眉、页脚、幻灯片函数和动画辅助函数使用。

## 配置概览

| 函数 | 控制内容 |
|------|---------|
| `config-info(…)` | 标题、作者、日期、机构、logo |
| `config-colors(…)` | 颜色方案 |
| `config-common(…)` | 全局功能标志（讲义模式、冻结计数器等） |
| `config-page(…)` | Typst 页面设置（边距、填充、纸张等） |
| `config-methods(…)` | 幻灯片函数和初始化钩子 |

所有配置函数可以在一个 `with(…)` 调用中组合：

```typst
#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [我的演讲], author: [Alice]),
  config-colors(primary: blue),
  config-common(handout: false),
)
```

或使用 `utils.merge-dicts` 合并：

```typst
#slide(
  config: utils.merge-dicts(
    config-colors(primary: red),
    config-page(fill: black),
  ),
)[内容]
```

## `config-info` — 文档元数据

```typst
config-info(
  title: [演示文稿标题],
  subtitle: [可选副标题],
  author: [作者姓名],
  date: datetime.today(),
  institution: [大学 / 公司],
  logo: image("logo.png"),   // 或 emoji.school，或任何内容
)
```

所有字段都是可选的。在幻灯片函数内通过 `self.info.title`、`self.info.author` 等访问。

`date` 字段接受：
- `datetime` 值 — 自动格式化。
- 任何 `content` — 直接显示。

更改日期显示格式：

```typst
config-common(datetime-format: "[year]-[month]-[day]")
// 或
config-common(datetime-format: "[year]年[month]月[day]日")
```

## `config-colors` — 颜色方案

每个主题都定义了默认颜色方案。你可以覆盖任何颜色：

```typst
config-colors(
  primary: rgb("#005bac"),
  secondary: rgb("#ff6b35"),
  neutral-lightest: white,
  neutral-darkest: black,
)
```

各主题使用的标准颜色槽：

| 槽位 | 典型用途 |
|------|---------|
| `primary` | 强调色、标题、进度条 |
| `secondary` | 次要强调色 |
| `tertiary` | 第三强调色 |
| `neutral-lightest` | 幻灯片背景 |
| `neutral-light` | 细微高亮 |
| `neutral-dark` | 柔和文字 |
| `neutral-darkest` | 主体文字 |

在幻灯片函数中通过 `self.colors.primary` 等访问当前颜色。

## `config-common` — 功能标志

`config-common` 是最常用的配置函数。以下是最有用的选项：

### 幻灯片级别

```typst
config-common(slide-level: 2)  // 大多数主题的默认值
```

控制标题深度到达多少级才创建新幻灯片。

### 讲义模式

```typst
config-common(handout: true)
```

只渲染每个动画幻灯片的最后一个子幻灯片。适合向观众分发幻灯片。

```typst
// 讲义模式显示第一个子幻灯片
config-common(handout: true, handout-subslides: 1)
```

### 冻结计数器

防止定理/公式计数器在子幻灯片之间重置：

```typst
config-common(frozen-counters: (theorem-counter,))
```

没有这个设置，如果在含定理的幻灯片上使用 `#pause`，定理编号可能在子幻灯片之间变化。

### 子幻灯片前言

自动为每个子幻灯片添加标题（对默认不添加的主题有用）：

```typst
config-common(
  subslide-preamble: self => text(
    1.2em,
    weight: "bold",
    utils.display-current-heading(depth: self.slide-level),
  ),
)
```

### 列表和枚举格式

```typst
// 强制非紧凑间距（等同于 tight: false）
config-common(nontight-list-enum-and-terms: true)

// 缩放列表项文字
config-common(scale-list-items: 0.85)

// 被 #pause 遮盖时显示/隐藏列表标记
config-common(show-hide-set-list-marker-none: true)
```

### 参考文献作为脚注

```typst
config-common(
  bibliography-as-footnote: bibliography(title: none, "refs.bib"),
)
```

这将所有参考文献条目移至每张幻灯片的脚注式引用。

### 演讲者备注显示

```typst
// 在第二块屏幕（右侧）显示备注
config-common(show-notes-on-second-screen: right)

// 全屏备注模式，带幻灯片缩略图
config-common(show-only-notes: true)
```

### 前言

在每张幻灯片前运行任意 Typst 代码——用于初始化 Codly 等包：

```typst
config-common(preamble: {
  // 在每张幻灯片前调用
  codly(zebra-fill: none)
})
```

## `config-page` — 页面参数

包装 Typst 的 `set page(…)` 设置：

```typst
config-page(
  paper: "presentation-16-9",   // 或 "presentation-4-3"
  margin: (x: 4em, y: 2em),
  fill: rgb("#ffffff"),
  header: align(top)[自定义页眉],
  footer: align(bottom)[自定义页脚],
  header-ascent: 0em,
  footer-descent: 0em,
)
```

## `config-methods` — 幻灯片钩子

覆盖主题引擎使用的函数：

```typst
config-methods(
  // 更改动画期间内容的遮盖方式
  cover: utils.semi-transparent-cover.with(alpha: 85%),

  // 自定义强调（粗体 + 主色）
  alert: utils.alert-with-primary-color,

  // 在第一张幻灯片前运行代码
  init: (self: none, body) => {
    set text(font: "Fira Sans", size: 20pt)
    body
  },
)
```

## 全局样式

在主题 `#show:` 调用前后的任何位置设置 Typst `set` 和 `show` 规则：

```typst
#show: my-theme.with(…)

// 这些应用于所有幻灯片
#set text(font: "Libertinus Serif")
#set par(justify: true)
#show strong: set text(fill: red)
```

也可以将它们放在 `config-methods(init: …)` 内以访问 `self`：

```typst
config-methods(
  init: (self: none, body) => {
    set text(fill: self.colors.neutral-darkest)
    show heading: set text(fill: self.colors.primary)
    body
  },
)
```

## 单张幻灯片配置覆盖

每个 `#slide` 函数都接受 `config:` 参数，仅为该幻灯片覆盖全局设置：

```typst
#slide(
  config: utils.merge-dicts(
    config-colors(primary: orange),
    config-page(fill: luma(95%)),
  ),
)[
  这张幻灯片有橙色强调和灰色背景。
]
```
