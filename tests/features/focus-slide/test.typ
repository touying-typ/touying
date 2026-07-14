#import "/lib.typ": *

#show: touying-slides.with(
  config-page(paper: "presentation-16-9"),
  config-common(slide-fn: slide),
)

#slide[
  Normal slide
]

#focus-slide[
  Focus!
]

#focus-slide(background-img: "/logo.png")[
  Focus with image
]
