#import "../common.typ": *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

#body
#reuse-body

== Check <s:check>

#context {
  assert-common()

  // Every subslide is rendered, so each anchor sits on the waypoint's own last
  // one. `<more>` owns B and C, and C is revealed on the third subslide (the
  // `#pause` extends the run), so the anchor lands there rather than on the
  // marker's own subslide. `<last>` owns D, revealed on the fourth.
  assert.eq(page-of("s:one.more"), 3)
  assert.eq(page-of("s:one.last"), 4)
}
