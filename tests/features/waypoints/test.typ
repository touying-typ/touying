#import "/lib.typ": *
#import themes.simple: *
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: simple-theme.with()

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
)[Revealed during waypoint. Basically a meanwhile starting from the waypoint.]

// -----------------------------------------------
// Test 2: Waypoint without advance
// -----------------------------------------------

== No Advance Waypoint

#waypoint(<here>, advance: false)

Everything on subslide 1.

#uncover(<here>)[This should be visible on subslide 1.]

// -----------------------------------------------
// Test 3: Explicit waypoint with effect
// -----------------------------------------------

== Effect Waypoint

Normal text.

#waypoint(<highlight>)

#effect(text.with(fill: red), <highlight>)[Red from waypoint onward.]

// -----------------------------------------------
// Test 4: Multiple explicit waypoints and only
// -----------------------------------------------

== Multiple Waypoints

#waypoint(<first>, advance: false)

First phase.

#waypoint(<second>)

Second phase.

#only(<first>)[Only during first.]

#only(<second>)[Only during second.]

// -----------------------------------------------
// Test 5: get-first / get-last
// -----------------------------------------------

== Get First and Last
#waypoint(<a>, advance: false)

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
// Test 6: from-wp() — visible from waypoint onward
// -----------------------------------------------

== From

Intro.

#waypoint(<step>)

Step content.

#waypoint(<next>)

Next content.

#uncover(from-wp(<step>))[Visible from step onward (including next).]

// -----------------------------------------------
// Test 7: until-wp() — visible before a waypoint
// -----------------------------------------------

== Until

#waypoint(<phase-1>, advance: false)
Phase 1 content.

#waypoint(<phase-2>)
Phase 2 content.

#uncover(until-wp(<phase-2>))[Only visible before phase 2.]

#uncover(from-wp(<phase-2>))[Only visible from phase 2.]

// -----------------------------------------------
// Test 8: Bounded range with (from-wp, until-wp) array
// -----------------------------------------------

== Bounded Range

#waypoint(<rng-a>, advance: false)
Range A.

#waypoint(<rng-b>)
Range B.

#waypoint(<rng-c>)
Range C.

#uncover((from-wp(<rng-a>), until-wp(<rng-c>)))[Visible during A and B only.]

#only((from-wp(<rng-b>), until-wp(<rng-c>)))[Only during B.]

// -----------------------------------------------
// Test 9: prev-wp / next-wp
// -----------------------------------------------

== Prev and Next WP

#waypoint(<nav-a>, advance: false)
Section A.

#waypoint(<nav-b>)
Section B.

#waypoint(<nav-c>)
Section C.

#only(next-wp(<nav-a>))[This shows during B (next after A).]

#only(prev-wp(<nav-c>))[This shows during B (prev before C).]

// -----------------------------------------------
// Test 10: from-wp(next-wp()) and until-wp(prev-wp()) composition
// -----------------------------------------------

== Composed Shifts

#waypoint(<cs-a>, advance: false)
Part A.

#waypoint(<cs-b>)
Part B.

#waypoint(<cs-c>)
Part C.

#uncover(from-wp(next-wp(<cs-a>)))[From B onward (next after A).]

#uncover(until-wp(prev-wp(
  <cs-c>,
)))[Until before C (prev of C = B => until B).]

// -----------------------------------------------
// Test 11: next-wp(until-wp()) pushed inward
// -----------------------------------------------

== Next-WP Until Push

#waypoint(<pu-a>)
Alpha.

#waypoint(<pu-b>)
Beta.

#waypoint(<pu-c>)
Gamma.

// next-wp(until-wp(<pu-b>)) becomes until-wp(next-wp(<pu-b>)) = until-wp(<pu-c>)
// So visible: subslides before pu-c = during A and B.
#uncover(next-wp(until-wp(<pu-a>), amount: 2))[Until Next^2(A): before C.]



// -----------------------------------------------
// Test 12: Alternatives with `at:`
// -----------------------------------------------

== Alternatives at Waypoints

#waypoint(<alt-a>, advance: false)

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

#uncover(<imp-end>)[New waypoint.]

// -----------------------------------------------
// Test 16: Multiple implicit waypoints
// -----------------------------------------------

== Multiple Implicit

Base content.

#uncover(<imp-a>)[Phase A content.]

#pause
Last of A, always.


#effect(text.with(fill: blue), <imp-b>)[Phase B styled.]

