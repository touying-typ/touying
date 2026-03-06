// Issue: metropolis heading on wrong slide bug
// https://github.com/touying-typ/touying/issues/307

#import "/lib.typ": *
#import themes.metropolis: *

#show: metropolis-theme.with(aspect-ratio: "16-9")

= Title

== First Slide
#lorem(5)

== Second slide
