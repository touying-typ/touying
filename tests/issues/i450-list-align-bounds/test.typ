// Regression test for https://github.com/touying-typ/touying/issues/450.
// Covered list items keep the full alignment bounds as pause and item-by-item
// reveal displayed equations, and left-, centered- and right-aligned text.
#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-methods(cover: utils.color-changing-cover.with(color: rgb("#999999"))),
)

== Alignment bounds inside a paused list

- First item
#pause
- Second item contains aligned content:
  $
    a + b = c
  $
  #align(left)[Left-aligned text]
  #align(center)[Centered text]
  #align(right)[Right-aligned text]
- Third item

== Alignment bounds inside item-by-item

#item-by-item[
  - First item
  - Second item contains aligned content:
    $
      a + b = c
    $
    #align(left)[Left-aligned text]
    #align(center)[Centered text]
    #align(right)[Right-aligned text]
  - Third item
]
