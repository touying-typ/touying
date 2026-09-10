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
// `_flatten-children` now recurses through `styled`, pushing the styles down
// onto each child the way Typst itself does, and leaving metadata marks bare
// so `utils.is-kind` still recognizes them. `parser.typ` has recursed through
// `styled` all along; this is article mode catching up.
//
// Compile-only. Two things are asserted, and both matter:
//   - the marks are consumed and the headings still bound sections, i.e. the
//     walker really did see through the `styled` node;
//   - the styles still apply, i.e. flattening pushed them down instead of
//     dropping them. That second half is what a "fix" that simply unwrapped
//     and discarded the styles would fail.
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
    // The styles survived being pushed down onto each child.
    assert.eq(text.size, 20pt, message: "set text was dropped by flattening")
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
    assert.eq(query(heading).len(), 4, message: "headings were not seen")
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
      4,
      message: "the skipped section's heading leaked into the article",
    )
  }
]

== Slide Wrappers And Separators
#slide[An explicit slide wrapper. #label("wrapped")]

---

#article-only[
  #context {
    assert.eq(
      query(<wrapped>).len(),
      1,
      message: "touying-slide-wrapper mark was not consumed",
    )
  }
]
