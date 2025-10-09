// Issue: meanwhile in cetz
// https://github.com/touying-typ/touying/issues/204

#import "/lib.typ": *
#import "@preview/cetz:0.4.1"
#import themes.default: *

// Cetz bindings for touying.
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#show: default-theme.with(aspect-ratio: "16-9")

#slide[
  Cetz in Touying:

  #cetz-canvas({
    import cetz.draw: *

    rect((0, 0), (5, 5))

    (pause,)

    rect((0, 0), (1, 1))
    rect((1, 1), (2, 2))
    rect((2, 2), (3, 3))

    (meanwhile,)

    line((0, 0), (2.5, 2.5), name: "line")
  })
]
