#import "/lib.typ": *
#import themes.university: *
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

// fletcher bindings for touying
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(aspect-ratio: "16-9")

== Fletcher Animation

#slide[
  Fletcher in Touying:

  #fletcher-diagram(
    node-stroke: .1em,
    node-fill: gradient.radial(
      blue.lighten(80%),
      blue,
      center: (30%, 20%),
      radius: 80%,
    ),
    spacing: 4em,
    edge((-1, 0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
    node((0, 0), `reading`, radius: 2em),
    edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
    pause,
    edge(`read()`, "-|>"),
    node((1, 0), `eof`, radius: 2em),
    pause,
    edge(`close()`, "-|>"),
    node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
    edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
  )
]
