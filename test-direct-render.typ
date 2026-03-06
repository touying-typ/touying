#import "/lib.typ": *
#import themes.university: *

#show: university-theme.with(
  header: context {
    let hs = query(heading)
    let cur-page = here().page()
    let found = hs.filter(h => h.location().page() <= cur-page and h.level == 2)
    if found != () {
      let h = found.last()
      // DIRECTLY render the heading element (like style: auto does)
      text(0.835em, h)  // This is the problematic part
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
