---
sidebar_position: 4
---

# Fletcher

Touying 提供了 `touying-reducer`，它能为 fletcher 加入 `pause` 和 `meanwhile` 动画。

一个例子：

```example
#import "@preview/touying:0.7.0": *
#import themes.metropolis: *
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: metropolis-theme.with(aspect-ratio: "16-9")

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

一个 callback-style 的例子：

```example
#import "@preview/touying:0.6.1": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#show: themes.simple.simple-theme.with(aspect-ratio: "16-9")

#let diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#slide(repeat: 6, self => {
  let (uncover, only, alternatives) = utils.methods(self)
  let uncover = uncover.with(cover-fn: fletcher.hide)
  diagram(
    node((0, 0), name: <A>)[$A$],
    pause,
    edge("->"),
    node((1, 0), name: <B>)[$B$],
    pause,
    edge("->"),
    node((2, 0), name: <C>)[$C$],
    uncover("4,6", edge(<A>, "~", <B>, bend: 40deg, stroke: red)),
    only("5,6", edge(<B>, "~", <C>, bend: 40deg, stroke: green)),
    only("6", edge(<C>, "~", <A>, bend: 40deg, stroke: blue)),
  )
})
```
