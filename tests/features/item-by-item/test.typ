#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Item-by-Item Animations

== List item-by-item (start: 1)

#item-by-item[
  - first
  - second
  - third
]

== List item-by-item (start: 2)

#item-by-item(start: 2)[
  - first
  - second
  - third
]

== Enum item-by-item

#item-by-item[
  + first
  + second
  + third
]

== Terms item-by-item

#item-by-item[
  / Term 1: description one
  / Term 2: description two
  / Term 3: description three
]

== Nested list item-by-item

#item-by-item[
  - first
  - second
    - sub-item a
    - sub-item b
  - third
]
