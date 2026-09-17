// Layout stability of `item-by-item` across its subslides.
//
// Covering a list item must not cost the enclosing list that item's row, or
// everything after the list creeps upwards as items are revealed. The basic
// single-list cases are pinned in `features/item-by-item-spacing`; this test
// covers the shapes where deciding *whether* a covered item occupies a list
// row is not obvious: several lists in one call, kinds that change partway,
// nesting, interleaved non-item content, and spacing that is set rather than
// inherited.
//
// Compile-only: what is pinned is a position, not an appearance. Each scenario
// puts a marker after the animated content and asserts its y-position is the
// same on every subslide. `stable` reports the observed positions on failure,
// since the drift amount identifies which gap went missing.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let ys(lbl) = query(lbl).map(m => m.location().position().y)

// A marker must appear on every subslide (`count`) and never move between
// them. Both halves matter: a marker that appears once trivially never moves.
#let stable(lbl, count, name) = {
  let seen = ys(lbl)
  assert.eq(
    seen.len(),
    count,
    message: name
      + ": expected "
      + str(count)
      + " subslides, got "
      + repr(seen),
  )
  // Compare with a tolerance rather than exactly: resolving em-based spacing
  // through `context` accumulates float error, so two positions that are the
  // same to well past any visible precision can still differ in the last bits.
  let first = seen.first()
  assert(
    seen.all(y => calc.abs((y - first).pt()) < 0.001),
    message: name + " moved across subslides: " + repr(seen),
  )
}

// Several animated lists on one slide reveal in sequence, so a marker between
// them legitimately moves while a list *below* it is still growing: only the
// last subslide is fully revealed. What must hold there is that the finished
// layout equals the one the same content has with no animation at all.
#let settles-to(lbl, expected, name) = {
  let seen = ys(lbl).last()
  assert(
    calc.abs((seen - expected).pt()) < 0.001,
    message: name
      + ": final subslide at "
      + repr(seen)
      + ", static layout is "
      + repr(expected),
  )
}

== Two lists of the same kind in one call

// The blank line splits these into two separate `list` elements while the
// reveal counter runs across both, so an item's row belongs to whichever list
// it sits in rather than to the call as a whole.

#item-by-item[
  - a
  - b

  - c
  - d
]
#[#metadata("t") <ibi-two-lists>]

== Kind change partway through

// The switch from list to enum ends one list and starts another. Items are
// only laid out as rows alongside neighbours of their own kind.

#item-by-item[
  - a
  - b
  + c
  + d
]
#[#metadata("t") <ibi-kind-change>]

== Alternating kinds

// No two adjacent items share a kind, so every item stands alone and none of
// them occupies a list row at all.

#item-by-item[
  - a
  + b
  - c
]
#[#metadata("t") <ibi-alternating>]

== A single item

// One item is not a list, so covering it costs no row spacing.

#item-by-item[
  - lonely
]
#[#metadata("t") <ibi-single>]

== Non-item content between items

// The paragraph breaks the list in two, exactly as a blank line does.

#item-by-item[
  - a

  some paragraph

  - b
]
#[#metadata("t") <ibi-interleaved>]

== A nested list

// Revealing the outer item reveals its nested list with it. The nested items
// are children of the outer item, not siblings of it, so they are not
// separately animated and the outer list's own rows are what must hold.

#item-by-item[
  - outer
    - inner1
    - inner2
  - outer2
]
#[#metadata("t") <ibi-nested>]

== Items that wrap onto several lines

// Row spacing is the gap between items, independent of how tall an item is,
// so a wrapping item must not be treated differently from a short one.

#item-by-item[
  - short
  - a much longer item that will certainly wrap onto a second line in this
    narrow slide body area
  - short again
]
#[#metadata("t") <ibi-multiline>]

== Explicitly set spacing

// With `spacing` set rather than `auto`, the restored gap must be the set
// value, not the paragraph metric an `auto` list would have fallen back to.

#[
  #set list(spacing: 2em)
  #item-by-item[
    - a
    - b
    - c
  ]
]
#[#metadata("t") <ibi-set-spacing>]

== A later start

// `start:` shifts which subslide the first item appears on. The items before
// the anchor are covered for longer, so the correction has to hold over more
// subslides, not fewer.

#item-by-item(start: 2)[
  - a
  - b
]
#[#metadata("t") <ibi-start>]

== Enum

// The same correction applies to the other two item kinds, whose spacing is
// read from `enum.spacing` and `terms.spacing`. Each gets its own slide: two
// animated lists on one slide reveal in sequence, so the upper one's marker
// legitimately moves while the lower one is still growing.

#item-by-item[
  + one
  + two
  + three
]
#[#metadata("t") <ibi-enum>]

== Terms

#item-by-item[
  / a: x
  / b: y
  / c: z
]
#[#metadata("t") <ibi-terms>]

== A linebreak between items

// Unlike a parbreak, a linebreak is absorbed into the item it ends rather than
// becoming a sibling of it, so the list stays tight and its rows keep the
// plain spacing. The correction must not mistake it for a list break.

#item-by-item[
  - a
  - b \\
  - c
]
#[#metadata("t") <ibi-linebreak>]

== Several item-by-item calls in sequence

// Three animated lists of different kinds on one slide. Their reveals run one
// after another, so each marker holds still only once every list below it has
// finished. The invariant that does hold throughout is the last subslide: it
// must reproduce the static layout exactly, which the reference slide below
// measures from the identical content with no animation.

#item-by-item[
  - a
  - b
]
#[#metadata("t") <ibi-seq-1>]
#item-by-item[
  + c
  + d
]
#[#metadata("t") <ibi-seq-2>]
#item-by-item[
  / e: x
  / f: y
]
#[#metadata("t") <ibi-seq-tail>]

== Static reference for the sequence

- a
- b
#[#metadata("t") <ibi-ref-1>]
+ c
+ d
#[#metadata("t") <ibi-ref-2>]
/ e: x
/ f: y
#[#metadata("t") <ibi-ref-tail>]

#context {
  // Two lists of two, revealed one item at a time: four subslides.
  stable(<ibi-two-lists>, 4, "two lists")
  stable(<ibi-kind-change>, 4, "kind change")
  stable(<ibi-alternating>, 3, "alternating kinds")

  // A single item still produces one subslide.
  stable(<ibi-single>, 1, "single item")

  stable(<ibi-interleaved>, 2, "interleaved content") // <-- breaking

  // Two outer items; the nested list rides along with its parent.
  stable(<ibi-nested>, 2, "nested list")

  stable(<ibi-multiline>, 3, "multiline items")
  stable(<ibi-set-spacing>, 3, "set spacing")

  // `start: 2` delays the first reveal, so the run is one subslide longer.
  stable(<ibi-start>, 3, "later start")

  stable(<ibi-linebreak>, 3, "linebreak between items")

  stable(<ibi-enum>, 3, "enum")
  stable(<ibi-terms>, 3, "terms")

  // No marker here is stable across subslides: each has an animated list below
  // it that is still revealing, so it keeps being pushed down. Asserting
  // stability would assert something false. What is pinned instead is where
  // the sequence ends up once every list has finished.
  let at(lbl) = ys(lbl).last()
  settles-to(<ibi-seq-1>, at(<ibi-ref-1>), "sequence first list")
  settles-to(<ibi-seq-2>, at(<ibi-ref-2>), "sequence second list")
  settles-to(<ibi-seq-tail>, at(<ibi-ref-tail>), "sequence tail")
}
