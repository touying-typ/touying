// How touying-render measures `body`'s own length, and how it reports that
// length to the slide around it. Three things are pinned down here:
//
//   1. `body`'s extent is measured from fn-wrappers (`uncover`/`only`/
//      `alternatives`) as well as from `#pause`. The measuring walk gets
//      `mrr` and `last-subslide` back as two separate values and has to
//      combine them; taking only `mrr` measured fn-wrapper-driven content
//      as a single stage.
//   2. A waypoint's own implicit advance counts toward that extent too.
//      The waypoint map and the repeat count are mutually dependent (the
//      map's ranges close against the count, the count needs the map for
//      an advance to fire at all), so the measurement runs twice: once
//      against no map, then again against the map the first pass makes
//      computable.
//   3. The measured length reaches the enclosing slide the way an
//      `#uncover` spanning that many subslides would — reserving subslides
//      without consuming them. Siblings written after the call therefore
//      keep their own position rather than being pushed past the rendered
//      content's end.
//
// Compile-only: what's asserted is which subslide things land on, not how
// they look. Every observable stage is wrapped in `only("h")` (absent
// entirely when not current) rather than left to `#pause` (which merely
// *hides* — still queryable, so useless as a presence check).

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== Extent comes from fn-wrappers, not only from pauses
#touying-render(
  [
    #only("1")[a #label("fnw-1")]
    #only("2")[b #label("fnw-2")]
    #only("3")[c #label("fnw-3")]
  ],
  subslides: "1-",
)

== A waypoint's own advance counts toward the extent
#touying-render(
  [
    #only("h")[A #label("adv-1")]
    #waypoint(<adv-w>)
    #only("h")[B #label("adv-2")]
    #pause
    #only("h")[C #label("adv-3")]
  ],
  subslides: "1-",
  base: 1,
)

== Subslides are reserved, not consumed
#touying-render(
  [
    #only("h")[a #label("resv-1")]
    #pause
    #only("h")[b #label("resv-2")]
    #pause
    #only("h")[c #label("resv-3")]
  ],
  subslides: "1-",
)
#only("h")[TAIL #label("resv-tail")]

== Assertions
#context {
  // --- 1. three `only` stages, no pause anywhere: all three must play ---
  assert.eq(query(label("fnw-1")).len(), 1)
  assert.eq(query(label("fnw-2")).len(), 1)
  assert.eq(query(label("fnw-3")).len(), 1)

  // --- 2. A at 1, the waypoint advances to 2 for B, #pause reaches 3 for
  // C: the advance has to be counted or C's stage never exists ---
  assert.eq(query(label("adv-1")).len(), 1)
  assert.eq(query(label("adv-2")).len(), 1)
  assert.eq(query(label("adv-3")).len(), 1)

  // --- 3. the trailing sibling's own "h" stays at subslide 1, sharing a
  // page with the render's *first* stage rather than being pushed past its
  // last one — while all three stages still play ---
  assert.eq(query(label("resv-1")).len(), 1)
  assert.eq(query(label("resv-2")).len(), 1)
  assert.eq(query(label("resv-3")).len(), 1)
  assert.eq(query(label("resv-tail")).len(), 1)
  assert.eq(
    query(label("resv-tail")).first().location().page(),
    query(label("resv-1")).first().location().page(),
  )
}
