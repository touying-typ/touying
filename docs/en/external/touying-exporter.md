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


### Reading inputs with `utils.get-input`

Everything passed through `--sys-inputs` (or `typst compile --input key=value`) arrives in
Typst as a string, and `sys.inputs.at(..)` hands you that string unchanged. Touying provides
`utils.get-input`, which parses each value as Typst first, and this is the supported way to
read command-line inputs in a Touying document — Touying reads its own command-line
overrides through exactly this function.

```typst
#import "@preview/touying:0.7.4": *

// a single value, or `none` when the key was not passed
#let accent = utils.get-input(key: "accent")

// or the whole dictionary, with every value parsed
#let inputs = utils.get-input()
```

Anything Typst knows is parsed as Typst:

| given on the command line | `utils.get-input(key: ..)` returns |
| --- | --- |
| `accent=red` | the colour `red` |
| `pos=left` | the alignment `left` |
| `size=2em`, `count=3` | the length `2em`, the integer `3` |
| `flag=true` | `true`; likewise `false`, `none` and `auto` |
| `config='(a: 1, b: (2, 3))'` | the dictionary |
| `mode=handout` | the string `"handout"` |

The last row is what makes this pleasant to use from a shell: a single bare word Typst does
not recognise — letters, digits, `_` and `-` — comes back verbatim as a string, so ordinary
values need no quoting. A key that was not passed yields `none`.

Two things to keep in mind:

- A bare word that *is* a Typst binding is parsed, not kept as text: `name=red` is a colour,
  not the string `"red"`. Write `name='"red"'` if you want the string.
- A value that is neither a bare word nor valid Typst code is a compile error, not a string:
  `title=My Presentation` fails on the space. Pass the quotes as part of the value,
  `title='"My Presentation"'`, or read `sys.inputs` directly for free-form text.

The same applies to `touying compile`, whose `--sys-inputs` JSON values are the raw text
Typst receives:

```sh
touying compile example.typ --sys-inputs '{"accent":"red","title":"\"My Presentation\""}'
```


## Use it as a python package

```python
import touying

touying.to_html("example.typ")
```
