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

== Fletcher with native uncover and only

// Tests fn-wrappers inside the reducer: uncover uses fletcher.hide,
// only produces no output when hidden.
#slide[
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

// == Fletcher with pause after uncover

// // Tests that pause lands after fn-wrapper range, not before.
// #slide[
//   #fletcher-diagram(
//     node-stroke: .1em,
//     spacing: 4em,
//     node((0, 0), [X], radius: 2em),
//     uncover("2-3", edge((0, 0), (1, 0), "-|>")),
//     uncover("2-3", node((1, 0), [Y], radius: 2em)),
//     pause,
//     edge((1, 0), (2, 0), "-|>"),
//     node((2, 0), [Z], radius: 2em),
//   )
// ]

== Fletcher with waypoints

// Tests waypoint labels inside the reducer with uncover/only.
#slide[
  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [Origin], radius: 2em),
    waypoint(<fl-step>, advance: false),
    uncover(<fl-step>, edge((0, 0), (1, 0), "-|>")),
    uncover(<fl-step>, node((1, 0), [W], radius: 2em)),
    only(<fl-done>, node(
      (1, 1),
      [Done],
      radius: 1.5em,
      fill: green.lighten(60%),
    )),
  )
]

== Fletcher with alternatives

// Tests alternatives: node swaps label per subslide.
#slide[
  #fletcher-diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), [Start], radius: 2em),
    edge("-|>"),
    alternatives(
      node((1, 0), [Phase 1], radius: 2em),
      node((1, 0), [Phase 2], radius: 2em),
    ),
  )
]
