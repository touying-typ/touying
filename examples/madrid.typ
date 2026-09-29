#import "/lib.typ": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "16-9",
  navigation-symbols: true,
  config-info(
    title: [Full Title of the Talk],
    short-title: [Short title],
    author: [John Smith],
    short-author: [John Smith (NU)],
    date: datetime(year: 2020, month: 6, day: 23),
    short-date: [2020.6.23],
    institution: [Name of University \ #text(style: "italic", size: 0.9em)[name\@email.com]],
  ),
)

#title-slide()

#outline-slide()

= First Section

== Paragraphs of Text

This is paragraphs of text. The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog. The quick brown fox jumps over
the lazy dog. The quick brown fox jumps over the lazy dog.

The quick brown fox jumps over the lazy dog. The quick brown fox jumps over
the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown
fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.

== Lists

+ This is an enumerate environment.
+ This is an enumerate environment.
+ This is an enumerate environment.

#v(1em)

#item-by-item-fn((time, it) => if time == 0 {
  text(fill: rgb("#cc0000"), it)
} else { it })[
  - This is an itemize environment.
  - This is an itemize environment.
  - This is an itemize environment.
]

== Blocks of Highlighted Text

#cblock(title: [Block Title])[
  This is the block environment. The quick brown fox jumps over the lazy dog.
  The quick brown fox jumps over the lazy dog.
]

#example-block(title: [Block Title])[
  This is the exampleblock environment. The quick brown fox jumps over the lazy dog.
  The quick brown fox jumps over the lazy dog.
]

#alert-block(title: [Block Title])[
  This is the alertblock environment. The quick brown fox jumps over the lazy dog.
  The quick brown fox jumps over the lazy dog.
]

== Multiple Columns

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    This is text in the first column.

    $ E = m c^2 $

    - First item
    - Second item
  ],
  [
    This text will be in the second column and on a second thought this is
    a nice looking layout in some cases.
  ],
)

= Second Section

== Theorems

#cblock(title: [Definition])[
  This is a definition environment.
]

#cblock(title: [Theorem (Mass-energy)])[
  This is a theorem environment.
  $ E = m c^2 $
]

#cblock(title: [Proof])[
  #text(style: "italic")[Proof:] It follows from special relativity. #h(1fr) $square$
]

== Formula and Table

This is the Pythagorean theorem:
$ a^2 + b^2 = c^2 $

This is a simple three-line table:

#align(center)[
  #table(
    columns: 3,
    stroke: none,
    table.hline(stroke: 1.2pt),
    [Treatments], [Response 1], [Response 2],
    table.hline(stroke: 0.6pt),
    [Treatment 1], [0.0003262], [0.562],
    [Treatment 2], [0.0015681], [0.910],
    [Treatment 3], [0.0009271], [0.296],
    table.hline(stroke: 1.2pt),
  )
]

== Verbatim

Here is Typst code demonstrating the Madrid block syntax:

````typst
#cblock(title: [Mass-energy equivalence])[
  $ E = m c^2 $
]
````

= Third Section

== Slide with Animations

Madrid theme fully supports Touying animations:

#pause

First point appears now.

#pause

Second point appears later.

#speaker-note[
  - Speaker notes are supported in Madrid theme!
  - Compatible with Touying 0.8.0 second-screen and pdfpc export.
]

#focus-slide[
  Thank you!
]
