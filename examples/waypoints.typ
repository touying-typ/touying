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
Note: Waypoints work in contexts like fletcher, but not inside text blocks like raw.


= Explicit Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#waypoint` + `#uncover`]
  #code-col(
    "Content before.\n#waypoint(<demo>)\nFirst Content.\n#pause\nSecond Content.\n#uncover(<demo>)[\n  Revealed during waypoint.\n]",
  )
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
  #code-col(
    "
    #waypoint(<intro>)
    Intro phase.
    #pause
    More Intro.
    #waypoint(<detail>)
    Detail phase.
    #uncover(<intro>)[During intro.]
    #uncover(<detail>)[During detail.]
  ",
  )
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
  #code-col(
    "Normal text.\n#waypoint(<hl>)\n#effect(\n  text.with(fill: red), <hl>\n)[Red during <hl>.]",
  )
  `#effect(fn, <lbl>)` applies a transform while the waypoint is active.
][
  Normal text.
  #waypoint(<hl>)
  #effect(text.with(fill: red), <hl>)[Red during `<hl>`.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[No-advance waypoint]
  #code-col(
    "#waypoint(<here>, advance: false)\nStill subslide 1.\n#uncover(<here>)[\n  Visible immediately.\n]",
  )
  `advance: false` marks the position *without* creating a new subslide.
][
  #waypoint(<here>, advance: false)
  Still subslide 1.
  #uncover(<here>)[Visible immediately.]
]

= Querying Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`get-first` / `get-last`]
  #code-col(
    "#waypoint(<p>)\nStart. #pause\nContinued.\n#waypoint(<q>)\nNext.\n#only(get-first(<p>))[First of p.]\n#only(get-last(<p>))[Last of p.]",
  )
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
  #text(weight: "bold")[`from-wp` — onward from a waypoint]
  #code-col(
    "#waypoint(<step>)\nStep content.\n#waypoint(<later>)\nLater content.\ \n#uncover(from-wp(<step>))[\n  From step onward — through `<later>` too.\n]",
  )
  #text(
    size: 20pt,
  )[`from-wp(<lbl>)` is visible from the waypoint's first subslide to the *end of the slide*. Unlike a bare label, it is not bounded by the next waypoint.]
][
  #waypoint(<step>)
  Step content.
  #waypoint(<later>)
  Later content. \
  #uncover(from-wp(<step>))[From `<step>` onward — through `<later>` too.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`until-wp` — before a waypoint]
  #code-col(
    "#waypoint(<phase-1>)\nPhase 1 content.\n#waypoint(<phase-2>)\nPhase 2 content.\n#uncover(until-wp(<phase-2>))[\n  Before phase 2.\n]\n#uncover(from-wp(<phase-2>))[\n  Only from phase 2.\n]",
  )
  `until-wp(<lbl>)` is visible on all subslides *before* the waypoint starts — including subslides before any waypoint is reached.
][
  #waypoint(<phase-1>)
  Phase 1 content.
  #waypoint(<phase-2>)
  Phase 2 content.
  #uncover(until-wp(<phase-2>))[Before phase 2.]
  #uncover(from-wp(<phase-2>))[Only from phase 2.]
]

= Ranges & Navigation

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Bounded range]
  #code-col(
    "#waypoint(<ra>)\nRange A.\n#waypoint(<rb>)\nRange B.\n#waypoint(<rc>)\nRange C.\n#uncover(\n  (from-wp(<ra>), until-wp(<rc>))\n)[During A and B.]",
  )
  Combine `from-wp` and `until-wp` in an array to span a range. Runs from `<ra>` up to (but not including) `<rc>`.
][
  #waypoint(<ra>)
  Range A.
  #waypoint(<rb>)
  Range B.
  #waypoint(<rc>)
  Range C.
  #uncover((from-wp(<ra>), until-wp(<rc>)))[During A and B.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`prev-wp` / `next-wp`]
  #v(-0.5em)
  #code-col(
    "#waypoint(<na>)\nSection A.\n#waypoint(<nb>)\nSection B.\n#waypoint(<nc>)\nSection C.\n#only(next-wp(<na>))[\n During B (next after A).\n]\n#only(prev-wp(<nc>))[\n  During B (prev before C).\n]",
  )
  Jump to the adjacent waypoint in subslide order.
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
  #text(weight: "bold")[Composing shifts with `from-wp`/`until-wp`]
  #code-col(
    "#waypoint(<ca>)\nPart A.\n#waypoint(<cb>)\nPart B.\n#waypoint(<cc>)\nPart C.\n// from-wp(next-wp(<ca>)) = from B\n#uncover(from-wp(next-wp(<ca>)))[\n  From B onward.\n]\n// until-wp(prev-wp(<cc>)) = until B\n#uncover(until-wp(prev-wp(<cc>)))[\n  Only during A.\n]",
  )
  Shifts compose naturally with `from-wp`/`until-wp`.
][
  #waypoint(<ca>)
  Part A.
  #waypoint(<cb>)
  Part B.
  #waypoint(<cc>)
  Part C.
  #uncover(from-wp(next-wp(<ca>)))[From B onward.]
  #uncover(until-wp(prev-wp(<cc>)))[Only during A.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Inclusive range via `next-wp`]
  #code-col(
    "#waypoint(<ia>)\nPart A.\n#waypoint(<ib>)\nPart B.\n#waypoint(<ic>)\nPart C.\n// A only (exclusive of B)\n#only((from-wp(<ia>), until-wp(<ib>)))[\n  Exactly A.\n]\n// A and B (inclusive)\n#only((from-wp(<ia>),\n   next-wp(until-wp(<ib>)))\n)[A and B.]",
  )
  `next-wp(until-wp(<ib>))` → `until-wp(<ic>)`, so `<ib>` is included.
][
  #waypoint(<ia>)
  Part A.
  #waypoint(<ib>)
  Part B.
  #waypoint(<ic>)
  Part C.
  #only((from-wp(<ia>), until-wp(<ib>)))[Exactly during A.]
  #only((from-wp(<ia>), next-wp(until-wp(<ib>))))[During A and B (inclusive).]
]