#only(<imp-c>)[Phase C only.]

#only((get-last(<imp-a>), <imp-c>))[On last of A, and at C.]

// -----------------------------------------------
// Test 17: Mixed explicit and implicit with from-wp()
// -----------------------------------------------

== Mixed Waypoints

#waypoint(<explicit-wp>, advance: false)

Explicit phase.

#uncover(<implicit-wp>)[Implicit phase content.]

#uncover(from-wp(<explicit-wp>))[Visible from explicit onward.]

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

#uncover(<eq-phase>)[Equation explanation visible from waypoint.]

#waypoint(<eq-after>)

Some more explanation.

#only(<eq-after>)[Visible after equation explanation.]


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

    #effect(text.with(fill: red), <cb-a>)[Red during cb-a.]
  ]
})

// -----------------------------------------------
// Test 21: Callback-style with get-first / get-last / from-wp
// -----------------------------------------------

== Callback Get-First Get-Last

#slide(self => {
  let (only,) = utils.methods(self)
  [
    #waypoint(<m1>, advance: false)
    Phase 1. \
    #pause
    Phase 1 continued. \
    #waypoint(<m2>)
    Phase 2. \

    #only(get-first(<m1>))[Exactly first of m1.]
    #only(get-last(<m1>))[Exactly last of m1.]
    #only(from-wp(<m2>))[From m2 onward.]
  ]
})

// -----------------------------------------------
// Test 22: Callback-style with alternatives at:
// -----------------------------------------------

== Callback Alternatives

#slide(self => {
  [
    #waypoint(<ca>, advance: false)
    Phase A. \
    #waypoint(<cb>)
    Phase B. \
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

#slide(self => {
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
#uncover(until-wp(<summary>))[Title: shown before summary.]

Content.

#waypoint(<summary>)

Summary text.

#uncover(from-wp(<summary>))[Summary visible.]

// -----------------------------------------------
// Test 26: Inclusive bounded range with next-wp
// -----------------------------------------------

== Inclusive Range

#waypoint(<ir-a>, advance: false)
Part A.

#waypoint(<ir-b>)
Part B.

#waypoint(<ir-c>)
Part C.

// from-wp(<ir-a>), until-wp(<ir-b>) = only A
// from-wp(<ir-a>), next-wp(until-wp(<ir-b>)) = until-wp(next-wp(<ir-b>)) = until-wp(<ir-c>) → A and B
#only((from-wp(<ir-a>), until-wp(<ir-b>)))[Exactly during A.]

#only((
  from-wp(<ir-a>),
  next-wp(until-wp(<ir-b>)),
))[During A and B (inclusive of B).]

// -----------------------------------------------
// Test 27: prev-wp / next-wp with amount parameter
// -----------------------------------------------

== Amount Shift

#waypoint(<am-a>, advance: false)
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

// Compose with from: from-wp(next-wp(<am-a>, amount: 2)) = from am-c onward
#uncover(from-wp(next-wp(
  <am-a>,
  amount: 2,
)))[From Next^2(A): C onward (amount: 2).]

// -----------------------------------------------
// Test 28: Hierarchy — parent first, then child (two subslides)
// -----------------------------------------------

== Parent Then Child

#waypoint(<top>, advance: false)
Top content.

#waypoint(<top:sub>)
Sub content.

#only(get-first(<top>))[Exactly first of top (the parent phase).]

#only(get-last(<top>))[Exactly last of top: the sub phase.]

#only(<top:sub>)[Only during the sub-waypoint.]

// -----------------------------------------------
// Test 29: Hierarchy — child first, parent is no-op
// -----------------------------------------------

== Child First

#waypoint(<rev:child>, advance: false)
Child content.

#waypoint(<rev>)
This is a no-op; both on same subslide.

#only(<rev:child>)[During the child waypoint.]

#only(<rev>)[During parent — same as child.]

// -----------------------------------------------
// Test 30: Implicit child first, then implicit parent — no-op
// -----------------------------------------------

== Implicit Child First

#uncover(<ic:sub>)[Child implicit content.]

#uncover(<ic>)[Parent implicit — no-op, same subslide as child.]

// -----------------------------------------------
// Test 31: Implicit parent first, then implicit child (two subslides)
// -----------------------------------------------

== Implicit Parent Then Child

#uncover(<ip>)[Parent implicit content.]

#uncover(<ip:sub>)[Child implicit content.]

