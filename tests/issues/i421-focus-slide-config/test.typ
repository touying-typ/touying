// Issue: Passing config to the university focus slide has no effect.
// https://github.com/touying-typ/touying/issues/421

#import "/lib.typ": *
#import themes.university: *

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
  config-info(
    title: [Test Title],
    date: none,
    logo: none,
  ),
)

#title-slide()

#focus-slide(
  config: config-colors(
    primary: white,
    neutral-lightest: black,
  ),
)[
  Thank you for your attention!
]
