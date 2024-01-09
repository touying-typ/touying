#import "utils/utils.typ": empty-object, methods, is-sequence, call-or-display

// touying pause mark
#let pause = [#"<touying-pause>"]

// touying slide counter
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = locate(loc => last-slide-counter.final(loc).first())
#let touying-progress(callback) = locate(loc => {
  let ratio = calc.min(1.0, slide-counter.at(loc).first() / last-slide-counter.final(loc).first())
  callback(ratio)
})
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
#let touying-outline(enum-args: (:), padding: 0pt) = locate(loc => {
  let sections = sections-state.final(loc)
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

// parse a sequence into content, and get the repetitions
#let _parse-content-with-pause(self: empty-object, base: 1, index: 1, it) = {
  // get cover function from self
  let cover = self.cover
  // if it is a function, then call it with self, uncover and only
  if type(it) == function {
    // subslide index
    self.subslide = index - base + 1
    // register the methods
    self.methods.uncover = (self: empty-object, i, uncover-cont) => if i == index { uncover-cont } else { cover(uncover-cont) }
    self.methods.only = (self: empty-object, i, only-cont) => if i == index { only-cont }
    it = it(self)
  }
  // repetitions
  let repetitions = base
  // parse the content
  let uncover-arr = ()
  let cover-arr = ()
  if is-sequence(it) {
    for child in it.children {
      if child == pause {
        repetitions += 1
      } else {
        if repetitions <= index {
          uncover-arr.push(child)
        } else {
          cover-arr.push(child)
        }
      }
    }
  } else {
    uncover-arr.push(it)
  }
  return (uncover-arr.sum(default: []) + if cover-arr.len() > 0 { cover(cover-arr.sum()) }, repetitions)
}

// touying-slide
#let touying-slide(self: empty-object, repeat: auto, setting: body => body, body) = {
  // update counters
  let update-counters = {
    slide-counter.step()
    if self.appendix == false {
      last-slide-counter.step()
      section-step()
    }
  }
  // page header and footer
  let header = call-or-display(self, self.page-args.at("header", default: none))
  let footer = call-or-display(self, self.page-args.at("footer", default: none))
  // for speed up, do not parse the content if repeat is none
  if repeat == none {
    return {
      header += update-counters
      page(..(self.page-args + (header: header, footer: footer)), setting(body))
    }
  }
  // for single page slide, get the repetitions
  if repeat == auto {
    let (_, repetitions) = _parse-content-with-pause(
      self: self,
      base: 1,
      index: 1,
      body,
    )
    repeat = repetitions
  }
  // render all the subslides
  let result = ()
  let current = 1
  for i in range(1, repeat + 1) {
    let (cont, _) = _parse-content-with-pause(self: self, index: i, body)
    // update the counter in the first subslide
    if i == 1 {
      header += update-counters
    }
    result.push(page(..(self.page-args + (header: header, footer: footer)), setting(cont)))
  }
  // return the result
  result.sum()
}

// build the touying singleton
#let s = {
  let self = empty-object + (
    // cover function, default is hide
    cover: hide,
    // handle mode
    handout: false,
    // appendix mode
    appendix: false,
    // page args
    page-args: (
      paper: "presentation-16-9",
      header: none,
      footer: align(right, slide-counter.display() + " / " + last-slide-number),
    )
  )
  // register the methods
  self.methods.touying-slide = touying-slide
  self.methods.slide = touying-slide
  self.methods.init = (self: empty-object, body) => {
    set text(size: 20pt)
    body
  }
  self.methods.touying-outline = (self: empty-object, ..args) => {
    touying-outline(..args)
  }
  self.methods.appendix = (self: empty-object) => {
    self.appendix = true
    self
  }
  self
}