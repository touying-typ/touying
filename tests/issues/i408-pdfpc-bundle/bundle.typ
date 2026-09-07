// Regression test for https://github.com/touying-typ/touying/issues/408.
// A bundle export writes one `.pdfpc` file per presentation, and each of them
// must contain that presentation's speaker notes and pdfpc configuration only -
// nothing from the other presentations of the same bundle.
//
// tytanic drives paged compilations only, so this file is not a tytanic test
// but is compiled by CI (see .github/workflows/test.yml) with
//
//   typst compile --features bundle --format bundle --root . \
//     tests/issues/i408-pdfpc-bundle/bundle.typ <outdir>
//
// The assertions at the bottom are the test; the workflow additionally checks
// that the two `.pdfpc` assets were written next to their PDFs and that neither
// of them mentions the other deck.

#import "/lib.typ": *
#import themes.simple: *

#pdfpc.bundle-assets()

#document(
  "slides-a.pdf",
  [
    #show: simple-theme

    #pdfpc.config(duration-minutes: 30)

    == Deck A - First
    #speaker-note[Note A1]

    == Deck A - Second
    #speaker-note[Note A2]
  ],
)

#document(
  "decks/slides-b.pdf",
  [
    #show: simple-theme

    == Deck B - Only
    #speaker-note[Note B1]
  ],
)

#context {
  let notes-of(pdfpc-file) = pdfpc-file
    .pages
    .map(page => page.at("note", default: none))
    .filter(note => note != none)

  // One assembled pdfpc file per presentation, in bundle order.
  let pdfpc-files = query(<pdfpc-file>).map(it => it.value)
  assert.eq(pdfpc-files.len(), 2)
  let (deck-a, deck-b) = pdfpc-files

  // The heart of #408: with an unscoped `query(<pdfpc>)`, both files listed all
  // three notes, because introspection observes the whole bundle.
  assert.eq(notes-of(deck-a), ("Note A1", "Note A2"))
  assert.eq(notes-of(deck-b), ("Note B1",))

  // Physical page indices and logical slide labels have to be relative to the
  // presentation the file describes. `idx` follows the physical page, which
  // restarts per document, while `label` follows touying's slide counter,
  // which does not - deck B's first slide used to be labelled "4".
  assert.eq(
    deck-a.pages.map(page => (page.idx, page.label)),
    ((0, "1"), (1, "2"), (2, "3")),
  )
  assert.eq(deck-b.pages.map(page => (page.idx, page.label)), ((0, "1"),))

  // Configuration must not bleed across presentations either.
  assert.eq(deck-a.duration, 30)
  assert(
    "duration" not in deck-b,
    message: "deck A's duration leaked into deck B",
  )
}
