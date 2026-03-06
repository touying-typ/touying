#import "/lib.typ": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly

// Simplified test: show heading counter at header vs at body position

#set heading(numbering: "1.1")

#let current-h = context {
  let hs = query(heading)
  let cur-page = here().page()
  let found = hs.filter(h => h.location().page() <= cur-page)
  if found != () {
    let h = found.last()
    // Default style: explicit counter query
    let explicit-num = numbering("1.1", ..counter(heading).at(h.location()))
    // Auto style: render element directly
    let implicit = [#h]  // renders heading element
    [Default: #explicit-num | Auto: #implicit | Counter at header: #counter(heading).display("1.1")]
  }
}

#page(header: current-h)[
  == Heading 1
  Text
]

#page(header: current-h)[
  == Heading 2  
  Text
]
