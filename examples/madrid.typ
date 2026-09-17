#import "/lib.typ": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Madrid Theme in Touying],
    subtitle: [A Typst Port of the Classic Beamer Madrid Theme],
    author: [Author Name],
    date: datetime.today(),
    institution: [University or Institution],
  ),
)

#title-slide()

= First Section

== First Slide

- First item with 3D Beamer ball
- Second item
  - Nested sub-item
- Third item

#cblock(title: [Standard Block])[
  This is a block styled like LaTeX Beamer's Madrid theme.
]

#alert-block(title: [Alert Block])[
  This is an alert block with Madrid red accent colors.
]

#example-block(title: [Example Block])[
  This is an example block with green styling.
]

== Dynamic Slide

Slide with animations:

#pause

First point appears now.

#pause

Second point appears later.

#focus-slide[
  Wake up!
]
