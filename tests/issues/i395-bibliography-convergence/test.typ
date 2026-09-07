// Regression test for #395: a footnote bibliography made the document fail to
// converge once the bibliography at the end overflowed its slide.
//
// This is intentionally a compile-only tytanic test without `ref/*.png` - the
// regression is not a layout change but a pair of warnings,
//
//   warning: document did not converge within five attempts
//   warning: query for elements labelled `<pdfpc>` did not stabilize
//
// so the assertion is that the compile emits no warnings at all. That only
// holds under `tt run --warnings promote`, which CI runs for this test; a plain
// `tt run` would report it as passing either way. Keep this test free of any
// other warning source for that reason.
//
// The old mechanism took the bibliography as a value
// (`show-bibliography-as-footnote: bibliography(..)`) and re-emitted the
// entries through `magic.bibliography()`, which fed layout back into the
// footnote pass. The reworked mechanism takes a bool and lets the user place a
// real `#bibliography(..)` call, which converges.
//
// The trigger is layout-sensitive: on the old code this MWE warns at a
// bibliography text size of 20pt and again from 32pt up, but is clean at
// 17/18/24/28pt, and only with `breakable: true`. 38pt below is the reporter's
// own "Case 8". Do not shrink it - the bibliography has to overflow the slide
// for this test to be testing anything.

#import "/lib.typ": *
#import themes.simple: *

#let bib-file = bytes(
  "@book{knuth1,
    title={The Art of Computer Programming1},
    author={Donald E. Knuth},
    year={1968},
    publisher={Addison-Wesley},
  }
  @article{knuth2,
    title = {{A model for sedimentation in inhomogeneous media. I. Dynamic density gradients from sedimenting co-solutes}},
    year = {2004},
    journal = {Biophysical Chemistry},
    author = {Schuck, Peter},
    number = {1-3},
    month = {3},
    pages = {187--200},
    volume = {108},
    publisher = {Elsevier},
    doi = {10.1016/J.BPC.2003.10.016},
    issn = {0301-4622},
  }
  @book{knuth3, title={The Art of Computer Programming3}, author={Donald E. Knuth}, year={1968}, publisher={Addison-Wesley}}
  @book{knuth4, title={The Art of Computer Programming4}, author={Donald E. Knuth}, year={1968}, publisher={Addison-Wesley}}
  @book{knuth5, title={The Art of Computer Programming5}, author={Donald E. Knuth}, year={1968}, publisher={Addison-Wesley}}
  @book{knuth6, title={The Art of Computer Programming6}, author={Donald E. Knuth}, year={1968}, publisher={Addison-Wesley}}",
)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(
    show-bibliography-as-footnote: true,
    breakable: true,
    detect-overflow: true,
    clip: true,
  ),
)

= Intro

== Slide 1

Some cited content. @knuth1
This is another citation @knuth2

#cite(<knuth3>, form: "prose")

== Slide 2

This is third citation @knuth4
And an old one again @knuth5

== Slide 3

This is the third slide @knuth6

== References

test

#text(size: 38pt)[
  #bibliography(bib-file, style: "american-chemical-society")
]
