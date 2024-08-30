#import "../lib.typ": *
#import themes.default: *
#import "@preview/hydra:0.5.1": hydra


#show: default-theme.with(
  aspect-ratio: "16-9",
  config-common(
    slide-level: 2,
  ),
  config-colors(
    primary: blue,
  ),
  config-methods(
    alert: utils.alert-with-primary-color,
  ),
  config-page(
    header: states.display-current-heading(level: 2),
  ),
)


= Title

== Recall <recall>

*Recall*

#speaker-note[sdfsdf]

#show: touying-set-config.with(config-methods(cover: utils.semi-transparent-cover))

== Animation

#set math.equation(numbering: "(1)")

Simple

#pause

$ x + y $

animation


#show: appendix

= Appendix

Appendix

#touying-recall(<recall>)