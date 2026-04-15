#import "/lib.typ": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  navigation: none,
  config-common(
    receive-body-for-new-section-slide-fn: true,
  ),
)

= Foo

#lorem(50)
