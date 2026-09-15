// `last-subslide` — the peak subslide count an fn-wrapper (`uncover`/`only`/…)
// requires — is meant to be a running peak across the whole slide, the same
// way `max-repetitions` already is for the pause cursor. But every absolute
// jump (`#meanwhile`, or a `#waypoint(<x>, start: n)`) reset it straight to
// 0 instead of folding its current value into that peak first:
//
//   max-repetitions = calc.max(max-repetitions, repetitions)
//   repetitions = child.value.n
//   last-subslide = 0
//
// So `#uncover("1-4")[..]` followed anywhere later in the same slide — even
// in a different column of `#slide[A][B]` — by an absolute jump would
// silently discard the 4 subslides `uncover` required, shrinking the
// slide's total subslide count below what it needs.
//
// Compile-only: what's asserted is each slide's own subslide count, via how
// many pages the `uncover`d content is queryable on. The check must land on
// the `uncover`d content itself, not on a marker placed after the jump — a
// marker there would independently re-establish `last-subslide` and mask
// the bug instead of testing it.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

== meanwhile in a different column does not shrink last-subslide
#slide[
  #uncover("1-4")[reserved #label("col-uncover")]
][
  #meanwhile
  Column 2 content
  #pause
  More column 2 content
]

== meanwhile in the same flow does not shrink last-subslide
#slide[
  #uncover("1-4")[reserved #label("flow-uncover")]
  #meanwhile
  Restarted content
]

== waypoint start: in the same flow does not shrink last-subslide

#uncover("1-4")[reserved #label("wp-uncover")]
#waypoint(<unstable-wp>, start: 2)
Content from the waypoint onward

#context {
  assert.eq(query(label("col-uncover")).len(), 4)
  assert.eq(query(label("flow-uncover")).len(), 4)
  assert.eq(query(label("wp-uncover")).len(), 4)
}

// The same reset also corrupted the *waypoint pre-pass* used to compute
// waypoint ranges (`_collect-waypoints-impl`, called before rendering to
// build `self.waypoints`). A non-advancing waypoint's `decl-reps` entry —
// which becomes the range-end of whichever waypoint precedes it — is
// `calc.max(repetitions, last-subslide)` at the point it's declared. If an
// intervening `#meanwhile` had already zeroed `last-subslide`, an earlier
// fn-wrapper's requirement was lost from that computation too, shrinking
// the earlier waypoint's range (e.g. to `(first: 1, last: 1)` instead of
// reaching subslide 4) — which corrupts anything that reads waypoint
// ranges: the link-anchor feature, `from-wp`/`until-wp`/`get-last`, etc.
== Waypoint Ranges

#waypoint(<range-a>, advance: false)
#uncover("1-4")[reserved]

#meanwhile
Content in A's own flow

#waypoint(<range-b>, advance: false)
B phase content

#pause

More B content
//from subslide 3 then
#waypoint(<range-c>)

//we need the context call here inside the callback so it only gets triggered after all internal computations are finished not not immediately at the start when the fn-wrapper-raw is parsed. Only at the end of parsing do we have the waypoint ranges fix
#touying-fn-wrapper-raw((self: none) => context {
  assert.eq(
    self.waypoints.at("range-a"),
    (first: 1, last: 4),
  )
  assert.eq(
    self.waypoints.at("range-b"),
    (first: 1, last: 2),
  )
  assert.eq(
    self.waypoints.at("range-c"),
    (first: 3, last: 4),
  )
})
