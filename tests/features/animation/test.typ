#import "/lib.typ": *
#import themes.simple: *
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: simple-theme

= Animation

== Simple Animation

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]


== Complex Animation

At subslide #touying-fn-wrapper((self: none) => str(self.subslide)), we can

use #uncover("2-")[`#uncover` function] for reserving space,

use #only("2-")[`#only` function] for not reserving space,

#alternatives[call `#only` multiple times ✗][use `#alternatives` function ✓] for choosing one of the alternatives.


== Callback Style Animation

#slide(
  repeat: 3,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    At subslide #self.subslide, we can

    use #uncover("2-")[`#uncover` function] for reserving space,

    use #only("2-")[`#only` function] for not reserving space,

    #alternatives[call `#only` multiple times ✗][use `#alternatives` function ✓] for choosing one of the alternatives.
  ],
)


== Math Equation Animation

Equation with `pause`:

$
  f(x) & = pause x^2 + 2x + 1 \
       & = pause (x + 1)^2 \
$

#meanwhile

Here, #pause we have the expression of $f(x)$.

#pause

By factorizing, we can obtain this result.


== CeTZ Animation

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


== Fletcher Animation

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

= Pause + Uncover Mixing

== Pause + Uncover/Only Inline

- On 1 #pause
- On 2 #pause
- #uncover("2-")[Uncover 2-]  // was hidden even on subslide 2
- #only(2)[Only 2]            // was hidden even on subslide 2
- On 3

== Pause + Alternatives Inline

Text #pause then #alternatives[Alt 1][Alt 2] and more.

= Jump

== jump(n, relative: true) — relative stepping

`#jump(1, relative: true)` is equivalent to `#pause`:

A #jump(1, relative: true) B #jump(1, relative: true) C

`#jump(2, relative: true)` skips an extra subslide:

X #jump(2, relative: true) Z


== jump(n) — absolute jumping

`#jump(1)` is equivalent to `#meanwhile`:

First #pause Second #jump(1) Always visible

`#jump(3)` jumps to absolute subslide 3:

Part A #pause Part B #jump(3) Part C


== jump negative relative in CeTZ

#cetz-canvas({
  import cetz.draw: *

  rect((0, 0), (5, 5))

  (jump(1, relative: true),)

  rect((0, 0), (2, 2))

  (jump(-1, relative: true),)

  circle((3.5, 3.5), radius: 1)
})
