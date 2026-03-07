#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(
    default-composer: components.side-by-side.with(gutter: 3em),
  ),
)

#set par(justify: true)

== Custom gutter via default-composer

#slide[
  First column with 3em gutter. #lorem(20)
][
  Second column with 3em gutter. #lorem(20)
]

== Override default-composer per slide

#slide(composer: components.side-by-side.with(gutter: 0.5em))[
  Overridden gutter (0.5em). #lorem(20)
][
  Second column. #lorem(20)
]
