#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(handout: true),
)

// -----------------------------------------------
// Test 1: Explicit waypoint with uncover
// -----------------------------------------------

== Explicit Waypoints

Always visible.

#waypoint(<reveal>)
First phase.
#pause
Second phase.

#uncover(
  <reveal>,
)[Revealed after waypoint. Basically a meanwhile starting from the waypoint.]

// -----------------------------------------------
// Test 2: Explicit waypoint with effect
// -----------------------------------------------

== Effect Waypoint

Normal text.

#waypoint(<highlight>)

#effect(text.with(fill: red), <highlight>)[Red from waypoint onward.]

// -----------------------------------------------
// Test 3: Multiple explicit waypoints and only
// -----------------------------------------------

== Multiple Waypoints

Start content.

#waypoint(<first>)

First phase.

#waypoint(<second>)

Second phase.

#only(<first>)[Only during first.]

#only(<second>)[Only during second.]

// -----------------------------------------------
// Test 4: get-first / get-last
// -----------------------------------------------

== Get First and Last

Content.

#waypoint(<a>)

Phase A.1.

#pause

Phase A.2.

#waypoint(<b>)

Phase B.1.
#pause
Phase B.2.

#only(get-first(<a>))[Exactly on first subslide of A: Phase A.1.]

#only(get-last(<b>))[Exactly on last subslide of B: Phase B.2.]

// -----------------------------------------------
// Test 5: from() — visible from waypoint onward
// -----------------------------------------------

== From

Intro.

#waypoint(<step>)

Step content.

#waypoint(<next>)

Next content.

#uncover(from(<step>))[Visible from step onward (including next).]

// -----------------------------------------------
// Test 6: until() — visible before a waypoint
// -----------------------------------------------

== Until

#waypoint(<phase-1>)
Phase 1 content.

#waypoint(<phase-2>)
Phase 2 content.

#uncover(until(<phase-2>))[Only visible during phase 1.]

#uncover(from(<phase-2>))[Only visible from phase 2.]

// -----------------------------------------------
// Test 7: Bounded range with (from, until) array
// -----------------------------------------------

== Bounded Range

#waypoint(<rng-a>)
Range A.

#waypoint(<rng-b>)
Range B.

#waypoint(<rng-c>)
Range C.

#uncover((from(<rng-a>), until(<rng-c>)))[Visible during A and B only.]

#only((from(<rng-b>), until(<rng-c>)))[Only during B.]

// -----------------------------------------------
// Test 8: prev-wp / next-wp
// -----------------------------------------------

== Prev and Next WP

#waypoint(<nav-a>)
Section A.

#waypoint(<nav-b>)
Section B.

#waypoint(<nav-c>)
Section C.

#only(next-wp(<nav-a>))[This shows during B (next after A).]

#only(prev-wp(<nav-c>))[This shows during B (prev before C).]

// -----------------------------------------------
// Test 9: from(next-wp()) and until(prev-wp()) composition
// -----------------------------------------------

== Composed Shifts

#waypoint(<cs-a>)
Part A.

#waypoint(<cs-b>)
Part B.

#waypoint(<cs-c>)
Part C.

#uncover(from(next-wp(<cs-a>)))[From B onward (next after A).]

#uncover(until(prev-wp(
  <cs-c>,
)))[Until before B (prev of C = B, until B = only A).]

// -----------------------------------------------
// Test 10: next-wp(until()) pushed inward
// -----------------------------------------------

== Next-WP Until Push

#waypoint(<pu-a>)
Alpha.

#waypoint(<pu-b>)
Beta.

#waypoint(<pu-c>)
Gamma.

// next-wp(until(<pu-b>)) becomes until(next-wp(<pu-b>)) = until(<pu-c>)
// So visible: subslides before pu-c = during A and B.
#uncover(next-wp(until(<pu-b>)))[Visible during A and B (pushed until next).]

// -----------------------------------------------
// Test 11: Waypoint without advance
// -----------------------------------------------

== No Advance Waypoint

#waypoint(<here>, advance: false)

Everything on subslide 1.

#uncover(<here>)[This should be visible on subslide 1.]

// -----------------------------------------------
// Test 12: Alternatives with `at:`
// -----------------------------------------------

== Alternatives at Waypoints

Intro.

#waypoint(<alt-a>)

Phase A.

#waypoint(<alt-b>)

Phase B.

#alternatives(at: (<alt-a>, <alt-b>))[Alt content A.][Alt content B.]

// -----------------------------------------------
// Test 13: Implicit waypoints with uncover
// -----------------------------------------------

== Implicit Uncover

Always visible.

#uncover(<imp-reveal>)[Implicitly waypointed content.]

// -----------------------------------------------
// Test 14: Implicit waypoints with effect
// -----------------------------------------------

== Implicit Effect

Normal text.

#effect(text.with(fill: red), <imp-red>)[Red via implicit waypoint.]

// -----------------------------------------------
// Test 15: Implicit waypoints with only
// -----------------------------------------------

== Implicit Only

Content always shown.

#only(<imp-show>)[Only via implicit waypoint.]

// -----------------------------------------------
// Test 16: Multiple implicit waypoints
// -----------------------------------------------

== Multiple Implicit

Base content.

#uncover(<imp-a>)[Phase A content.]

#pause

