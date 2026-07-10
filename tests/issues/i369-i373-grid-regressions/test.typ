// Minimal regressions for grid/cell animation issues.
// - #369: covering a paused grid.cell must preserve rowspan/colspan metadata.
// - #373: #meanwhile inside a container must escape outer hiding.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

#let tile(fill, body) = rect(
  fill: fill,
  width: 100%,
  height: 2.5em,
  inset: .4em,
  body,
)

== Preserve grid.cell while covered

#grid(
  columns: (1fr, 1fr),
  gutter: .5em,
  tile(aqua.lighten(50%), [top-left]),
  pause,
  grid.cell(rowspan: 2, tile(red.lighten(60%), [rowspan-right])),
  tile(blue.lighten(70%), [bottom-left]),
)

== Meanwhile with reducer inside grid

#let mini-reducer(..args) = touying-reducer(
  reduce: arr => arr.sum(default: none),
  cover: arr => hide(arr.sum(default: none)),
  ..args,
)

#grid(
  columns: (1fr, 1fr),
  gutter: .5em,
  mini-reducer(
    [left-1],
    pause,
    [left-2],
  ),
  [
    #meanwhile
    right-1
    #pause
    right-2
  ],
)
