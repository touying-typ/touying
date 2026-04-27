#import "/lib.typ": *
#import themes.custom: *

#let slide-template = {
  place(top + left, rect(width: 100%, height: 2em, fill: teal.lighten(60%))[
    #place(left + horizon, dx: .5em)[*Custom Theme*]
    #place(right + horizon, dx: -.5em)[
      #context utils.slide-counter.display()
    ]
  ])
  place(bottom + left, rect(width: 100%, height: 1.5em, fill: teal.lighten(80%))[
    #place(left + horizon, dx: .5em,
      text(size: .7em)[
        #context utils.display-current-heading(level: 1)
      ]
    )
  ])
  pad(top: 2.5em, bottom: 2em)[
    #block(width: 100%, height: 1fr)<content>
  ]
}
#set text(2em)

#show: custom-theme.with(
  aspect-ratio: "16-9",
  slide: slide-template,
  new-section-slide: body => align(center + horizon,
    [#text(size: 1.5em, weight: "bold", utils.display-current-heading(level: 1))

    #body]
  ),
)

= First Section

== Basic slide

#lorem(30)

== Dynamic slide

Animations work too.

#pause

Second part revealed after pause.

= Second Section

== More content

A slide in the second section.

#lorem(15)
