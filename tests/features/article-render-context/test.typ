// Article mode resolves touying-render after the body's final absolute stage
// is known. A non-1 base must not be added twice, and an advancing waypoint
// must contribute its stage before `auto` selects the final state.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(export-mode: "article"))

#let offset-stages = [
  #only("h")[first #label("article-render-base-first")]
  #pause
  #only("h")[last #label("article-render-base-last")]
]

== Negative stage with an offset base

#touying-render(offset-stages, base: 3, subslides: -1)

#let waypoint-stages = [
  #only("h")[first #label("article-render-waypoint-first")]
  #waypoint(<article-render-waypoint>)
  #only("h")[second #label("article-render-waypoint-second")]
  #pause
  #only("h")[third #label("article-render-waypoint-third")]
]

== Final stage after an advancing waypoint

#touying-render(waypoint-stages, subslides: auto)

#let nested-offset-stages = [
  #only("h")[first #label("article-nested-base-first")]
  #pause
  #only("h")[last #label("article-nested-base-last")]
]

#let nested-waypoint-stages = [
  #only("h")[first #label("article-nested-waypoint-first")]
  #waypoint(<article-nested-waypoint>)
  #only("h")[second #label("article-nested-waypoint-second")]
  #pause
  #only("h")[third #label("article-nested-waypoint-third")]
]

== The same resolution inside article-only

#article-only[
  #touying-render(nested-offset-stages, base: 3, subslides: -1)
  #touying-render(nested-waypoint-stages, subslides: auto)
]

== Source for nested recall

#block[
  #only("h")[first #label("article-recall-base-first")]
  #pause
  #only("h")[last #label("article-recall-base-last")]
] <article-recall-base-source>

#article-only[
  #touying-recall(<article-recall-base-source>, base: 3, subslides: -1)
]

#context {
  assert.eq(query(label("article-render-base-first")).len(), 0)
  assert.eq(query(label("article-render-base-last")).len(), 1)
  assert.eq(query(label("article-render-waypoint-first")).len(), 0)
  assert.eq(query(label("article-render-waypoint-second")).len(), 0)
  assert.eq(query(label("article-render-waypoint-third")).len(), 1)
  assert.eq(query(label("article-nested-base-first")).len(), 0)
  assert.eq(query(label("article-nested-base-last")).len(), 1)
  assert.eq(query(label("article-nested-waypoint-first")).len(), 0)
  assert.eq(query(label("article-nested-waypoint-second")).len(), 0)
  assert.eq(query(label("article-nested-waypoint-third")).len(), 1)
  assert.eq(query(label("article-recall-base-first")).len(), 0)
  assert.eq(query(label("article-recall-base-last")).len(), 2)
}
