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

#context {
  // The original two-slide sequence contributes one of each. The recall adds
  // one more occurrence of the selected second stage only.
  assert.eq(query(label("wrapper-recall-first")).len(), 1)
  assert.eq(query(label("wrapper-recall-second")).len(), 2)
}
