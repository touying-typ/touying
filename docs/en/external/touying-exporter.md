---
sidebar_position: 1
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) is a command-line tool that exports Touying presentations to various formats. It is designed to be used with Touying presentations, but it can also be used with other Typst files. Export presentation slides in various formats for Touying.

## Touying Template

[Touying template](https://github.com/touying-typ/touying-template) for online presentation in github pages.

Demo: https://touying-typ.github.io/touying-template/

To use this template, follow these steps:

1. Click `Use this template` button to copy repo.
2. Click `Settings -> Pages -> Branch -> None -> gh-pages -> Save` to enable github pages.
3. Open link `your-name.github.io/repo-name` to start your presentation.

Disadvantages: Cannot select and copy text, if needed, please use [Gistd](https://github.com/Myriad-Dreamin/gistd).

## HTML Export

We generate SVG image files and package them with impress.js into an HTML file. This way, you can open and present it using a browser, and it supports GIF animations and speaker notes.

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/207ddffc-87c8-4976-9bf4-4c6c5e2573ea)

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/eac4976b-7d5d-40b6-8827-88c9a024b89a)

[Touying template](https://github.com/touying-typ/touying-template) for online presentation. [Online](https://touying-typ.github.io/touying-template/)

## PPTX Export

We generate PNG image files and package them into a PPTX file. This way, you can open and present it using PowerPoint, and it supports speaker notes.

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/3d547c74-fb4b-4c31-81e5-5138a5d727c9)

## Install

```sh
pip install touying
```


## CLI

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

For example:

```sh
touying compile example.typ
```

You will get a `example.html` file. Open it with your browser and start your presentation :-)

### Passing variables to typst

You can pass variables to your typst files using the `--sys-inputs` parameter:

```sh
touying compile example.typ --sys-inputs '{"title":"My Presentation","author":"John Doe"}'
```

In your typst file, you can access these variables like this:

```typst
#let title = sys.inputs.at("title", default: "Default Title")
#let author = sys.inputs.at("author", default: "Default Author")

= #title
By #author
```


## Use it as a python package

```python
import touying

touying.to_html("example.typ")
```
