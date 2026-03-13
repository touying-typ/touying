#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Animations with `auto`, "h" (here)

== auto

Part A.
#pause
#only(auto)[Only at B.]
#pause
Part C.

== here

Part A.
#pause
#only("h")[Only here: at B.]
#pause
Part C.

== here with range backwards

Part A.
#pause
#only("-h")[Until here: at B.]
#pause
Part C.

== here with range forwards

//exactly like `pause` would behave
Part A.
#pause
#only("h-")[From here: at B.]
#pause
Part C.
