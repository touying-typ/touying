#import "../common.typ": *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none, handout: true),
)

#body
#reuse-body

== Check <s:check>

#context {
  assert-common()

  // Handout renders only the last subslide of each slide, which is not the
  // subslide either waypoint's content completes on. Both anchors therefore
  // move forward to that one rendered page, which still carries their content.
  // Before this rule they were dropped entirely and `#link` hard-errored.
  assert.eq(page-of("s:one.more"), 1)
  assert.eq(page-of("s:one.last"), 1)
}

== Partial handout <s:partial>

// `handout-subslides` renders an explicit subset, which is where the rule has
// to choose. This slide has four subslides and renders only 2 and 3.
#slide(config: config-common(handout-subslides: (2, 3)))[
  A
  #waypoint(<p1>)
  B
  #waypoint(<p2>)
  C
  #waypoint(<p3>)
  D
]

== Partial check

#context {
  // `<p1>` completes on subslide 2 and `<p2>` on subslide 3; both are rendered,
  // so each anchors on its own page.
  assert.eq(query(label("s:partial.p1")).len(), 1)
  assert.eq(query(label("s:partial.p2")).len(), 1)
  assert(
    query(label("s:partial.p1")).first().location().page()
      < query(label("s:partial.p2")).first().location().page(),
  )

  // `<p3>` completes on subslide 4, which is not rendered, and no rendered
  // subslide reaches it. Its content is absent from the document, so there is
  // nothing to link to and no anchor is emitted — rather than one pointing at
  // a page that does not show it.
  assert.eq(query(label("s:partial.p3")).len(), 0)
}
