// A boolean `wrap: false` disables extraction altogether. In particular, a
// standalone image between two explicit slide bodies must remain between them
// after article-mode linearization instead of being appended to the section.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(wrap: false),
)

== Ordering

#slide(composer: (1fr, 1fr, 1fr))[
  #box[First body] <wrap-disabled-before>
][
  #image(
    "/tests/features/article-mode/image.png",
    width: 40%,
  ) <wrap-disabled-image>
][
  #box[Third body] <wrap-disabled-after>
]

#context {
  let y(lbl) = query(lbl).first().location().position().y
  //the three composer columns linearize in source order, so the image sits
  //between the two bodies: with wrapping off nothing is lifted out of the flow
  assert(y(<wrap-disabled-before>) < y(<wrap-disabled-image>))
  assert(
    y(<wrap-disabled-image>) < y(<wrap-disabled-after>),
    message: "wrap: false moved the image after the following slide body",
  )
}
