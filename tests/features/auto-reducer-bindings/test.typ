#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-info(
    title: "Auto Reducer Bindings",
  ),
)

== Test Cetz
#import "@preview/cetz:0.5.0"
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
