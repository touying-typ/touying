#import "/lib.typ": *

#import themes.simple: *
#show: simple-theme.with(
  config-common(
    export-mode: "presentation",
    handout-mode: false,
    show-hide-set-list-marker-none: true,
  ),
  config-info(
    title: [Appendix Test],
  ),
)

#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")

= Content

== First Slide

First
#pause
#show par: set text(2em)

More bigger content


== Second Slide

Second
#pause
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))

Semi Transparent Cover Effect


== Third Slide

Third

#show: appendix


#set heading(numbering: "A.1")
#counter(heading).update((1, 0))
// Case 1 (Bug 1 fix): config in absorbing context, no leading-preamble before it.
// The cover change must take effect on the appendix slides.
#show: touying-set-config.with(config-methods(
  cover: utils.method-wrapper(hide),
))
= Appendix <touying:hidden> //does not render the section slide, but still registers the section for numbering
== First Appendix
// Cover for #pause should be "hide" (content disappears completely, no semi-transparent)
My Appendix Content #pause More Appendix Content

== Second Appendix
// Case 2 (Bug 2 fix): config right after heading (slide-parts == ()), leading-preamble
// was already set by the counter update above. The counter update must not be dropped.
// Heading numbering should be A.2 (counter was set to (1,0), incremented once for A.1)
// and the cover change here must also take effect.
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))
Second Appendix Content #pause Semi-Transparent Cover Here

== Third Appendix
// Case 3: nested configs in absorbing context (before first heading).
// Both configs must be applied and counter update must survive.
// Heading should be A.3, content visible, pause uses hide cover.
#counter(heading.where(level: 2)).update(2)
#show: touying-set-config.with(config-methods(
  cover: utils.method-wrapper(hide),
))
#show: touying-set-config.with(config-info(
  author: [Test Author],
))
Third Appendix Content #pause Hidden Pause Content

== Fourth Appendix
// Case 4: immediate path — config appears AFTER slide content (slide-parts non-empty).
// This exercises the non-deferred immediate path unchanged by our bug fixes.
Before config change.
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))
#pause
After config change with semi-transparent cover.

#show: touying-set-config.with((:), defer: true) // test that preamble capture properly stops.

== Fifth Appendix
// Case 5 (absorb-leading-preamble reset): a pagebreak/--- after a section slide must
// NOT absorb subsequent content into leading-preamble.  The content below must appear
// on its own slide, not be silently dropped.
---
Content after pagebreak must be visible on this slide.
#pause
And this too.

== Sixth Appendix
// Case 6: same as Case 5 but using an explicit #pagebreak() instead of ---.
// Content after the pagebreak must appear, not be swallowed by absorb-leading-preamble.
#show: touying-set-config.with((:), defer: true) // test that preamble capture properly stops.
#pagebreak()
Content after explicit pagebreak must be visible.
#pause
And this too.
