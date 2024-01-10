#import "utils/utils.typ"
#import "utils/states.typ"

// touying pause mark
#let pause = [#"<touying-pause>"]

// parse a sequence into content, and get the repetitions
#let _parse-content-with-pause(self: utils.empty-object, base: 1, index: 1, it) = {
  // get cover function from self
  let cover = self.cover
  // if it is a function, then call it with self, uncover and only
  if type(it) == function {
    // subslide index
    self.subslide = index - base + 1
    // register the methods
    self.methods.uncover = (self: utils.empty-object, i, uncover-cont) => if i == index { uncover-cont } else { cover(uncover-cont) }
    self.methods.only = (self: utils.empty-object, i, only-cont) => if i == index { only-cont }
    it = it(self)
  }
  // repetitions
  let repetitions = base
  // parse the content
  let uncover-arr = ()
  let cover-arr = ()
  if utils.is-sequence(it) {
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
#let touying-slide(self: utils.empty-object, repeat: auto, setting: body => body, body) = {
  // update counters
  let update-counters = {
    states.slide-counter.step()
    if self.appendix == false {
      states.last-slide-counter.step()
      states.section-step()
    }
  }
  // page header and footer
  let header = utils.call-or-display(self, self.page-args.at("header", default: none))
  let footer = utils.call-or-display(self, self.page-args.at("footer", default: none))
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
  let self = utils.empty-object + (
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
      footer: align(right, states.slide-counter.display() + " / " + states.last-slide-number),
    )
  )
  // register the methods
  self.methods.touying-slide = touying-slide
  self.methods.slide = touying-slide
  self.methods.init = (self: utils.empty-object, body) => {
    set text(size: 20pt)
    body
  }
  self.methods.touying-outline = (self: utils.empty-object, ..args) => {
    touying-outline(..args)
  }
  self.methods.appendix = (self: utils.empty-object) => {
    self.appendix = true
    self
  }
  self
}