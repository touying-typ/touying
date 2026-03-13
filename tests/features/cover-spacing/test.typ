#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-page(
    height: 200pt,
    width: 900pt,
    margin: (x: 4pt, y: 4pt),
    header: none,
    footer: none,
  ),
)

// == cover-spacing: list items
//
// On subslide 1 the left column has two list items hidden behind #pause.
// The right column (reset via #meanwhile) always shows all three items.
// The guide line sits at the vertical centre of the right column.
// If cover-spacing is correct the left column is centred at the same height
// and the guide line bisects both columns equally on every subslide.

#slide(
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    place(top + left, dy: 90pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[#align(horizon)[
    - text

    #pause
    - more

    normal text
  ]
]

#slide(
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    place(top + left, dy: 90pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    - text

    - more text

    normal text
  ]
]

// == cover-spacing: enum items

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    + first
    #pause
    + second
    + third
  ]
][
  #meanwhile
  #align(horizon)[
    + first
    + second
    + third
  ]
]

// == cover-spacing: terms items

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    / A: first
    #pause
    / B: second
    / C: third
  ]
][
  #meanwhile
  #align(horizon)[
    / A: first
    / B: second
    / C: third
  ]
]

// == cover-spacing: paragraphs

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    text

    #pause

    more

    even more
  ]
][
  #meanwhile
  #align(horizon)[
    text

    more text

    even more
  ]
]

// == more complex case with multiple stuff interleaved

#slide(setting: body => {
  place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
  place(top + left, dy: 89pt)[#line(length: 100%, stroke: .4pt + red)]
  place(top + left, dy: 135pt)[#line(length: 100%, stroke: .4pt + red)]
  place(top + left, dy: 168pt)[#line(length: 100%, stroke: .4pt + red)]
  body
})[
  #align(horizon)[
    - first
    #pause
    - second
    #pause
    normal text
    #pause
    / term 1: one
  ]
][
  #meanwhile
  #align(horizon)[
    - first
    - second
    normal text
    / term 1: one
  ]
]


// == more special cases

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    paragraph text
    #pause
    - list item (hidden)
    paragraph again
  ]
][
  #meanwhile
  #align(horizon)[
    paragraph text
    - list item (hidden)
    paragraph again
  ]
]
//== with multiple newlines
#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    place(top + left, dy: 103pt)[#line(length: 100%, stroke: .4pt + red)]
    place(top + left, dy: 150pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    paragraph text2

    #pause
    - list item2 (hidden)

    paragraph again
  ]
][
  #meanwhile
  #align(horizon)[
    paragraph text2

    - list item2 (hidden)

    paragraph again
  ]
]

//== with vertical space
#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    paragraph text3
    #pause #v(1em)
    - list item3 (hidden)
    paragraph again
  ]
][
  #meanwhile
  #align(horizon)[
    paragraph text3 #v(1em)
    - list item3 (hidden)
    paragraph again
  ]
]

//== now some tests with nontight lists.
//bc we do this locally this will break.

#slide(
  composer: (1fr, 1fr),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    //locally setting lists to be nontight.
    show list.where(tight: true): magic.nontight

    body
  },
)[
  #align(horizon)[
    - should break
    #pause
    - second
    - third
  ]
][
  #meanwhile
  #align(horizon)[
    - should break
    - second
    - third
  ]
]

== Rect Cover

#slide(
  composer: (1fr, 1fr),
  config: config-methods(cover: utils.cover-with-rect.with(fill: rgb(255, 0, 0, 20%), stroke: none)),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    - first
    #pause
    - second
    - third
  ]
][
  #meanwhile
  #align(horizon)[
    - first
    - second #uncover("2-")[inline cover]
    - third
  ]
]

== Semi-transparent Cover

#slide(
  composer: (1fr, 1fr),
  config: config-methods(cover: utils.semi-transparent-cover),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    - first
    #pause
    - second
    - third
  ]
][
  #meanwhile
  #align(horizon)[
    - first
    - second #uncover("2-")[inline cover]
    - third
  ]
]

== Color Changing Cover

#slide(
  composer: (1fr, 1fr),
  config: config-methods(cover: utils.color-changing-cover),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    - first
    #pause
    - second
    - third
  ]
][
  #meanwhile
  #align(horizon)[
    - first
    - second
    - third
  ]
]

== Alpha Changing Cover

#slide(
  composer: (1fr, 1fr),
  config: config-methods(cover: utils.alpha-changing-cover),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #align(horizon)[
    - first
    #pause
    - second
    - third
  ]
][
  #meanwhile
  #align(horizon)[
    - first
    - second
    - third
  ]
]