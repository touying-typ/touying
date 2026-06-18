---
sidebar_position: 3
---

# CeTZ

Touying 提供了 `touying-diagram`/`touying-reduce` 函数（同义），它们可以为 CeTZ 添加 `pause`、`meanwhile` 及其他动画。

另外也有 `touying-reducer`，但你需要自行指定绑定。

## 简单动画

一个例子：

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reduce.with(cetz) // 对于暴露了包名的包可使用的新语法
#let fletcher-diagram = touying-reduce.with(fletcher)

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


## only 与 uncover

同样，我们也可以使用 `only` 和 `uncover`。注意：在 Cetz 中，你需要将 Touying 的智能动画命令包裹在数组中，如 `(only(...),)`，而在 Fletcher 中则可以直接原生书写。

```example
#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2"
#import themes.simple: *
#show: simple-theme.with(aspect-ratio: "16-9")

// cetz bindings for touying
#let cetz-canvas = touying-diagram.with(cetz) // 对于暴露了包名的包可使用的新语法

== Cetz 中的 Only 与 Uncover

Cetz in Touying in subslide #touying-get-config("subslide")

#cetz-canvas({
  import cetz.draw: *
  
  rect((0,0), (5,5))

  (uncover("2-3", {
    rect((0,0), (1,1))
    rect((1,1), (2,2))
    rect((2,2), (3,3))
  }),)

  (only(3, line((0,0), (2.5, 2.5), name: "line")),)
})

```

## 使用 slide self 的 only 与 uncover

我们也可以传入 slide 的 self，然后使用 utils 方法。无需将这些包裹在数组中。注意：你必须为此正确计算子幻灯片数量，并传入正确的 `repeat` 数量。

```example
#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2"
#import themes.simple: *
#show: simple-theme.with(aspect-ratio: "16-9")

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  Cetz in Touying in subslide #self.subslide:

  #cetz.canvas({
    import cetz.draw: *
    let uncover = uncover.with(cover-fn: hide.with(bounds: true)) //使用 cetz 的 hide 函数进行遮盖
    
    rect((0,0), (5,5))

    (uncover("2-3", {
      rect((0,0), (1,1))
      rect((1,1), (2,2))
      rect((2,2), (3,3))
    }),)

    (only(3, line((0,0), (2.5, 2.5), name: "line")),)
  })
])
```