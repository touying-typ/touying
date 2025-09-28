#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Layout & Composition

== Side-by-side

#slide[
  First column.
][
  Second column.
]

== Three columns

#slide(composer: (1fr, 2fr, 1fr))[
  Left column.
][
  Middle column with more space.
][
  Right column.
]

== 2 Plus 1

#slide(composer: (1fr, 1fr))[
  Wider left column.
][
  Narrower right column.
][#grid.cell(colspan: 2)[
  #v(1fr)
  #lorem(20)
]]

