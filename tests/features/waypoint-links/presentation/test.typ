#import "../common.typ": *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

#body
#reuse-body
#call-body

== Check <s:check>

#context {
  assert-common()

  // Every subslide is rendered, so each anchor sits on the waypoint's own last
  // one. `<more>` owns B and C, and C is revealed on the third subslide (the
  // `#pause` extends the run), so the anchor lands there rather than on the
  // marker's own subslide. `<last>` owns D, revealed on the fourth.
  assert.eq(page-of("s:one.more"), 3)
  assert.eq(page-of("s:one.last"), 4)

  // The slide call's label sits on its first subslide and its anchors on the
  // same subslides as the heading form's.
  assert.eq(page-of("s:call.more") - page-of("s:call"), 2)
  assert.eq(page-of("s:call.last") - page-of("s:call"), 3)
}

== Recalls

// A recalled copy of a slide names its anchors with a number, or with the label
// written after the call, and every label keeps occurring once.
#touying-recall(<s:one>)
#touying-recall(<s:call>)<s:call-again>

== Recall check

#context {
  let count(name) = query(label(name)).len()
  for name in (
    "s:one",
    "s:one.more",
    "s:one-1",
    "s:one-1.more",
    "s:one-1.last",
    "s:call",
    "s:call.more",
    "s:call-again",
    "s:call-again.more",
    "s:call-again.last",
  ) {
    assert.eq(count(name), 1, message: "label `" + name + "` has to occur once")
  }
}

== Source figure

#figure(rect(width: 1cm), caption: [Figure])<mark-fig>

== Marks

// The label after a content recall sits on the last subslide only, like any
// label on a slide with subslides.
#touying-recall(<mark-fig>)<mark-fig-copy>
A #pause B @mark-fig-copy

== Box around a mark

// A box the user wrote around a touying mark is theirs, and keeps its label.
#uncover("1-")[#box(alert[X])<user-box>]

== Marks check

#context {
  assert.eq(query(<mark-fig-copy>).len(), 1)
  assert.eq(query(<user-box>).len(), 1)
}
