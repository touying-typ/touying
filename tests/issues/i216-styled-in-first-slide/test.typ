// Issue: Special case for styled content on the first slide?
// https://github.com/touying-typ/touying/issues/216

#import "/lib.typ": *
#import themes.university: *
#show: university-theme

== Slide 1

first slide before styled
#[
  #set text(fill: red)
  first slide styled
]
first slide after styled
