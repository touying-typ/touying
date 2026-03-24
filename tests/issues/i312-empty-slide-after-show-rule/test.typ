// Issue: empty slide after all show-rules
// https://github.com/touying-typ/touying/issues/312

#import "/lib.typ": *
#import themes.stargazer: *

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Title]),
)

== Frame Title
There should be only 1 contents slide.

#show: appendix
#counter(heading).update(0)  // This line

== Backup Slide
Appendix.
