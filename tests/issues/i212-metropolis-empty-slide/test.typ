// Issue: metropolis heading on wrong slide bug
// https://github.com/touying-typ/touying/issues/212
// An empty slide (heading with no body content) should create its own page.
// Without the fix, "Second slide" heading appears on the "First Slide" page.

#import "/lib.typ": *
#import themes.metropolis: *

#show: metropolis-theme.with(aspect-ratio: "16-9")

= Title

== First Slide
#lorem(5)

== Second slide
