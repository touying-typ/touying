#import "/lib.typ": *
#import themes.metropolis: *

#set heading(numbering: "1.")

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-common(
    show-notes-on-second-screen: right,
    receive-body-for-new-section-slide-fn: false,
  ),
)

#outline-slide()

= First Section

#speaker-note[Notes for the first section slide]

== Slide One

Content on slide one.

= Second Section

#speaker-note[Notes for the second section]
#speaker-note[Additional notes for second section]

== Slide Two

Content on slide two.
