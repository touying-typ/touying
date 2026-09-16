// Covering a list next to a paragraph break must not move the list that stays
// visible.
//
// A blank line between two item runs does not split them into two lists: Typst
// keeps one list and makes it non-tight, which both widens the row pitch and
// lowers where the list starts. If covering the run on one side of the break
// lets the rest revert to tight, every visible row shifts -- including the
// first, which is nowhere near the covered content.
//
// Each slide draws full-width guide lines at fixed positions and puts the
// animated content in the left column against an all-visible copy (reset with
// `#meanwhile`) in the right. The guides are absolute, so a row that moves
// between subslides leaves its line while the reference column stays on it.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-page(
    height: 300pt,
    width: 900pt,
    margin: (x: 4pt, y: 4pt),
    header: none,
    footer: none,
  ),
)

// Guides at the four row baselines of a non-tight two-plus-two list.
#let guides = {
  for dy in (77.3pt, 123.75pt, 170.2pt, 216.65pt) {
    place(top + left, dy: dy)[#line(length: 100%, stroke: .4pt + red)]
  }
}

== pause covers the run after the break

#slide(composer: (1fr, 1fr), setting: body => {
  guides
  body
})[
  - alpha
  - beta
  #pause

  - gamma
  - delta
][
  #meanwhile
  - alpha
  - beta

  - gamma
  - delta
]

== item-by-item over the same content

#slide(composer: (1fr, 1fr), setting: body => {
  guides
  body
})[
  #item-by-item[
    - alpha
    - beta

    - gamma
    - delta
  ]
][
  #meanwhile
  - alpha
  - beta

  - gamma
  - delta
]

== enum

#slide(composer: (1fr, 1fr), setting: body => {
  guides
  body
})[
  #item-by-item[
    + alpha
    + beta

    + gamma
    + delta
  ]
][
  #meanwhile
  + alpha
  + beta

  + gamma
  + delta
]

== the break before the covered run

// Here the pause sits before the blank line, so the covered run carries the
// parbreak instead of the visible one. The visible rows must still hold.

#slide(composer: (1fr, 1fr), setting: body => {
  guides
  body
})[
  - alpha
  - beta
  #pause
  - gamma

  - delta
][
  #meanwhile
  - alpha
  - beta
  - gamma

  - delta
]

== a tight list is not loosened

// A linebreak is absorbed into the item it ends rather than becoming a sibling,
// so this list stays tight and its rows keep the narrow pitch. Guides sit at
// the tight baselines.

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    for dy in (77.3pt, 110pt, 142.7pt) {
      place(top + left, dy: dy)[#line(length: 100%, stroke: .4pt + blue)]
    }
    body
  },
)[
  #item-by-item[
    - alpha
    - beta \
    - gamma
  ]
][
  #meanwhile
  - alpha
  - beta \
  - gamma
]
