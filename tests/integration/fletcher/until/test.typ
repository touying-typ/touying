#import "/lib.typ": *
#import themes.university: *
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(aspect-ratio: "16-9")

== Reverse Reveal with `until`

#slide[
  Content visible until slide 2, then hidden:

  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [A], radius: 2em),
    node((2, 0), [B], radius: 2em),
    // Temporary edge visible on slides 1-2, hidden from slide 3
    until(2, edge((0, 0), (2, 0), "-|>", stroke: red, label: [temp])),
    // Permanent edge from slide 3 onwards
    at(3, edge((0, 0), (2, 0), "-|>", stroke: green, label: [final], bend: -30deg)),
  )
]
