#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Waypoints — Touying],
)

#let code-col(code-text) = {
  set text(size: 16pt)
  block(
    width: 100%,
    fill: luma(245),
    inset: 6pt,
    radius: 4pt,
    raw(block: true, lang: "typst", code-text),
  )
}
#set text(size: 20pt)

#title-slide[
  = Waypoints
  _Name your subslides, not count them._
  #v(1em)
  A Touying Waypoints Guide
]

= The Problem

== Why waypoints?

With numeric indices, inserting a `#pause` shifts every number:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    *Before* — correct:
    ```typst
    A #pause B #pause C
    #uncover("2-")[From 2]
    #only(3)[Only on 3]
    ```
  ],
  [
    *After* adding a pause — broken:
    ```typst
    A #pause A2 #pause B #pause C
    #uncover("2-")[From 2] // wrong!
    #only(3)[Only on 3]    // wrong!
    ```
  ],
)

#pause

*Waypoints* replace fragile numbers with stable names:

```typst
#waypoint(<reveal>)          // named pause
#uncover(<reveal>)[content]  // refers to the name
```

And in reality we don't need to know every single animation step, special ones are often enough.
Note: Waypoints are not compatible within `cetz` or similar contexts.


= Explicit Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#waypoint` + `#uncover`]
  #code-col("Content before.\n#waypoint(<demo>)\nFirst Content.\n#pause\nSecond Content.\n#uncover(<demo>)[\n  Revealed during waypoint.\n]")
  `#waypoint` acts like `#pause` but names the position.
  `#uncover(<lbl>)` shows content during that waypoint's range.
][
  Content before.
  #waypoint(<demo>)
  First Content.
  #pause
  Second Content.
  #uncover(<demo>)[Revealed during waypoint.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#waypoint` + `#uncover` (multiple)]
  #code-col("
    #waypoint(<intro>)
    Intro phase.
    #pause
    More Intro.
    #waypoint(<detail>)
    Detail phase.
    #uncover(<intro>)[During intro.]
    #uncover(<detail>)[During detail.]
  ")
  Each waypoint owns a range of subslides. Content uncovered with a label is visible only during that range.
][
  #waypoint(<intro>)
  Intro phase.
  #pause
  More Intro.
  #waypoint(<detail>)
  Detail phase.
  #uncover(<intro>)[During _intro_.]
  #uncover(<detail>)[During _detail_.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#waypoint` + `#effect`]
  #code-col("Normal text.\n#waypoint(<hl>)\n#effect(\n  text.with(fill: red), <hl>\n)[Red during <hl>.]")
  `#effect(fn, <lbl>)` applies a transform while the waypoint is active.
][
  Normal text.
  #waypoint(<hl>)
  #effect(text.with(fill: red), <hl>)[Red during `<hl>`.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[No-advance waypoint]
  #code-col("#waypoint(<here>, advance: false)\nStill subslide 1.\n#uncover(<here>)[\n  Visible immediately.\n]")
  `advance: false` marks the position *without* creating a new subslide.
][
  #waypoint(<here>, advance: false)
  Still subslide 1.
  #uncover(<here>)[Visible immediately.]
]

= Querying Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`get-first` / `get-last`]
  #code-col("#waypoint(<p>)\nStart. #pause\nContinued.\n#waypoint(<q>)\nNext.\n#only(get-first(<p>))[First of p.]\n#only(get-last(<p>))[Last of p.]")
  A waypoint spanning multiple subslides (due to `#pause` inside its range) can be queried at its edges.
][
  #waypoint(<p>)
  Start. #pause
  Continued.
  #waypoint(<q>)
  Next.
  #only(get-first(<p>))[First of `<p>` only.]
  #only(get-last(<p>))[Last of `<p>` only.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`from` — onward from a waypoint]
  #code-col("#waypoint(<step>)\nStep content.\n#waypoint(<later>)\nLater content.\ \n#uncover(from(<step>))[\n  From step onward — through `<later>` too.\n]")
  #text(size:20pt)[`from(<lbl>)` is visible from the waypoint's first subslide to the *end of the slide*. Unlike a bare label, it is not bounded by the next waypoint.]
][
  #waypoint(<step>)
  Step content.
  #waypoint(<later>)
  Later content. \
  #uncover(from(<step>))[From `<step>` onward — through `<later>` too.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`until` — before a waypoint]
  #code-col("#waypoint(<phase-1>)\nPhase 1 content.\n#waypoint(<phase-2>)\nPhase 2 content.\n#uncover(until(<phase-2>))[\n  Before phase 2.\n]\n#uncover(from(<phase-2>))[\n  Only from phase 2.\n]")
  `until(<lbl>)` is visible on all subslides *before* the waypoint starts — including subslides before any waypoint is reached.
][
  #waypoint(<phase-1>)
  Phase 1 content.
  #waypoint(<phase-2>)
  Phase 2 content.
  #uncover(until(<phase-2>))[Before phase 2.]
  #uncover(from(<phase-2>))[Only from phase 2.]
]

