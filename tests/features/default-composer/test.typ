#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(
    default-composer: components.side-by-side.with(gutter: 3em),
  ),
)

= Default Composer

== Custom gutter via default-composer

#slide[
  First column with 3em gutter.
][
  Second column with 3em gutter.
]

== Override default-composer per slide

#slide(composer: components.side-by-side.with(gutter: 0.5em))[
  Overridden gutter (0.5em).
][
  Second column.
]

== Single column still works

#slide[
  Single column slide.
]
