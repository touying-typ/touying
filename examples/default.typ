#import "../lib.typ": *
#import themes.default: *

#import "@preview/numbly:0.1.0": numbly

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-common(
    slide-level: 3,
    zero-margin-header: false,
  ),
  config-colors(
    primary: blue,
  ),
  config-methods(
    alert: utils.alert-with-primary-color,
  ),
  config-page(
    header: text(gray, utils.display-current-short-heading(level: 2)),
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

= Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Title

== Recall <recall>

*Recall*

#speaker-note[Recall]

#show: touying-set-config.with(config-methods(cover: utils.semi-transparent-cover))

== Animation

#set math.equation(numbering: "(1)")

Simple

#pause

$ x + y $

animation

#touying-recall(<recall>)


#show: appendix

= Appendix

Appendix