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
