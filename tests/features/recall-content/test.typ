#import "/lib.typ": *
#import themes.simple: *
#import "@preview/cetz:0.4.2"

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

== Source: Animated Table

#table(
  columns: 2,
  [Header 1], [Header 2], pause,
  [Cell 1], [Cell 2], pause,
  [Cell 3], [Cell 4],
) <my-table>

== Source: Animated Reducer

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#cetz-canvas(label: "my-diagram", {
  import cetz.draw: *
  rect((0, 0), (4, 3), fill: blue.lighten(80%), stroke: blue)
  (pause,)
  circle((2, 1.5), radius: 0.8, fill: red.lighten(60%), stroke: red)
  (pause,)
  line((0, 0), (4, 3), stroke: 2pt + green)
}, length: 30pt)

== Source: Static Content

#rect(width: 3cm, height: 2cm, fill: yellow, [Static box]) <my-static>

== Source: Content With Waypoints
before content #pause
#block[
  First stage. #waypoint(<wp-a>, advance: false) #pause
  Second stage. #waypoint(<wp-b>)
  Third stage. #uncover("4")[third again]
] <wp-block>

== Recall Table: default (auto — final state)

#touying-recall(<my-table>)

== Recall Table: subslide 1

#touying-recall(<my-table>, subslide: 1)

== Recall Table: subslide 2

#touying-recall(<my-table>, subslide: 2)

== Recall Table: negative index (last)

#touying-recall(<my-table>, subslide: -1)

== Recall Table: none (final state, explicit)

#touying-recall(<my-table>, subslide: none)

== Recall Table: alongside other content

Some text before the recall:

#touying-recall(<my-table>, subslide: 2)

Some text after the recall, on the same slide — confirms the recall renders
natively inside this slide instead of creating its own separate page.

== Recall Reducer: default (auto — final state)

#touying-recall(<my-diagram>)

== Recall Reducer: subslide 1

#touying-recall(<my-diagram>, subslide: 1)

== Recall Reducer: subslide 2

#touying-recall(<my-diagram>, subslide: 2)

== Recall Reducer: negative index (last)

#touying-recall(<my-diagram>, subslide: -1)

== Recall Reducer: with base offset

#figure(
  scale(50%, reflow: true)[#touying-recall(
    <my-diagram>,
    subslide: 3,
    base: 2, // accounts for the outer context
  )],
  caption: [Scaled recall with an outer pause already advancing the counter],
)

== Recall Static Content: default

#touying-recall(<my-static>)

== Recall Static Content: alongside other content

Text before:
#touying-recall(<my-static>)
Text after — confirms it doesn't create its own separate page/slide either.

== Recall via Waypoint: get-first

Only "First stage." should be visible — `<wp-a>` marks the start of its
own phase (`advance: false`, so it doesn't itself create a new subslide),
and the range collapses to its first subslide.

#touying-recall(<wp-block>, subslide: get-first(<wp-a>))

== Recall via Waypoint: get-last

Same waypoint, resolved via `get-last` instead — `<wp-a>`'s range extends
through the next subslide (up to where `<wp-b>` begins), so this shows the
cumulative state up to there: "First stage. Second stage."

#touying-recall(<wp-block>, subslide: get-last(<wp-a>))

== Recall via Waypoint: bare label

A bare waypoint label (not wrapped in `get-first`/`get-last`) also collapses
to its first subslide. `<wp-b>` sits at the block's own final stage, so this
shows the full cumulative text — same output as the `base: auto` column of
the base-shifted grid below.

#touying-recall(<wp-block>, subslide: <wp-b>)

== Recall via Waypoint: base-shifted (regression test for the base-shift bug)

// Both recalls below target the same waypoint (`<wp-b>`, "Second stage.", not
// `<wp-block>`'s own first stage) but with a different `base:` — this is
// exactly the case that renders the wrong stage without the base-shift fix
// (waypoints collected from `<wp-block>`'s own body are always in local,
// base-1 terms, so resolving them against an outer `base:` requires shifting
// the result). Both should render identically ("Second stage." only).

#grid(
  columns:3,
  gutter: 1cm,
  [
    `base: auto` \
    #touying-recall(<wp-block>, subslide: get-first(<wp-b>))
  ],
  [
    `base: 2` \
    #touying-recall(<wp-block>, subslide: get-first(<wp-b>), base: 2)
  ],
  [
    `base: 2, int` \
    #touying-recall(<wp-block>, subslide: 4, base: 2)
  ],
)

== Recall Nesting: touying-recall inside uncover/only

// `touying-recall`'s fallback path has no visibility of its own — nesting it
// inside `uncover`/`only` lets the outer wrapper gate it exactly like ordinary
// content, appearing then disappearing again across the outer subslides.
#v(-1em)
#uncover("2-3")[Uncover-gated recall (reserves space): #touying-recall(<my-table>, subslide: 2)]
#v(-1em)
#only("2")[Only-gated recall (no reserved space): #touying-recall(<my-table>, subslide: 2)]

text stays and moves upwards