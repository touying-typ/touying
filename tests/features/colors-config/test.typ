#import "/lib.typ": *
#import themes.default: *

#show: default-theme.with(
  config-colors(primary: red),
  config-methods(alert: utils.alert-with-primary-color),
)

= Colors & Configuration Tests

== Primary Color Configuration

This theme uses red as the primary color.

#alert[This is an alert with the primary color.]

// TODO: fix styled bugs
Regular text and #text(fill: red)[red colored text].

== Different Color Scheme

// TODO: fix touying-set-config bug
#show: touying-set-config.with(config-colors(
  primary: blue,
  secondary: green,
))

#alert[Alert with blue primary color.]

Text with #text(fill: blue)[blue] and #text(fill: green)[green] colors.

== Purple Theme

#show: touying-set-config.with(config-colors(
  primary: purple,
  secondary: purple.lighten(30%),
))

#alert[Purple themed alert.]

== Neutral Colors

#show: touying-set-config.with(config-colors(
  primary: gray,
  secondary: gray.lighten(20%),
))

#alert[Neutral gray themed alert.]

== Custom Color Methods

#show: touying-set-config.with(config-methods(
  alert: (self: none, it) => text(fill: orange, weight: "bold")[⚠ #it],
))

#alert[Custom orange alert with warning icon.]

== Gradient Colors

#show: touying-set-config.with(config-colors(
  primary: gradient.linear(red, orange),
))

#alert[Gradient colored alert element.]