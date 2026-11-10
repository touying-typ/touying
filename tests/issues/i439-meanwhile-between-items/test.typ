// A `#meanwhile` between list items must not move the rows between subslides
// (#439). Each animated row is compared on every subslide with the same row of
// a deck without animation. Compile-only: what is pinned is a position.

#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme.with(config-common(new-section-slide-fn: none))

#let p(lbl) = [#metadata("p")#lbl]

== meanwhile between items

- #p(<a1>)First #pause
  - First detail
#meanwhile
- #p(<a2>)Second #pause
  - Second detail
#meanwhile
- #p(<a3>)Third #pause
  - Third detail

== enum

+ #p(<e1>)First #pause
  + First detail
#meanwhile
+ #p(<e2>)Second #pause
  + Second detail

== pause and meanwhile with nothing between them

- #p(<g1>)First
#pause
#meanwhile
- #p(<g2>)Second
#pause
#meanwhile
- #p(<g3>)Third #pause
  - Third detail

== static

- #p(<s1>)First
  - First detail
- #p(<s2>)Second
  - Second detail
- #p(<s3>)Third
  - Third detail

== static enum

+ #p(<se1>)First
  + First detail
+ #p(<se2>)Second
  + Second detail

== static pause

- #p(<sg1>)First
- #p(<sg2>)Second
- #p(<sg3>)Third
  - Third detail

== assertions

#context {
  let ys(lbl) = query(lbl).map(m => m.location().position().y)
  let same(a, b) = calc.abs((a - b).pt()) < 0.001

  let check(animated, static) = {
    let seen = ys(label(animated))
    let want = ys(label(static)).first()
    assert(seen.len() >= 2, message: animated + ": expected several subslides")
    for y in seen {
      assert(same(y, want), message: animated + " moved: " + repr(seen))
    }
  }

  check("a1", "s1")
  check("a2", "s2")
  check("a3", "s3")
  check("e1", "se1")
  check("e2", "se2")
  check("g1", "sg1")
  check("g2", "sg2")
  check("g3", "sg3")
}
