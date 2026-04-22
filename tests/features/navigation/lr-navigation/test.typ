#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  footer: self=>[
    #align(center,
      lr-navigation(
        self: self,
        mode: "both",
        show-useless: false,
        nav: (
          filled: sym.triangle.filled,
          stroked: sym.chevron,
        ),
      )
    )
  ],
)

= LR Navigation

== First Slide
#lorem(10)

#pause

And after pause: #lorem(5)


== Third Slide

#lorem(10)

