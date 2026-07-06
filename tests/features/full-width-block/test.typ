#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(breakable: false),
  footer-right: none,
)

= Full-Width Block

== Basic: full-width-block spans page width

// The blue bar should extend to both edges of the page,
// ignoring the slide's horizontal margins.
#components.full-width-block(fill: blue, height: 1em)[]

Some content below the bar.

// The bar should contain text and still span the full page width.
#components.full-width-block(fill: luma(220), inset: .5em)[
  This text is inside a full-width block.
]

Some content below.

#components.full-width-block(fill: red, height: 4pt)[]

Normal indented content here.

#components.full-width-block(fill: blue, height: 4pt)[]
