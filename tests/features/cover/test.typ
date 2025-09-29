#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme
#set figure(numbering: none)

= Cover & Overlay Tests

== Semi-transparent Cover

Regular content here.

#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))

#pause

This content appears with semi-transparent cover effect.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More content with the same effect.

== Default Cover Behavior

#show: touying-set-config.with(config-methods(
  cover: utils.method-wrapper(hide),
))

Content that gets hidden completely when covered.

#pause

New content replaces the old content entirely.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

== Color Changing Cover

Regular content here.

#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(color: gray),
))

#pause

This text should appear in gray when covered.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More text with gray cover effect.

== Alpha Changing Cover

Regular content here.

#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover.with(alpha: 25%),
))

#pause

This text should appear semi-transparent when covered.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More semi-transparent text.
