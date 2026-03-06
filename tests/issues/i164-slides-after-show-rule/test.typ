// Issue: slides after table not rendering
// https://github.com/touying-typ/touying/issues/164

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== First Slide

Hello, Typst!

== Second Slide

#set table(
  stroke: none,
  gutter: 0.2em,
  fill: (x, y) =>
    if x == 0 or y == 0 { gray },
  inset: (right: 1.5em),
)
#show table.cell: it => {
  if it.x == 0 or it.y == 0 {
    set text(white)
    strong(it)
  } else if it.body == [] {
    pad(..it.inset)[_N/A_]
  } else {
    it
  }
}
#let a = table.cell(fill: green.lighten(60%))[A]
#let b = table.cell(fill: aqua.lighten(60%))[B]
#table(
  columns: 4,
  [], [Exam 1], [Exam 2], [Exam 3],
  [John], [], a, [],
  [Mary], [], a, a,
  [Robert], b, a, b,
)

== Third Slide

This slide should render.
