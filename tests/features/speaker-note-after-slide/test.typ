#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(show-notes-on-second-screen: right))

= Speaker Note After Slide

== Basic: slide followed by speaker-note

#slide[Slide content here]

#speaker-note[
  This note should attach to the previous slide, not create a new one.
]

== Pause: slide with pause followed by speaker-note

#slide[
  Before pause

  #pause

  After pause
]

#speaker-note[
  Notes for the slide with pause.
]

== Multiple: slide followed by multiple speaker-notes

#slide[Multiple notes test]

#speaker-note[First note]
#speaker-note[Second note]

== Normal: inline speaker-note still works

Normal content with inline note.

#speaker-note[This is an inline note on a normal slide.]

More content here.
