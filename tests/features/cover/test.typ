#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme
#set figure(numbering: none)

= Cover & Overlay Tests

== Semi-transparent Cover
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))
// #show par: set text(2em)
Regular content here.#pause This content appears |with semi-transparent cover effect. Math: $E = m c^(f f)_g$ and also Raw: `inline code` and Quote: #quote(block: false)[This is a quote.]

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

== Text Blocks with Semi-transparent Cover

// #figure(
//   rect(fill: red, height: 1pt),
//   caption: [A red rectangle.],
// )
#skew[Normal text block]
// Normal Text
#pause
#show skew: set text(2em)

#{
  show par: set text(2em)
  align(center)[Big ff text]
}
#pause

#skew(ax: 0deg)[Big ff text.]
#pause

#rotate(0deg)[Not Rotated]



== Default Cover Behavior

#show: touying-set-config.with(config-methods(
  cover: utils.method-wrapper(hide),
))

Content that gets hidden completely when covered.#pause New content replaces the old content entirely.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

== Color Changing Cover
#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(color: gray),
))
Regular content here.#pause This text should appear in gray when covered.
#let pantone = color.spot(
  "PANTONE 2221 C",
  rgb("#239dad"),
)
#figure(
  rect(fill: pantone.tint(40%)),
  caption: [A red rectangle.],
)

#pause

More text with gray cover effect.

== Color Changing Cover with Color Fallback Overlay
#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(
    color: gray,
    fallback-hide: utils.cover-with-rect,
    fallback-hide-args: (fill: gray.transparentize(50%)),
  ),
))

Regular content here.#pause This text should appear in gray when covered, and non-text content should be covered with a semi-transparent gray rectangle.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More text with the same effect.

== Alpha Changing Cover
#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover.with(alpha: 25%),
))
Regular content here.#pause This text should appear semi-transparent when covered.

#figure(
  rect(fill: pantone.tint(40%)),
  caption: [A red rectangle.],
)

#pause

More semi-transparent text.

== Alpha Changing Cover with Semi-transparent Fallback Overlay
#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover.with(
    alpha: 25%,
    fallback-hide: utils.semi-transparent-cover,
    fallback-hide-args: (alpha: 75%),
  ),
))

Regular content here.#pause This text should appear semi-transparent when covered, and non-text content should be covered with a semi-transparent gray overlay.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More semi-transparent text.

== Cover Reconstruction: Layout
#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover.with(alpha: 25%),
))

Positional fields and labels must survive a cover rebuild.
#pause

#align(center)[Centered] <cov-align>
A #link("https://typst.app")[link] in a sentence.
#rotate(10deg, reflow: true)[Rotated]
#block(width: 100%, height: 0.8cm, stroke: 0.5pt)[#place(top + right)[Placed] <cov-place>]
#columns(2)[Two #colbreak() columns] <cov-columns>

== Cover Reconstruction: Math and Shapes
#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(color: gray),
))

The same for math classes and shapes with positional vertices.
#pause

$ underbrace(a + b, "sum") quad a class("binary", star) b $
#polygon(fill: blue, (0pt, 0pt), (20pt, 0pt), (10pt, 16pt))
#curve(fill: red, curve.move((0pt, 0pt)), curve.line((20pt, 12pt)), curve.line((0pt, 12pt)))
#raw("let x = 1\nlet y = 2", lang: "typst", block: true)
