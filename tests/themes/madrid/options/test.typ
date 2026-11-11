#import "/lib.typ": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "4-3",
  font: "New Computer Modern",
  title-font: "Libertinus Serif",
  small-font: "DejaVu Sans Mono",
  font-size: 28pt,
  sans-math: false,
  primary: rgb("#006b64"),
  navigation-symbols: false,
  block-shadow: false,
  title-shadow: false,
  section-outline-title: [Contents],
  config-info(
    title: [A longer title \ on two lines],
    subtitle: [A subtitle],
    authors: ([First Author], [Second Author]),
    short-author: [Authors],
    short-title: [Options],
    institution: [First institution \ Second institution],
    date: [Today],
    logo: rect(width: 1em, height: 1em, fill: rgb("#006b64"), stroke: none),
  ),
)

// Title-local metadata and explicit exclusion from frame numbering.
#title-slide(numbered: false, date: [Title date])
#outline-slide(title: [Contents], depth: 2)

= First section

== Animated blocks

#cblock(title: [Normal])[
  First #pause then second $E = m c^2$.
]

#alert-block(title: [Alert])[
  #alert[Important] #pause and animated.
]

#example-block(title: [Example])[
  Example content.
]

// Per-slide theme overrides must affect the block and alert methods too.
#slide(
  title: [Overrides],
  align: top + left,
  config: config-colors(
    primary: purple,
    primary-light: purple.lighten(90%),
    alert: orange,
  ),
)[
  #cblock(title: [Purple])[Normal block.]
  #alert[Orange alert.]
]

= Second section

#slide(header: [Custom header], footer: [Custom footer])[
  Custom header and footer replace the built-in decorations.
]

#focus-slide(config: config-colors(primary: rgb("#006b64")))[Finished]
