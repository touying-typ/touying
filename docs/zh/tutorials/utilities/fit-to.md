---
sidebar_position: 1
---

# Fit to height / width

感谢 [ntjess](https://github.com/ntjess) 的代码。

## Fit to height

如果你需要将图片占满剩余的 slide 高度，你可以来试试 `fit-to-height` 函数：

```typst
#utils.fit-to-height(1fr)[BIG]
```

函数定义：

```typst
#let fit-to-height(
  height: 1fr,
  width: auto,
  prescale-width: none,
  grow: true,
  shrink: true,
  reflow: true,
  force-height: false,
  body,
  ..args,
) = { .. }
```

参数：

- `height`: 需要适配的高度，默认为 `1fr`，即填满剩余的可用高度。可以是 `length`、`fraction` 或 `relative`，例如 `height: 50%` 表示占据幻灯片高度的一半。
- `width`: 如果指定，这将确定缩放后内容的宽度。因此，如果您希望缩放的内容填充幻灯片宽度的一半，则可以使用 `width: 50%`。默认为 `auto`。
- `prescale-width`: 此参数允许您使 Typst 的布局假设给定的内容在缩放之前要布局在一定宽度的容器中。例如，您可以使用 `prescale-width: 200%` 假设幻灯片的宽度为原来的两倍。
- `grow`: 内容比可用高度小时是否放大，默认为 `true`。
- `shrink`: 内容比可用高度大时是否缩小，默认为 `true`。
- `reflow`: 缩放时是否允许文本重新折行，默认为 `true`。仅当 `width` 为 `auto` 且内容包含文本时生效。
- `force-height`: 是否强制内容占满整个高度，而不是让它去填满可用宽度，默认为 `false`。仅当 `reflow` 为 `true` 且 `width` 为 `auto` 时才有意义。文本重新折行后，尽量用满宽度通常更合理：行数是离散的，因此可用的缩放比例也是离散的，强制占满高度可能导致文本无法用满宽度。
- `body`: 具体的内容。
- `..args`: 为兼容旧版本，仍然支持把高度作为位置参数传入，例如 `#utils.fit-to-height(1fr)[BIG]`。


## Fit to width

如果你需要限制标题宽度刚好占满 slide 的宽度，你可以来试试 `fit-to-width` 函数：

```typst
#utils.fit-to-width(1fr)[#lorem(20)]
```

函数定义：

```typst
#let fit-to-width(width: 1fr, grow: true, shrink: true, body, ..args) = { .. }
```

参数：

- `width`: 需要适配的宽度，默认为 `1fr`，即填满剩余的可用宽度。可以是 `length`、`fraction` 或 `relative`，例如 `width: 50%` 表示占据幻灯片宽度的一半。
- `grow`: 内容比可用宽度小时是否放大，默认为 `true`。
- `shrink`: 内容比可用宽度大时是否缩小，默认为 `true`。
- `body`: 具体的内容。
- `..args`: 为兼容旧版本，仍然支持把宽度作为位置参数传入，例如 `#utils.fit-to-width(1fr)[#lorem(20)]`。


## 实用示例：将表格适配到幻灯片

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-height(1fr)[
    #table(
      columns: (1fr, 1fr, 1fr),
      [A], [B], [C],
      [1], [2], [3],
      [4], [5], [6],
    )
  ]
]
```

## 将标题适配到全宽

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-width(1fr)[
    #text(weight: "bold")[A Very Long Presentation Title That Should Fill the Entire Slide Width]
  ]
]
```
