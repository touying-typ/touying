// touying slide counters
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = locate(loc => last-slide-counter.final(loc).first())

#let touying-progress(callback) = locate(loc => {
  let ratio = calc.min(1.0, slide-counter.at(loc).first() / last-slide-counter.final(loc).first())
  callback(ratio)
})

// sections
#let sections-state = state("touying-sections-state", ((title: none, short-title: none, loc: none, count: 0, slides: ()),))

#let new-section(short-title: auto, title) = locate(loc => {
  sections-state.update(sections => {
    sections.push((title: title, short-title: short-title, loc: loc, count: 0, slides: ()))
    sections
  })
})

#let section-step(repetitions) = locate(loc => {
  sections-state.update(sections => {
    let last = sections.pop()
    last.slides.push((loc: loc, count: repetitions))
    last.count += 1
    sections.push(last)
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
      .map(section => link(section.loc, section.title))
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