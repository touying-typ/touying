// #219: with `show-notes-on-second-screen`, the page is doubled along one axis
// and the extra half is pushed into the margin, so a `config-page(background: ..)`
// used to be stretched across the slide *and* the notes half. Each slide below
// uses a red->blue gradient as its background: the fix is visible as the slide
// showing the whole sweep, rather than only the red half of it with the blue
// half hidden behind the notes panel.
//
// This test needs reference images: the defect is purely where a background is
// painted, which is not observable through introspection.
//
// All four directions are covered, since `left` and `top` are new here - the
// option previously accepted only `bottom` and `right`.

#import "/lib.typ": *
#import themes.simple: *

#let bg = rect(width: 100%, height: 100%, fill: gradient.linear(red, blue))

#show: simple-theme.with(aspect-ratio: "16-9")

#let probe(side) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(background: bg),
    config-common(show-notes-on-second-screen: side),
  )
  touying-slide(
    self: self,
    [
      Notes on the #repr(side).

      #speaker-note[Note for the #repr(side) case.]
    ],
  )
})

= Notes on a second screen

== Right
#probe(right)

== Left
#probe(left)

== Bottom
#probe(bottom)

== Top
#probe(top)
