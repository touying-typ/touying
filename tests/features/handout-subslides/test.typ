#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(handout: true),
)

= Handout Subslides Test

// Slide 1: default handout (shows last subslide)
== Default Handout Slide

Subslide 1 content.

#pause

Subslide 2 content (this should appear in handout).

// Slide 2: specify handout subslides via per-slide config
#slide(config: config-common(handout-subslides: 2))[
  Subslide 1 content.

  #pause

  Subslide 2 content (this should appear in handout).

  #pause

  Subslide 3 content (this should NOT appear in handout).
]

// Slide 3: multiple handout subslides (renders subslides 1 and 3)
#slide(config: config-common(handout-subslides: (1, 3)))[
  Subslide 1 content (should appear in handout).

  #pause

  Subslide 2 content (should NOT appear in handout).

  #pause

  Subslide 3 content (should appear in handout).
]

// Slide 4: handout-subslides with string notation
#slide(config: config-common(handout-subslides: "2-"))[
  Subslide 1 content (should NOT appear in handout).

  #pause

  Subslide 2 content (should appear in handout).

  #pause

  Subslide 3 content (should appear in handout).
]
