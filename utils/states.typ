// touying slide counters
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = locate(loc => last-slide-counter.final(loc).first())

#let touying-progress(callback) = locate(loc => {
  if last-slide-counter.final(loc).first() == 0 {
    callback(1.0)
    return
  }
  let ratio = calc.min(1.0, slide-counter.at(loc).first() / last-slide-counter.final(loc).first())
  callback(ratio)
})

// sections
#let sections-state = state("touying-sections-state", ((kind: "section", title: none, short-title: none, loc: none, count: 0, children: ()),))

#let _new-section(short-title: auto, duplicate: false, title) = locate(loc => {
  sections-state.update(sections => {
    if duplicate or sections.last().title != title or sections.last().short-title != short-title {
      sections.push((kind: "section", title: title, short-title: short-title, loc: loc, count: 0, children: ()))
    }
    sections
  })
})

#let _new-subsection(short-title: auto, duplicate: false, title) = locate(loc => {
  sections-state.update(sections => {
    let last-section = sections.pop()
    let last-subsection = (kind: "none")
    let i = -1
    while last-subsection.kind != "subsection" {
      last-subsection = last-section.children.at(i, default: (kind: "subsection", title: none, short-title: none, loc: none, count: 0, children: ()))
      i += 1
    }
    if duplicate or last-subsection.title != title or last-subsection.short-title != short-title {
      last-section.children.push((kind: "subsection", title: title, short-title: short-title, loc: loc, count: 0, children: ()))
    }
    sections.push(last-section)
    sections
  })
})

#let _sections-step(repetitions) = locate(loc => {
  sections-state.update(sections => {
    let last-section = sections.pop()
    if last-section.children.len() == 0 or last-section.children.last().kind == "slide" {
      last-section.children.push((kind: "slide", loc: loc, count: repetitions))
      last-section.count += 1
      sections.push(last-section)
    } else {
      // update for subsection
      let last-subsection = last-section.children.pop()
      last-subsection.children.push((kind: "slide", loc: loc, count: repetitions))
      last-subsection.count += 1
      last-section.count += 1
      last-section.children.push(last-subsection)
      sections.push(last-section)
    }
    sections
  }
)})

#let touying-final-sections(callback) = locate(loc => {
  callback(sections-state.final(loc))
})

#let touying-outline(self: none, enum-args: (:), padding: 0pt) = touying-final-sections(sections => {
  let enum-args = (full: true) + enum-args
  if self != none and self.numbering != none {
    enum-args = (numbering: self.numbering) + enum-args
  }
  pad(padding, enum(
    ..enum-args,
    ..sections.filter(section => section.loc != none)
      .map(section => [#link(section.loc, section.title)<touying-link>] + if section.children.filter(it => it.kind != "slide").len() > 0 {
        let subsections = section.children.filter(it => it.kind != "slide")
        enum(
          ..enum-args,
          ..subsections.map(subsection => [#link(subsection.loc, subsection.title)<touying-link>])
        )
      })
  ))
})

#let current-section-title = locate(loc => {
  let sections = sections-state.at(loc)
  sections.last().title
})

#let _typst-numbering = numbering
#let current-section-number(numbering: "01", ignore-zero: true) = locate(loc => {
  let sections = sections-state.at(loc)
  if not ignore-zero or sections.len() - 1 != 0 {
    _typst-numbering(numbering, sections.len() - 1)
  }
})

#let current-section-with-numbering(self, ignore-zero: true) = locate(loc => {
  let sections = sections-state.at(loc)
  if self.numbering != none and (not ignore-zero or sections.len() - 1 != 0) {
    _typst-numbering(self.numbering, sections.len() - 1)
    [ ]
  }
  sections.last().title
})

#let current-subsection-number(numbering: "1.1", ignore-zero: true) = locate(loc => {
  let sections = sections-state.at(loc)
  let subsections = sections.last().children
  if (not ignore-zero or sections.len() - 1 != 0) and (not ignore-zero or subsections.len() - 1 != 0) {
    _typst-numbering(numbering, sections.len() - 1, subsections.len() - 1)
  }
})

#let current-subsection-with-numbering(self, ignore-zero: true) = locate(loc => {
  let sections = sections-state.at(loc)
  let subsections = sections.last().children
  if self.numbering != none and (not ignore-zero or sections.len() - 1 != 0) and (not ignore-zero or subsections.len() - 1 != 0) {
    _typst-numbering(self.numbering, sections.len() - 1, subsections.len() - 1)
    [ ]
  }
  subsections.last().title
})

#let touying-progress-with-sections(callback) = locate(loc => {
  callback((
    current-sections: sections-state.at(loc),
    final-sections: sections-state.final(loc),
    current-slide-number: slide-counter.at(loc).first(),
    last-slide-number: last-slide-counter.final(loc).first(),
  ))
})