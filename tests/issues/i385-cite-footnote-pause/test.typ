#import "/lib.typ": *
#import themes.simple: *

// A footnote placed after `#pause` must stay hidden on the earlier subslides, whether it
// is a literal `#footnote` or a note-style citation (which renders as a footnote). Each
// slide's first subslide shows no footnote; it appears once revealed.
#show: simple-theme

#let bib-data = bytes(
  "@book{a, author={Alpha}, title={Book A}, publisher={P}, year={2020}}\n"
    + "@book{b, author={Bravo}, title={Book B}, publisher={Q}, year={2021}}",
)

== Literal footnote with pause

Before. #pause After.#footnote[Revealed with the second step.]

== Note-style citation with pause

First @a #pause then @b.

#only("h", bibliography(bib-data, style: "chicago-notes", title: none))
