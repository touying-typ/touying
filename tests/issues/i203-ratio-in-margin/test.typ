// Issue: ratio in margin
// https://github.com/touying-typ/touying/issues/203

#import "/lib.typ": *
#import "@preview/cetz:0.4.1"
#import themes.university: *

#show: university-theme.with(
  config-page(
    margin: (top: 2.25em, bottom: 1em, x: (100% - 30em) / 2),
  ),
)

= Title

== Subtitle

Content
