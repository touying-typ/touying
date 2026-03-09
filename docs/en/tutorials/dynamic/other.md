---
sidebar_position: 5
---

# Other Animations

Touying also provides `touying-reducer`, which adds `pause` and `meanwhile` animations to cetz and fletcher.

## Simple Animations

Here's an example:

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


## only and uncover

In fact, we can also use `only` and `uncover` within cetz, just requiring a bit of skill:

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
    let self = utils.merge-dicts(
      self,
      config-methods(cover: utils.method-wrapper(hide.with(bounds: true))),
    )
    let (uncover,) = utils.methods(self)
    // let uncover = uncover.with(cover-fn: hide.with(bounds: true))
    
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