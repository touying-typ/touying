#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(handout: true)
)

= Handout Mode Test

== Slide with Animation

This is the first part.

#pause

This is the second part that should appear in handout.

#pause

This is the final part.

== Another Slide

Content that should all be visible in handout mode.

#pause

More content.