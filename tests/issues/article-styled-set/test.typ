// A bare top-level `#set` or `#show` used to break every touying mark after
// it in article mode.
//
//   #show: simple-theme.with(config-common(export-mode: "article"))
//   #set text(size: 10pt)     // any top-level set/show
//   == A Slide
//   Just text.
//   #article-text[Prose.]     // -> panic
//
//   panicked with: Unsupported mark `touying-article-text`
//
// A bare `#set`/`#show` does not style the elements around it — it wraps the
// *entire rest of the document* in one `styled` node. Article mode flattened
// sequences but not `styled`, so the walker saw a single opaque child: no
// heading started a section, no mark was ever consumed, and the end-of-article
// leak check reported the survivors. The panic's own text ("You can't use it
// inside some functions like `context`") sent everyone who hit this looking in
// the wrong place — `context` had nothing to do with it.
//
// `_flatten-children` now recurses through `styled`. `parser.typ` has done so
// all along; this is article mode catching up.
//
// What it must not do is hand every child its own copy of the styles.
// `styled(a b c, S)` and `styled(a, S) styled(b, S) styled(c, S)` are
// different documents — Typst's realizer groups adjacent elements and a
// wrapper between them stops it — so only the children the walk actually
// classifies (marks, headings, the `---` separator) are peeled out on their
// own; each run between them keeps one shared wrapper.
//
// Compile-only. Four things are asserted, and all of them are load-bearing:
//   - the marks are consumed and the headings still bound sections, i.e. the
//     walker really did see through the `styled` node;
//   - the styles still apply, i.e. they were pushed down rather than dropped.
//     A "fix" that unwrapped and discarded them would pass the first half;
//   - the styles nest in the original order, which needs two rules *separated
//     by content*: Typst merges adjacent top-level set/show rules into one
//     `styled` node, so a test with them side by side never exercises it;
//   - the runs between structural children are still grouped, i.e. a
//     paragraph is one paragraph and an enum numbers 1, 2, 3.
//
// Known limitation, deliberately not asserted here: a top-level `#set page(..)`
// still opens a page per run, because Typst breaks the page for every
// separate `styled` node that carries one. Set the page through the theme or
// `config-page` instead.
//
// Assertions live in `#article-only[..]` blocks: `#article-text` discards the
// run in front of it, and a `#context` block in a discarded run never renders,
// so it would never fire.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(
  export-mode: "article",
  new-section-slide-fn: none,
))

// The styled node starts here and runs to the end of the document.
#set text(size: 20pt)
#show strong: set text(fill: red)
#show regex("foo\s+bar"): it => [MATCH#label("regex-across-break")]
#show table: it => [#it#metadata("table")<table-styled>]

Prose between the two rules, so the second one opens a *nested* styled node
instead of being merged into the first.

// Relative to the 20pt above: 40pt only if the wrappers nest in source order.
#set text(size: 2em)

== A Slide
Just text. #label("slide-body")
#article-text[Prose. #label("prose")]

#article-only[
  #context {
    // The mark was consumed: article-text replaced the slide body.
    assert.eq(
      query(<prose>).len(),
      1,
      message: "article-text body missing",
    )
    assert.eq(
      query(<slide-body>).len(),
      0,
      message: "article-text did not replace the slide content",
    )
    // The styles survived, and the two nested wrappers are in source order.
    // Reversed, this would be 20pt.
    assert.eq(
      text.size,
      40pt,
      message: "styles were dropped or nested in the wrong order",
    )
  }
]

== Second Slide
Still inside the same styled node. #label("second")

#article-only[
  #context {
    // Headings after the `set` still bound sections rather than being buried
    // in one opaque child. `query` sees the whole document, so this is every
    // heading that reached the article: four of the five written below, since
    // one is filtered out by its mode label.
    assert.eq(query(heading).len(), 5, message: "headings were not seen")
    assert.eq(query(<second>).len(), 1)
  }
]

== Skipped In The Article <touying:slides>
This heading and its body must not reach the article. #label("slides-only")

== Mode Filtering Still Works
#article-only[
  #context {
    assert.eq(
      query(<slides-only>).len(),
      0,
      message: "a mode label on a styled-wrapped heading stopped filtering",
    )
    assert.eq(
      query(heading).len(),
      5,
      message: "the skipped section's heading leaked into the article",
    )
  }
]

== Grouping Within A Run
Alpha foo
bar beta — the regex spans a source line break, so it only matches if the two
text children are still under one shared wrapper.

+ one
+ two
+ three

#article-only[
  #context {
    assert.eq(
      query(<regex-across-break>).len(),
      1,
      message: "a show-regex rule stopped matching across a line break",
    )
    let enums = query(enum)
    assert.eq(enums.len(), 1, message: "the enum was split into separate lists")
    assert.eq(
      enums.first().children.len(),
      3,
      message: "the enum lost its items",
    )
  }
]

== Slide Wrappers And Separators
#slide[An explicit slide wrapper. #label("wrapped")]

// Block-level content pulled out of a slide for meander wrapping is emitted
// later, from a different queue than the slide's own body — it needs the
// styles put back just the same, or a top-level `#show table: ..` reaches
// only the bare table.
#slide[#table(
  columns: 2,
  [a], [b],
)]

#table(
  columns: 2,
  [c], [d],
)

---

#article-only[
  #context {
    assert.eq(
      query(<wrapped>).len(),
      1,
      message: "touying-slide-wrapper mark was not consumed",
    )
    assert.eq(
      query(<table-styled>).len(),
      2,
      message: "a show rule did not reach the table extracted from a slide",
    )
  }
]
