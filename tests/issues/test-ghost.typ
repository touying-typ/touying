#import "/lib.typ": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-colors(primary: red),
  config-methods(alert: utils.alert-with-primary-color),
)

== Slide 1
Body 1

== Slide 2
// heading BEFORE the show: rule - this is the ghost slide case
#show: touying-set-config.with(config-colors(primary: blue))

Body 2 with blue
