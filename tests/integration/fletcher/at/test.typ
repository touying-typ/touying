#import "/lib.typ": *
#import themes.university: *
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(aspect-ratio: "16-9")

== Show at specific slide with `at`

#slide[
  Demonstrates `at()` showing content only at one specific slide:

  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [X], radius: 2em),
    // Node Y only visible at slide 2 (not before, not after)
    at(2, node((1, 0), [Y], radius: 2em, fill: yellow)),
    // Node Z appears from slide 3 onwards (uses step, not at)
    step(3),
    node((2, 0), [Z], radius: 2em),
  )
]
