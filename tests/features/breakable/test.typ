#import "/lib.typ": *
#import themes.simple: *

// Test breakable: false — content should not overflow to the next slide.
// When breakable is false, each slide uses a non-breakable block so that
// overflowing content is constrained rather than creating an additional page.

#show: simple-theme.with(
  config-common(breakable: false),
)

= Breakable False

== Slide That Should Not Overflow

#lorem(200)


== Breakable False with Clip True

#show: touying-set-config.with(config-common(clip: true))

#lorem(200)