= Implicit Waypoints

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Labels as auto-waypoints]
  #code-col(
    "Always visible.\n#uncover(<imp-rev>)[\n  Appears via implicit wp.\n]",
  )
  Using a label in `#uncover`, `#only`, or `#effect` creates a waypoint automatically — no `#waypoint` call needed.
][
  Always visible.
  #uncover(<imp-rev>)[Appears via implicit waypoint.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Multiple implicit]
  #code-col(
    "Base content.\n#uncover(<im-a>)[Phase A.]\n#effect(\n  text.with(fill: blue), <im-b>\n)[Phase B styled.]\n#only(<im-c>)[Phase C only.]",
  )
  Each distinct label → one implicit waypoint. Reusing a label adds no extra subslides.
][
  Base content.
  #uncover(<im-a>)[Phase A.]
  #effect(text.with(fill: blue), <im-b>)[Phase B styled.]
  #only(<im-c>)[Phase C only.]
]

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Mixed explicit + implicit]
  #code-col(
    "#waypoint(<expl>)\nExplicit phase.\n#uncover(<impl>)[\n  Implicit phase.\n]\n#uncover(from-wp(<expl>))[\n  From explicit onward.\n]",
  )
][
  #waypoint(<expl>)
  Explicit phase.
  #uncover(<impl>)[Implicit phase.]
  #uncover(from-wp(<expl>))[From explicit onward.]
]

= Forward References

== Using waypoints before they are defined

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[Forward reference]
  #code-col(
    "// Reference before definition\n#uncover(until-wp(<summary>))[\n  Shown before summary.\n]\nContent.\n#waypoint(<summary>)\nSummary text.\n#uncover(from-wp(<summary>))[\n  Summary visible.\n]",
  )
  Waypoints can be referenced *before* they are defined on the same slide. `from-wp`/`until-wp` are lazy markers resolved at render time — after all waypoints are collected.
][
  #uncover(until-wp(<summary>))[Shown before summary.]
  Content.
  #waypoint(<summary>)
  Summary text.
  #uncover(from-wp(<summary>))[Summary visible.]
]

== Rules for waypoint references

- *Forward references work.* `from-wp(<lbl>)`, `until-wp(<lbl>)`, and bare `<lbl>` can appear before `#waypoint(<lbl>)` (or other waypoint creating functions) on the same slide.

- *Cross-slide references do not work.* Waypoints are scoped to a single slide. A label defined on slide 3 cannot be used on slide 5.

- *Undefined waypoints are errors.* If a label is referenced but never defined on the slide (by `#waypoint` or an implicit label), Touying raises an error at the end of the slide.

- *Implicit waypoints are created at first use.* `#uncover(<lbl>)` both references and defines the waypoint — a forward reference is never needed for implicit waypoints.

= Advanced Usage

#slide(composer: (1fr, 1fr))[
  #text(weight: "bold")[`#alternatives` with `at:`]
  #code-col(
    "#waypoint(<opt-a>)\nOption A active.\n#waypoint(<opt-b>)\nOption B active.\n#alternatives(\n  at: (<opt-a>, <opt-b>)\n)[Content A.][Content B.]",
  )
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
  #code-col(
    "Text before.\n#pause\nAfter first pause.\n#item-by-item[\n  - First item\n  - Second item\n  - Third item\n]",
  )
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
  #code-col(
    "#waypoint(<list-wp>)\n#item-by-item(start: <list-wp>)[\n  - Alpha\n  - Beta\n  - Gamma\n]\n#uncover(<list-wp>)[\n  List revealed above.\n]",
  )
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
    #code-col(
      "#slide(self => {
  let (uncover, only) = utils.methods(self)
  [
    Base content.
    #waypoint(<cb-a>)
    #uncover(<cb-a>)[Uncovered from cb-a.]
    #waypoint(<cb-b>)
    #only(<cb-b>)[Only during cb-b.]
  ]
})",
    )
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

