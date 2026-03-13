---
sidebar_position: 5
---

# Other Animations

Touying also provides `touying-reducer`, which allows all animations to work natively in CeTZ and Fletcher.

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


## `only`,`uncover` and `alternatives`

In fact, we can also use `only`,`uncover` and even `alternatives` within CeTZ and Fletcher with the same syntax. Since CeTZ and Fletcher are generally position based the diagram will turn out to be the same, but under the hood the act differently. `only` drops the draw command, whereas `uncover` covers it.

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
Note that commands like `effect` and `item-by-item` might not work as expected.

## Callback-Style Bindings

If you don't want to have to write the array syntax `(anim-cmd(), )` for CeTZ, you can redefine the commands you need via utils locally in the canvas. This way they output the format CeTZ understands natively. However, then you need to manually count your subslides via `repeat`! 

```example
#import "@preview/touying:0.6.3": *
#import "@preview/cetz:0.4.2"
#import themes.simple: *
#show: simple-theme.with(aspect-ratio: "16-9")

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

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
(This also works for Fletcher, but there should be no reason to use it really.)