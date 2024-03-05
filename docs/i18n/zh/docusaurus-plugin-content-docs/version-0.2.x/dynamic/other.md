---
sidebar_position: 6
---

# 其他动画

Touying 还提供了 `touying-reducer`，它能为 cetz 与 fletcher 加入 `pause` 和 `meanwhile` 动画。

## 简单动画

一个例子：

```typst
#import "@preview/touying:0.2.1": *
#import "@preview/cetz:0.2.1"
#import "@preview/fletcher:0.4.1" as fletcher: node, edge

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: (arr, ..args) => fletcher.diagram(..args, ..arr))

#let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
#let (init, slide) = utils.methods(s)
#show: init

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

![image](https://github.com/touying-typ/touying/assets/34951714/9ba71f54-2a5d-4144-996c-4a42833cc5cc)


## only 与 uncover

事实上，我们也可以在 cetz 内部使用 `only` 和 `uncover`，只是需要一点技巧：

```typst
#slide(repeat: 3, self => [
  #let (uncover, only) = utils.methods(self)

  Cetz in Touying in subslide #self.subslide:

  #cetz.canvas({
    import cetz.draw: *
    let self = (self.methods.update-cover)(self: self, hide)
    let (uncover,) = utils.methods(self)
    
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