// The subject of this test is the pdfpc metadata, which is textual and never
// rendered, so the assertions below are the test and there are intentionally
// no `ref/*.png` images to compare against.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

// Note that this call is content itself, so - as with any content in front of
// the first heading - it opens a slide of its own, which is the first, empty
// page in the expected metadata below.
#pdfpc.config(duration-minutes: 30, last-minutes: 5)

== First

#speaker-note[First note]

== Second

Some content.

#pause

More content.

#speaker-note[Second note]

== Third

#pdfpc.hidden-slide
#pdfpc.end-slide

== Metadata

#context {
  let files = query(<pdfpc-file>)
  // The metadata is assembled once, in the preamble of the first slide.
  assert.eq(files.len(), 1)
  let pdfpc-file = files.first().value
  assert.eq(pdfpc-file.pdfpcFormat, 2)
  assert.eq(pdfpc-file.disableMarkdown, false)
  assert.eq(pdfpc-file.duration, 30)
  assert.eq(pdfpc-file.lastMinutes, 5)
  // `#pdfpc.end-slide` is on the fourth logical slide, `endSlide` is 0-based.
  assert.eq(pdfpc-file.endSlide, 3)
  assert.eq(
    pdfpc-file.pages,
    (
      (idx: 0, label: "1", overlay: 0, forcedOverlay: false, hidden: false),
      (
        idx: 1,
        label: "2",
        overlay: 0,
        forcedOverlay: false,
        hidden: false,
        note: "First note",
      ),
      // Both subslides of the paused slide share the logical slide label, the
      // second one being an overlay carrying the note.
      (idx: 2, label: "3", overlay: 0, forcedOverlay: false, hidden: false),
      (
        idx: 3,
        label: "3",
        overlay: 1,
        forcedOverlay: true,
        hidden: false,
        note: "Second note",
      ),
      (idx: 4, label: "4", overlay: 0, forcedOverlay: false, hidden: true),
      (idx: 5, label: "5", overlay: 0, forcedOverlay: false, hidden: false),
    ),
  )
}
