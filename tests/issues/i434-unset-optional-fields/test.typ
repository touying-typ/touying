// Regression test for https://github.com/touying-typ/touying/issues/434.
//
// Content built by a direct call, such as `figure(rect[x])` or `raw("x")`,
// carries no field for an optional argument that was left out. Reading one
// with `it.field` instead of `it.at(field, default: ..)` aborts the document.
// Where the value decides how content is covered, the default is the one the
// active `set` rule gives, read in context, so it matches what Typst renders.

#import "/lib.typ": *
#import themes.simple: *

#assert.eq(utils.markup-text(raw("x")), "`x`")
#assert.eq(utils.markup-text(raw("x", block: true)), "\n```\nx\n```")
#assert.eq(utils.markup-text(heading[x]), "= x\n")
#assert.eq(utils.markup-text(heading(level: 2)[x]), "== x\n")
// A materialized heading has both fields; `depth` wins over `offset + depth`.
#context {
  set heading(offset: 1)
  show heading: it => assert.eq(utils.markup-text(it), "= x\n")
  heading[x]
}
#context {
  assert.eq(utils.is-block(quote[x]), false)
  assert.eq(utils.is-block(raw("x")), false)
  assert.eq(utils.is-block(math.equation[x]), false)
}
#[
  #set quote(block: true)
  #set raw(block: true)
  #set math.equation(block: true)
  #context {
    assert.eq(utils.is-block(quote[x]), true)
    assert.eq(utils.is-block(raw("x")), true)
    assert.eq(utils.is-block(math.equation[x]), true)
    // An explicit argument still beats the `set` rule.
    assert.eq(utils.is-block(raw("x", block: false)), false)
  }
]

#show: simple-theme.with(
  config-info(author: raw("me")),
  config-methods(cover: utils.cover-with-rect.with(fill: white)),
)

== Figure without caption

#pause
#figure(rect[x])
B

== Inline elements covered by rects

A
#pause
#quote[x]
#raw("y")
#math.equation[z]

#heading[Headings built by a call]

#heading(level: 2)[A slide from `heading(level: 2)`]

C
