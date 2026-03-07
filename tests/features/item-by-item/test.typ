#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

== Item-by-item

#slide[
  #item-by-item[
    - first
    - second
    - third
  ]
][
  #meanwhile

  #item-by-item(start: 2)[
    - second
    - third
  ]
][
  #meanwhile

  #item-by-item[
    + first
    + second
    + third
  ]
][
  #meanwhile

  #item-by-item[
    / Term 1: one
    / Term 2: two
    / Term 3: three
  ]
][
  #meanwhile

  #item-by-item[
    - first
    - second
      - item a
      - item b
    - third
  ]
]