#slide(composer: (1fr, 1fr))[
  #code-col(
    "#alternatives(at: (<intro>, <more>))[Introduction.][More details.]
  #waypoint(<intro:background>)
  Some background during intro.
  #waypoint(<intro:goal>)
  The goal during intro.
  #waypoint(<more:analysis>)
  Analysis during more.
  #waypoint(<more:results>)
  Results during more.",
  )
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

== Navigating Hierarchies with `next-wp` / `prev-wp`

#slide(composer: (1fr, 1fr))[
  #v(-1em)
  #code-col(
    "#waypoint(<before>)
Before the group.
#waypoint(<grp:a>)
Part A.
#waypoint(<grp:b>)
Part B.
#waypoint(<after>)
After the group.
// Virtual parent (no <grp> waypoint):
// next-wp → last child + 1
#only(next-wp(<grp>))[Past the group (after).]
// prev-wp → first child − 1
#only(prev-wp(<grp>))[ Before the group.]
",
  )
  #v(-0.8em)
  When `<grp>` is a _virtual_ parent (only children like `<grp:a>` etc. exist), `next-wp` anchors to the *last* child and `prev-wp` to the *first* — so they navigate _past_ or _before_ the entire group.

][

  #waypoint(<hn-before>)
  Before the group.
  #waypoint(<hn-grp:a>)
  Part A.
  #waypoint(<hn-grp:b>)
  Part B.
  #waypoint(<hn-after>)
  After the group.

  #only(next-wp(<hn-grp>))[_(next-wp: past group → after)_]
  #only(prev-wp(<hn-grp>))[_(prev-wp: before group → before)_]

  #uncover("0-")[#place(
    bottom,
  )[You can also reach children: `next-wp(get-first(<grp>))` starts at the first child and steps forward within the group. \
    If an explicit `#waypoint(<grp>)` exists, it anchors to that label directly — stepping into the children from there.]]
]

= Integration: CeTZ & Fletcher

== Waypoints inside `touying-reducer`

Waypoints work inside `touying-reducer`, letting you name animation steps in CeTZ and Fletcher diagrams.

First, set up the reducer bindings (once, at the top of your file):
#show block: set text(size: 16pt)
#grid(
  columns: (1fr, 1fr),
  fill: luma(245),
  inset: 5pt,
  column-gutter: 1em,
  [
    *CeTZ:* #v(-0.5em)
    ```typst
    #import "@preview/cetz:0.4.2"
    #let cetz-canvas = touying-reducer.with(
      reduce: cetz.canvas,
      cover: cetz.draw.hide.with(bounds: true),
    )
    ```
  ],
  [
    *Fletcher:* #v(-0.5em)
    ```typst
    #import "@preview/fletcher:0.5.8" as fletcher: edge, node
    #let fletcher-diagram = touying-reducer.with(
      reduce: fletcher.diagram,
      cover: fletcher.hide,
    )
    ```
  ],
)
Then use `(waypoint(<lbl>),)` for CeTZ or `waypoint(<lbl>)` for Fletcher inside the diagram — just like `(pause,)` or `pause`.


== Fletcher: First Isomorphism Theorem

#slide(composer: (1.5fr, 1fr))[
  #show block: set text(size: 12pt)
  #v(-1em)
  #code-col(
    "#fletcher-diagram(
  cell-size: 15mm,
  waypoint(<fl-maps>, advance: false),
  node((0, 0), $G$),
  edge((0, 0), (1, 0), $f$, \"->\"),
  edge((0, 0), (0, 1), $pi$, \"->>\"),
  pause,
  node((1, 0), $im(f)$),
  node((0, 1), $G\\/ker(f)$),
  waypoint(<fl-iso>),
  edge((0, 1), (1, 0), $tilde(f)$, \"hook-->\"),
)
#alternatives(
  at: (get-first(<fl-maps>), from-wp(get-last(<fl-maps>)))
)[
  $f: G -> $, $pi: G ->> $ ][
  $f: G -> im(f)$, $pi: G ->> G\/ker(f)$ ]
#uncover(<fl-iso>)[$tilde(f)$: the isomorphism.]
",
  )
  #v(-0.5em)
  Use math as labels, not for the whole diagram when using `pause` or `waypoint` inside it. We cannot recognize it otherwise.
][
  #fletcher-diagram(
    cell-size: 15mm,
    waypoint(<fl-maps>, advance: false),
    node((0, 0), $G$),
    edge((0, 0), (1, 0), $f$, "->"),
    edge((0, 0), (0, 1), $pi$, "->>"),
    pause,
    node((1, 0), $im(f)$),
    node((0, 1), $G\/ker(f)$),
    waypoint(<fl-iso>),
    edge((0, 1), (1, 0), $tilde(f)$, "hook-->"),
  ) \ \
  #alternatives(
    at: (get-first(<fl-maps>), from-wp(get-last(<fl-maps>))),
  )[
    $f: G ->$,\ $pi: G ->>$
  ][
    $f: G -> im(f)$, \ $pi: G ->> G\/ker(f)$
  ] \
  #uncover(<fl-iso>)[$tilde(f)$: the isomorphism.]
]