#only(get-first(<ip>))[First of parent.]

#only(get-last(<ip>))[Last of parent: the child phase.]

// -----------------------------------------------
// Test 32: Deep hierarchy — three levels
// -----------------------------------------------

== Deep Hierarchy

#waypoint(<d>, advance: false)
Level 0.

#waypoint(<d:a>)
Level 1.

#waypoint(<d:a:x>)
Level 2.

#only(get-first(<d>))[First of d: level 0.]

#only(get-last(<d>))[Last of d: level 2.]

#only(get-first(<d:a>))[First of d:a: level 1.]

#only(get-last(<d:a>))[Last of d:a: level 2.]

// -----------------------------------------------
// Test 33: Mixed explicit and implicit hierarchy
// -----------------------------------------------

== Mixed Hierarchy

#waypoint(<mx>, advance: false)
Explicit parent.

#uncover(<mx:detail>)[Implicit child detail.]

#only(get-last(<mx>))[Last of mx: the detail phase.]

// -----------------------------------------------
// Test 34: Hierarchy with from/until
// -----------------------------------------------

== Hierarchy With From

#waypoint(<hf>, advance: false)
Phase A.

#waypoint(<hf:more>)
Phase B.

#waypoint(<other>)
Phase C.

#uncover(from-wp(<hf>))[From hf onward — visible on A, B, and C.]

#only((from-wp(<hf>), until-wp(<other>)))[During A and B only.]

// -----------------------------------------------
// Test 35: prev-wp / next-wp with hierarchical labels
// -----------------------------------------------

== Hierarchy Nav

#waypoint(<hn:a>, advance: false)
Part A.

#waypoint(<hn:b>)
Part B.

#waypoint(<hn:c>)
Part C.

#only(next-wp(<hn:a>))[During B (next after A).]

#only(prev-wp(<hn:c>))[During B (prev before C).]

// -----------------------------------------------
// Test 36: Forward reference in callback
// -----------------------------------------------

== Callback Forward Reference

#slide(self => {
  let (uncover, only) = utils.methods(self)
  [
    #uncover(until-wp(<cb-summary>))[Title: shown before summary.]

    Content.

    #waypoint(<cb-summary>)

    Summary text.

    #uncover(from-wp(<cb-summary>))[Summary visible.]

    #only(<cb-summary>)[Only during summary.]
  ]
})


// -----------------------------------------------
// Test 37: touying-equation then waypoint
// -----------------------------------------------

== Equation Block then Waypoint

Before equation.

#touying-equation(`f(x) = pause x^2`)

#waypoint(<after-eq-block>)

After equation text via waypoint.

#uncover(<after-eq-block>)[Only after equation animation.]


// -----------------------------------------------
// Test 38: touying-raw then waypoint
// -----------------------------------------------

== Raw Block then Waypoint

Before raw.

#touying-raw(```rust
fn main() {
    // pause
    println!("Hello!");
}
```)

#waypoint(<after-raw>)

After raw text via waypoint.

#only(<after-raw>)[Only after raw animation.]


// -----------------------------------------------
// Test 39: touying-equation with 2 pauses then waypoint + from-wp
// -----------------------------------------------

== Multi-pause Equation then Waypoint

#touying-equation(
  `
  f(x) &= pause x^2 + 2x + 1 \
       &= pause (x + 1)^2
