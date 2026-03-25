#import "../../../lib.typ": *


#import themes.dual: *
#import themes.simple: simple-theme
#import themes.document: document-theme

#import "@preview/edgeframe:0.3.0": ef-document

#show: dual-theme.with(
  slide-theme: simple-theme,
  // document-theme: ef-document, //numbering: "1.1"
  document-theme: document-theme.with(numbering: "1.1"),
  config-common(
    export-mode: "document",
    handout: true,
    show-hide-set-list-marker-none: true,
  ),
  config-info(
    title: [Document Mode Test],
    author: [Test Author],
    subtitle: [Testing Touying's Document Mode],
    date: datetime.today(),
  ),
  config-document(
    wrap-images: true, 
    wrap-image-figures: true
  ),
)

// #import themes.simple: *
// #show: simple-theme.with(
//   config-common(
//     show-hide-set-list-marker-none: true,
//   ),
//   config-info(
//     title: [Document Mode Test],
//   )
// )

= Introduction

This is the introduction section. Content should flow continuously without page breaks between slides. #lorem(30)

== Background

Some background information here. #lorem(20)

=== Details

More detailed information. #lorem(15)

== With Pause

First part of the content. #lorem(10)

#pause

Second part — in document mode this should appear directly (no animation). #lorem(10)

== With Explicit Slide
#slide[
  This content is inside an explicit `slide` call.
  It should render inline in the document. #lorem(15)
]

== With Uncover

#uncover("2-")[This text uses uncover — should be visible in document mode.]

Normal text after uncover. #lorem(20)

== Multi-body Slide

#slide(composer: (1fr, 1fr))[
  Left column content in the slide. #lorem(15)
][
  Right column content — should be linearized in document mode. #lorem(10)
]

== With Only

#only("2-")[This text uses only — should be visible in document mode.]

More text here. #lorem(15)

== Lists and Items

- First item
- Second item
- Third item

+ Numbered one
+ Numbered two
+ Numbered three

#lorem(20)

== Image Content
#slide(composer: (1fr, 1fr))[
  Here is some text alongside an image. The image should be wrapped to the side in document mode when
  
   `wrap-images` is enabled. #lorem(80)
][
  #image("./image.png", width: 80%)<my-img>
]

== Animated CeTZ Canvas

//import and bindings
#import "@preview/cetz:0.4.2"

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
//actual content

#lorem(25)
#cetz-canvas(label: "doc-test-diagram",{
  import cetz.draw: *
  rect((0, 0), (4, 3), fill: blue.lighten(80%), stroke: blue)
  (pause,)
  circle((2, 1.5), radius: 0.8, fill: red.lighten(60%), stroke: red)
  (pause,)
  line((0, 0), (4, 3), stroke: 2pt + green)
  (waypoint(<final>, advance:false),)
})

#document-text[

  The animated CeTZ diagram is recalled at specific stages below inside this document-text.

  Stage 1 (rectangle only):
  #touying-block-recall(<doc-test-diagram>, subslides: 1)

  Stage 2 (rectangle and circle):
  #touying-block-recall(
    <doc-test-diagram>,
    subslides: 2,
    supplement: [Graphic],
  )<fig:cetz-stage2>

  Final state (all elements):
  #touying-block-recall(<doc-test-diagram>, subslides:<final>)

  See @fig:cetz-stage2 for stage 2 of the animated diagram.

  Also see #touying-block-recall(<my-img>)
]

== Table Content

#slide(composer: (1fr, 1fr))[
  #table(
    columns: 2,
    [Header 1], [Header 2],
    [Cell 1], [Cell 2],
    [Cell 3], [Cell 4],
  )
][
  Some text next to the table. #lorem(15)
]

== Figure with Image

#slide(composer: (1fr, 1fr))[
  This section tests a figure containing an image. It should behave identically to a raw image — wrapped to the side via meander with text flowing around it. #lorem(40)
][
  #figure(
    image("./image.png", width: 80%),
    caption: [A test figure with an image.],
  )
]

== Figure with Table

#slide(composer: (1fr, 1fr))[
  #figure(
    table(
      columns: 3,
      [A], [B], [C],
      [1], [2], [3],
      [4], [5], [6],
    ),
    caption: [A table inside a figure.],
  )
][
  This tests a figure wrapping a table. It should be centered at the end of the subsection, just like a bare table. #lorem(20)
]

== Document Text

#slide[
  - Key finding A
  - Key finding B
  - Key finding C
]

#document-text[
  This prose only appears in document mode. It replaces the terse bullet points
  in the slides with a longer discussion suitable for a written report. #lorem(30)

  #figure(
    image("./image.png", width: 60%),
    caption: [A placed figure inside document-text.],
    placement: top,
  )

  #lorem(40)
]

== Slide/Presentation/Handout-Only Content

#slides-only[
  _This content only appears in the presentation or handout, not in the document._
]

#presentation-only[
  _This content only appears during the live presentation, not in handouts._
]

#handout-only[
  _This content only appears in handouts, not during the live presentation._
]

Some text visible in all modes. Above we have content only in slides,presentation, or handout.

== Document-Only Content
Next section is only visible in document mode, hidden in slides (presentation and handout).
#document-only[
  === Extended Methodology

  This methodology section only appears in the document output. It provides
  additional detail that would be too verbose for a presentation. #lorem(40)
]

== Document-Only Section via Label <touying:document>

This entire section only appears in document mode. It is hidden in both
presentation and handout modes. #lorem(20)

== Handout+Document Section <touying:handout-document>

This section appears in handout and document modes, but is hidden during
a live presentation. #lorem(15)

== Conclusion

This is the conclusion. The document should be continuous A4 with no slide boundaries. #lorem(30)