= Ranges & Navigation

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Bounded range]
  #code-col("#waypoint(<ra>)\nRange A.\n#waypoint(<rb>)\nRange B.\n#waypoint(<rc>)\nRange C.\n#uncover(\n  (from(<ra>), until(<rc>))\n)[During A and B.]")
  Combine `from` and `until` in an array to span a range. Runs from `<ra>` up to (but not including) `<rc>`.
][
  #waypoint(<ra>)
  Range A.
  #waypoint(<rb>)
  Range B.
  #waypoint(<rc>)
  Range C.
  #uncover((from(<ra>), until(<rc>)))[During A and B.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`prev-wp` / `next-wp`]
  #code-col("#waypoint(<na>)\nSection A.\n#waypoint(<nb>)\nSection B.\n#waypoint(<nc>)\nSection C.\n#only(next-wp(<na>))[\n  During B (next after A).\n]\n#only(prev-wp(<nc>))[\n  During B (prev before C).\n]")
  Jump to the adjacent waypoint in subslide order. \
  In fact you may also pass an `amount` to jump multiple waypoints: `next-wp(<lbl>, amount: 2)`.
][
  #waypoint(<na>)
  Section A.
  #waypoint(<nb>)
  Section B.
  #waypoint(<nc>)
  Section C.
  #only(next-wp(<na>))[During B (next after A).]
  #only(prev-wp(<nc>))[During B (prev before C).]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Composing shifts with from/until]
  #code-col("#waypoint(<ca>)\nPart A.\n#waypoint(<cb>)\nPart B.\n#waypoint(<cc>)\nPart C.\n// from(next-wp(<ca>)) = from B\n#uncover(from(next-wp(<ca>)))[\n  From B onward.\n]\n// until(prev-wp(<cc>)) = until B\n#uncover(until(prev-wp(<cc>)))[\n  Only during A.\n]")
  Shifts compose naturally with `from`/`until`.
][
  #waypoint(<ca>)
  Part A.
  #waypoint(<cb>)
  Part B.
  #waypoint(<cc>)
  Part C.
  #uncover(from(next-wp(<ca>)))[From B onward.]
  #uncover(until(prev-wp(<cc>)))[Only during A.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Inclusive range via `next-wp`]
  #code-col("#waypoint(<ia>)\nPart A.\n#waypoint(<ib>)\nPart B.\n#waypoint(<ic>)\nPart C.\n// A only (exclusive of B)\n#only((from(<ia>), until(<ib>)))[\n  Exactly A.\n]\n// A and B (inclusive)\n#only((from(<ia>),\n   next-wp(until(<ib>)))\n)[A and B.]")
  `next-wp(until(<ib>))` → `until(<ic>)`, so `<ib>` is included.
][
  #waypoint(<ia>)
  Part A.
  #waypoint(<ib>)
  Part B.
  #waypoint(<ic>)
  Part C.
  #only((from(<ia>), until(<ib>)))[Exactly during A.]
  #only((from(<ia>), next-wp(until(<ib>))))[During A and B (inclusive).]
]

= Implicit Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Labels as auto-waypoints]
  #code-col("Always visible.\n#uncover(<imp-rev>)[\n  Appears via implicit wp.\n]")
  Using a label in `#uncover`, `#only`, or `#effect` creates a waypoint automatically — no `#waypoint` call needed.
][
  Always visible.
  #uncover(<imp-rev>)[Appears via implicit waypoint.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Multiple implicit]
  #code-col("Base content.\n#uncover(<im-a>)[Phase A.]\n#effect(\n  text.with(fill: blue), <im-b>\n)[Phase B styled.]\n#only(<im-c>)[Phase C only.]")
  Each distinct label → one implicit waypoint. Reusing a label adds no extra subslides.
][
  Base content.
  #uncover(<im-a>)[Phase A.]
  #effect(text.with(fill: blue), <im-b>)[Phase B styled.]
  #only(<im-c>)[Phase C only.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Mixed explicit + implicit]
  #code-col("#waypoint(<expl>)\nExplicit phase.\n#uncover(<impl>)[\n  Implicit phase.\n]\n#uncover(from(<expl>))[\n  From explicit onward.\n]")
][
  #waypoint(<expl>)
  Explicit phase.
  #uncover(<impl>)[Implicit phase.]
  #uncover(from(<expl>))[From explicit onward.]
]

= Forward References

== Using waypoints before they are defined

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Forward reference]
  #code-col("// Reference before definition\n#uncover(until(<summary>))[\n  Shown before summary.\n]\nContent.\n#waypoint(<summary>)\nSummary text.\n#uncover(from(<summary>))[\n  Summary visible.\n]")
  Waypoints can be referenced *before* they are defined on the same slide. `from`/`until` are lazy markers resolved at render time — after all waypoints are collected.
][
  #uncover(until(<summary>))[Shown before summary.]
  Content.
  #waypoint(<summary>)
  Summary text.
  #uncover(from(<summary>))[Summary visible.]
]

== Rules for waypoint references

- *Forward references work.* `from(<lbl>)`, `until(<lbl>)`, and bare `<lbl>` can appear before `#waypoint(<lbl>)` (or other waypoint creating functions) on the same slide.

