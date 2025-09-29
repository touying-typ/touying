#import "/lib.typ": *
#import themes.university: *
#import "@preview/cetz:0.4.2"

// cetz bindings for touying
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#show: university-theme.with(aspect-ratio: "16-9")

== CeTZ Animation

// cetz animation
#slide[
  Cetz in Touying:

  #cetz-canvas({
    import cetz.draw: *

    rect((0, 0), (5, 5))

    (pause,)

    rect((0, 0), (1, 1))
    rect((1, 1), (2, 2))
    rect((2, 2), (3, 3))

    (pause,)

    line((0, 0), (2.5, 2.5), name: "line")
  })
]

== only and uncover in Cetz

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

    rect((0, 0), (5, 5))

    uncover("2-3", {
      rect((0, 0), (1, 1))
      rect((1, 1), (2, 2))
      rect((2, 2), (3, 3))
    })

    only(3, line((0, 0), (2.5, 2.5), name: "line"))
  })
])
