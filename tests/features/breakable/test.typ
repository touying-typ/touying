#import "/lib.typ": *
#import themes.simple: *

// Test breakable: false — content should not overflow to the next slide.
// When breakable is false, each slide uses `page(..args, body)` instead of
// `set page(..args)` so that overflowing content is clipped rather than
// creating an additional page.

#show: simple-theme.with(
  config-common(breakable: false),
)

= Breakable False

== Slide That Should Not Overflow

#lorem(200)

