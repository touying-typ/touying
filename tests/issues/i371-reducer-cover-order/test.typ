#import "/lib.typ": *
#import themes.simple: *
#import "@preview/cetz:0.5.0"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reduce.with(cetz)
#let fletcher-diagram = touying-reduce.with(fletcher)

#show: simple-theme

== Fletcher

There is a #pause in this slide.

#let mynode(pos, name) = node(
  pos,
  "",
  shape: "circle",
  stroke: black,
  name: name,
)

#fletcher-diagram({
  mynode((0, 0), "anchor1")
  uncover(2, mynode((1, 0), "anchor2"))

  uncover(3, node("anchor1", "x")) // Assertion failed: node `anchor1` not found.
  node("anchor2", "y") // Ok.
})

== Cetz

There is a #pause in this slide.

// "b" is defined without uncover — on subslide 1 it goes to hidden-parts.
// The line referencing "b.east" is in an uncover fn-wrapper, so it gets
// added to result in-place (before hidden-parts are flushed at the end).
// Previously this broke ordering: CeTZ saw the line before the "b" anchor.
#cetz-canvas(
  {
    import cetz.draw: *

    circle((0, 0), radius: 0.3, name: "a")

    (pause,)

    // not wrapped in uncover — hidden via hidden-parts on subslide 1
    circle((2, 0), radius: 0.3, name: "b")

    // fn-wrapper: processed in-place; references "b" as anchor
    (uncover(3, line("b.east", (3.5, 0))),)
  },
  length: 30pt,
)
