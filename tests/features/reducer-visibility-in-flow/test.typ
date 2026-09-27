// A reducer takes part in the pause flow around it, so an unmarked element
// lands on the subslide the flow has reached. The numbers its own elements
// carry are the slide's own either way, so an absolute subslide number or a
// waypoint keeps firing where it points, and `meanwhile` among the elements
// rewinds the inherited counter.

#import "/lib.typ": *
#import themes.simple: *
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#let fletcher-diagram = touying-reduce.with(fletcher)

#show: simple-theme

#let dot(pos, name) = node(
  pos,
  name,
  shape: "circle",
  stroke: black,
  name: label(name),
)

// The pauses of the first body leave the counter at 4, which the reducer in
// the second body inherits. Its absolute subslide numbers are the slide's own
// either way, so they have to keep firing on 2 and 3 rather than be skipped
// along with the diagram.
== Absolute numbers survive a foreign pause flow

#slide(repeat: 4, composer: (1fr, 1fr))[
  intro
  #pause
  A
  #pause
  B
  #pause
  C
][
  #fletcher-diagram(
    dot((0, 0), "flow=C"),
    uncover(2, dot((1, 0), "two-A")),
    uncover(3, dot((2, 0), "three-B")),
  )
]

// A waypoint the first body opened is reached from inside the diagram, which
// only works if the diagram is built on the subslides before it too.
== Waypoints survive a foreign pause flow

#slide(repeat: 4, composer: (1fr, 1fr))[
  #waypoint(<wp:first>)
  first
  #waypoint(<wp:second>)
  second
  #pause
  third
][
  #fletcher-diagram(
    dot((0, 0), "three"),
    uncover(from-wp(<wp:second>), dot((1, 0), "two")),
  )
]

// `meanwhile` among the elements rewinds the inherited counter, which is how
// an unmarked element is moved off the subslide the flow would give it.
== Meanwhile rewinds the inherited counter

#slide(repeat: 3, composer: (1fr, 1fr))[
  intro
  #pause
  A
  #pause
  B
][
  #fletcher-diagram(
    meanwhile,
    dot((0, 0), "always"),
    uncover(3, dot((1, 0), "last")),
  )
]
