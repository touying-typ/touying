#import "/lib.typ": *
#import themes.simple: *

// Test handout-only inline content (handout mode ON)
#show: simple-theme.with(
  config-common(handout: true),
)

== Regular Slide

This content should always be visible.

#handout-only[This content should only be visible in handout mode.]

== Handout Only Slide <touying:handout>

This entire slide is only visible in handout mode.
