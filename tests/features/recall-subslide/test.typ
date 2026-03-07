#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none)
)

== Animated Slide <animated>

Step 1 #pause Step 2 #pause Step 3

== Recall all (default):

#touying-recall(<animated>)

== Recall subslide 1:

#touying-recall(<animated>, subslide: 1)

== Recall subslide 2:

#touying-recall(<animated>, subslide: 2)

== Recall subslide 3:

#touying-recall(<animated>, subslide: 3)
