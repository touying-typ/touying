#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-common(new-section-slide-fn: none),
)

// Touying's `measure` shadows Typst's. It parses the body the way a slide
// would, renders it at one subslide and measures that, so animation functions
// reserve the space they will actually occupy. Typst's own `measure` sees them
// as bare metadata marks and reports `0pt` (issue #417).
//
// Assertions compare against `std.measure`, so they pin the *relationship*
// (equal / greater / zero) rather than absolute point values, which would drift
// with font metrics and the theme's text size.

== Equivalence with the native measure

// With no `subslide`/`base`, `measure` must be a drop-in replacement: content
// with no animation in it has exactly one subslide, which is all of it.
#context {
  let cases = (
    [Hello world],
    [A longer paragraph that wraps onto more than a single line of text.],
    block(width: 80pt, height: 40pt)[fixed],
    [#figure(rect(width: 30pt, height: 20pt), caption: [cap])],
    table(
      columns: 2,
      [a], [b],
      [c], [d],
    ),
    [],
  )
  for c in cases {
    assert.eq(measure(c), std.measure(c))
  }

  // Forwarded arguments reach the native call unchanged.
  let wide = [some text that has to wrap when the region is narrow]
  assert.eq(measure(wide, width: 40pt), std.measure(wide, width: 40pt))
  assert.eq(
    measure(wide, width: 40pt, height: 10pt),
    std.measure(wide, width: 40pt, height: 10pt),
  )

  // A `#pause` chain already measured correctly before this existed, because
  // `pause` reserves space for what follows it. Still equal.
  let paused = [A #pause B]
  assert.eq(measure(paused), std.measure(paused))
}

== Animated content the native measure cannot see

#context {
  // The defect from #417: `uncover` reserves space on the slide, but the
  // native measure sees only a metadata mark.
  let unc = [#uncover("2-")[Reserved]]
  assert.eq(std.measure(unc).height, 0pt)
  assert(measure(unc).height > 0pt)

  // It reserves exactly what the same text occupies unanimated, since
  // `uncover` covers in place rather than removing.
  assert.eq(measure(unc).height, std.measure([Reserved]).height)

  // `only` genuinely reserves nothing — it is removed when not visible — so
  // zero here is the correct answer, not the bug above.
  assert.eq(measure([#only("2")[Gone]], subslide: 1).height, 0pt)

  // `item-by-item` removes the space of items it has not revealed yet, so it
  // *shrinks* as it advances. Its first subslide is its largest.
  let items = [
    #item-by-item[
      - one
      - two
      - three
    ]
  ]
  assert.eq(std.measure(items).height, 0pt)
  let first = measure(items, subslide: 1).height
  let last = measure(items, subslide: auto).height
  assert(first > last)

  // `subslide: none` maximises over every subslide, which is the worst case
  // and therefore what an overflow check wants.
  assert.eq(measure(items, subslide: none).height, first)

  // Each dimension is maximised independently: the tallest and the widest
  // subslide need not be the same one.
  let wide-then-tall = [
    #only("1")[#block(width: 90pt, height: 10pt)[wide]]
    #only("2")[#block(width: 10pt, height: 90pt)[tall]]
  ]
  let both = measure(wide-then-tall, subslide: none)
  assert.eq(both.width, measure(wide-then-tall, subslide: 1).width)
  assert.eq(both.height, measure(wide-then-tall, subslide: 2).height)
}

== Selecting a subslide

#context {
  // Three stages, each a different height, so "which subslide" is visible in
  // the number rather than inferred.
  let staged = [
    #only("1")[#block(height: 20pt)[a]]
    #only("2")[#block(height: 40pt)[b]]
    #only("3")[#block(height: 60pt)[c]]
  ]
  assert.eq(measure(staged, subslide: 1).height, 20pt)
  assert.eq(measure(staged, subslide: 2).height, 40pt)
  assert.eq(measure(staged, subslide: 3).height, 60pt)
  // `auto` is the last subslide; `none` the largest over all of them.
  assert.eq(measure(staged, subslide: auto).height, 60pt)
  assert.eq(measure(staged, subslide: none).height, 60pt)
  // Negative indices count back from the last subslide. They are allowed here
  // (unlike on `only`/`uncover`) because the count is already fixed by the
  // time this resolves: nothing can be appended to the body afterwards.
  assert.eq(measure(staged, subslide: -1).height, 60pt)
  assert.eq(measure(staged, subslide: -3).height, 20pt)

  // `base` shifts the body's internal *counter*, exactly as in
  // `touying-render`. The specs written inside the body stay absolute, so with
  // `base: 3` the valid range becomes 3..5 while `only("3")` still means 3 —
  // it is the counter that moves, not the numbering the body was written in.
  assert.eq(measure(staged, base: 3, subslide: 3).height, 60pt)
  assert.eq(measure(staged, base: 3, subslide: 4).height, 0pt)
  // `base` does move a *relative* spec: "h" means "wherever the counter is",
  // so it lands on `base` rather than on 1.
  let here-spec = [#only("h")[#block(height: 25pt)[h]]]
  assert.eq(measure(here-spec, base: 1, subslide: 1).height, 25pt)
  assert.eq(measure(here-spec, base: 3, subslide: 3).height, 25pt)

  // A waypoint label resolves against the body's own waypoints.
  let wp-body = [
    #only("1")[#block(height: 20pt)[a]]
    #waypoint(<second>)
    #only("2")[#block(height: 40pt)[b]]
  ]
  assert.eq(measure(wp-body, subslide: <second>).height, 40pt)
  assert.eq(measure(wp-body, subslide: get-last(<second>)).height, 40pt)
}

== Inside layout, and returning a value

#context {
  // `measure` opens no context of its own, so it returns a dictionary the
  // caller can compute with rather than opaque content.
  let h = measure([#uncover("2-")[x]]).height
  assert(type(h) == length)
  assert(h > 0pt)
}

// It also inherits the caller's region, so it works inside `layout` and sees
// the width it is given.
#layout(size => context {
  let body = [#uncover("2-")[some text that wraps when the region is narrow]]
  let full = measure(body, width: size.width).height
  let narrow = measure(body, width: 40pt).height
  assert(narrow > full)
  // The same content, measured natively, is invisible at either width.
  assert.eq(std.measure(body, width: 40pt).height, 0pt)
})

== Reducers

// A `touying-reducer` is the other shape animated content takes. It is what
// `page-container`'s overflow detection has to cope with.
#context {
  let red = touying-reducer(
    reduce: it => it.sum(default: none),
    cover: it => it.map(c => hide(c)),
    ([#block(height: 30pt)[one]], pause, [#block(height: 30pt)[two]]),
  )
  // Covered with `hide`, which reserves, so both stages measure the same and
  // neither is zero.
  assert(measure(red, subslide: 1).height > 0pt)
  assert.eq(measure(red, subslide: none).height, measure(red).height)
}
