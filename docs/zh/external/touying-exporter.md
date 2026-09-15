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

### 用 `utils.get-input` 读取输入

任何通过 `--sys-inputs`（或者 `typst compile --input key=value`）传入的值，到了 Typst
这一侧都是字符串，`sys.inputs.at(..)` 拿到的也是原样未加工的字符串。Touying 提供了
`utils.get-input`，它会先把每个值当作 Typst 来解析——这是在 Touying 文档中读取命令行输入的推荐方式，
Touying 自己读取命令行覆盖项时用的正是这个函数。

```typst
#import "@preview/touying:0.7.4": *

// 单个值；如果没有传入该 key，则为 `none`
#let accent = utils.get-input(key: "accent")

// 或者拿到整个字典，其中每个值都已被解析
#let inputs = utils.get-input()
```

只要是 Typst 认识的东西，都会被解析成对应的值：

| 命令行传入的内容 | `utils.get-input(key: ..)` 返回的结果 |
| --- | --- |
| `accent=red` | 颜色 `red` |
| `pos=left` | alignment `left` |
| `size=2em`、`count=3` | 长度 `2em`、整数 `3` |
| `flag=true` | `true`；同理还有 `false`、`none` 和 `auto` |
| `config='(a: 1, b: (2, 3))'` | 该字典 |
| `mode=handout` | 字符串 `"handout"` |

最后一行正是这个函数用起来顺手的地方：一个 Typst 不认识的裸词——字母、数字、`_` 和 `-`——会原样以字符串形式返回，因此普通的值不需要加引号。没有传入的 key 会得到 `none`。

有两点需要留意：

- 一个裸词如果*恰好*是某个 Typst 绑定，就会被解析掉，而不是保留为文本：`name=red` 会得到颜色，而不是字符串 `"red"`。如果想要字符串，请写成 `name='"red"'`。
- 一个既不是裸词、也不是合法 Typst 代码的值，会导致编译错误，而不是变成字符串：`title=My Presentation` 会因为其中的空格而失败。请把引号本身也作为值的一部分传入，即 `title='"My Presentation"'`，或者直接读取 `sys.inputs` 来处理自由格式的文本。

这同样适用于 `touying compile`，它的 `--sys-inputs` JSON 值就是 Typst 收到的原始文本：

```sh
touying compile example.typ --sys-inputs '{"accent":"red","title":"\"My Presentation\""}'
```

## 作为 Python 包使用

```python
import touying

touying.to_html("example.typ")
```
