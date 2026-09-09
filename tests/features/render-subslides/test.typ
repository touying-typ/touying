// touying-render's `subslides:` used to only ever resolve to a single,
// frozen stage of `body` - a bare waypoint label or a range/complement
// marker (`from-wp`, `until-wp`, `not-wp`) collapsed down to its first
// subslide instead of exposing the whole range. This test pins down the
// generalization: any spec that captures more than one subslide now steps
// through all of them, one per outer subslide, and a genuinely
// single-point spec (a plain int, `get-first`, `get-last`) still behaves
// exactly as before. Compile-only: asserted via `query()` rather than an
// image reference, since what's being pinned down is "which stage renders
// on which subslide", not appearance.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

// Each scenario gets its own copy of the animated content with its own
// uniquely-labeled stages, so a `query()` after the fact can be attributed
// to exactly one scenario, with zero cross-scenario contamination. Each
// stage is gated with `only("h")` (exclusive reveal at exactly the current
// position) rather than left as a bare `#pause` chain (cumulative reveal),
// so that "which stage rendered" is a clean presence/absence question — a
// bare `#pause` chain would legitimately keep every earlier stage's label
// around too, which is correct pause semantics but would make assertions
// about *this* feature murkier. `#pause` is still what drives the stage
// count here (`only(...)` siblings with no `#pause` between them don't
// currently grow touying-render's own probed repeat count — a separate,
// pre-existing gap, not something this test is about).
#let stages(prefix) = [
  #only("h")[First #label(prefix + "-1")]
  #pause
  #only("h")[Second #label(prefix + "-2")]
  #pause
  #only("h")[Third #label(prefix + "-3")]
  #pause
  #only("h")[Fourth #label(prefix + "-4")]
]

// Both waypoints are `advance: false` — positions come entirely from the
// explicit `#pause` calls, never from a waypoint's own implicit advance.
// That advance doesn't register in touying-render's own probed repeat
// count (a separate, pre-existing gap: the probe walks with an empty
// waypoint map, so `lbl in wp` never holds for it) and, independently,
// `_collect-waypoints`' own position bookkeeping isn't a no-op when an
// advancing waypoint's target coincides with a `#pause` immediately
// before it — both are pre-existing wrinkles this test isn't about, so
// pure `#pause`-driven positions sidestep both cleanly.
#let wp-stages(prefix) = [
  #waypoint(label(prefix + "-a"), advance: false)
  #only("h")[A #label(prefix + "-wp-a")]
  #pause
  #waypoint(label(prefix + "-b"), advance: false)
  #only("h")[B #label(prefix + "-wp-b")]
  #pause
  #only("h")[B2 #label(prefix + "-wp-b2")]
]

== Regression: a plain int is still a single, frozen stage
#touying-render(stages("int"), subslides: 2)

== Contiguous range steps through every member
#touying-render(stages("range"), subslides: "2-4")

== Negated range collapses its gap onto the next member
#touying-render(stages("negated"), subslides: "!2-3")

== Bare "h" pins this render's own numbering anchor (render-base)
#touying-render(stages("here"), subslides: "h")

== Bare "!h" is the complement of that single anchor point
#touying-render(stages("neg-here"), subslides: "!h")

== A bare waypoint label now exposes its whole range, not just its start
// base: 1 (not auto) is required so subslides: resolves against
// wp-stages("bare")'s own internal waypoints, rather than the enclosing
// slide's (an existing, unrelated coupling this test isn't about).
#touying-render(wp-stages("bare"), subslides: label("bare-b"), base: 1)

== get-last still pins a single subslide
#touying-render(
  wp-stages("last"),
  subslides: get-last(label("last-b")),
  base: 1,
)

#context {
  // --- plain int: unchanged single-frame behavior ---
  assert.eq(query(label("int-1")).len(), 0)
  assert.eq(query(label("int-2")).len(), 1)
  assert.eq(query(label("int-3")).len(), 0)
  assert.eq(query(label("int-4")).len(), 0)

  // --- "2-4": every member shown exactly once, stage 1 never shown ---
  assert.eq(query(label("range-1")).len(), 0)
  assert.eq(query(label("range-2")).len(), 1)
  assert.eq(query(label("range-3")).len(), 1)
  assert.eq(query(label("range-4")).len(), 1)

  // --- "!2-3": stages 2 and 3 skipped, the gap collapses onto stage 4 ---
  assert.eq(query(label("negated-1")).len(), 1)
  assert.eq(query(label("negated-2")).len(), 0)
  assert.eq(query(label("negated-3")).len(), 0)
  assert.eq(query(label("negated-4")).len(), 1)

  // --- bare "h": pins render-base (1 here, since base: auto and this
  // slide has no #pause of its own before the call) — single frame ---
  assert.eq(query(label("here-1")).len(), 1)
  assert.eq(query(label("here-2")).len(), 0)
  assert.eq(query(label("here-3")).len(), 0)
  assert.eq(query(label("here-4")).len(), 0)

  // --- bare "!h": everything except render-base (1), stepped through ---
  assert.eq(query(label("neg-here-1")).len(), 0)
  assert.eq(query(label("neg-here-2")).len(), 1)
  assert.eq(query(label("neg-here-3")).len(), 1)
  assert.eq(query(label("neg-here-4")).len(), 1)

  // --- bare waypoint label spans both of its subslides: both must
  // appear, not just the first ---
  assert.eq(query(label("bare-wp-a")).len(), 0)
  assert.eq(query(label("bare-wp-b")).len(), 1)
  assert.eq(query(label("bare-wp-b2")).len(), 1)

  // --- get-last: only the waypoint's own final subslide ---
  assert.eq(query(label("last-wp-a")).len(), 0)
  assert.eq(query(label("last-wp-b")).len(), 0)
  assert.eq(query(label("last-wp-b2")).len(), 1)
}
