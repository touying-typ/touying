#import "../lib.typ": *

// #let s = themes.simple.register(s, aspect-ratio: "16-9", footer: [Simple slides])
// #let s = themes.metropolis.register(s, aspect-ratio: "16-9", footer: [Custom footer])
// #let s = themes.dewdrop.register(s, aspect-ratio: "16-9", footer: [Dewdrop])
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide,) = utils.slides(s)
#show: slides

= Let's start a new section

== First Title

First content

#pause

with a pause.

== Second Title

Second content.