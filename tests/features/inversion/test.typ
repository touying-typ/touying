#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Animations with Range Inversion

== Simple inversion

Part A.
#pause
Part B.
#pause
Part C.

#only("!3")[During A and B]

== Range inversion

Part A.
#pause
Part B.
#pause
Part C.

#only("!2-3")[During A.]

== here inversion
Part A.
#pause
#only("!h")[Not B.]
#pause
Part C.
