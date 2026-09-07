// Companion to tests/issues/i415-citation-numbering, documenting the shape of
// #415 that is still broken. This test asserts the CURRENT, WRONG behaviour so
// that a fix has a target to flip - it is not an endorsement of it.
//
// The reporter's own MWE puts `#bibliography(..)` on the same slide as a
// `#pause`. touying re-renders a slide body once per subslide, so the
// bibliography is instantiated twice, and because citation numbers are handed
// out in one global sequence with a fresh block per bibliography instance, the
// second subslide renders `[3][4]` where it should render `[1][2]`.
//
// When this is fixed, the expected instance count below becomes 1 and this
// file should be folded into the main i415 test.
//
// Workaround for users until then: put the bibliography on its own slide (a
// `== References` heading with no `#pause` on it), which is the usual pattern
// anyway and numbers correctly - see the companion test.

#import "/lib.typ": *
#import themes.simple: *

#let bib-data = bytes(
  "@book{a, author={Alpha}, title={Book A}, publisher={P}, year={2020}}\n"
    + "@book{b, author={Bravo}, title={Book B}, publisher={Q}, year={2021}}",
)

#show: simple-theme.with(aspect-ratio: "16-9")

= Bibliography on an animated slide

First @a #pause then @b.
#bibliography(bib-data, style: "ieee", title: none)

== Assertions

#context {
  let instances = query(bibliography).len()
  assert.eq(
    instances,
    2,
    message: "KNOWN BUG #415: the bibliography shares a slide with a #pause, "
      + "so it is instantiated once per subslide (expected 2 while the bug "
      + "stands). If this now reports 1, the bug is fixed - flip this "
      + "assertion to 1 and fold the file into i415-citation-numbering.",
  )
}
