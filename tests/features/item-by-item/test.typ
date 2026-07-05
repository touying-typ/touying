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

== Item-by-item functions

#slide[
  #item-by-item-fn(none)[
    - first
    - second
    - third
  ]
][
  #meanwhile

  #item-by-item-fn("current-bold")[
    - second
    - third
  ]
][
  #meanwhile

  #item-by-item-fn("current-highlight")[
    + first
    + second
    + third
  ]
][
  #meanwhile

  #item-by-item-fn("past-faded")[
    / Term 1: one
    / Term 2: two
    / Term 3: three
  ]
][
  #meanwhile

  #item-by-item-fn("past-progressive-faded")[
    - first
    - second
      - item a
      - item b
    - third
  ]
][
  #meanwhile

  #item-by-item-fn(
    item-by-item-functions
      .at("past-progressive-faded")
      .with(alpha: (exponential: 40%)),
  )[
    - first
    - second
    - third
  ]
]

