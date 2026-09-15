// A math equation is a container, not a text leaf. Walking only the equation
// as a whole lets an explicitly colored text node inside override the outer
// cover style and remain fully visible before its reveal.

#import "/lib.typ": *

#let flattened-math-text = text(fill: red)[
  x #context [#metadata(text.fill)<covered-math-color>]
]
#let faded-math-text = text(fill: blue)[
  x #context [#metadata(text.fill)<covered-math-alpha>]
]

#utils.color-changing-cover(
  color: gray,
  fallback-hide: none,
  $ #flattened-math-text + y $,
)

#utils.alpha-changing-cover(
  alpha: 25%,
  fallback-hide: none,
  $ #faded-math-text + y $,
)

#context {
  let flattened = query(<covered-math-color>).first()
  let faded = query(<covered-math-alpha>).first()
  assert.eq(flattened.value, gray)
  assert.eq(faded.value.components(alpha: true).last(), 25%)
}
