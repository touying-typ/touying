---
sidebar_position: 8
---

# Madrid 主题

Madrid 主题为 Touying 重现了经典的 LaTeX Beamer Madrid 主题风格，包含 3D 球形列表标记（Beamer balls）、圆角彩色块，以及由作者、标题、日期和页码组成的三段式页脚栏。

## 初始化

你可以通过以下代码初始化：

```typst
#import "@preview/touying:0.8.0": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()
```

## 块样式 (Blocks)

Madrid 主题提供了 Beamer 风格的圆角块：

- `#cblock(title: [Title])[Body]`（亦可使用 `#tblock`）：经典蓝色的标准块。
- `#alert-block(title: [Title])[Body]`：醒目红色的 Alert 警告块。
- `#example-block(title: [Title])[Body]`：柔和绿色的 Example 示例块。

## 幻灯片函数族

- `#title-slide(numbered: true, ..args)`：标题页，在圆角蓝色框中展示标题，下方展示作者、机构与日期。默认计入总页数；设置 `numbered: false` 可排除该页。可用 `date:` 等命名参数覆盖本页元数据。
- `#outline-slide(numbered: true, depth: 1, ..args)`：大纲/目录页。默认仅显示章节；设置 `depth: 2` 可包含幻灯片标题。
- `#slide(...)`：普通内容页。
- `#new-section-slide(config: (:), level: 1, numbered: true, alpha: 80%, title: auto, body)`：显示渐进式目录的章节页，高亮当前章节并淡化其他章节。一级标题（`= 章节`）会自动生成此页，`alpha` 控制其他章节的淡化程度。`title: auto` 使用主题的 `section-outline-title`。
- `#focus-slide[...]`：聚焦页。

## 外观选项

- `align`：正文默认使用 `horizon + left`，垂直居中时下方留白略大，接近 Beamer。可设置 `top + left` 改为顶端对齐。
- `font-size`：默认 `24pt`。标题栏高度 `header-height` 默认为 `2.5em`。
- `sans-math`：默认 `true`，使用接近 Beamer 的无衬线数学字母。设置 `false` 可保留 Typst 的默认数学变体。
- `font`：正文字体，默认 `auto`，继承文档字体。
- `title-font`、`small-font`：分别控制标题和页脚/机构字体，默认继承正文字体。安装 Latin Modern 后，可分别使用 `"Latin Modern Sans"`、`"Latin Modern Sans 12"` 和 `"Latin Modern Sans 8"` 接近 Beamer 的字形。必要时通过 Typst CLI 的 `--font-path` 指定字体目录。
- `logo`：右下角标志，默认读取 `info.logo`。设置 `none` 可隐藏。建议使用相对字号的高度，例如 `config-info(logo: image("logo.svg", height: 2.6em))`。
- `block-shadow`、`title-shadow`：分别控制内容块和标题面板阴影，默认均为 `true`。
- `section-outline-title`：自动生成的章节目录页标题，默认使用本地化目录标题。
- `navigation-symbols`：默认 `true`。关闭后隐藏整行导航符号。导航可跳转到页面、逻辑帧、章节和文档首尾；最后的历史后退/搜索/前进图标仅用于外观，Typst 无法生成这些 PDF 阅读器操作。

普通目录和渐进式目录共用带编号球形标记和蓝色链接文字的布局，没有点引导线或页码。`numbered: false` 将编号球替换为普通球形标记。

`primary-light`、`alert-light`、`example-light` 默认 `auto`，在初始化时从对应主题色派生内容块背景色；块标题使用深色变体。`#alert[...]` 使用警告色（默认红色 `#ff0000`）。单页使用 `config-colors(...)` 覆盖配色时，应同时指定基础色和浅色。
