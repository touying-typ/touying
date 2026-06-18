---
sidebar_position: 3
---

# CeTZ

Touying provides the `touying-diagram`/`touying-reduce` functions (synonyms), which add `pause`, `meanwhile`, and other animations to CeTZ.

There also is `touying-reducer`, for which you have to specify the bindings yourself.

## Simple Animation

An example:

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: node, edge

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reduce.with(cetz) // new syntax for packages that expose their name
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


## only and uncover

Similarly we can also use `only` and `uncover`. Notice that for Cetz you need to wrap touying's smart animation commands in an array `(only(...),)` whereas in Fletcher you can write them natively.

```example
#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2"
#import themes.simple: *
#show: simple-theme.with(aspect-ratio: "16-9")

// cetz bindings for touying
#let cetz-canvas = touying-diagram.with(cetz) // new syntax for packages that expose their name

== Only and Uncover in Cetz

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

## only and uncover with slide self

We can also pass the slide self and then use the utils methods. You don't need to wrap these in an array. Note: you must count your subslides for this and parse in the correct `repeat` count.


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
    let uncover = uncover.with(cover-fn: hide.with(bounds: true)) //use cetz' hide function for covering
    
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

