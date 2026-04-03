#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Fit-To

== height: no reflow
#lorem(50)
#utils.fit-to-height(reflow: false)[
  #lorem(40)
]

== height: with reflow
#lorem(50)
#utils.fit-to-height(reflow: true)[
  #lorem(40)
]

== height: with reflow but with force-height
#lorem(50)
#utils.fit-to-height(reflow: true, force-height: true)[
  #lorem(40)
]

== width

#utils.fit-to-width[
  #lorem(2)
]
