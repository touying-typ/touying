#import "utils/utils.typ"
#import "utils/states.typ"
#import "utils/pdfpc.typ"

// touying pause mark
#let pause = [#"<touying-pause>"]

// parse a sequence into content, and get the repetitions
#let _parse-content-with-pause(self: utils.empty-object, base: 1, index: 1, it) = {
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  // if it is a function, then call it with self, uncover and only
  if type(it) == function {
    // subslide index
    self.subslide = index - base + 1
    // register the methods
    self.methods.uncover = (self: utils.empty-object, visible-subslides, uncover-cont) => {
      if utils._check-visible(index, visible-subslides) { 
        uncover-cont
      } else {
        cover(uncover-cont)
      }
    }
    self.methods.only = (self: utils.empty-object, visible-subslides, only-cont) => {
      if utils._check-visible(index, visible-subslides) { only-cont }
    }
    it = it(self)
  }
  // repetitions
  let repetitions = base
  // parse the content
  let result = ()
  let cover-arr = ()
  if utils.is-sequence(it) {
    for child in it.children {
      if child == pause {
        repetitions += 1
      } else if child == linebreak() or child == parbreak() {
        // clear the cover-arr when linebreak or parbreak
        if cover-arr.len() != 0 {
          result.push(cover(cover-arr.sum()))
          cover-arr = ()
        }
        result.push(child)
      } else {
        if repetitions <= index {
          result.push(child)
        } else {
          cover-arr.push(child)
        }
      }
    }
  } else {
    result.push(it)
  }
  // clear the cover-arr when end
  if cover-arr.len() != 0 {
    result.push(cover(cover-arr.sum()))
    cover-arr = ()
  }
  return (result.sum(default: []), repetitions)
}

// touying-slide
#let touying-slide(self: utils.empty-object, repeat: auto, setting: body => body, body) = {
  // pdfpc slide markers
  let pdfpc-slide-markers(curr-subslide) = locate(loc => [
    #metadata((t: "NewSlide")) <pdfpc>
    #metadata((t: "Idx", v: counter(page).at(loc).first() - 1)) <pdfpc>
    #metadata((t: "Overlay", v: curr-subslide - 1)) <pdfpc>
    #metadata((t: "LogicalSlide", v: states.slide-counter.at(loc).first())) <pdfpc>
  ])
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
      page(..(self.page-args + (header: header, footer: footer)), setting(
        pdfpc-slide-markers(1) + body
      ))
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
  if self.handout {
    let (cont, _) = _parse-content-with-pause(self: self, index: repeat, body)
    header += update-counters
    page(..(self.page-args + (header: header, footer: footer)), setting(
      pdfpc-slide-markers(1) + cont
    ))
  } else {
    // render all the subslides
    let result = ()
    let current = 1
    for i in range(1, repeat + 1) {
      let new-header = header
      let (cont, _) = _parse-content-with-pause(self: self, index: i, body)
      // update the counter in the first subslide
      if i == 1 {
        new-header += update-counters
      }
      result.push(page(
        ..(self.page-args + (header: new-header, footer: footer)),
        setting(pdfpc-slide-markers(i)  + cont),
      ))
    }
    // return the result
    result.sum()
  }
}

// build the touying singleton
#let s = {
  let self = utils.empty-object + (
    // handle mode
    handout: false,
    // appendix mode
    appendix: false,
    // page args
    page-args: (
      paper: "presentation-16-9",
      header: none,
      footer: align(right, states.slide-counter.display() + " / " + states.last-slide-number),
      fill: rgb("#ffffff"),
    )
  )
  // register the methods
  // cover method
  self.methods.cover = utils.wrap-method(hide)
  self.methods.update-cover = (self: utils.empty-object, is-method: false, cover-fn) => {
    if is-method {
      self.methods.cover = cover-fn
    } else {
      self.methods.cover = utils.wrap-method(cover-fn)
    }
    self
  }
  self.methods.enable-transparent-cover = (
    self: utils.empty-object, constructor: rgb, alpha: 80%) => {
    // it is based on the default cover method
    self.methods.cover = (self: utils.empty-object, body) => {
      utils.cover-with-rect(fill: utils.update-alpha(
        constructor: constructor, self.page-args.fill, alpha), body)
    }
    self
  }
  // handout mode
  self.methods.enable-handout-mode = (self: utils.empty-object) => {
    self.handout = true
    self
  }
  // default slide
  self.methods.touying-slide = touying-slide
  self.methods.slide = touying-slide
  // default init
  self.methods.init = (self: utils.empty-object, pdfpc-file: true, body) => {
    // pdfpc file for export
    if pdfpc-file {
      pdfpc.pdfpc-file
    }
    // default text size
    set text(size: 20pt)
    body
  }
  // default outline
  self.methods.touying-outline = (self: utils.empty-object, ..args) => {
    states.touying-outline(..args)
  }
  self.methods.appendix = (self: utils.empty-object) => {
    self.appendix = true
    self
  }
  self
}