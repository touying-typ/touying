// A covered citation under a visual-only cover method must stay a real citation:
// marker recoloured in place, entry present. Two bugs used to break that, and the
// assertions below pin the mechanism rather than the pixels.
//
// 1. `color-changing-cover` sent the citation to `fallback-hide` (`hide`), because
//    `@key` is a `ref` in the content tree - it only becomes a `cite` during
//    layout - and neither was in the recolourable set. `hide` suppresses the
//    marker but not the entry it queues, so the marker vanished.
// 2. `magic.bibliography-as-footnote` decided whether to draw a width-reserving
//    placeholder instead of a real footnote by looking for a `hide` element,
//    rather than asking `utils.cover-hides-footnote` the way the parser's own
//    footnote branch does. Under a visual-only cover it therefore suppressed the
//    entry too.
//
// This needs reference images, unusually. Introspection cannot tell the two
// broken states from the fixed one: a `hide`-wrapped footnote is still a footnote
// element, so `query(footnote)` counts the same either way, and bug 2 only
// manifests while bug 1 puts a `hide` around the citation in the first place.
// What actually differs is whether the marker is painted, which only the pixels
// record. Page 2 is the subslide where `@einstein` is covered: its marker must be
// there, in red, with both entries below.

#import "/lib.typ": *
#import themes.simple: *

#let bib-data = bytes(
  "@book{dirac, title={Principles of QM}, author={P. Dirac}, year={1981}, publisher={CP}}\n"
    + "@article{einstein, title={Zur Elektrodynamik}, author={A. Einstein}, journal={AdP}, year={1905}}",
)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-bibliography-as-footnote: true),
  // Visual-only: covered content stays visible, just recoloured.
  config-methods(cover: utils.color-changing-cover.with(color: red)),
)

= Covered citations

== Cites

Visible from the start @dirac

#pause

Revealed on subslide two @einstein

== References

#bibliography(bib-data, title: none)
