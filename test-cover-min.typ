#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

== Slide 1

Some content.

#touying-set-config(config-methods(
  cover: utils.semi-transparent-cover,
), [
  #pause

  Content after pause.

  #pause

  More content.
])

== Slide 2

Another slide.
