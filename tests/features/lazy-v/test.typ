#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Lazy Vspace

== Basic: lazy-layout with lazy-v

// The block should shrink to fit the content, not expand to the full page height.
// The 1fr lazy-v pushes content to the bottom within the measured block height.
#components.lazy-layout(
  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #components.lazy-v(1fr)
    Bottom of block.
  ],
)

== Basic: two blocks with lazy-v side by side (manual)

#components.lazy-layout(grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #components.lazy-v(1fr)
    Bottom left.
  ],

  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(20)
    #components.lazy-v(1fr)
    Bottom right.
  ],
))

== side-by-side with lazy-layout: true

// Both blocks should be the same height (matching the taller one),
// and the overall layout should NOT fill the entire page height.
#components.side-by-side(lazy-layout: true)[
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #components.lazy-v(1fr)
    Bottom left.
  ]
][
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(20)
    #components.lazy-v(1fr)
    Bottom right.
  ]
]


== side-by-side without lazy-layout (default)

// Default behaviour: lazy-layout is false, lazy-v markers are invisible.
#components.side-by-side[
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)

    Bottom left.
  ]
][
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(20)
    
    Bottom right.
  ]
]
