// A `#pause` following a fn-wrapper must count from where the flow actually
// is, not from the end of whatever range that wrapper reserved.
//
// v0.7.0 (commit feade0e1, part of the waypoint PR) made every relative jump
// snap past the highest `last-subslide` seen so far:
//
//   repetitions = calc.max(repetitions, last-subslide) + child.value.n
//
// The goal was `item-by-item`, which stands in for a run of pauses and so
// should push a later `#pause` past its whole animation. But `item-by-item`
// reports its extent through exactly the same `last-subslide` channel as
// `uncover`/`only`/`alternatives`, so the snap could not be scoped to it and
// silently caught every wrapper:
//
//   #uncover("2")[..]     // reserves subslide 2, animates only its own body
//   On subslide one
//   #pause                // 0.6.x: -> 2.  0.7.0-0.7.4: -> 3.
//
// That was never documented, never asserted by a test, and never mentioned in
// the changelog; the one test covering the interaction was reshaped in the
// same commit to stay insensitive to it. The rule is now carried by an
// explicit `advances-flow` flag on `touying-fn-wrapper`, set only by
// `item-by-item`/`item-by-item-fn`, which moves the pause cursor to the end
// of their own range; every other wrapper leaves the cursor alone.
//
// Both halves matter, so both are pinned here:
//   - the *flow*, as the subslide distance from a marker before the wrapper
//     to one after the following `#pause`;
//   - the *extent*, as each slide's own subslide count (the distance to the
//     next slide's first marker) — reserving subslides is still the
//     wrapper's job and must be untouched by any of this.
//
// Compile-only: what's asserted is which subslide things land on.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

// `only("h")` marks exactly the current flow position and is absent
// everywhere else, so each label's page *is* its subslide.

== uncover reserves a subslide without consuming it
#only("h")[start #label("u-start")]
#uncover("2")[reserved]
#pause
#only("h")[after #label("u-after")]

== only reserves subslides without consuming them
#only("h")[start #label("o-start")]
#only("3")[reserved]
#pause
#only("h")[after #label("o-after")]

== item-by-item stands in for its pauses and does consume them
#only("h")[start #label("i-start")]
#item-by-item[
  - one
  - two
  - three
]
#pause
#only("h")[after #label("i-after")]

== item-by-item-fn behaves the same way
#only("h")[start #label("f-start")]
#item-by-item-fn("current-bold")[
  - one
  - two
  - three
]
#pause
#only("h")[after #label("f-after")]

== an advancing waypoint lands one past the flow, not past the reservation
#only("h")[start #label("w-start")]
#uncover("5")[reserved]
#waypoint(<w>)
#only("h")[at waypoint #label("w-at")]

== Assertions
#only("h")[end #label("end")]

#context {
  let at(name) = query(label(name)).first().location().page()

  // --- flow: how far the following #pause (or waypoint) moved ---

  // reverted: reserving subslide 2 doesn't move the flow, so #pause is 1 -> 2
  assert.eq(at("u-after") - at("u-start"), 1)
  // reverted: same for a reservation that reaches beyond the pause
  assert.eq(at("o-after") - at("o-start"), 1)
  // kept: three items consume subslides 1-3, so #pause is 3 -> 4
  assert.eq(at("i-after") - at("i-start"), 3)
  assert.eq(at("f-after") - at("f-start"), 3)
  // reverted: the waypoint is placed one past the flow (1), not one past
  // the uncover's reservation (5)
  assert.eq(at("w-at") - at("w-start"), 1)

  // --- extent: each slide's own subslide count, unchanged by the above ---

  // max(flow 2, uncover's 2)
  assert.eq(at("o-start") - at("u-start"), 2)
  // max(flow 2, only's 3)
  assert.eq(at("i-start") - at("o-start"), 3)
  // item-by-item's 3, then the pause
  assert.eq(at("f-start") - at("i-start"), 4)
  assert.eq(at("w-start") - at("f-start"), 4)
  // max(flow 2, uncover's 5)
  assert.eq(at("end") - at("w-start"), 5)
}
