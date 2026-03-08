#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

// -----------------------------------------------
// Test 1: Explicit waypoint animation (2 subslides)
// -----------------------------------------------

== Explicit Waypoints <wp-anim>

Always visible.

#waypoint(<reveal>)

#uncover(<reveal>)[Revealed after waypoint.]

// -----------------------------------------------
// Test 2: Recall the waypoint slide (all subslides)
// -----------------------------------------------

== Recall All

#touying-recall(<wp-anim>)

// -----------------------------------------------
// Test 3: Recall specific subslide
// -----------------------------------------------

== Recall Subslide 2

#touying-recall(<wp-anim>, subslide: 2)

// -----------------------------------------------
// Test 4: Multiple waypoints — 3 subslides expected
// -----------------------------------------------

== Multiple Waypoints

Start content.

#waypoint(<first>)

First phase.

#waypoint(<second>)

Second phase.

#only(<first>)[Only during first.]

#only(<second>)[Only during second.]

// -----------------------------------------------
// Test 5: Implicit waypoint animation
// -----------------------------------------------

== Implicit

Always visible.

#uncover(<imp>)[Implicit waypoint content.]

// -----------------------------------------------
// Test 6: Waypoint with touying-equation
// -----------------------------------------------

== Equation With Waypoint

Intro.

#waypoint(<eq-step>)

$
  f(x) & = pause x^2 + 2x + 1 \
       & = pause (x + 1)^2 \
$

#uncover(<eq-step>)[Equation explanation.]

