#import "/lib.typ": *
#import themes.metropolis: *
#import "@preview/cetz:0.5.2"

// ---------------------------------------------------------------------
//One source, three outputs:
//
//   typst compile --root . examples/advanced.typ examples/advanced.pdf
// typst compile --root . --input export-mode=handout examples/advanced.typ examples/advanced-handout.pdf
//   typst compile --root . --input export-mode=article examples/advanced.typ examples/advanced-article.pdf
// ---------------------------------------------------------------------

#let cetz-canvas = touying-reduce.with(cetz)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Advanced Touying],
    subtitle: [Animation, layout, recall — and one source for two outputs],
    author: [The Touying Authors],
    date: datetime(day:1, month:1, year:2042),
  ),
  config-common(new-section-slide-fn: none),
  config-article(
    available-fields: (
      title: "info.title",
      author: "info.author",
      date: "info.date"
    ),
    //title-block-fn is kept at default and by routing the above to it we get block you see
  )
)

// Source shown next to the thing it produces. Small enough to sit beside a
// live demo without either crowding the other.
#let src(code) = align(center, block(
  width: 80%,
  fill: luma(240),
  inset: 7pt,
  radius: 4pt,
  
  align(left, text(size: 0.72em, raw(block: true, lang: "typst", code))),
))

#show raw.where(block:false): set text(fill: orange.darken(15%))

#show link: it => {
  set text(fill: blue.lighten(20%))
  underline(it)
}

// present the title-slide only in slides mode if you also target an article, an article typically has its own title block.
#slides-only(title-slide())

#article-only[
#heading(level:2, numbering: none)[_Abstract_]
This document is the article output of the example `advanced.typ` and showcases all the normal presentation does as well but written in prose. See at the #link(<article-mode>)[end] or the source directly for how that is done. 
]

= Animating mathematics
Since touying `v0.8.0` math is now fully supported.

== Marks reach inside math elements

A `#pause` works wherever it is written in an equation — including inside
`frac`, `mat` and the other elements that keep their content in named fields
of their own, rather than in a `body`:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.2em,
  src("$ frac(a #pause + b, c) $"),
  align(horizon + center, $ frac(a #pause + b, c) $),
)

#pause

The same holds for a matrix, cell by cell:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.2em,
  src("$ mat(a, #pause b; c, #pause d) $"),
  align(horizon + center, $ mat(a, #pause b; c, #pause d) $),
)

#article-text[
  Animation marks reach into the math elements that store their content in
  named fields — `frac`, `mat`, `vec`, `cases`, `binom`, `root`, `attach`,
  `accent`, `cancel`, `lr` and the brace family — so the numerator is revealed
  in place. In this article every stage is already shown.

  Written as:
  #src("$ frac(a #pause + b, c) $")
  or, cell by cell:
  #src("$ mat(a, #pause b; c, #pause d) $")

  More in #link("https://touying-typ.github.io/docs/tutorials/dynamic/equation")[Docs/Math Equation Animations].
]

== Building a derivation

`#uncover` and `#only` work in math too, so a derivation can grow a term at a
time while the layout stays put:

#src("$ f(x) &= x^2 #uncover(\"2-\")[$+ 2x$]#uncover(\"3-\")[$+ 1$] \\\n     #only(\"3-\")[$&= (x + 1)^2$] $")

#v(0.5em)

$
  f(x) &= x^2 #uncover("2-")[$+ 2x$] #uncover("3-")[$+ 1$] \
       #only("3-")[$&= (x + 1)^2$]
$

#pause

`#uncover` reserves the space it will occupy, so nothing shifts as terms
appear. `#only` removes it, which is why the second line arrives late.

#article-text[
  `#uncover` and `#only` work inside math as well as around it. `#uncover`
  keeps the space a term will occupy so the equation does not reflow as it is
  revealed, while `#only` removes the space entirely — which is why a line
  gated with it arrives without having reserved room first. The finished
  derivation is $f(x) = x^2 + 2x + 1 = (x + 1)^2$.

  Written as:
  #src("$ f(x) &= x^2 #uncover(\"2-\")[$+ 2x$] #uncover(\"3-\")[$+ 1$] \\
       #only(\"3-\")[$&= (x + 1)^2$] $")
]

= Choosing between versions

== `alternatives` and its cousins

`#alternatives` shows one body per subslide, possibly reserving room for the largest with `stretch: true` so
the surrounding layout never jumps:

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 1.2em,
  src("#alternatives(stretch: true)[first][second][third]"),
  box(stroke:red+2pt, text(1.4em, alternatives(stretch: true)[first][second][third])),
)

#jump(3)

`#alternatives-cases` is the same idea driven by a function, which e.g. allows writing a 
list where one row is highlighted at a time. The strings say which subslides
each case covers:

#src("#alternatives-cases((\"3\", \"4\", \"5\"), case => {
  let rows = (\"chlorophyll\", \"carotene\", \"anthocyanin\")
  stack(dir: ltr, spacing: 1.2em,
    ..rows.enumerate().map(((i, r)) => {
      if i == case { strong(r) } else { text(fill: gray, r) }
  }),)
})")

#v(0.4em)

#align(center, alternatives-cases(("3", "4", "5"), case => {
  let rows = ("chlorophyll", "carotene", "anthocyanin")
  stack(
    dir: ltr,
    spacing: 1.2em,
    ..rows.enumerate().map(((i, r)) => {
      if i == case { strong(r) } else { text(fill: gray, r) }
    }),
  )
}))

#article-text[
  `#alternatives` shows one body per subslide and reserves the space of the
  largest with `stretch: true`, so nothing around it moves; `#alternatives-cases` drives the same
  mechanism from a function, which e.g. suits highlighting one row of a list at a
  time. An article has no subslides, so both collapse to their final state.

  That may look like this:
  #src("#alternatives(stretch: true)[first][second][third]")
  or this
  #src("#alternatives-cases((\"3\", \"4\", \"5\"), case => {
    let rows = (\"chlorophyll\", \"carotene\", \"anthocyanin\")
    stack(dir: ltr, spacing: 1.2em,
      ..rows.enumerate().map(((i, r)) => {
        if i == case { strong(r) } else { text(fill: gray, r) }
    }),)
  })")

  More in #link("https://touying-typ.github.io/docs/tutorials/dynamic/complex")[Docs/Complex Animations].
]

== `animate` composes effects

`#animate` applies several effects to one body, each over its own subslide
range. A *placement*  decides whether the body is shown, covered or removed; a
*styling* function wraps it. The last one written wins a tie but you can also use `priority`.\
There are 4 placements: `"show"`, `"cover"`, `"remove"` and `swap()`. The default effect uses the placement `"show"` with subslides `"1-"` and priority `0` which is why "Photosynthesis" shows on the first subslide.

#src("#animate(
  [Photosynthesis],
  effects: (
    (effect: swap([Respiration], stretch: true), subslides: \"2-\"),
    (effect: (body, self: none) => text(fill: red, body), subslides: \"3-\"),
    (effect: swap([Photosynthesis], stretch: true), subslides: 4, priority: 2)
  ),
)")

#v(0.5em)

#align(center, text(1.4em, animate(
  [Photosynthesis],
  effects: (
    (effect: swap([Respiration], stretch: true), subslides: "2-"),
    (
      effect: (body, self: none) => text(fill: red, body),
      subslides: "3-",
    ),
    (effect: swap([Photosynthesis], stretch: true), subslides: 4, priority: 2)
  ),
)))

#article-text[
  `#animate` layers effects on one body, each with its own subslide range and
  priority: placements choose
  whether and what body appears at all, while styling functions wrap whatever the
  placement left. Multiple styling effects may stack on top of each other.

  There are four placements — `"show"`, `"cover"`, `"remove"` and `swap(..)`. These are modeled after uncover, only and alternatives.
  The default effect is `"show"` over subslides `"1-"` at priority `0`, which
  is why an unmarked body is visible from the first subslide. The last effect
  written wins a tie, and `priority` overrides that ordering.

  That may look like this:
  #src("#animate(
    [Photosynthesis],
    effects: (
      (effect: swap([Respiration], stretch: true), subslides: \"2-\"),
      (effect: (body, self: none) => text(fill: red, body), subslides: \"3-\"),
      (effect: swap([Photosynthesis], stretch: true), subslides: 4, priority: 2)
    ),
  )")
]

= Reusing content

== Waypoints name positions

Counting subslides breaks the moment you insert a `#pause` above. A waypoint
names a position instead, and everything referring to it follows:

#src("#waypoint(<detail>, advance:false)
#uncover(<detail>)[This line names `<detail>`, not \"subslide 2\".]
#pause
#only(get-last(<detail>))[`#get-last` pins the waypoint's final subslide — useful when a range should end exactly where a phase does.]
#waypoint(<other-stuff>)
Waypoints capture all subslides up until the next waypoint.
")

#v(0.4em)

Numbers stay correct here no matter what is added before the waypoint.

#slide[
  #waypoint(<detail>, advance: false)

  #uncover(<detail>)[
    This line names `<detail>`, not "subslide 2".
  ]

  #pause

  #only(get-last(<detail>))[
    `#get-last` pins the waypoint's final subslide — useful when a range
    should end exactly where a phase does.
  ]

  #waypoint(<other-stuff>)
  Waypoints capture all subslides up until the next waypoint.
]

