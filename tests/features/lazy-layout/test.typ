#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(footer-right: none)

= Lazy Vspace

== Basic: lazy-layout with lazy-v

// The block should shrink to fit the content, not expand to the full page height.
// The 1fr lazy-v pushes content to the bottom within the measured block height.
#lazy-layout(
  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #lazy-v(1fr)
    Bottom of block.
  ],
)

== Basic: two blocks with lazy-v side by side (manual)

#lazy-layout(grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #lazy-v(1fr)
    Bottom left.
  ],

  block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(20)
    #lazy-v(1fr)
    Bottom right.
  ],
))

== `cols` with lazy-layout: true

// Both blocks should be the same height (matching the taller one),
// and the overall layout should NOT fill the entire page height.
#cols(lazy-layout: true)[
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(10)
    #lazy-v(1fr)
    Bottom left.
  ]
][
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(20)
    #lazy-v(1fr)
    Bottom right.
  ]
]


== `cols` without lazy-layout (explicit false)

// Opt out of lazy-layout by passing lazy-layout: false.
// lazy-v markers are invisible and blocks are not height-equalized.
#cols(lazy-layout: false)[
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

== Mixed: cols with multi-blocks

// Left column: a single block with more text to be taller.
// Right column: two blocks, each with a lazy-v marker.
// Only the last lazy-v per x-column is activated, so the bottom block on the
// right expands to fill the remaining height, while the top block stays compact.
#cols[
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(30)
    #lazy-v(1fr)
    Bottom left.
  ]
][
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(5)
    #lazy-v(1fr)
    End of top block.
  ]
  #block(fill: luma(220), inset: .5em, radius: .2em, width: 100%)[
    #lorem(5)
    #lazy-v(1fr)
    Bottom right.
  ]
]

= Lazy Hspace

== Basic: lazy-layout with lazy-h (single block)

// The block should shrink to fit the content width, not expand to the full page width.
// The 1fr lazy-h pushes "Right." to the right edge within the measured block width.
#lazy-layout(
  direction: ltr,
  block(fill: luma(220), inset: .5em, radius: .2em, height: 2em)[
    Left. #lazy-h(1fr) Right.
  ],
)

== Basic: two blocks with lazy-h stacked (manual)

// Both blocks should be the same width (matching the wider one),
// and the overall layout should NOT fill the entire page width.
#lazy-layout(
  direction: ltr,
  stack(
    dir: ttb,
    spacing: 1em,
    block(fill: luma(220), inset: .5em, radius: .2em, height: 2em)[
      #lorem(3) #lazy-h(1fr) Right label.
    ],
    block(fill: luma(220), inset: .5em, radius: .2em, height: 2em)[
      #lorem(6) #lazy-h(1fr) Right label.
    ],
  ),
)
