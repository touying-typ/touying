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
