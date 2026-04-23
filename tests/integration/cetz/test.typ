#import "../../../lib.typ": *
#import themes.university: *
#import "@preview/cetz:0.5.0"

// cetz bindings for touying
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#show: university-theme.with(aspect-ratio: "16-9")

== CeTZ Animation

// cetz animation with pause
#slide[
  #cetz-canvas({
    import cetz.draw: *
    rect((0, 0), (5, 5))
    (pause,)
    rect((0, 0), (1, 1))
    (pause,)
    line((0, 0), (2.5, 2.5), name: "line")
  })
]

== only and uncover in Cetz (callback style)

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #cetz.canvas({
    import cetz.draw: *
    let uncover = uncover.with(cover-fn: hide.with(bounds: true))

    rect((0, 0), (5, 5))

    uncover("2-3", {
      rect((0, 0), (1, 1))
      rect((1, 1), (2, 2))
      rect((2, 2), (3, 3))
    })

    only(3, line((0, 0), (2.5, 2.5), name: "line"))
  })
])

== Cetz with native only/uncover

// Same as above but using the reducer — should produce identical output.
#slide[

  #cetz-canvas({
    import cetz.draw: *
    rect((0, 0), (5, 5))
    (
      uncover("2-3", {
        rect((0, 0), (1, 1))
        rect((1, 1), (2, 2))
        rect((2, 2), (3, 3))
      }),
    )
    (only(3, line((0, 0), (2.5, 2.5), name: "line")),)
    (
      only(from-wp(<wp2>), line(
        (0, 5),
        (2.5, 2.5),
        stroke: red,
        name: "line-alt",
      )),
    )
  })
  #meanwhile
  #waypoint(<wp1>, advance: false)
  Normal Content.
  #waypoint(<wp2>)
  My Line.
  #waypoint(<wp3>)
  Also My line?
]


== Cetz with native alternatives

#slide[
  #cetz-canvas({
    import cetz.draw: *
    rect((0, 0), (5, 5))

    (
      alternatives(start: 1, rect((0, 0), (1, 1)), rect((1, 1), (2, 2)), rect(
        (2, 2),
        (3, 3),
      )),
    )

    (
      alternatives(start: 2, line((0, 0), (2.5, 2.5), name: "line"), line(
        (0, 5),
        (2.5, 2.5),
        name: "line-alt",
      )),
    )
  })
]
