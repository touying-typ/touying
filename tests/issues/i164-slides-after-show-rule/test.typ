// Issue: slides after table not rendering
// https://github.com/touying-typ/touying/issues/164

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Section

== First Slide

#set text(red)
test
#set text(black)

== I Should Be Rendered

This slide should render.
