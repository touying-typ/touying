---
sidebar_position: 5
---

# 其他动画

Touying 还提供了 `touying-reducer`，它能让所有动画在 CeTZ 和 Fletcher 中原生工作。

## 简单动画

一个例子：

```example
#import "@preview/touying:0.6.3": *
#import themes.university: *
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(aspect-ratio: "16-9")

// cetz animation
#slide[
  Cetz in Touying:

  #cetz-canvas({
    import cetz.draw: *
    
    rect((0,0), (5,5))

    (pause,)

    rect((0,0), (1,1))
    rect((1,1), (2,2))
    rect((2,2), (3,3))

    (pause,)

    line((0,0), (2.5, 2.5), name: "line")
  })
]

// fletcher animation
#slide[
  Fletcher in Touying:

  #fletcher-diagram(
    node-stroke: .1em,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,
    edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
    node((0,0), `reading`, radius: 2em),
    edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
    pause,
    edge(`read()`, "-|>"),
    node((1,0), `eof`, radius: 2em),
    pause,
    edge(`close()`, "-|>"),
    node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
    edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
  )
]
```

## `only`、`uncover` 和 `alternatives`

事实上，我们也可以在 CeTZ 和 Fletcher 内部使用 `only`、`uncover` 甚至 `alternatives`，使用相同的语法。由于 CeTZ 和 Fletcher 通常是基于位置的，不同命令得到图表看起来是一样的，但在底层它们的工作方式不同。`only` 会丢弃绘制命令，而 `uncover` 会使用包里的 `hide` 来隐藏。

```typst
//imports, bindings and theme

#slide[
  Cetz in Touying:

  #cetz-canvas({
    import cetz.draw: *
    
    rect((0,0), (5,5))
    (pause,)

    rect((0,0), (1,1))

    (uncover(3, {
      rect((1,1), (2,2))
      rect((2,2), (3,3)) 
    }),)

    (only(3, line((0,0), (2.5, 2.5), name: "line") ),)
  })
]

#slide[
  Fletcher in Touying:

  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [A], radius: 2em),
    pause,
    uncover("1-2", edge((0, 0), (1, 0), "-|>", stroke: blue)),
    uncover("2-", node((1, 0), [B], radius: 2em)),
    only(3, node((0, 1), [tmp], radius: 1em, fill: orange)),
  )
]
```

注意，像 `effect` 和 `item-by-item` 这样的命令可能无法按预期工作。

## 回调式绑定

如果你不想为 CeTZ 编写数组语法 `(anim-cmd(), )`，你可以在 canvas 中通过 utils 本地重新定义你需要的命令。这样它们就会输出 CeTZ 原生理解的格式。但是，你需要通过 `repeat` 手动计算子幻灯片的数量！

```example
#import "@preview/touying:0.6.3": *
#import "@preview/cetz:0.4.2"
#import themes.simple: *
#show: simple-theme.with(aspect-ratio: "16-9")

#slide(repeat: 3, self => [
  #let (uncover, only) = utils.methods(self)

  Cetz in Touying in subslide #self.subslide:

  #cetz.canvas({
    import cetz.draw: *
    let uncover = uncover.with(cover-fn: hide.with(bounds: true))
    
    rect((0,0), (5,5))

    uncover("2-3", {
      rect((0,0), (1,1))
      rect((1,1), (2,2))
      rect((2,2), (3,3))
    })

    only(3, line((0,0), (2.5, 2.5), name: "line"))
  })
])
```

（这也适用于 Fletcher，但实际上没有理由使用它。）