// The two cover paths must agree with each other and with plain Typst.
//
// `#pause` inside a list (`cover-hidden`, in `core/parser.typ`) and
// `#item-by-item` (in `utils.typ`) both have to keep a list's layout fixed
// while its items are revealed. They arrive there by different code, so each
// is checked against the same two invariants:
//
//   - a marker after the animated content must not move between subslides, and
//   - once everything is revealed, it must sit exactly where the identical
//     content with no animation at all puts it.
//
// The second is what makes the first worth asserting: a path that reserves the
// wrong amount of space consistently would hold still while being wrong. Each
// scenario therefore appears twice, animated and static, and the two are
// compared.
//
// The cases are the ones where the paths used to disagree. A blank line
// between two item runs does not split them into two lists: Typst keeps one
// list and makes it non-tight, widening every row gap. Covering a run across
// that break has to preserve the wider pitch both between the visible rows and
// inside the covered block, and a covered run of a different kind than the
// visible one opens a list of its own, which is separated by paragraph
// spacing rather than a row gap.
//
// Compile-only: what is pinned is a position, not an appearance.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let p(lbl) = [#metadata("p")#lbl]

// Each scenario gets its own slide. Two of them on one slide would let the
// upper marker be pushed down by the lower list while it is still revealing,
// so it would legitimately move and the stability assertion would be false.

== pause, list across a blank line

- a
- b

#pause
- c
- d
#p(<a-pb>)

== static

- a
- b

- c
- d
#p(<s-pb>)

== pause, enum across a blank line

+ a
+ b

#pause
+ c
+ d
#p(<a-enum>)

== static

+ a
+ b

+ c
+ d
#p(<s-enum>)

== pause, terms across a blank line

/ a: x
/ b: y

#pause
/ c: z
/ d: w
#p(<a-terms>)

== static

/ a: x
/ b: y

/ c: z
/ d: w
#p(<s-terms>)

== pause, blank line past the boundary

// The `#pause` sits before the blank line rather than after it, so the
// parbreak is among the covered items instead of ending the visible run. The
// list is non-tight either way, so the correction has to find the parbreak on
// whichever side of the cover boundary it fell.

- a
- b
#pause

- c
- d
#p(<a-past>)

== static

- a
- b

- c
- d
#p(<s-past>)

== pause, kind change

// List then enum is two lists, not one, so the gap between them is paragraph
// spacing and not a row gap. Covering the enum must reserve that wider gap.

- a
- b
#pause
+ c
+ d
#p(<a-kind>)

== static

- a
- b
+ c
+ d
#p(<s-kind>)

== pause, tight list

// The unbroken case, which has to keep working: one tight list, row spacing
// throughout, no rebuild.

- a
- b
#pause
- c
- d
#p(<a-tight>)

== static

- a
- b
- c
- d
#p(<s-tight>)

== item-by-item across a blank line

#item-by-item[
  - a
  - b

  - c
  - d
]
#p(<a-ibi>)

== static

- a
- b

- c
- d
#p(<s-ibi>)

== item-by-item enum across a blank line

#item-by-item[
  + a
  + b

  + c
  + d
]
#p(<a-ibi-enum>)

== static

+ a
+ b

+ c
+ d
#p(<s-ibi-enum>)

== item-by-item kind change

#item-by-item[
  - a
  - b
  + c
  + d
]
#p(<a-ibi-kind>)

== static

- a
- b
+ c
+ d
#p(<s-ibi-kind>)

== item-by-item, kind change across a blank line

// Items of different kinds are separate containers whether or not a blank line
// stands between them, and each stays tight. A parbreak there must therefore
// not be mistaken for one that widens a list.

#item-by-item[
  - a
  - b

  + c
  + d
]
#p(<a-ibi-split-kind>)

== static

- a
- b

+ c
+ d
#p(<s-ibi-split-kind>)

== pause, kind change across a blank line

- a
- b

#pause
+ c
+ d
#p(<a-split-kind>)

== static

- a
- b

+ c
+ d
#p(<s-split-kind>)

== pause, blank line inside the covered run

// The `#pause` splits one source list across several covering steps, and the
// parbreak that makes the container non-tight lies past the first of them. A
// step that only saw the items before it would reserve the tight pitch.

- alpha
- beta
#pause
- gamma

- delta
#p(<a-late-break>)

== static

- alpha
- beta
- gamma

- delta
#p(<s-late-break>)

== assertions

#context {
  let ys(lbl) = query(lbl).map(m => m.location().position().y)

  // Compare with a tolerance rather than exactly: resolving em-based spacing
  // through `context` accumulates float error, so two positions that are the
  // same well past any visible precision can still differ in the last bits.
  let same(a, b) = calc.abs((a - b).pt()) < 0.001

  // The animated marker must hold still across its subslides *and* land where
  // the static one does. `count` guards the stability half: a marker that
  // appeared only once would satisfy it trivially.
  let matches-static(name, count) = {
    let seen = ys(label("a-" + name))
    let static = ys(label("s-" + name)).first()
    assert.eq(
      seen.len(),
      count,
      message: name
        + ": expected "
        + str(count)
        + " subslides, got "
        + repr(seen),
    )
    assert(
      seen.all(y => same(y, seen.first())),
      message: name + " moved across subslides: " + repr(seen),
    )
    assert(
      same(seen.last(), static),
      message: name
        + " settled at "
        + repr(seen.last())
        + ", but the same content unanimated is at "
        + repr(static),
    )
  }

  // Two subslides each: everything before the `#pause`, then everything.
  matches-static("pb", 2)
  matches-static("enum", 2)
  matches-static("terms", 2)
  matches-static("past", 2)
  matches-static("kind", 2)
  matches-static("tight", 2)

  // Four items revealed one at a time.
  matches-static("ibi", 4)
  matches-static("ibi-enum", 4)
  matches-static("ibi-kind", 4)
  matches-static("ibi-split-kind", 4)

  matches-static("split-kind", 2)
  matches-static("late-break", 2)
}
