#import "/lib.typ": *
#import themes.university: *
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(aspect-ratio: "16-9")

== Show in range with `between`

#slide[
  Content visible only during slides 2-3:

  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [Start], radius: 2em),
    // Edge visible only on slides 2-3
    ..between(2, 3, edge((0, 0), (1, 0), "-|>", stroke: blue, label: [2-3 only])),
    pause,
    pause,
    pause,
    node((2, 0), [End], radius: 2em),
  )
]
