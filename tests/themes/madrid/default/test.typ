#import "/lib.typ": *
#import themes.madrid: *

#show: madrid-theme.with(
  aspect-ratio: "16-9",
  navigation-symbols: true,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime(year: 1970, month: 1, day: 1),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()

= The Section

== Slide Title

- Item A
- Item B
  - Sub-item

#speaker-note[
  + Note for the slide.
  + Tests speaker notes in Madrid theme.
]

#cblock(title: [Block Title])[
  Standard block content.
]

#alert-block(title: [Alert Block])[
  Alert block content.
]

#example-block(title: [Example Block])[
  Example block content.
]

#focus-slide[
  Focus slide
]