`,
)

#waypoint(<after-multi-eq>)

#uncover(from-wp(<after-multi-eq>))[Visible only after all equation pauses.]

#only(get-first(<after-multi-eq>))[Exactly on the waypoint subslide.]


// -----------------------------------------------
// Test 40: CeTZ reducer then waypoint
// -----------------------------------------------

== CeTZ then Waypoint

#cetz-canvas({
  import cetz.draw: *
  rect((0, 0), (4, 3))
  (pause,)
  circle((2, 1.5), radius: 1)
})

#waypoint(<after-cetz>)

#uncover(<after-cetz>)[Visible after CeTZ animation.]

#only(from-wp(<after-cetz>))[From-wp after CeTZ.]


// -----------------------------------------------
// Test 41: Fletcher reducer then waypoint
// -----------------------------------------------

== Fletcher then Waypoint

#fletcher-diagram(
  node-stroke: .1em,
  spacing: 3em,
  node((0, 0), `A`, radius: 1.5em),
  edge(`go`, "-|>"),
  pause,
  node((1, 0), `B`, radius: 1.5em),
)

#waypoint(<after-fletcher>)

#uncover(<after-fletcher>)[Visible after Fletcher animation.]

#only(from-wp(<after-fletcher>))[From-wp after Fletcher.]


// -----------------------------------------------
// Test 42: Waypoint inside CeTZ reducer
// -----------------------------------------------

== Waypoint inside CeTZ

#cetz-canvas({
  import cetz.draw: *
  rect((0, 0), (4, 3))
  (waypoint(<cetz-mid>, advance: false),)
  (pause,)
  circle((2, 1.5), radius: 1)
  (waypoint(<cetz-end>),)
  circle((2, 1.5), radius: 0.1, fill: red, stroke: none)
})

#uncover(<cetz-mid>)[Visible from start (no-advance waypoint inside CeTZ).]

#uncover(<cetz-end>)[Visible when Cetz Red Dot appears.]

#only(from-wp(<cetz-end>))[From-wp referencing waypoint inside CeTZ.]


// -----------------------------------------------
// Test 43: Waypoint inside Fletcher reducer
// -----------------------------------------------

== Waypoint inside Fletcher

#fletcher-diagram(
  node-stroke: .1em,
  spacing: 3em,
  node((0, 0), `A`, radius: 1.5em),
  waypoint(<fl-mid>, advance: false),
  pause,
  edge(`go`, "-|>"),
  node((1, 0), `B`, radius: 1.5em),
  waypoint(<fl-after-b>),
  edge((1, 0), (0, 0), `back`, "|->", bend: 50deg),
)

#uncover(<fl-mid>)[Visible from start (no-advance waypoint in Fletcher).]

#uncover(get-last(<fl-mid>))[Visible after node B appears.]

#only(from-wp(<fl-after-b>))[From-wp referencing back waypoint inside Fletcher.]


// -----------------------------------------------
// Test 44: Waypoint inside reducer + outer waypoint interaction
// -----------------------------------------------

== Reducer Waypoint with Outer Reference

#cetz-canvas({
  import cetz.draw: *
  rect((0, 0), (4, 3))
  (pause,)
  line((0, 0), (4, 3))
  (waypoint(<inner-cetz>),)
  circle((2, 1.5), radius: 0.5)
  (waypoint(<after-inner-cetz>),)
  rect((0, 0), (4, 3), stroke: red)
})

#waypoint(<after-inner-cetz>) //noop bc inside already declares it.

Text after CeTZ. Box should be red now.

#uncover(from-wp(<inner-cetz>))[From inner CeTZ waypoint (subslide 3).]

#uncover(from-wp(
  <after-inner-cetz>,
))[From outer waypoint after CeTZ (subslide 4).]

// ------------------------------------------------
// Test 45: get-last inside from-wp resolves correctly
// -----------------------------------------------
// <gl-phase> spans subslides 1-2 (pause inside its range), <gl-after> at 3.
// from-wp(get-last(<gl-phase>)) should mean "from subslide 2 onward".
// BUG before fix: resolved to (beginning: 1) instead of (beginning: 2).

== get-last inside from-wp

#waypoint(<gl-phase>, advance: false)
Phase content.
#pause
More phase content.
#waypoint(<gl-after>)
After content.

#only(get-first(<gl-phase>))[First of phase only (subslide 1).]
#only(get-last(<gl-phase>))[Last of phase only (subslide 2).]
#uncover(from-wp(get-last(
  <gl-phase>,
)))[From last of phase onward (subslides 2-3).]

// -----------------------------------------------
// Test 46: get-first inside from-wp (control — should behave like bare label)
// -----------------------------------------------

== get-first inside from-wp

#waypoint(<gf-phase>, advance: false)
Phase content.
#pause
More phase content.
#waypoint(<gf-after>)
After content.

#uncover(from-wp(get-first(
  <gf-phase>,
)))[From first of phase onward (subslides 1-3).]
#uncover(from-wp(<gf-phase>))[From phase onward (subslides 1-3, same).]

// -----------------------------------------------
// Test 47: get-last inside until-wp
// -----------------------------------------------

== get-last inside until-wp

#waypoint(<gu-a>, advance: false)
Part A.
#pause
More A.
#waypoint(<gu-b>)
Part B.

#uncover(until-wp(get-last(<gu-a>)))[Until last of A (subslide 1 only).]
#uncover(from-wp(get-last(<gu-a>)))[From last of A onward (subslides 2-3).]