- *Cross-slide references do not work.* Waypoints are scoped to a single slide. A label defined on slide 3 cannot be used on slide 5.

- *Undefined waypoints are errors.* If a label is referenced but never defined on the slide (by `#waypoint` or an implicit label), Touying raises an error at the end of the slide.

- *Implicit waypoints are created at first use.* `#uncover(<lbl>)` both references and defines the waypoint — a forward reference is never needed for implicit waypoints.

= Advanced Usage

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#alternatives` with `at:`]
  #code-col("#waypoint(<opt-a>)\nOption A active.\n#waypoint(<opt-b>)\nOption B active.\n#alternatives(\n  at: (<opt-a>, <opt-b>)\n)[Content A.][Content B.]")
  Maps each body to a named waypoint instead of sequential numbering.
][
  #waypoint(<opt-a>)
  Option A active.
  #waypoint(<opt-b>)
  Option B active.
  #alternatives(at: (<opt-a>, <opt-b>))[Content *A*.][Content *B*.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`item-by-item` — relative (auto)]
  #code-col("Text before.\n#pause\nAfter first pause.\n#item-by-item[\n  - First item\n  - Second item\n  - Third item\n]")
  With `start: auto` (default), items continue from the current pause position.
][
  Text before.
  #pause
  After first pause.
  #item-by-item[
    - First item
    - Second item
    - Third item
  ]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`item-by-item` with waypoint start]
  #code-col("#waypoint(<list-wp>)\n#item-by-item(start: <list-wp>)[\n  - Alpha\n  - Beta\n  - Gamma\n]\n#uncover(<list-wp>)[\n  List revealed above.\n]")
  Anchor the item reveal to a named waypoint.
][
  #waypoint(<list-wp>)
  #item-by-item(start: <list-wp>)[
    - Alpha
    - Beta
    - Gamma
  ]
  #uncover(<list-wp>)[List revealed above.]
]

== Callback style

#slide(self => {
block(width: 50%)[
  #code-col("#slide(self => {
  let (uncover, only) = utils.methods(self)
  [
    Base content.
    #waypoint(<cb-a>)
    #uncover(<cb-a>)[Uncovered from cb-a.]
    #waypoint(<cb-b>)
    #only(<cb-b>)[Only during cb-b.]
  ]
})")
]
[ 
    #let (uncover, only) = utils.methods(self)
    Base content.
    #waypoint(<cb-a>)
    #uncover(<cb-a>)[Uncovered from `<cb-a>`.]
    #waypoint(<cb-b>)
    #only(<cb-b>)[Only during `<cb-b>`.]
  ]
})

== Hierarchical Waypoints

#slide(composer: (1fr,1fr))[
  #code-col("#alternatives(at: (<intro>, <more>))[Introduction.][More details.]
  #waypoint(<intro:background>)
  Some background during intro.
  #waypoint(<intro:goal>)
  The goal during intro.
  #waypoint(<more:analysis>)
  Analysis during more.
  #waypoint(<more:results>)
  Results during more.")
  You may even construct hierarchical waypoints, which we collect automatically by their shared top level. \ We use ':' as the separator of levels.
][
  #alternatives(at: (<intro>, <more>))[*Introduction.*][*More details.*]\
  #waypoint(<intro:background>)
  Some background during intro.
  #waypoint(<intro:goal>)
  The goal during intro. \
  #waypoint(<more:analysis>)
  Analysis during more.
  #waypoint(<more:results>)
  Results during more.
]

= Summary

== Quick reference

#set text(size: 13pt)

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  inset: 5pt,
  align: (left, left),
  table.header[*Syntax*][*Effect*],
  [`#waypoint(<lbl>)`], [Named `#pause` — marks + advances],
  [`#waypoint(<lbl>, advance: false)`], [Marks without advancing],
  [`#uncover(<lbl>)[...]`], [Show during waypoint range (implicit)],
  [`#only(<lbl>)[...]`], [Show only during range (implicit)],
  [`#effect(fn, <lbl>)[...]`], [Apply style during range (implicit)],
  [`get-first(<lbl>)`], [First subslide of the range],
  [`get-last(<lbl>)`], [Last subslide of the range],
  [`from(<lbl>)`], [From waypoint to end of slide],
  [`until(<lbl>)`], [Before waypoint (exclusive)],
  [`next-wp(<lbl>, amount:1)`], [Adjacent waypoint (forward), allows `amount` to skip multiple],
  [`prev-wp(<lbl>, amount:1)`], [Adjacent waypoint (backward), allows `amount` to skip multiple],
  [`(from(<a>), until(<b>))`], [Bounded range: `<a>` to before `<b>`],
  [`#alternatives(at: (..))[..][..]`], [Named alternative mapping],
  [`#item-by-item[...]`], [Relative item reveal (auto from pause)],
  [`#item-by-item(start: <wp>)[...]`], [Waypoint-anchored item reveal],
  [`<label:sublabel>`], [Hierarchical waypoint. The parent (e.g. `<label>`) refers to all its children (e.g. `<label:sublabel>`).],
)
