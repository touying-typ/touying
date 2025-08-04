#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(show-notes-on-second-screen: right))

= Speaker Notes Tests

== Basic Speaker Notes

This slide contains speaker notes that won't be visible in normal presentation mode.

#speaker-note[
  + This is the first speaker note point
  + Remember to explain the concept clearly
  + Don't forget to mention the example
]

Regular slide content continues here.

== Multiple Speaker Notes

First paragraph of content.

#speaker-note[
  First set of speaker notes for this section.
]

Second paragraph with more information.

#speaker-note[
  + Additional notes for the second part
  + Key points to emphasize
  + Transition to next slide
]

== Speaker Notes with Animation

Content before animation.

#pause

#speaker-note[
  Explain what happens after the pause.
]

Content after animation pause.

#meanwhile

Meanwhile content with its own speaker notes.

#speaker-note[
  Notes specific to the meanwhile content.
]