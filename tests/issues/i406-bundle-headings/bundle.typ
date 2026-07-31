// Regression test for https://github.com/touying-typ/touying/issues/406.
// Headings from one document in a bundle must not leak into another.

#import "/lib.typ": *
#import themes.simple: *

#document(
  "slides-a.pdf",
  [
    #show: simple-theme

    == Deck A — First
    #context assert.eq(
      utils.current-heading(level: 2, hierachical: false).body,
      [Deck A — First],
    )
    This slide belongs to deck A.

    == Deck A — Second
    #context assert.eq(
      utils.current-heading(level: 2, hierachical: false).body,
      [Deck A — Second],
    )
    This slide also belongs to deck A.
  ],
)

#document(
  "slides-b.pdf",
  [
    #show: simple-theme

    == Deck B — First
    #context assert.eq(
      utils.current-heading(level: 2, hierachical: false).body,
      [Deck B — First],
    )
    This slide belongs to deck B.

    == Deck B — Second
    #context assert.eq(
      utils.current-heading(level: 2, hierachical: false).body,
      [Deck B — Second],
    )
    This slide also belongs to deck B.
  ],
)
