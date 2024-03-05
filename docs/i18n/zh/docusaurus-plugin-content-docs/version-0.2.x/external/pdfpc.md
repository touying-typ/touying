---
sidebar_position: 1
---

# pdfpc

[pdfpc](https://pdfpc.github.io/) 是一个 "对 PDF 文档具有多显示器支持的演示者控制台"。这意味着，您可以使用它以 PDF 页面的形式显示幻灯片，并且还具有一些已知的出色功能，就像 PowerPoint 一样。

pdfpc 有一个 JSON 格式的 `.pdfpc` 文件，它可以为 PDF slides 提供更多的信息。虽然您可以手动编写此它，但你也可以通过 Touying 来管理。


## 加入 Metadata

Touying 与 [Polylux](https://polylux.dev/book/external/pdfpc.html) 保持一致，以避免 API 之间的冲突。

例如，你可以通过 `#pdfpc.speaker-note("This is a note that only the speaker will see.")` 加入 notes。


## pdfpc 配置

为了加入 pdfpc 配置，你可以使用

```typst
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
))
```

加入对应的配置，具体配置方法可以参考 [Polylux](https://polylux.dev/book/external/pdfpc.html)。


## 输出 .pdfpc 文件

假设你的文档为 `./example.typ`，则你可以通过

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

直接导出 `.pdfpc` 文件。

借助 Touying 与 Polylux 的兼容性，你可以让 Polylux 也支持直接导出，只需要加入下面的代码即可。

```
#import "@preview/touying:0.2.1"

#locate(loc => touying.pdfpc.pdfpc-file(loc))
```