#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Styled Content Tests

== Inline Styled Content

before styled

#text(fill: red)[styled text on same slide]

after styled

== Block Styled Content

before styled

#[
  #set text(fill: red)
  block styled text on same slide
]

after styled

== Mixed Styled and Animation

before styled

#text(fill: blue)[styled text]

#pause

after pause
