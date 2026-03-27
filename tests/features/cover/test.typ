#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme
#set figure(numbering: none)

= Cover & Overlay Tests

== Semi-transparent Cover
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))

Regular content here.#pause This content appears |with semi-transparent cover effect. Math: $E = m c^(f f)_g$ and also Raw: `inline code` and Quote: #quote(block:false)[This is a quote.]

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More content with the same effect.

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

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More text with gray cover effect.

== Color Changing Cover with Color Fallback Overlay
#show: touying-set-config.with(config-methods(
  cover: utils.color-changing-cover.with(
    color: gray, 
    fallback-hide: utils.cover-with-rect,
    fallback-hide-args: (fill: gray.transparentize(50%))
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
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More semi-transparent text.

== Alpha Changing Cover with Semi-transparent Fallback Overlay
#show: touying-set-config.with(config-methods(
  cover: utils.alpha-changing-cover.with(
    alpha: 25%, 
    fallback-hide: utils.semi-transparent-cover,
    fallback-hide-args: (alpha: 40%)
  ),
))

Regular content here.#pause This text should appear semi-transparent when covered, and non-text content should be covered with a semi-transparent gray overlay.

#figure(
  rect(fill: red),
  caption: [A red rectangle.],
)

#pause

More semi-transparent text.