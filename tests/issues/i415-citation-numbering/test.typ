// Regression test for #415: numeric citation numbers must not drift across
// subslides.
//
// Compile-only, assertion-based: the resolved citation number is produced by
// typst's CSL pass and is exposed on neither the `cite` element (whose only
// fields are key/supplement/form/style) nor the `bibliography` element, so it
// cannot be asserted directly. What *can* be asserted is the mechanism behind
// #415, which was established empirically:
//
//   citation numbers are allocated in one global sequence, and each
//   `bibliography` *instance* claims a fresh block of it.
//
// touying re-renders a slide body once per subslide, so a `#bibliography(..)`
// call sitting on a multi-subslide slide is instantiated once per subslide and
// each instance claims a new block - the second block is why the reporter saw
// `[3][4]` instead of `[1][2]`.
//
// Re-rendered *citations* are harmless: the four subslides below re-render
// `@a`/`@b`/`@c` repeatedly and still number them `[1][2][3]`, because the
// bibliography is instantiated exactly once. So "exactly one bibliography
// instance" is the invariant that keeps the numbering stable, and asserting it
// is both necessary and sufficient here.
//
// See tests/issues/i415-bibliography-instances-known-bug for the shape that
// still gets this wrong.

#import "/lib.typ": *
#import themes.simple: *

#let bib-data = bytes(
  "@book{a, author={Alpha}, title={Book A}, publisher={P}, year={2020}}\n"
    + "@book{b, author={Bravo}, title={Book B}, publisher={Q}, year={2021}}\n"
    + "@book{c, author={Charlie}, title={Book C}, publisher={R}, year={2022}}",
)

#show: simple-theme.with(aspect-ratio: "16-9")

= Citation numbering under pause

== Content

First @a #pause then @b #pause and @c #pause done.

== References

#bibliography(bib-data, style: "ieee", title: none)

== Assertions

#context {
  // The bibliography sits on its own slide, which has no `#pause`, so it is
  // rendered once for the whole document however many subslides the content
  // slide has.
  assert.eq(
    query(bibliography).len(),
    1,
    message: "the bibliography must be instantiated exactly once, or each "
      + "extra instance shifts the citation numbers (#415)",
  )
  // Meanwhile the citations really are re-rendered once per subslide of the
  // content slide - four subslides, three citations, one of them repeated on
  // every later subslide. This is here to document that cite re-renders are
  // *not* the problem, so a future fix is not tempted to chase them.
  assert(
    query(cite).len() > 3,
    message: "expected the citations to be re-rendered per subslide",
  )
}
