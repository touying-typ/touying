// A labeled element can get all of its animation extent from fn wrappers and
// contain no pause at all. Breadcrumb detection must include `last-subslide`,
// or explicit recall mistakes this for static content and panics.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== Source

#block[
  #only("1")[first #label("wrapper-recall-first")]
  #only("2")[second #label("wrapper-recall-second")]
] <wrapper-recall-source>

== Recalled second stage

#touying-recall(<wrapper-recall-source>, subslides: 2)

== A nested reducer keeps the rest of its labelled source

#let nested-reducer = touying-reducer(
  reduce: it => it.sum(default: none),
  cover: it => it.map(hide),
  ([inside], pause, [later]),
)
#block[
  before #label("compound-recall-before")
  #nested-reducer
  after #label("compound-recall-after")
] <compound-recall-source>

#only(1)[#touying-recall(<compound-recall-source>, subslides: 1)]

#context {
  // The original two-slide sequence contributes one of each. The recall adds
  // one more occurrence of the selected second stage only.
  assert.eq(query(label("wrapper-recall-first")).len(), 1)
  assert.eq(query(label("wrapper-recall-second")).len(), 2)

  // Two occurrences come from the source's two stages, and the outer `only`
  // limits the recall to one more. The nested reducer may not replace either
  // surrounding sibling.
  assert.eq(query(label("compound-recall-before")).len(), 3)
  assert.eq(query(label("compound-recall-after")).len(), 3)
}
