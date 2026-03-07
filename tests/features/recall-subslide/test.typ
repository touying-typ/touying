#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

== Animated Slide <animated>

Step 1 #pause Step 2

== Recall all (default):

Recall the entire slide:

#touying-recall(<animated>)

== Recall subslide 2:

Recall only the second subslide:

#touying-recall(<animated>, subslide: 2)
