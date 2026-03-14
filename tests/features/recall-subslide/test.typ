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

== Recall subslide negative:

Recall the last subslide (via negative index):

#touying-recall(<animated>, subslide: -1)

== Slide with waypoints <wp-slide>

#waypoint(<phase-a>, advance: false)
Phase A content
#waypoint(<phase-b>)
Phase B content
#pause
More B content

== Recall auto (last subslide):
Recall only the last subslide.

#touying-recall(<animated>, subslide: auto)

#touying-recall(<wp-slide>, subslide: auto)

== Recall waypoints (last of each):
Recall the last subslide of each waypoint.

#touying-recall(<wp-slide>, subslide: "waypoints")

== Recall waypoint range:

Show only the subslides covered by `<phase-b>`:

#touying-recall(<wp-slide>, subslide: <phase-b>)

== Recall get-last:

Show only the last subslide of `<phase-b>`:

#touying-recall(<wp-slide>, subslide: get-last(<phase-b>))