#effect(text.with(fill: blue), <imp-b>)[Phase B styled.]

#only(<imp-c>)[Phase C only.]

#only((get-last(<imp-a>), <imp-c>))[On last of A and at C.]

// -----------------------------------------------
// Test 17: Mixed explicit and implicit with from()
// -----------------------------------------------

== Mixed Waypoints

Intro.

#waypoint(<explicit-wp>)

Explicit phase.

#uncover(<implicit-wp>)[Implicit phase content.]

#uncover(from(<explicit-wp>))[Visible from explicit onward.]

// -----------------------------------------------
// Test 18: Same implicit label used twice (idempotent)
// -----------------------------------------------

== Duplicate Implicit

#uncover(<dup>)[First use.]

#uncover(<dup>)[Second use — same label, no extra pause.]

// -----------------------------------------------
// Test 19: Waypoints with touying-equation
// -----------------------------------------------

== Equation with Waypoints

Intro text.

#waypoint(<eq-phase>)

$
  f(x) & = pause x^2 + 2x + 1 \
       & = pause (x + 1)^2 \
$

#waypoint(<eq-after>)

Some more explanation.

#only(<eq-after>)[Visible after equation explanation.]

#uncover(<eq-phase>)[Equation explanation visible from waypoint.]

// -----------------------------------------------
// Test 20: Callback-style with uncover + only + effect
// -----------------------------------------------

== Callback with Waypoints

#slide(self => {
  let (uncover, only, effect) = utils.methods(self)
  [
    Base content in callback.

    #waypoint(<cb-a>)

    #uncover(<cb-a>)[Uncovered from cb-a.]

    #waypoint(<cb-b>)

    #only(<cb-b>)[Only during cb-b.]

    #effect(text.with(fill: red), <cb-a>)[Red from cb-a onward.]
  ]
})

// -----------------------------------------------
// Test 21: Callback-style with get-first / get-last / from
// -----------------------------------------------

== Callback Get-First Get-Last

#slide(self => {
  let (only,) = utils.methods(self)
  [
    #waypoint(<m1>)
    Phase 1.
    #pause
    Phase 1 continued.
    #waypoint(<m2>)
    Phase 2.

    #only(get-first(<m1>))[Exactly first of m1.]
    #only(get-last(<m1>))[Exactly last of m1.]
    #only(from(<m2>))[From m2 onward.]
  ]
})

// -----------------------------------------------
// Test 22: Callback-style with alternatives at:
// -----------------------------------------------

== Callback Alternatives

#slide(self => {
  [
    #waypoint(<ca>)
    Phase A.
    #waypoint(<cb>)
    Phase B.
    #alternatives(at: (<ca>, <cb>))[Alt A callback.][Alt B callback.]
  ]
})

// -----------------------------------------------
// Test 23: item-by-item after explicit waypoint
// -----------------------------------------------

== Item-by-item with Waypoint

Intro content.

#waypoint(<list-start>)

#item-by-item[
  - First item
  - Second item
  - Third item
]

#uncover(<list-start>)[List is being revealed above.]

// -----------------------------------------------
// Test 24: Callback item-by-item with waypoint start
// -----------------------------------------------

== Callback Item-by-item

#slide(repeat: 5, self => {
  let (uncover, only) = utils.methods(self)
  [
    Intro.

    #waypoint(<ibi-wp>)

    #item-by-item[
      - Alpha
      - Beta
      - Gamma
    ]

    #only(get-last(<ibi-wp>))[All items revealed.]
  ]
})

// -----------------------------------------------
// Test 25: Forward reference — use waypoint before it is defined
// -----------------------------------------------

== Forward Reference

// Title shown until the summary waypoint (forward reference)
#uncover(until(<summary>))[Title: shown before summary.]

Content.

#waypoint(<summary>)

Summary text.

#uncover(from(<summary>))[Summary visible.]

// -----------------------------------------------
// Test 26: Inclusive bounded range with next-wp
// -----------------------------------------------

== Inclusive Range

#waypoint(<ir-a>)
Part A.

#waypoint(<ir-b>)
Part B.

#waypoint(<ir-c>)
Part C.

// from(<ir-a>), until(<ir-b>) = only A
// from(<ir-a>), next-wp(until(<ir-b>)) = until(next-wp(<ir-b>)) = until(<ir-c>) → A and B
#only((from(<ir-a>), until(<ir-b>)))[Exactly during A.]

#only((from(<ir-a>), next-wp(until(<ir-b>))))[During A and B (inclusive of B).]

// -----------------------------------------------
// Test 27: prev-wp / next-wp with amount parameter
// -----------------------------------------------

== Amount Shift

#waypoint(<am-a>)
First.

#waypoint(<am-b>)
Second.

#waypoint(<am-c>)
Third.

#waypoint(<am-d>)
Fourth.

// next-wp(<am-a>, amount: 2) = skip 2 forward = am-c
#only(next-wp(<am-a>, amount: 2))[During C (jumped forward 2 from A).]

// prev-wp(<am-d>, amount: 2) = skip 2 backward = am-b
#only(prev-wp(<am-d>, amount: 2))[During B (jumped backward 2 from D).]

// Compose with from: from(next-wp(<am-a>, amount: 2)) = from am-c onward
#uncover(from(next-wp(<am-a>, amount: 2)))[From C onward (amount: 2).]
