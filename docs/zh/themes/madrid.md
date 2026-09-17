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

- `#title-slide()`：标题页，在圆角蓝色框中展示标题，下方展示作者、机构与日期。
- `#outline-slide()`：大纲/目录页。
- `#slide(...)`：普通内容页。
- `#new-section-slide(...)`：章节分页。
- `#focus-slide[...]`：聚焦页。
