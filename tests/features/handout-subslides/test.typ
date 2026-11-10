#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(handout: true),
)

== Slide with Handout Subslides

// Slide 2: specify handout subslides via per-slide config
#slide(config: config-common(handout-subslides: 2))[
  #only(1)[Subslide 1 content.]

  #only(2)[Subslide 2 content (this should appear in handout).]

  #only(3)[Subslide 3 content (this should NOT appear in handout).]
]

== Multiple Handout Subslides

// Slide 3: multiple handout subslides (renders subslides 1 and 3)
#slide(config: config-common(handout-subslides: (1, 3)))[
  #only(1)[Subslide 1 content (should appear in handout).]

  #only(2)[Subslide 2 content (should NOT appear in handout).]

  #only(3)[Subslide 3 content (should appear in handout).]
]

== Handout Subslides with String Notation

// Slide 4: handout-subslides with string notation
#slide(config: config-common(handout-subslides: "2-"))[
  #only(1)[Subslide 1 content (should NOT appear in handout).]

  #only(2)[Subslide 2 content (should appear in handout).]

  #only(3)[Subslide 3 content (should appear in handout).]
]


== Negative Handout Subslide Indices
// Slide 5: negative handout subslide indices (should render subslides 2 and 3)
#slide(config: config-common(handout-subslides: (-2, -1)))[
  #only(1)[Subslide 1 content (should NOT appear in handout).]

  #only(2)[Subslide 2 content (should appear in handout).]

  #only(3)[Subslide 3 content (should appear in handout).]
]

== Handout Subslides: Last of Every Waypoint
// "waypoints" keeps one page per waypoint, each at the last subslide of that
// waypoint: three pages here, growing from "Intro" to "Wrap-up". The pause
// inside "Intro" is skipped, since its first half is not a waypoint's end.
#slide(config: config-common(handout-subslides: "waypoints"))[
  #waypoint(<intro>)
  Intro.

  #pause
  Intro, second half.

  #waypoint(<main>)
  Main point.

  #waypoint(<end>)
  Wrap-up.
]

== Handout Subslides: Waypoints Mixed With Indices
// "waypoints" works as one element of an array, next to plain indices: the
// first subslide, which precedes both waypoints and is empty, plus the last
// subslide of each waypoint.
#slide(config: config-common(handout-subslides: (1, "waypoints")))[
  #waypoint(<first>)
  First waypoint.

  #waypoint(<second>)
  Second waypoint.
]

== Handout Subslides: Waypoints Without Any Waypoint
// A slide without waypoints has nothing to choose between, so it falls back
// to its last subslide, like the default handout.
#slide(config: config-common(handout-subslides: "waypoints"))[
  #only(1)[Subslide 1 content (should NOT appear in handout).]

  #only(2)[Subslide 2 content (should appear in handout).]
]

== Handout Subslides: Waypoint Labels and Markers
// Each waypoint spans two subslides here: <intro> 2-3, <main> 4-5, <end> 6-7.
// A label is one page, the last subslide of its waypoint (3); `get-first` is
// the first one (4); and `not-wp(not-wp(..))` keeps every subslide of exactly
// one waypoint (6 and 7), since a range marker keeps all it spans.
#slide(
  config: config-common(handout-subslides: (
    <intro>,
    get-first(<main>),
    not-wp(not-wp(<end>)),
  )),
)[
  #waypoint(<intro>)
  Intro.

  #pause
  Intro, second half.

  #waypoint(<main>)
  Main.

  #pause
  Main, second half.

  #waypoint(<end>)
  End.

  #pause
  End, second half.
]

== Handout Subslides: A Single Waypoint
// A waypoint can be given without an array: one page, the last subslide of it.
#slide(config: config-common(handout-subslides: <intro>))[
  #waypoint(<intro>)
  Intro.

  #pause
  Intro, second half.

  #waypoint(<main>)
  Main.
]
