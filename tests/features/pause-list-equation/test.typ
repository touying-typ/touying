// A displayed equation in a covered list item stays centered when revealed.
#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-methods(cover: utils.color-changing-cover.with(color: rgb("#999999"))),
)

== Display equation inside a paused list

- First item
#pause
- Second item contains a displayed equation:
  $
    a + b = c
  $
- Third item
