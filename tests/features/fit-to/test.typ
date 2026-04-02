#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Fit To Test

== Fit-To-Height
---
=== a) no reflow
#lorem(50)
#utils.fit-to-height(reflow: false)[
  #lorem(40)
]
---
=== b) with reflow
#lorem(50)
#utils.fit-to-height(reflow: true)[
  #lorem(40)
]
---
=== c) with reflow but with force-height
#lorem(50)
#utils.fit-to-height(reflow: true, force-height: true)[
  #lorem(40)
]

== Fit-To-Width

#utils.fit-to-width[
  #lorem(2)
]