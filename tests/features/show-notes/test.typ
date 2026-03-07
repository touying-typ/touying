#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(show-notes: true))

= Show Notes Tests

== Full-Screen Speaker Notes

This slide has speaker notes that appear as the main content with the slide as a thumbnail.

#speaker-note[
  + This is the first speaker note point
  + Remember to explain the concept clearly
  + Don't forget to mention the example
]

Regular slide content is shown as a thumbnail in the top right.

== No Notes Slide

This slide has no speaker notes.

== Animated Slide With Notes

Content before animation.

#pause

#speaker-note[
  Explain what happens after the pause.
]

Content after animation pause.
