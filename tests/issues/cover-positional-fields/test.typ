// Covering an element whose defining field is *positional* used to be a hard
// error.
//
// Both `color-changing-cover` and `alpha-changing-cover` rebuild content they
// cannot recolour in place: they take `it.fields()`, replace the body, and
// call the element function again. Every field went in as a *named* argument,
// which five built-ins reject outright, because their defining field is
// positional:
//
//   align   -> error: unexpected argument: alignment
//   place   -> error: unexpected argument: alignment
//   columns -> error: unexpected argument: count
//   rotate  -> error: unexpected argument: angle
//   link    -> error: expected string, dictionary, location, or label,
//              found content         (the body landed in `dest`)
//   math.class            -> error: expected "normal", …, found content
//   math.underbrace & co. -> error: unexpected argument: annotation
//   polygon / curve       -> error: unexpected argument: vertices/components
//
// `scale` is the reason this went unnoticed: since Typst 0.15 it has no
// `factor` field at all, only the resolved named `x`/`y`, so the one element
// everybody reaches for when testing transforms happened to survive.
//
// `utils.positional-fields` now names them all and `utils.call-with-fields`
// leads with them. Two of the entries are not plain field names: `polygon`
// and `curve` take their geometry *variadically*, and `math.underbrace(body,
// annotation)` takes the body positionally but not last — put the body at the
// end there and the brace and its annotation swap places.
//
// The naive fix — passing *every* field positionally instead — trades the bug
// for its mirror image. `box(width: …)` does not catch that (both cover
// methods have their own `box` branch and never reach the shared
// reconstruction), so the named side is pinned by `pad`, `move`,
// `place(dx: …)` and `quote(attribution: …)`, which do reach it and which all
// break the moment fields go in positionally.
//
// Compile-only: what's asserted is that the field survived the rebuild, i.e.
// that a covered element still aligns / sizes its body the way an uncovered
// one does.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let mark(name) = box(width: 0pt, height: 0pt)[#h(0pt)#label(name)]

// Every marker below is emitted exactly twice: once on the covered subslide
// and once on the uncovered one, in that order. Reading them by index rather
// than by page number keeps the assertions independent of how the cases
// happen to paginate.
#let both(name) = {
  let marks = query(label(name))
  assert.eq(
    marks.len(),
    2,
    message: name + ": expected one covered and one uncovered rendering",
  )
  marks.map(m => m.location().position().x)
}

// Covering may recolor content, but it must never move it.
#let same-on-both(name) = {
  let (covered, shown) = both(name)
  assert.eq(
    covered,
    shown,
    message: name
      + ": covering moved it ("
      + repr(covered)
      + " vs "
      + repr(
        shown,
      )
      + ")",
  )
}

#let further-right(a, b) = {
  let xs-a = both(a)
  let xs-b = both(b)
  for i in (0, 1) {
    assert(
      xs-a.at(i) > xs-b.at(i),
      message: (
        a
          + " should sit right of "
          + b
          + " ("
          + repr(xs-a.at(i))
          + " vs "
          + repr(xs-b.at(i))
          + ")"
      ),
    )
  }
}

// Two shapes of case. Where the element has a body, the marker goes *inside*
// it, so its x reports where the element put its body. Where it has none (or
// where the body is not the interesting part), the marker follows the element
// on the same line, so its x is the element's own width.
#let cases(prefix) = [
  #uncover("2-")[#align(center)[c#mark(prefix + "-align-center")]]

  #uncover("2-")[#align(left)[l#mark(prefix + "-align-left")]]

  #uncover("2-")[#place(top + right)[r#mark(prefix + "-place-right")]]

  #uncover("2-")[#place(top + left)[l#mark(prefix + "-place-left")]]

  #uncover("2-")[#columns(2)[c#mark(prefix + "-columns")]]

  #uncover("2-")[#rotate(0deg)[r#mark(prefix + "-rotate")]]

  #uncover("2-")[#link("https://typst.app")[t#mark(prefix + "-link")]]

  // Variadic geometry: rebuilt without spreading, these error outright.
  #uncover("2-")[#polygon((0pt, 0pt), (30pt, 0pt), (15pt, 10pt))]#mark(
    prefix + "-polygon",
  )

  #uncover("2-")[#curve(curve.line((40pt, 10pt)))]#mark(prefix + "-curve")

  // A body that is positional but not last. Deliberately lopsided: swap the
  // brace's body and its annotation and the width changes.
  #uncover("2-")[#math.underbrace([wwwwwwwwww], [i])]#mark(
    prefix + "-underbrace",
  )

  #uncover("2-")[#math.class("unary", [u])]#mark(prefix + "-math-class")

  // The named-argument side of the same code path. A fix that passed all
  // fields positionally would lose the width, the offsets and the attribution
  // — `box` would not notice, since both cover methods handle it themselves
  // before the shared reconstruction is reached.
  #pagebreak()

  #uncover("2-")[#box(width: 100pt)[]]#mark(prefix + "-box-wide")

  #uncover("2-")[#box(width: 10pt)[]]#mark(prefix + "-box-narrow")

  #uncover("2-")[#pad(left: 40pt)[p]]#mark(prefix + "-pad")

  #uncover("2-")[#move(dx: 30pt)[m]]#mark(prefix + "-move")

  // `place` without an alignment: the positional field is simply absent, and
  // must be skipped rather than passed as `none`.
  #uncover("2-")[#place(dx: 25pt)[d#mark(prefix + "-place-dx")]]

  #uncover("2-")[#quote(block: false, attribution: [someone])[q]]#mark(
    prefix + "-quote",
  )
]

#let check(prefix) = context {
  for name in (
    "align-center",
    "align-left",
    "place-right",
    "place-left",
    "place-dx",
    "columns",
    "rotate",
    "link",
    "polygon",
    "curve",
    "underbrace",
    "math-class",
    "box-wide",
    "box-narrow",
    "pad",
    "move",
  ) {
    same-on-both(prefix + "-" + name)
  }
  // `quote` is checked for presence only. Covering it shifts it by ~0.6pt,
  // with or without an attribution: the rebuilt body is re-wrapped in a
  // `text(..)` node, which changes how the quotation marks lay out. That is a
  // cover artifact of its own and has nothing to do with the fields — what
  // matters here is that `quote(attribution: ..)` rebuilds at all, since it
  // is one of the elements a fields-as-positionals "fix" would break.
  let _ = both(prefix + "-quote")
  further-right(prefix + "-align-center", prefix + "-align-left")
  further-right(prefix + "-place-right", prefix + "-place-left")
  further-right(prefix + "-box-wide", prefix + "-box-narrow")
}

== alpha-changing-cover
#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover,
))

#cases("alpha")
#check("alpha")

== color-changing-cover
#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover,
))

#cases("color")
#check("color")
