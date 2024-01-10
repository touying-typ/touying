// touying slide counters
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = locate(loc => last-slide-counter.final(loc).first())

#let touying-progress(callback) = locate(loc => {
  let ratio = calc.min(1.0, slide-counter.at(loc).first() / last-slide-counter.final(loc).first())
  callback(ratio)
})

// sections
#let sections-state = state("touying-sections-state", ((body: none, count: 0, loc: none),))

#let new-section(section) = locate(loc => {
  sections-state.update(sections => {
    let last = sections.pop()
    last.count -= 1
    sections.push(last)
    sections.push((body: section, count: 1, loc: loc))
    sections
  })
})

#let section-step() = sections-state.update(sections => {
  let last = sections.pop()
  last.count += 1
  sections.push(last)
  sections
})

#let touying-final-sections(callback) = locate(loc => {
  callback(sections-state.final(loc))
})

#let touying-outline(enum-args: (:), padding: 0pt) = touying-final-sections(sections => {
  pad(padding, enum(
    ..enum-args,
    ..sections.filter(section => section.loc != none)
      .map(section => link(section.loc, section.body))
  ))
})

#let current-section = locate(loc => {
  let sections = sections-state.at(loc)
  sections.last().body
})

#let touying-progress-with-sections(callback) = locate(loc => {
  callback((
    current-sections: sections-state.at(loc),
    final-sections: sections-state.final(loc),
    current-slide-number: slide-counter.at(loc).first(),
    last-slide-number: last-slide-counter.final(loc).first(),
  ))
})