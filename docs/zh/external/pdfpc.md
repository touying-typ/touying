---
sidebar_position: 4
---

# pdfpc

[pdfpc](https://pdfpc.github.io/) 是一个 "对 PDF 文档具有多显示器支持的演示者控制台"。这意味着，您可以使用它以 PDF 页面的形式显示幻灯片，并且还具有一些已知的出色功能，就像 PowerPoint 一样。

pdfpc 有一个 JSON 格式的 `.pdfpc` 文件，它可以为 PDF slides 提供更多的信息。虽然您可以手动编写它，但你也可以通过 Touying 来管理。
其原理是向文档中加入 metadata，Touying 再把它们收集并提取成一个 `.pdfpc` 文件。所有相关函数都位于 `pdfpc` 模块下。

Touying 与 [Polylux](https://polylux.dev/book/external/pdfpc.html) 保持一致，以避免 API 之间的冲突，下面的大部分内容也来自 Polylux。


## 演讲者备注

你可以使用 `pdfpc.speaker-note(str|raw)` 函数为幻灯片加入备注，这些备注只会在 pdfpc 的演讲者视图中可见。
例如 `#pdfpc.speaker-note("This is a note that only the speaker will see.")`。

## 结束页

有时候演示文稿的最后一页并不是你真正想要收尾的那一页。比如在「感谢我妈妈和所有相信我的人」这一页之后，
为了完整性你还附上了参考文献或附录。

只要在任意一页里放一个简单的 `#pdfpc.end-slide`，就可以告诉 pdfpc 这是你通常想展示到的最后一页，
按下 End 键便会跳转到那里。

## 标记页面

类似地，pdfpc 还有一个为特定页面添加书签的功能（之后可以用 Shift + M 跳转过去）。
在 Typst 源码中，把 `#pdfpc.save-slide` 放进某一页即可选中该页。

## 隐藏页面

如果你想在演示文稿中保留某一页（以防万一），但通常并不打算展示它，可以在 pdfpc 中把它隐藏起来。
放映时这一页会被跳过，但在总览视图中仍然可用。在 Typst 源码中使用 `#pdfpc.hidden-slide`
即可把一页标记为隐藏。

## pdfpc 配置

为了加入 pdfpc 配置，你可以使用

```typst
#pdfpc.config(
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
)
```

加入对应的配置，具体配置方法可以参考 [Polylux](https://polylux.dev/book/external/pdfpc.html)。


## 输出 .pdfpc 文件

假设你的文档为 `./example.typ`，则你可以通过

```sh
typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
```

直接导出 `.pdfpc` 文件。

借助 Touying 与 Polylux 的兼容性，你可以让 Polylux 也支持直接导出，只需要加入下面的代码即可。

```typst
#import "@preview/touying:0.7.4"

#context touying.pdfpc.pdfpc-file(here())
```

## 以 Bundle 资源的形式输出 .pdfpc 文件

从 Typst 0.15 开始，一次编译可以输出一整个 bundle 的文件，因此 `.pdfpc` 文件可以直接
输出到 PDF 旁边，而不需要额外执行一条命令。只需要在文件的顶层，也就是所有
`#document(..)` 之外，加入 `#pdfpc.bundle-assets()`：

```typst
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#pdfpc.bundle-assets()

#document("deck.pdf", [
  #show: simple-theme

  == A slide
  #speaker-note[Only the speaker sees this.]
])
```

用下面的命令编译

```sh
typst compile --features bundle --format bundle --root . ./example.typ ./out
```

就会同时得到 `./out/deck.pdf` 和 `./out/deck.pdfpc`。bundle 中的每个 PDF 文档都会得到
以自身命名的 `.pdfpc` 文件，其中只包含该演示文稿自己的 notes 与配置。没有 pdfpc metadata
的文档以及非 PDF 的文档会被跳过；在非 bundle 的导出中，这个调用不会有任何作用，因此可以把
`#pdfpc.bundle-assets()` 留在同时也会编译为普通 PDF 的文件里。请注意这只适用于该调用本身：
上面的 `#document(..)` 只能用于 bundle，编译为 PDF 时 Typst 会报错
`constructing a document is only supported in the bundle target`。

注意 bundle 导出目前仍是实验性功能，Typst 会为此发出警告，其行为也可能发生变化。
