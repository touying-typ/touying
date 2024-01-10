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
    sections.push((body: section, count: 0, loc: loc))
    sections
  })
})

#let section-step() = sections-state.update(sections => {
  let last = sections.pop()
  last.count += 1
  sections.push(last)
  sections
})

#let touying-sections(callback) = locate(loc => {
  callback(sections-state.final(loc))
})

#let touying-outline(enum-args: (:), padding: 0pt) = touying-sections(sections => {
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