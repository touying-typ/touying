// `<touying:never>` drops its content from every output mode.
//
// Compile-only (no `ref/*.png`): the property under test is which slides exist,
// not what they look like, so each mode queries marker labels instead of
// diffing images.
//
// Two behaviours are pinned:
//
//  1. `<touying:never>` on a heading drops the whole section -- in slides
//     output and in article output alike -- and on a `#slide[..]` drops that
//     slide. The speaker note goes with it.
//  2. `never` is the empty mode list, so unlike presentation / handout /
//     article -- which can hold at the same time and therefore combine with
//     hyphens -- it does not compose. `<touying:never-presentation>` is not a
//     valid label and must filter nothing.
//
// The heading cases are the regression-prone ones: the mode filter used to be
// defeated on any heading level that has a section-slide fn (level 1 in every
// bundled theme), because the skip path reset `current-headings`, so the
// section's body slides saw no label at all and were emitted anyway.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: false),
)

// The assertions live here, before the filtered content, on purpose: a
// trailing `#context` block can itself be swallowed by the very filtering
// under test, which would make this test pass vacuously. `query` sees the
// whole document from anywhere, so position costs nothing.
#context {
  assert.eq(
    query(<m-a>).len(),
    1,
    message: "presentation: unlabelled section must render",
  )
  assert.eq(
    query(<m-b>).len(),
    0,
    message: "presentation: <touying:never> section must not render",
  )
  assert.eq(
    query(<m-c>).len(),
    1,
    message: "presentation: never-presentation is not a keyword and must filter nothing",
  )
  assert.eq(
    query(<m-d>).len(),
    1,
    message: "presentation: unlabelled slide must render",
  )
  assert.eq(
    query(<m-e>).len(),
    0,
    message: "presentation: <touying:never> slide must not render",
  )
}

= Kept
Body A #metadata("a") <m-a>

= Dropped <touying:never>
Body B #metadata("b") <m-b>
#speaker-note[This note must vanish with its section.]

= Typo <touying:never-presentation>
Body C #metadata("c") <m-c>

== Slides
#slide[kept #metadata("d") <m-d>]
#slide[dropped #metadata("e") <m-e>] <touying:never>
