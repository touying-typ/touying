// Mode markers wrap a slide *call*, they do not go inside its body.
//
//   #slides-only(title-slide[..])    // correct
//   #title-slide[#slides-only[..]]   // panics: Unsupported mark
//
// A slide function hands touying a description of a slide and captures its
// body in a closure; the body is rendered later, from inside the slide, well
// past the walk over the document body that consumes these marks. `#pause` is
// unaffected — that one is read by the parser, which does look inside a slide
// body — which is exactly why the failure is so surprising when you meet it.
//
// The panic used to end with "You may want to use the callback-style
// `utils.none` function instead", because these marks carry no function and
// the message interpolated `repr(none)`. `utils.unsupported-mark-message` now
// splits the two cases.
//
// This pins the documented pattern (docs/en/tutorials/dynamic/handout.md,
// "Around a Slide, Not Inside It") rather than the panic: the marker must
// suppress the whole slide in article mode and keep it in slides mode.
//
// Compile-only: what's asserted is which content reached the output.

#import "../../../lib.typ": *
#import themes.simple: *

#let render(export-mode) = [
  #show: simple-theme.with(config-common(
    export-mode: export-mode,
    new-section-slide-fn: none,
  ))

  #slides-only(title-slide[Deck only #label("deck-only")])

  == A Section
  Ordinary content. #label("ordinary")

  #context {
    let slides = export-mode != "article"
    assert.eq(
      query(<deck-only>).len(),
      if slides { 1 } else { 0 },
      message: (
        "slides-only(title-slide[..]) in "
          + export-mode
          + " mode: wrong number of occurrences"
      ),
    )
    assert.eq(query(<ordinary>).len(), 1)
  }
]
