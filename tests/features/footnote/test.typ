#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Footnote with Animations

== Labeled Footnote with pause

You can edit Typst documents online.#footnote[https://typst.app/app] <fn>

#pause

Checkout Typst's website. @fn
And the online app. #footnote(<fn>)

== Footnote Numbering Survives Manual Counter Manipulation

// A footnote hidden behind a pause must not create a real entry (it would leak
// below the separator before the pause), but reserving its marker's width must
// still number correctly relative to any earlier manual `counter(footnote)`
// changes made by the user - not just relative to touying's own bookkeeping.

First footnote#footnote[first] here.

#counter(footnote).update(10)

#pause

Second footnote, should be numbered 11#footnote[second, numbered 11] here.

Third footnote, should be numbered 12#footnote[third, numbered 12] here.


== Footnote Style Config

// `show footnote: set super(..)` does not affect Typst's own footnote marker
// rendering, and a raw `show footnote: it => ..` rule would only restyle real,
// revealed footnotes - not the placeholder touying draws for one hidden behind a
// pause. The `footnote-style` config keeps both consistent, and applies from
// where it's set via `touying-set-config` - not retroactively, and not
// independently per subslide of the same slide.

#show: touying-set-config.with(config-common(
  footnote-style: it => text(fill: blue, it),
))


Real one, styled from the start#footnote[first, blue] here.

#pause

Real two, was hidden then revealed - must match the same style#footnote[second, blue] here.


== Visual-only Cover Methods Keep Footnotes Visible

// `color-changing-cover` and `alpha-changing-cover` are meant to keep covered
// content visible (just de-emphasized), unlike the default cover method, which
// truly hides it. A footnote behind a pause under one of these must still show
// its real marker and entry, recolored like the rest of the covered content -
// not disappear the way it would under the default hiding cover.

#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(color: red),
))

Real one#footnote[first] here.

#pause

Real two, covered but still visible (recolored), not hidden#footnote[second, still visible] here.
