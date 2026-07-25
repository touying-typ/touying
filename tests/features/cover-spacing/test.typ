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
  config: config-methods(cover: utils.cover-with-rect.with(
    fill: rgb(255, 0, 0, 20%),
    stroke: none,
  )),
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

= Discussion #387

== Hiding Cover
#slide(
  config: config-page(
    height: 300pt,
    width: 900pt,
    margin: (x: 4pt, y: 4pt),
    header: none,
    footer: none,
  ),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #text(size: 32pt, $ E = m c^2 $)

  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  #pause
  - Test Text #pause
  - More Test Text #pause
  - Even More Text
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  #uncover(auto)[
    $ |NN| < |ZZ| $
  ]
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
][
  #meanwhile
  #text(size: 32pt, $ E = m c^2 $)
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  - Test Text
  - More Test Text
  - Even More Text
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  $ |NN| < |ZZ| $
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
]

== Color-Changing Cover
#slide(
  config: config-page(
    height: 300pt,
    width: 900pt,
    margin: (x: 4pt, y: 4pt),
    header: none,
    footer: none,
  )
    + config-methods(cover: utils.color-changing-cover.with(color: gray)),
  setting: body => {
    place(top + left, dy: 56pt)[#line(length: 100%, stroke: .4pt + red)]
    body
  },
)[
  #text(size: 32pt, $ E = m c^2 $)

  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  #pause
  - Test Text #pause
  - More Test Text #pause
  - Even More Text
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  #uncover(auto)[
    $ |NN| < |ZZ| $
  ]
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
][
  #meanwhile
  #text(size: 32pt, $ E = m c^2 $)
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  - Test Text
  - More Test Text
  - Even More Text
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
  $ |NN| < |ZZ| $
  #uncover("0-")[#place[#line(length: 100%, stroke: .4pt + red)]]
]

= Meanwhile look-below spacing

// A #meanwhile can reveal further list/enum/terms items directly *after* a
// covered run.  The covered block then needs list spacing *below* it (not the
// default paragraph spacing), so the revealed items line up with the
// all-visible reference.  This is the mirror image of the #pause case, which
// corrects the spacing *above* the covered block.
//
// Full-width guide lines are drawn (always visible, spanning both columns) at
// the baseline of each of the four items.  The animated left column and the
// all-visible right column (reset with #meanwhile) must sit on the same lines
// on every subslide — in particular the revealed items after the covered run
// (c, d) must not drift below their guides.

#let guides = {
  for dy in (58pt, 90.5pt, 123pt, 156pt) {
    place(top + left, dy: dy)[#line(length: 100%, stroke: .4pt + red)]
  }
}

== list
#slide(
  composer: (1fr, 1fr),
  setting: body => {
    guides
    body
  },
)[
  #align(horizon)[
    - a
    #pause
    - b
    #meanwhile
    - c
    - d
  ]
][
  #meanwhile
  #align(horizon)[
    - a
    - b
    - c
    - d
  ]
]

== enum
#slide(
  composer: (1fr, 1fr),
  setting: body => {
    guides
    body
  },
)[
  #align(horizon)[
    + a
    #pause
    + b
    #meanwhile
    + c
    + d
  ]
][
  #meanwhile
  #align(horizon)[
    + a
    + b
    + c
    + d
  ]
]

== terms
#slide(
  composer: (1fr, 1fr),
  setting: body => {
    guides
    body
  },
)[
  #align(horizon)[
    / A: a
    #pause
    / B: b
    #meanwhile
    / C: c
    / D: d
  ]
][
  #meanwhile
  #align(horizon)[
    / A: a
    / B: b
    / C: c
    / D: d
  ]
]

// Same list case with a color-changing cover so the covered item b stays
// visible (grey) — makes it obvious that b keeps its slot and the below-gap
// to c is list-tight.
== list (color-changing cover)
#slide(
  composer: (1fr, 1fr),
  config: config-methods(cover: utils.color-changing-cover.with(color: gray)),
  setting: body => {
    guides
    body
  },
)[
  #align(horizon)[
    - a
    #pause
    - b
    #meanwhile
    - c
    - d
  ]
][
  #meanwhile
  #align(horizon)[
    - a
    - b
    - c
    - d
  ]
]
