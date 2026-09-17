// #415: numeric citation numbers looked inflated under `#pause` - the second
// subslide showed `[3][4]` where `[1][2]` was expected.
//
// Not a bug in the end, and closed as such. The cause is that a `bibliography`
// *claims* the citations present in the render it sees, and touying re-renders a
// slide body once per subslide. On a multi-subslide slide the bibliography is
// therefore instantiated more than once: the first instance claims the
// citations (while being covered, so nobody sees its numbering) and each later
// instance starts a fresh block of the global numbering sequence. Two symptoms
// fall out of that one cause:
//
//   - citations re-rendered on the later subslide get renumbered -> `[3][4]`;
//   - citations that live on an *earlier* slide are not re-rendered at all, so
//     the later instance has nothing left to claim and renders nothing.
//
// The fix is to make sure only one instance exists. Either put the bibliography
// on its own slide with no `#pause` on it, or - if it has to live on an animated
// slide - wrap it in `only("h", ..)`, which emits it at a single subslide.
//
// So the invariant this test pins down is "exactly one bibliography instance",
// which is what keeps the numbering stable. It is asserted rather than compared
// as an image because the resolved number is exposed on neither the `cite`
// element (whose only fields are key/supplement/form/style) nor the
// `bibliography` element, while the instance count is directly queryable.
//
// Re-rendered *citations* are harmless, and the first slide below is here to
// keep that clear: four subslides re-render `@a`/`@b`/`@c` repeatedly and still
// number them `[1][2][3]`.

#import "/lib.typ": *
#import themes.simple: *

#let bib-data = bytes(
  "@book{a, author={Alpha}, title={Book A}, publisher={P}, year={2020}}\n"
    + "@book{b, author={Bravo}, title={Book B}, publisher={Q}, year={2021}}\n"
    + "@book{c, author={Charlie}, title={Book C}, publisher={R}, year={2022}}",
)

#show: simple-theme.with(aspect-ratio: "16-9")

= Citation numbering under pause

== Cites re-rendered across four subslides

First @a #pause then @b #pause and @c #pause done.

== References on their own slide

#bibliography(bib-data, style: "ieee", title: none)

== Assertions

#context {
  // The bibliography is on a slide with no `#pause`, so it is instantiated
  // once for the whole document no matter how many subslides the content
  // slide has. Every extra instance would shift the citation numbers.
  assert.eq(
    query(bibliography).len(),
    1,
    message: "expected exactly one bibliography instance; each extra one "
      + "claims a fresh block of citation numbers (#415)",
  )
  // The citations really are re-rendered per subslide. Asserted so that a
  // future change is not tempted to chase cite re-renders, which are not the
  // cause.
  assert(
    query(cite).len() > 3,
    message: "expected the citations to be re-rendered once per subslide",
  )
}
