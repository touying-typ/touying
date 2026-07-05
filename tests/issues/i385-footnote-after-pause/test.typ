#import "/lib.typ": *
#import themes.simple: *

#let bib = bytes(
    "@book{knuth,
  title={The Art of Computer Programming},
  author={Donald E. Knuth},
  year={1968},
  publisher={Addison-Wesley},
  }",
)

#show: simple-theme.with(aspect-ratio: "16-9", config-common(
    show-bibliography-as-footnote: bibliography(bib),
))

= Title

== First Slide

#slide()[
    Hello, Touying!

    #pause

    Hello, Typst!  #footnote[A footnote] <fn>

    #waypoint(<test>)

    Left Column @fn
][
    #uncover(<test>)[Another Test for Waypoint and Bibliography. @knuth]
]