#article-text[
  A waypoint labels a position in a slide's flow so that animations refer to
  a name rather than a number, which keeps them correct when a `#pause` is
  inserted earlier. Markers such as `get-first`, `get-last`, `from-wp` and
  `until-wp` derive ranges from it. A waypoint captures every subslide up to
  the next one, and `advance: false` marks the current position instead of
  claiming a new subslide of its own.

  That may look like this:
  #src("#waypoint(<detail>, advance:false)
#uncover(<detail>)[This line names `<detail>`, not \"subslide 2\".]
#pause
#only(get-last(<detail>))[`#get-last` pins the waypoint's final subslide — useful when a range should end exactly where a phase does.]
#waypoint(<other-stuff>)
Waypoints capture all subslides up until the next waypoint.
")

  More in #link("https://touying-typ.github.io/docs/tutorials/dynamic/waypoints")[Docs/Waypoints] or #link("https://github.com/touying-typ/touying/blob/main/examples/waypoints.typ")[Examples/Waypoints].
]

== Recalling a slide

A slide can carry a label either via the heading or the slide function, and `#touying-recall` brings it back later — handy
for a summary that should show the finished state of an earlier build:

#src("== Shared heading
#slide[.. first ..]<intro-a>
#slide[.. second ..]<intro-b>

#touying-recall(<intro-b>)")

#pause

You may also pass in a subslide index, range or waypoint to recall whatever stage you want to show again.

#article-text[
  Labelling a slide and calling `#touying-recall(<label>)` replays it later in
  the presentation. Because a label belongs to the slide rather than to its
  heading, several slides under one heading remain individually addressable.
  In an article there are no slides to replay, so a recall of a whole slide is
  skipped.

  That may look like this:
  #src("== Shared heading
#slide[.. first ..]<intro-a>
#slide[.. second ..]<intro-b>

#touying-recall(<intro-b>)")
]

== Rendering Content

You may also store some content in a variable and render only subslides of it via `#touying-render`.

#grid(
  columns:(1fr, 1fr),
  gutter: 1.2em,
  src("#let my-table = table(
  columns: 2,
  [Header 1], [Header 2],
  pause, [Cell 1],
  [Cell 2], pause,
  [Cell 3], [Cell 4],
)

#touying-render(my-table, subslides: 2)"
  ),
  align(horizon+center)[
    #let my-table = table(
      columns: 2,
      [Header 1], [Header 2],
      pause, [Cell 1],
      [Cell 2], pause,
      [Cell 3], [Cell 4],
    )

    #touying-render(my-table, subslides: 2)
  ]
)

#pause
It does not have to be a single element but can be even a reveal sequence leaving individual steps out.

#article-text[
  `#touying-render` takes content held in a variable and renders one stage of
  it, so an animated element can be shown at a chosen point without being
  written out again. `subslides:` picks the stage: an index, a range, a
  negative index counting back from the last, or a waypoint. The content need
  not be a single element — a whole reveal sequence works, and individual
  steps can be left out.

  That may look like this:
  #src("#let my-table = table(
  columns: 2,
  [Header 1], [Header 2],
  pause, [Cell 1],
  [Cell 2], pause,
  [Cell 3], [Cell 4],
)

#touying-render(my-table, subslides: 2)")

  More in #link("https://touying-typ.github.io/docs/tutorials/dynamic/complex")[Docs/Complex Animations].
]

= Layout and graphics

== Animating a drawing

`#touying-reduce` wires an external drawing package into the same animation
system, so `pause` inside a `cetz.canvas` means what it means everywhere else:

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 1.2em,
  src("#let cetz-canvas = touying-reduce.with(cetz)

#cetz-canvas({
  import cetz.draw: *
  circle((0, 0), radius: 1)
  (pause,)
  line((-1, 0), (1, 0))
})"),
  align(horizon + center, cetz-canvas({
    import cetz.draw: *
    circle((0, 0), radius: 1)
    (pause,)
    line((-1, 0), (1, 0))
  })),
)

#pause

Touying supplies#footnote[For Cetz, Fletcher and Alchemist we supply the bindings. Other packages need to expose those to touying themselves.] the package's own cover function, so a hidden part keeps its
size and the drawing does not jump as it is revealed.

You may also use the synonym `touying-diagram` instead of `touying-reduce`.

#article-text[
  `#touying-reduce` connects a drawing package such as cetz or fletcher to
  Touying's animation system, so a `pause` between draw commands splits the
  canvas across subslides while keeping one coordinate space. The article
  shows the completed drawing. Touying supplies the package's own cover
  function, so a hidden part keeps its size and the drawing does not shift as
  it is revealed. Bindings ship for cetz, fletcher and alchemist; other
  packages have to expose their own. `#touying-diagram` is a synonym, named
  for the diagrams these packages usually draw.

  That may look like this:
  #src("#let cetz-canvas = touying-reduce.with(cetz)

