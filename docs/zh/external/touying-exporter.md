---
sidebar_position: 4
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) 是 Touying 的配套命令行工具，可将演示文稿导出为 PDF 以外的其他格式。它封装了 `typst compile` 并对输出进行后处理，适用于以下场景：

- **PPTX** — Microsoft PowerPoint 格式。
- **HTML** — 带有 CSS 过渡的交互式 HTML 幻灯片。
- **PNG/SVG 每张幻灯片** — 单独的图像文件，每个子幻灯片一个。

## 安装

```sh
# 使用 cargo（Rust 包管理器）
cargo install touying-exporter

# 或从发布页面下载预构建的二进制文件
# https://github.com/touying-typ/touying-exporter/releases
```

## 基本用法

### 导出为 PNG

将每张幻灯片（子幻灯片）导出为单独的 PNG 文件：

```sh
touying-exporter png my-slides.typ
```

输出文件命名为 `my-slides-001.png`、`my-slides-002.png` 等。

### 导出为 SVG

```sh
touying-exporter svg my-slides.typ
```

### 导出为 PPTX

```sh
touying-exporter pptx my-slides.typ
```

### 导出为 HTML

```sh
touying-exporter html my-slides.typ
```

## 选项

| 标志 | 说明 |
|------|------|
| `--root <path>` | Typst 根目录（默认：当前目录） |
| `--output <path>` | 输出文件或目录 |
| `--ppi <n>` | PNG/SVG 导出的每英寸像素数（默认：144） |
| `--input <key=value>` | 透传的 Typst `--input` 参数 |

## 处理多文件项目

对于多文件项目，指定根目录：

```sh
touying-exporter png --root . main.typ --output ./output/
```

## 生成用于网页画廊的每张幻灯片图像

常见用例是为网站或 README 生成幻灯片画廊：

```sh
# 以高分辨率导出所有幻灯片为 PNG
touying-exporter png --ppi 200 slides.typ --output ./gallery/
```

## 提示

- 导出器遵循 Touying 的幻灯片计数器，因此仅限讲义的幻灯片和附录幻灯片均能正确处理。
- 对于 PDF 导出，直接使用 `typst compile` 即可——导出器在原生 PDF 输出上没有额外价值。
- 在将单张幻灯片嵌入其他文档或网页时，SVG 导出非常有用。
