// Issue: meanwhile does not work in grids
// https://github.com/touying-typ/touying/issues/259

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== Grid with meanwhile

#grid(columns: 2, gutter: 1em)[
  Hello

  #pause

  world
][
  #meanwhile
  this should always show up
]

== Box with meanwhile

#box[
  left

  #pause

  l1
]
#box[
  #meanwhile
  right
]
