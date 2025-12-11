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
  Content visible only during specific slide ranges:

  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    // Always visible
    node((0, 0), [Start], radius: 2em),
    node((3, 0), [End], radius: 2em),
    // Blue edge visible only on slides 2-3
    between(2, 3, edge((0, 0), (1, 0), "-|>", stroke: blue, label: [2-3])),
    // Middle node visible on slides 2-4
    between(2, 4, node((1, 0), [Mid], radius: 2em, fill: yellow)),
    // Red edge visible only on slides 3-4
    between(3, 4, edge((1, 0), (2, 0), "-|>", stroke: red, label: [3-4])),
    // Green edge appears from slide 4
    step(4),
    node((2, 0), [Near], radius: 2em, fill: green.lighten(50%)),
    // Final edge from slide 5
    step(5),
    edge((2, 0), (3, 0), "-|>", stroke: purple, label: [final]),
  )
]
