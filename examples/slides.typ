#import "../lib.typ": *

// #let store = themes.simple.register(store, aspect-ratio: "16-9", footer: [Simple slides])
// #let store = themes.metropolis.register(store, aspect-ratio: "16-9", footer: [Custom footer])
// #let store = themes.dewdrop.register(store, aspect-ratio: "16-9", footer: [Dewdrop])
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let store = (store.methods.enable-transparent-cover)(self: store)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#show strong: alert

#let (slide,) = utils.slides(store)
#show: slides

= Let's start a new section

== First Title

First content

#pause

with a pause.

== Second Title

Second content.