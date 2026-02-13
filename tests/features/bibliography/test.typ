#import "/lib.typ": *
#import themes.simple: *

#let bib = bytes(
  "@book{dirac,
    title={The Principles of Quantum Mechanics},
    author={Paul Adrien Maurice Dirac},
    series={International series of monographs on physics},
    year={1981},
    publisher={Clarendon Press},
  }",
)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-bibliography-as-footnote: bibliography(bib)),
)

= Title

== First Slide

Hello, Touying! @dirac

== Bibliography

#magic.bibliography(title: none)
