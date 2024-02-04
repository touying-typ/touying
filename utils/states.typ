// touying slide counters
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = locate(loc => last-slide-counter.final(loc).first())

#let touying-progress(callback) = locate(loc => {
  let ratio = calc.min(1.0, slide-counter.at(loc).first() / last-slide-counter.final(loc).first())
  callback(ratio)
})

// sections
#let sections-state = state("touying-sections-state", ((kind: "section", title: none, short-title: none, loc: none, count: 0, children: ()),))

#let _new-section(short-title: auto, id: auto, title) = locate(loc => {
  sections-state.update(sections => {
    sections.push((kind: "section", title: title, short-title: short-title, loc: loc, count: 0, children: ()))
    sections
  })
})

#let _new-subsection(short-title: auto, id: auto, title) = locate(loc => {
  sections-state.update(sections => {
    let last-section = sections.pop()
    last-section.children.push((kind: "subsection", title: title, short-title: short-title, loc: loc, count: 0, children: ()))
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

#let touying-outline(enum-args: (:), padding: 0pt) = touying-final-sections(sections => {
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

#let touying-progress-with-sections(callback) = locate(loc => {
  callback((
    current-sections: sections-state.at(loc),
    final-sections: sections-state.final(loc),
    current-slide-number: slide-counter.at(loc).first(),
    last-slide-number: last-slide-counter.final(loc).first(),
  ))
})