#import "../../lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [],
  footer-progress: false,
  config-info(
    title: [Title],
    author: [Author],
  ),
)

== 1
content

#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover
))

== 2
#pause
content

== 3

#show: appendix

== Appendix