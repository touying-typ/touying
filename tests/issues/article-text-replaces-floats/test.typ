// `#article-text[..]` stands in for the slide content in front of it. It did
// not stand in for that content's *floats*.
//
//   == s
//   #components.side-by-side[GRIDLEFT][GRIDRIGHT]
//   #article-text[PROSEONLY]
//
// The article contained the grid as well as the prose. With `wrap-images` on
// — which is the default, so this is the path almost every article takes —
// the walker pulls images and block-level content out of each run into
// `current-images` / `current-blocks`, for meander to wrap the section's text
// around later. `article-text` reset `current-items` but left those two
// queues alone, so `_wrap-section` still emitted them at the end of the
// section.
//
// Compile-only: what's asserted is which content reached the article.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(
  export-mode: "article",
  new-section-slide-fn: none,
))

== Replaced Block Content
#components.side-by-side[
  Left column. #label("grid-left")
][
  Right column. #label("grid-right")
]
#article-text[Prose standing in for the columns. #label("block-prose")]

== Replaced Image
#image("image.png", width: 40%)#label("floated-image")
#article-text[Prose standing in for the image. #label("image-prose")]

== Kept Alongside
// `#article-only` supplements rather than replaces, so nothing it follows
// may be dropped — the mirror image of the case above, and the reason this
// can't be fixed by clearing the queues for every mark.
#components.side-by-side[
  Kept left. #label("kept-left")
][
  Kept right. #label("kept-right")
]
#article-only[Extra prose. #label("extra-prose")]

#article-only[
  #context {
    for name in ("block-prose", "image-prose", "extra-prose") {
      assert.eq(
        query(label(name)).len(),
        1,
        message: name + " is missing from the article",
      )
    }
    for name in ("grid-left", "grid-right", "floated-image") {
      assert.eq(
        query(label(name)).len(),
        0,
        message: name + " was not replaced by the article-text prose",
      )
    }
    for name in ("kept-left", "kept-right") {
      assert.eq(
        query(label(name)).len(),
        1,
        message: name + " was dropped, but article-only replaces nothing",
      )
    }
  }
]
