// Covering a list item must not cost the list its row spacing. `item-by-item`
// covers whole `list.item`/`enum.item`/`terms.item` children, and a covered
// item stops being laid out as a list row, so without a correction the
// enclosing list shrinks and everything after it creeps upwards as items are
// revealed. The same correction the parser applies around a `#pause`-broken
// list (`cover-hidden`) is applied here by `_item-row-spacing`.
//
// Compile-only: what is pinned is a position, not an appearance.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== List

#item-by-item[
  - one
  - two
  - three
]
#[#metadata("tail") <ibi-list-tail>]

== Enum

#item-by-item[
  + one
  + two
  + three
]
#[#metadata("tail") <ibi-enum-tail>]

== Terms

#item-by-item[
  / a: x
  / b: y
  / c: z
]
#[#metadata("tail") <ibi-terms-tail>]

#context {
  let ys(lbl) = query(lbl).map(m => m.location().position().y)

  // Three subslides, one per item revealed. The trailing marker must sit at
  // exactly the same height on every one of them: the list reserves all three
  // rows from the start, so revealing an item changes what is visible, never
  // where the content after the list begins.
  let list-ys = ys(<ibi-list-tail>)
  assert.eq(list-ys.len(), 3)
  assert.eq(
    list-ys.dedup().len(),
    1,
    message: "list tail moved: " + repr(list-ys),
  )

  let enum-ys = ys(<ibi-enum-tail>)
  assert.eq(enum-ys.len(), 3)
  assert.eq(
    enum-ys.dedup().len(),
    1,
    message: "enum tail moved: " + repr(enum-ys),
  )

  let terms-ys = ys(<ibi-terms-tail>)
  assert.eq(terms-ys.len(), 3)
  assert.eq(
    terms-ys.dedup().len(),
    1,
    message: "terms tail moved: " + repr(terms-ys),
  )
}
