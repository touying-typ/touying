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
//
// `scale` is the reason this went unnoticed: since Typst 0.15 it has no
// `factor` field at all, only the resolved named `x`/`y`, so the one element
// everybody reaches for when testing transforms happened to survive.
// `utils.positional-fields` now names the five, and `utils.reconstruct` leads
// with them.
//
// The naive fix — passing *every* field positionally instead — trades the bug
// for its mirror image, so the `box(width: …)` cases below pin the named side
// down as well.
//
// Compile-only: what's asserted is that the field survived the rebuild, i.e.
// that a covered element still aligns / sizes its body the way an uncovered
// one does.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let mark(name) = box(width: 0pt, height: 0pt)[#h(0pt)#label(name)]

// x of a marker on a given page. Each `cases(..)` block spans two subslides:
// the first renders everything covered, the second uncovered. The two must
// agree, since covering may recolour content but must never move it.
#let x-on(name, page) = {
  query(label(name))
    .filter(m => m.location().page() == page)
    .first()
    .location()
    .position()
    .x
}

#let same-on-both(name, pages) = {
  let (covered, shown) = pages.map(page => x-on(name, page))
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

#let further-right(a, b, pages) = {
  for page in pages {
    assert(
      x-on(a, page) > x-on(b, page),
      message: (
        a
          + " should sit right of "
          + b
          + " on page "
          + str(page)
          + " ("
          + repr(x-on(a, page))
          + " vs "
          + repr(x-on(b, page))
          + ")"
      ),
    )
  }
}

#let cases(prefix) = [
  #uncover("2-")[#align(center)[c#mark(prefix + "-align-center")]]

  #uncover("2-")[#align(left)[l#mark(prefix + "-align-left")]]

  #uncover("2-")[#place(top + right)[r#mark(prefix + "-place-right")]]

  #uncover("2-")[#place(top + left)[l#mark(prefix + "-place-left")]]

  #uncover("2-")[#columns(2)[c#mark(prefix + "-columns")]]

  #uncover("2-")[#rotate(0deg)[r#mark(prefix + "-rotate")]]

  #uncover("2-")[#link("https://typst.app")[t#mark(prefix + "-link")]]

  // The named-argument side of the same code path: a `box` takes its width by
  // name, so a fix that passed all fields positionally would lose it here.
  #uncover("2-")[#box(width: 100pt)[]]#mark(prefix + "-box-wide")

  #uncover("2-")[#box(width: 10pt)[]]#mark(prefix + "-box-narrow")
]

#let check(prefix) = context {
  // The two subslides this block landed on, read off the marks themselves
  // rather than assumed, so the test survives a change in slide numbering.
  let pages = query(label(prefix + "-align-center")).map(m => (
    m.location().page()
  ))
  assert.eq(pages.len(), 2, message: prefix + ": expected two subslides")
  for name in (
    "align-center",
    "align-left",
    "place-right",
    "place-left",
    "columns",
    "rotate",
    "link",
    "box-wide",
    "box-narrow",
  ) {
    same-on-both(prefix + "-" + name, pages)
  }
  further-right(prefix + "-align-center", prefix + "-align-left", pages)
  further-right(prefix + "-place-right", prefix + "-place-left", pages)
  further-right(prefix + "-box-wide", prefix + "-box-narrow", pages)
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
