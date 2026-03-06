#import "/lib.typ": *
#import themes.university: *

// Test: what if we just use a simpler header that uses current-heading with style: none?

#show: university-theme.with(
  // Use explicit counter query (like default style but with simple display)
  header: context {
    let hs = query(heading)
    let cur-page = here().page()
    let found = hs.filter(h => h.location().page() <= cur-page and h.level == 2)
    if found != () {
      let h = found.last()
      text(0.835em, h.body)  // Just body, no counter dependency
    }
  },
  progress-bar: false
)

#outline(title: none, indent: 1em)

= T1

== S1
C1

== S2
C2

== S3
C3

== S4
C4
