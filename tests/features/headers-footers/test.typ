#import "/lib.typ": *
#import themes.default: *
#import "@preview/numbly:0.1.0": numbly

#show: default-theme.with(
  config-page(
    header: text(gray, utils.display-current-short-heading(level: 2)),
    footer: [Custom Footer Content],
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

= Headers & Footers Tests

== Header Display Test

This slide should show the section title "Headers & Footers Tests" in the header.

Content of the slide goes here.

== Different Header Styles

#show: touying-set-config.with(config-page(
  header: text(blue, weight: "bold", utils.display-current-short-heading(level: 1)),
))

Now the header should be blue and bold, showing the main section.

== Custom Footer Content

#show: touying-set-config.with(config-page(
  footer: [Page #context utils.slide-counter.display() | Custom Footer | Today: #datetime.today().display()],
))

This slide has a custom footer with page number and date.

== No Header or Footer

#show: touying-set-config.with(config-page(
  header: none,
  footer: none,
))

This slide has no header or footer - clean layout.

== Header with Progress

#show: touying-set-config.with(config-page(
  header: [
    #text(gray, utils.display-current-short-heading(level: 2))
    #h(1fr)
    #text(size: 0.8em, [Slide #context utils.slide-counter.display()])
  ],
))

Header now includes slide progress information.