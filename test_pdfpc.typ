#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
)

#title-slide[
  = My Title
  #pdfpc.speaker-note("Title note")
]

== Slide 1
Content 1

#pdfpc.speaker-note("Note for overlay 1")

#pause

Content 2

#pdfpc.speaker-note("Note for overlay 2 - last overlay")

== Slide 2
Content 3

#pdfpc.speaker-note("Note for slide 2")
