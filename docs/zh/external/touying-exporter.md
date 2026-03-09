---
sidebar_position: 1
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) 是一个命令行工具，用于将 Touying 演示文稿导出为各种格式。它是专为 Touying 演示文稿设计的，但也可以用于其他 Typst 文件。用于 Touying 的导出演示文稿幻灯片工具。

## Touying 模板

[Touying 模板](https://github.com/touying-typ/touying-template) 用于在 GitHub Pages 上进行在线演示。

演示：https://touying-typ.github.io/touying-template/

使用此模板，请按照以下步骤操作：

1. 点击 `Use this template` 按钮复制仓库。
2. 点击 `Settings -> Pages -> Branch -> None -> gh-pages -> Save` 启用 GitHub Pages。
3. 打开链接 `your-name.github.io/repo-name` 开始你的演示。

缺点：无法选中复制文本，如果有对应需要，请使用 [Gistd](https://github.com/Myriad-Dreamin/gistd)。

## HTML 导出

我们生成 SVG 图像文件，并将其与 impress.js 打包成一个 HTML 文件。这样，你可以使用浏览器打开并进行演示，支持 GIF 动画和演讲者备注。

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/207ddffc-87c8-4976-9bf4-4c6c5e2573ea)

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/eac4976b-7d5d-40b6-8827-88c9a024b89a)

[Touying 模板](https://github.com/touying-typ/touying-template) 用于在线演示。[在线查看](https://touying-typ.github.io/touying-template/)

## PPTX 导出

我们生成 PNG 图像文件，并将其打包成 PPTX 文件。这样，你可以使用 PowerPoint 打开并进行演示，支持演讲者备注。

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/3d547c74-fb4b-4c31-81e5-5138a5d727c9)

## 安装

```sh
pip install touying
```

## 命令行工具

```text
usage: touying compile [-h] [--output OUTPUT] [--root ROOT] [--font-paths [FONT_PATHS ...]] [--start-page START_PAGE] [--count COUNT] [--ppi PPI] [--silent SILENT] [--format {html,pptx,pdf,pdfpc}] [--sys-inputs SYS_INPUTS] input

positional arguments:
  input                 Input file

options:
  -h, --help            show this help message and exit
  --output OUTPUT       Output file
  --root ROOT           Root directory for typst file
  --font-paths [FONT_PATHS ...]
                        Paths to custom fonts
  --start-page START_PAGE
                        Page to start from
  --count COUNT         Number of pages to convert
  --ppi PPI             Pixels per inch for PPTX format
  --silent SILENT       Run silently
  --format {html,pptx,pdf,pdfpc}
                        Output format
  --sys-inputs SYS_INPUTS
                        JSON string to pass to typst's sys.inputs
```

例如：

```sh
touying compile example.typ
```

你将得到一个 `example.html` 文件。用你的浏览器打开它，开始你的演示吧 :-)

### 传递变量给 Typst

你可以使用 `--sys-inputs` 参数将变量传递给你的 Typst 文件：

```sh
touying compile example.typ --sys-inputs '{"title":"My Presentation","author":"John Doe"}'
```

在你的 Typst 文件中，你可以这样访问这些变量：

```typst
#let title = sys.inputs.at("title", default: "Default Title")
#let author = sys.inputs.at("author", default: "Default Author")

= #title
By #author
```

## 作为 Python 包使用

```python
import touying

touying.to_html("example.typ")
```
