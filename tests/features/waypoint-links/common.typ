#import "/lib.typ": *
#import themes.simple: *

// A waypoint inside a labelled slide emits a link anchor named
// `<slideLabel.waypointLabel>`, so `#link` can reach a position in a slide's
// flow rather than only the slide itself. The anchor sits at the end of the
// content run the waypoint owns: up to the next waypoint, or the end of the
// slide.
//
// Compile-only in every mode: the property under test is which anchors exist
// and which page carries them, which assertions state directly.
//
// Which subslide carries the anchor depends on what the mode renders. With
// every subslide rendered it is the waypoint's own last one; when only some are
// rendered the anchor moves to the nearest rendered page that still carries the
// content, and is dropped when no rendered page does. Each mode's test asserts
// its own pages, so the three sit side by side here.

#let body = {
  [
    == One <s:one>

    A
    #waypoint(<more>)
    B
    #pause
    C
    #waypoint(<last>)
    D

    == Two <s:two>

    #link(label("s:one.more"))[back to more]
  ]
}

// The same waypoint name in different slides must not collide, an unlabelled
// slide must not error, and the raw waypoint label must never reach the
// document (it rides a `<touying-temporary-mark>`, which the parser strips).
#let reuse-body = {
  [
    == Unlabelled

    #waypoint(<shared>)
    X

    == Labelled A <s:a>

    #waypoint(<shared>)
    Y

    == Labelled B <s:b>

    #waypoint(<shared>)
    Z
  ]
}

#let assert-common() = {
  assert.eq(query(label("s:one.more")).len(), 1)
  assert.eq(query(label("s:one.last")).len(), 1)
  assert.eq(query(label("s:a.shared")).len(), 1)
  assert.eq(query(label("s:b.shared")).len(), 1)
  // No unique name exists without a slide label, so nothing is emitted.
  assert.eq(query(label("shared")).len(), 0)
  // The waypoint's own label is never leaked into the document.
  assert.eq(query(<more>).len(), 0)
}

#let page-of(name) = query(label(name)).first().location().page()
