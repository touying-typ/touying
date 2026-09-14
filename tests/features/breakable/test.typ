#import "/lib.typ": *
#import themes.simple: *

// Test breakable: false — content should not overflow to the next slide.
// When breakable is false, each slide uses a non-breakable block so that
// overflowing content is constrained rather than creating an additional page.
//
// This also covers `detect-overflow`, which only runs on this path: with
// `breakable: true` there is no fixed slide height to measure against, so the
// default `auto` stays quiet there. Both axes are checked. The warnings are
// not assertable (tytanic does not fail on them), so the slides below exist to
// keep the detection code exercised and to catch a false positive on the width
// axis — `#lorem(200)` reflows and must never be reported as too wide.

#show: simple-theme.with(
  config-common(breakable: false),
)

= Breakable False

== Slide That Should Not Overflow

#lorem(200)


== Breakable False with Clip True

#show: touying-set-config.with(config-common(clip: true))

#lorem(200)


== Width Overflow

// Too wide to fit and unable to reflow, so it is reported on the width axis.
// Kept short enough not to also overflow in height, so the two are separable.
#block(width: 900pt, height: 30pt, fill: aqua)[Wider than the slide]
