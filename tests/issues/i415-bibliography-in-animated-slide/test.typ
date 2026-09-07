// Companion to tests/issues/i415-citation-numbering: the supported way to put a
// bibliography on a slide that *does* have subslides.
//
// A bare `#bibliography(..)` there is instantiated once per subslide, and since
// each instance claims a fresh block of the global citation numbering, the
// visible one renumbers the citations (`[3][4]` instead of `[1][2]`, which is
// what #415 reported). Wrapping it in `only("h", ..)` emits it at a single
// subslide - the "h" marker resolves to the subslide it is written at - so only
// one instance exists and the numbering stays put.
//
// This is the shape recommended on the issue, so it is worth a regression test:
// if `only("h", ..)` ever stopped collapsing the bibliography to one instance,
// the advice given to users would silently break.

#import "/lib.typ": *
#import themes.simple: *

#let bib-data = bytes(
  "@book{a, author={Alpha}, title={Book A}, publisher={P}, year={2020}}\n"
    + "@book{b, author={Bravo}, title={Book B}, publisher={Q}, year={2021}}",
)

#show: simple-theme.with(aspect-ratio: "16-9")

= Bibliography on an animated slide

Cited before the pause @a #pause and after it @b.

#only("h", bibliography(bib-data, style: "ieee", title: none))

== Assertions

#context {
  assert.eq(
    query(bibliography).len(),
    1,
    message: "only(\"h\", ..) must collapse the bibliography to a single "
      + "instance even on a slide with subslides, or the citation numbers "
      + "shift (#415)",
  )
}