#cetz-canvas({
  import cetz.draw: *
  circle((0, 0), radius: 1)
  (pause,)
  line((-1, 0), (1, 0))
})")

  More in #link("https://touying-typ.github.io/docs/integration/cetz")[Docs/CeTZ integration].
]

== Two columns, and what the article does with them

#slide[
  A slide can be split into multiple columns via 
  #src("#slide[left][right]") or by passing in an explicit `composer` to split the columns differently:
  #src("#slide(composer:(2fr, 1fr))[left][right]")
][
#pause

An article has no slide to divide, so a composer's columns are flattened back
into running text. That is usually what you want when the same source has to
read as prose — and when it is not, `#article-keep-layout[..]` holds a
container together: usable on columns, grids, tables. Tables and grids are by default linearized if they have no heading or footer. Read more in the docs on how to configure this.
]

#article-text[
  A slide can be passed multiple bodies which will be layed out in columns. Article mode linearizes them into
  running text, since a flowing document has no slide to divide. Two bodies
  split a slide in half by default; an explicit `composer` such as
  `(2fr, 1fr)` divides it differently.

  Wrap a container in `#article-keep-layout[..]` to keep its shape in the
  article, or `#article-linearize[..]` to force the opposite; both work on
  columns, grids and tables. Tables and grids are linearized by default unless
  they carry a header or footer.

  That may look like this:
  #src("#slide(composer: (2fr, 1fr))[left][right]")

  More in #link("https://touying-typ.github.io/docs/integration/article-mode")[Docs/Article Mode].
]

= One source, multiple outputs <article-mode>

== Selecting what goes where.

Five markers decide where content goes.
`#presentation-only[..]`, `#handout-only[..]` and `#article-only[..]` keep
content to one output; `#slides-only[..]` routes it to both the presentation and handout. `#article-text[..]` replaces a slide's body with prose
written for reading, which is what nearly every slide in this deck does. The
same filtering of `..-only` is available as `<touying:..>` labels on a heading or a slide —
see #link("https://touying-typ.github.io/docs/tutorials/output-modes")[Output Modes].

#pause

#slides-only[
  You are reading the #touying-fn-wrapper-raw((self:none)=>{
    if self.handout [Handout] else [Presentation]
  }), so this paragraph — written inside
  `#slides-only[..]` — is visible and the article's paragraph is not.
]

#article-only[
  You are reading the article, so this paragraph, written inside
  `#article-only[..]`, is the one that survives.
]

#pause

The rule of thumb: write the slide for projection, then add
`#article-text[..]` wherever the prose version needs to differ. It replaces the entire slide content with written prose. See the docs or this source.

== Handout mode

A handout is a slide output with the animation flattened: every slide keeps by default
only its last subslide, so a reader gets one page per slide instead of one
per reveal. Compile it with `--input export-mode=handout` or set `handout: true` inside `config-common`.

#pause

`#presentation-only[..]` and `#handout-only[..]` split content between the
two, which is how a deck carries speaker-facing and reader-facing wording in
one file:

#presentation-only[
  *You are reading the live presentation.* This paragraph sits inside
  `#presentation-only[..]`, so the handout shows the other one instead.
]

#handout-only[
  *You are reading the handout.* This paragraph sits inside
  `#handout-only[..]`, and it is the one the live presentation hides.
]

#pause

Per-slide control which subslides end up in the handout is available too: `config-common(handout-subslides: ..)`
keeps chosen subslides rather than just the last, which is useful when a
build only makes sense in stages. Set this via `#touying-set-config` or pass it to as an argument to a `#slide` call.

#article-text[
  A handout is a slide output with the animations flattened: each slide keeps by default
  only its final subslide, so this deck's presentation pages collapse to
  roughly a third.
  `#presentation-only[..]` and `#handout-only[..]` divide content between the
  live talk and the printed version. Compile a handout with
  `--input export-mode=handout`, or set `handout: true` in the global `config-common`.

  `config-common(handout-subslides: ..)` keeps particular subslides rather
  than only the last; set it with
  `#touying-set-config` or pass it as an argument to a `#slide` call.

  That may look like this:
  #src("#presentation-only[.. only in the live talk ..]
#handout-only[.. only in the printed handout ..]

#slide(config: config-common(handout-subslides: (1, 3)))[.. ..]")

  More in #link("https://touying-typ.github.io/docs/tutorials/dynamic/handout")[Docs/Handout Mode].
]

// No `#article-text` on this slide, deliberately: it would replace the body
// and the `#article-only[..]` paragraph above would never be seen, which is
// the one thing this slide is trying to show.
