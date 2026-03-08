// Ghost slide test WITHOUT section heading
#import "/lib.typ": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-colors(primary: red),
)

== Slide 1
Body 1

== Slide 2
#show: touying-set-config.with(config-colors(primary: blue))
Body 2 with blue
