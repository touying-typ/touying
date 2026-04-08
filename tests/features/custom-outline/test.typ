#import "/lib.typ": *
#import themes.simple: *

#let outline-section-fn(config: (:), ..args) = touying-slide-wrapper(self => {
  self.insert("header", "Contents")
  touying-slide(self: self, ..args.named(), config: config, [
    #text(2em, weight: "bold", [Contents rn])
    #components.custom-progressive-outline(
      self: self,
      level: 1,
      show-past: (true, false),
      show-future: (true, false),
      show-current: (true, true, false),
      vspace: (.0em, .0em),
      numbering: ("1.1",),
      numbered: (true,),
      title: none,
    )])
})

#show: simple-theme.with(numbering: "1.1", config-common(
  new-section-slide-fn: outline-section-fn,
  receive-body-for-new-section-slide-fn: false,
))

#set heading(numbering: "1.1")

= Start
== Start Sub
#lorem(5)
= My content
== My heading
#lorem(5)
---
#{
  // displays all top levels and all levels of the current top-level,
  // with future siblings and other top levels semi-transparent
  // and the current entry bold

  show outline.entry: it => {
    let relationship = utils.section-relationship(it)
    let current = utils.current-heading()
    let alpha = if relationship == -2 or relationship > 0 { 40% } else { 100% }
    let weight = if relationship == 0 and current.level == it.level {
      "bold"
    } else { "regular" }
    if it.level > 1 and calc.abs(relationship) > 1 {
      text(fill: red, it)
    } else {
      text(fill: utils.update-alpha(text.fill, alpha), weight: weight, it)
    }
  }
  outline(title: none)
}
---
=== Subsubhedaing
#lorem(3)

== Another heading
#lorem(5)

= Next Top Level

== Subsection
#lorem(5)