== CeTZ: 3D Sine Waves

#slide(composer: (1.5fr, 1fr))[
  #show block: set text(size: 12pt)
  #code-col(
    "#cetz-canvas({
  import cetz.draw: *
  let wave(amp, col) = { ... }
  (waypoint(<cz-grid>, advance: false),)
  ortho(y: -30deg, x: 30deg, {
    on-xz({grid((0,-2), (8,2), stroke: gray + .5pt)})
  })
  (waypoint(<cz-xy>),)
  ortho(y: -30deg, x: 30deg, {on-xy({ wave(1.6, blue) })})
  (waypoint(<cz-xz>),)
  ortho(y: -30deg, x: 30deg, {on-xz({ wave(1.0, red) })})
})
#only(<cz-grid>)[Grid plane.]
#only(<cz-xy>)[Blue wave (xy).]
#only(<cz-xz>)[Red wave (xz).]",
  )
  #set text(size: 16pt)
  Similarly, for CeTZ, `pause` and `waypoint` must be at the top level of the canvas. Split `ortho(...)` and similar functions into separate calls — one per animation step. Do not put `pause` or `waypoint` inside functions like `ortho` or `on-xz`.
][
  #cetz-canvas({
    import cetz.draw: *
    let N = 50
    let wave(amp, fill-col, stroke-col) = {
      line(
        ..(
          for i in range(N + 1) {
            let t = i / N
            let p = 4 * calc.pi * t
            ((t * 8, calc.sin(p) * amp),)
          }
        ),
        stroke: stroke-col + 1.2pt,
        fill: fill-col,
      )
      for phase in range(0, 2) {
        let x0 = phase / 2
        for div in range(1, 9) {
          let p = 2 * calc.pi * (div / 8)
          let y = calc.sin(p) * amp
          let x = x0 * 8 + div / 8 * 4
          line((x, 0), (x, y), stroke: stroke-col.transparentize(40%) + .5pt)
        }
      }
    }
    (waypoint(<cz-grid>, advance: false),)
    ortho(y: -30deg, x: 30deg, {
      on-xz({
        grid(
          (0, -2),
          (8, 2),
          stroke: gray + .5pt,
        )
      })
    })
    (waypoint(<cz-xy>),)
    ortho(y: -30deg, x: 30deg, {
      on-xy({
        wave(1.6, rgb(0, 0, 255, 50), blue)
      })
    })
    (waypoint(<cz-xz>),)
    ortho(y: -30deg, x: 30deg, {
      on-xz({
        wave(1.0, rgb(255, 0, 0, 50), red)
      })
    })
  })

  #v(0.5em)
  #only(<cz-grid>)[Grid plane drawn.]
  #only(<cz-xy>)[Blue wave on the xy-plane.]
  #only(<cz-xz>)[Red wave on the xz-plane.]
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
  [`from-wp(<lbl>)`], [From waypoint to end of slide],
  [`until-wp(<lbl>)`], [Before waypoint (exclusive)],
  [`next-wp(<lbl>, amount:1)`],
  [Adjacent waypoint (forward), allows `amount` to skip multiple],

  [`prev-wp(<lbl>, amount:1)`],
  [Adjacent waypoint (backward), allows `amount` to skip multiple],

  [`(from-wp(<a>), until-wp(<b>))`], [Bounded range: `<a>` to before `<b>`],
  [`#alternatives(at: (..))[..][..]`], [Named alternative mapping],
  [`#item-by-item[...]`], [Relative item reveal (auto from pause)],
  [`#item-by-item(start: <wp>)[...]`], [Waypoint-anchored item reveal],
  [`<label:sublabel>`],
  [Hierarchical waypoint. The parent (e.g. `<label>`) refers to all its children (e.g. `<label:sublabel>`).],

  [`(waypoint(<lbl>),)` inside CeTZ],
  [Waypoint inside `touying-reducer` (CeTZ). Wrap in tuple like `(pause,)`.],

  [`waypoint(<lbl>)` inside Fletcher],
  [Waypoint inside `touying-reducer` (Fletcher). No tuple needed.],
)
