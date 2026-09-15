// Content recall has an inlined resolver in slide parsing and a shared one in
// article rendering. Negative indices count from the number of stages, while
// the parser reports an absolute final counter that already includes `base`.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== Source

#block[
  #only("h")[first #label("recall-offset-first")]
  #pause
  #only("h")[last #label("recall-offset-last")]
] <recall-offset-source>

== Recalled final stage

#touying-recall(<recall-offset-source>, base: 3, subslides: -1)

== Waypoint recall with the same offset

#block[
  #waypoint(<recall-offset-a>, advance: false)
  #only("h")[A #label("recall-offset-wp-a")]
  #pause
  #waypoint(<recall-offset-b>, advance: false)
  #only(<recall-offset-b>)[B #label("recall-offset-wp-b")]
] <recall-offset-wp-source>

== Recalled waypoint stage

#touying-recall(
  <recall-offset-wp-source>,
  base: 3,
  subslides: get-last(<recall-offset-b>),
)

#context {
  // Each source stage appears once in the original slide sequence. Recalling
  // the final stage adds only a second occurrence of `last`.
  assert.eq(query(label("recall-offset-first")).len(), 1)
  assert.eq(query(label("recall-offset-last")).len(), 2)

  // The source contributes each stage once; the recall adds the second
  // waypoint's stage at absolute position 4, not a doubly shifted position.
  assert.eq(query(label("recall-offset-wp-a")).len(), 1)
  assert.eq(query(label("recall-offset-wp-b")).len(), 2)
}
