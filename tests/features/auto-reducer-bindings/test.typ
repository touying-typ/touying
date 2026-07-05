#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-info(
    title: "Auto Reducer Bindings",
  ),
)

== Test Cetz
#import "@preview/cetz:0.5.2"
#touying-reduce(cetz, {
  import cetz.draw: *

  rect((0, 0), (5, 5))

  (pause,)

  rect((0, 0), (1, 1))
  rect((1, 1), (2, 2))
  rect((2, 2), (3, 3))

  (pause,)

  line((0, 0), (2.5, 2.5), name: "line")
})


== Test Alchemist
#import "@preview/alchemist:0.1.9" as alch
#touying-reduce(alch, {
  alch.fragment(name: "A", "A")
  alch.single()
  alch.fragment("B")

  (pause,)

  alch.branch({
    alch.single(angle: 1)
    alch.fragment(name: "C", "C")
  })
})

== Test Fletcher
#import "@preview/fletcher:0.5.8" as fletcher: *
#touying-reduce(
  fletcher,
  node-stroke: .1em,
  spacing: 4em,
  node((0, 0), [A], radius: 2em),
  pause,
  uncover("1-2", edge((0, 0), (1, 0), "-|>", stroke: blue)),
  uncover("2-", node((1, 0), [B], radius: 2em)),
  only(3, node((0, 1), [tmp], radius: 1em, fill: orange)),
)
