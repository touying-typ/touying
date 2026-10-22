// Regression test for https://github.com/touying-typ/touying/issues/450.
// Displayed equations stay centered as pause and item-by-item reveal list items.
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

== Display equation inside item-by-item

#item-by-item[
  - First item
  - Second item contains a displayed equation:
    $
      a + b = c
    $
  - Third item
]
