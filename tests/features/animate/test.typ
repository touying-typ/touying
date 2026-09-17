// `#animate` combines visibility and styling on one piece of content.
//
// The two classes of effect combine differently, and that asymmetry is the
// whole design:
//
//   - Placements ("show"/"cover"/"remove"/swap) are *resolved*: exactly one
//     wins per subslide. They cannot be composed, because the cover method is
//     `hide` (not a style node) and "remove" drops the content outright —
//     nothing nested inside either could undo it. So the winner is picked
//     before anything renders.
//   - Styles (plain functions) are *composed*, nesting innermost-first, which
//     is something Typst already handles correctly.
//
// Ties break the same way in both classes: the last effect written wins. A
// placement wins by being the one used, a style by ending up innermost.
//
// The other half is space. A swap replaces the body outright and lets the
// layout reflow, unless it asks to `stretch`, in which case it joins the
// reservation. Nothing is measured at all until some swap does ask.
//
// Most of this is asserted from the x position of a marker placed immediately
// after the animate on the same line: that x *is* the width the animate
// occupied, which is exactly what these rules are about.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let mark(name) = box(width: 0pt, height: 0pt)[#h(0pt)#label(name)]

// Widths, narrowest to widest, so an assertion can name which one it expects.
#let narrow = [nn]
#let medium = [mmmmmmmmmm]
#let wide = [wwwwwwwwwwwwwwwwwwww]

// Two styles that do not commute: whichever ends up outermost decides the
// width. A pin-200 outermost measures 200pt, a grow outermost measures 220pt.
#let grow = (body, ..) => box(body, inset: 10pt)
#let pin-200 = (body, ..) => box(body, width: 200pt)

== baselines
#narrow#mark("base-narrow")

#medium#mark("base-medium")

#wide#mark("base-wide")

== no effects at all leaves layout untouched
#animate(medium)#mark("plain")

== cover reserves, remove does not
#animate(medium, effects: ((effect: "cover", subslides: 1),))#mark("covered")

#animate(medium, effects: ((effect: "remove", subslides: 1),))#mark("removed")

== defaults: subslides is "1-" and priority is 1
// Neither key is written, so this must still beat the implicit priority-0
// "show" and apply on subslide 1.
#animate(medium, effects: ((effect: "remove"),))#mark("defaulted")

== a higher-priority placement wins
// "remove" at priority 2 beats the priority-1 "cover"; a *style*, whatever its
// priority, cannot put back what a placement took away.
#animate(
  medium,
  effects: (
    (effect: "cover", subslides: 1),
    (effect: "remove", subslides: 1, priority: 2),
    (effect: (body, ..) => body, subslides: 1, priority: 9),
  ),
)#mark("out-ranked")

== equal placement priorities: the last one written wins
#animate(
  medium,
  effects: (
    (effect: "cover", subslides: 1, priority: 3),
    (effect: "remove", subslides: 1, priority: 3),
  ),
)#mark("tie-remove-last")

#animate(
  medium,
  effects: (
    (effect: "remove", subslides: 1, priority: 3),
    (effect: "cover", subslides: 1, priority: 3),
  ),
)#mark("tie-cover-last")

== equal style priorities: the last one written is innermost
#animate(
  narrow,
  effects: (
    (effect: grow, subslides: 1),
    (effect: pin-200, subslides: 1),
  ),
)#mark("style-grow-first")

#animate(
  narrow,
  effects: (
    (effect: pin-200, subslides: 1),
    (effect: grow, subslides: 1),
  ),
)#mark("style-pin-first")

== style priority overrides the written order
// pin-200 is innermost because of its lower priority, not because of where
// it is written - priority is consulted before the written order.
#animate(
  narrow,
  effects: (
    (effect: grow, subslides: 1, priority: 2),
    (effect: pin-200, subslides: 1, priority: 1),
  ),
)#mark("style-by-priority")

== a swap without stretch lets the layout reflow
#animate(
  medium,
  effects: ((effect: swap(wide), subslides: 2),),
)#mark("reflowing-swap")

== a swap with stretch joins the reservation
#animate(
  medium,
  effects: ((effect: swap(wide, stretch: true), subslides: 2),),
)#mark("stretching-swap")

== a reflowing swap alongside a stretching one
// The reservation is the original plus the stretching body; the reflowing
// swap is the widest of the three and must not enlarge it.
#animate(
  narrow,
  effects: (
    (effect: swap(wide), subslides: 2),
    (effect: swap(medium, stretch: true), subslides: 3),
  ),
)#mark("mixed")

== the reservation is measured with the styles that are active
// The body is narrow everywhere, but on subslide 2 a style grows it. Since
// some swap stretches, that grown size has to be what gets reserved — and it
// must hold on subslide 1 too, where the style is not active.
#animate(
  narrow,
  effects: (
    (effect: pin-200, subslides: 2),
    (effect: swap(narrow, stretch: true), subslides: 3),
  ),
)#mark("styled-measure")

== Assertions
#context {
  // Every marker sits at the end of its own line, so its x is the width of
  // whatever preceded it. Markers inside a multi-subslide animate appear once
  // per subslide; `.first()` is subslide 1 unless stated otherwise.
  let xs(name) = query(label(name)).map(m => m.location().position().x)
  let x(name) = xs(name).first()

  let nn = x("base-narrow")
  let mm = x("base-medium")
  let ww = x("base-wide")
  assert(nn < mm and mm < ww, message: "baseline widths are not ordered")

  // --- placement ---------------------------------------------------------

  // no effects: identical to writing the body directly
  assert.eq(x("plain"), mm)
  // cover keeps the full space, exactly like uncover
  assert.eq(x("covered"), mm)
  // remove keeps none of it, exactly like only
  assert(x("removed") < nn, message: "remove still reserved space")

  // subslides defaults to "1-" and priority to 1, so this removes on
  // subslide 1 without either key being written
  assert.eq(x("defaulted"), x("removed"))

  // a higher-priority placement wins, and a style — at any priority — cannot
  // undo it: this must match `remove`, not `cover`
  assert.eq(x("out-ranked"), x("removed"))

  // --- tie-breaking ------------------------------------------------------

  // equal priorities: the later placement wins, in either order
  assert.eq(x("tie-remove-last"), x("removed"))
  assert.eq(x("tie-cover-last"), mm)

  // equal priorities: the LAST style written is innermost, so pin-then-grow
  // ends at pin-200's 200pt and grow-then-pin ends 20pt wider
  let pinned = x("style-pin-first")
  assert.eq(x("style-grow-first") - pinned, 20pt)
  // and priority beats the written order: pin-200 at the lower priority goes
  // innermost even though it is written first
  assert.eq(x("style-by-priority"), x("style-grow-first"))

  // --- reservation -------------------------------------------------------

  // no stretch anywhere: nothing is measured, so each subslide is its own
  // natural width
  assert.eq(xs("reflowing-swap"), (mm, ww))
  // with stretch, both subslides sit in the overlay of body and swap body
  assert.eq(xs("stretching-swap"), (ww, ww))
  // narrow body + swap(wide) + swap(medium, stretch: true): the reservation
  // is max(narrow, medium) on every subslide, and the wider reflowing swap
  // does not push it to `ww`
  assert.eq(xs("mixed"), (mm, mm, mm))

  // measured styled: subslide 2's pin-200 sets the reservation for all three
  assert.eq(xs("styled-measure"), (pinned, pinned, pinned))
}
