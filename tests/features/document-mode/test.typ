#import "/lib.typ": *
#import themes.document: *

#show: document-theme.with(
  config-info(
    title: [Document Mode Test],
    author: [Test Author],
  ),
  numbering: "1.1",
  wrap-images: true,
)

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
  Here is some text alongside an image. The image should be wrapped to the side in document mode when `wrap-images` is enabled. #lorem(40)
][
  #image("image.png", width: 40%)
]

== Animated CeTZ Canvas

#import "@preview/cetz:0.4.2"

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#slide[
  #cetz-canvas({
    import cetz.draw: *
    rect((0, 0), (4, 3), fill: blue.lighten(80%), stroke: blue)
    (pause,)
    circle((2, 1.5), radius: 0.8, fill: red.lighten(60%), stroke: red)
    (pause,)
    line((0, 0), (4, 3), stroke: 2pt + green)
  })
]

#lorem(25)

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

== Conclusion

This is the conclusion. The document should be continuous A4 with no slide boundaries. #lorem(30)
