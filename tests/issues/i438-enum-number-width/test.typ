// Regression test for https://github.com/touying-typ/touying/issues/438.
// An enum split by `#pause` or `#item-by-item` is laid out as several
// containers, and Typst sizes the number column of each to its own widest
// number. Each part has to be given the width the whole enum has, or the visible
// items sit at another indent than the covered ones and move sideways when
// those are revealed.
//
// Each scenario draws the enum animated and unanimated. The text of every item
// is marked, and the marker must hold the same x on every subslide and match the
// unanimated one. The numbers are pinned by x of the text after them, since the
// column is what moves it.
//
// Compile-only: what is pinned is a position, not an appearance.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(
  config-page(height: 600pt),
  config-methods(cover: utils.color-changing-cover.with(color: rgb("#999999"))),
)

#let m(name) = [#metadata(name)#label(name)]

// The covered part used to sit in a column as wide as "10." and the visible part
// in one as wide as "2.".
== pause, widest number in the covered part
+ #m("a-pb-1") one
+ #m("a-pb-2") two #pause
+ #m("a-pb-3") three
9. #m("a-pb-4") nine
+ #m("a-pb-5") ten

== static
+ #m("s-pb-1") one
+ #m("s-pb-2") two
+ #m("s-pb-3") three
9. #m("s-pb-4") nine
+ #m("s-pb-5") ten

// The reverse: the covered part is the narrow one.
== pause, widest number in the visible part
9. #m("a-rev-1") nine
+ #m("a-rev-2") ten #pause
1. #m("a-rev-3") one
+ #m("a-rev-4") two

== static
9. #m("s-rev-1") nine
+ #m("s-rev-2") ten
1. #m("s-rev-3") one
+ #m("s-rev-4") two

// A blank line makes the enum non-tight, which takes the other rebuilding path.
== pause, non-tight
+ #m("a-nt-1") one
+ #m("a-nt-2") two #pause

+ #m("a-nt-3") three
9. #m("a-nt-4") nine
+ #m("a-nt-5") ten

== static
+ #m("s-nt-1") one
+ #m("s-nt-2") two

+ #m("s-nt-3") three
9. #m("s-nt-4") nine
+ #m("s-nt-5") ten

// Widths come from the numbering itself, whatever it is.
== pause, numbering pattern
#set enum(numbering: "i.")
+ #m("a-roman-1") one
+ #m("a-roman-2") two #pause
+ #m("a-roman-3") three
+ #m("a-roman-4") four
+ #m("a-roman-5") five
+ #m("a-roman-6") six
+ #m("a-roman-7") seven
+ #m("a-roman-8") eight

== static
#set enum(numbering: "i.")
+ #m("s-roman-1") one
+ #m("s-roman-2") two
+ #m("s-roman-3") three
+ #m("s-roman-4") four
+ #m("s-roman-5") five
+ #m("s-roman-6") six
+ #m("s-roman-7") seven
+ #m("s-roman-8") eight

== pause, numbering function and start offset
#set enum(numbering: n => [Step #n:], start: 8)
+ #m("a-fn-1") one
+ #m("a-fn-2") two #pause
+ #m("a-fn-3") three
+ #m("a-fn-4") four

== static
#set enum(numbering: n => [Step #n:], start: 8)
+ #m("s-fn-1") one
+ #m("s-fn-2") two
+ #m("s-fn-3") three
+ #m("s-fn-4") four

// Parent numbers are part of the number, and a nested enum's column is its own.
== pause in a nested enum, full numbering
#set enum(full: true, numbering: "1.1.1)")
+ outer
  + #m("a-nest-1") one
  + #m("a-nest-2") two #pause
  + #m("a-nest-3") three
  9. #m("a-nest-4") nine
  + #m("a-nest-5") ten

== static
#set enum(full: true, numbering: "1.1.1)")
+ outer
  + #m("s-nest-1") one
  + #m("s-nest-2") two
  + #m("s-nest-3") three
  9. #m("s-nest-4") nine
  + #m("s-nest-5") ten

== item-by-item
#item-by-item[
  + #m("a-ibi-1") one
  + #m("a-ibi-2") two
  + #m("a-ibi-3") three
  9. #m("a-ibi-4") nine
  + #m("a-ibi-5") ten
]

== static
+ #m("s-ibi-1") one
+ #m("s-ibi-2") two
+ #m("s-ibi-3") three
9. #m("s-ibi-4") nine
+ #m("s-ibi-5") ten

== item-by-item, non-tight
#item-by-item[
  + #m("a-ibint-1") one
  + #m("a-ibint-2") two

  + #m("a-ibint-3") three
  9. #m("a-ibint-4") nine
  + #m("a-ibint-5") ten
]

== static
+ #m("s-ibint-1") one
+ #m("s-ibint-2") two

+ #m("s-ibint-3") three
9. #m("s-ibint-4") nine
+ #m("s-ibint-5") ten

== assertions
#context {
  let xs(name) = query(label(name)).map(m => m.location().position().x)
  let same(a, b) = calc.abs((a - b).pt()) < 0.001

  // `subslides` is how many pages the scenario spans, so that a marker seen on
  // only some of them cannot pass for stable.
  let matches-static(scenario, count, subslides) = {
    for index in range(1, count + 1) {
      let seen = xs("a-" + scenario + "-" + str(index))
      let static = xs("s-" + scenario + "-" + str(index)).first()
      assert.eq(
        seen.len(),
        subslides,
        message: scenario
          + " item "
          + str(index)
          + ": expected "
          + str(subslides)
          + " subslides, got "
          + repr(seen),
      )
      assert(
        seen.all(x => same(x, static)),
        message: scenario
          + " item "
          + str(index)
          + " is at "
          + repr(seen)
          + " but the unanimated enum puts it at "
          + repr(static),
      )
    }
  }
  matches-static("pb", 5, 2)
  matches-static("rev", 4, 2)
  matches-static("nt", 5, 2)
  matches-static("roman", 8, 2)
  matches-static("fn", 4, 2)
  matches-static("nest", 5, 2)
  matches-static("ibi", 5, 5)
  matches-static("ibint", 5, 5)
}
