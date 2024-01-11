#import "utils/utils.typ"
#import "utils/states.typ"
#import "utils/pdfpc.typ"

// touying pause mark
#let pause = [#"<touying-pause>"]

// parse a sequence into content, and get the repetitions
#let _parse-content-with-pause(self: utils.empty-object, need-cover: true, base: 1, index: 1, it) = {
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  // if it is a function, then call it with self
  if type(it) == function {
    // subslide index
    self.subslide = index
    it = it(self)
  }
  // repetitions
  let repetitions = base
  // parse the content
  let result = ()
  let cover-arr = ()
  let children = if utils.is-sequence(it) { it.children } else { (it,) }
  for child in children {
    if child == pause {
      repetitions += 1
    } else if child == linebreak() or child == parbreak() {
      // clear the cover-arr when linebreak or parbreak
      if cover-arr.len() != 0 {
        result.push(cover(cover-arr.sum()))
        cover-arr = ()
      }
      result.push(child)
    } else if type(child) == content and child.func() == list.item {
      // handle the list item
      let (cont, nextrepetitions) = _parse-content-with-pause(
        self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
      )
      if repetitions <= index or not need-cover {
        result.push(list.item(cont))
      } else {
        cover-arr.push(list.item(cont))
      }
      repetitions = nextrepetitions
    } else if type(child) == content and child.func() == enum.item {
      // handle the enum item
      let (cont, nextrepetitions) = _parse-content-with-pause(
        self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
      )
      if repetitions <= index or not need-cover {
        result.push(enum.item(child.at("number", default: none), cont))
      } else {
        cover-arr.push(enum.item(child.at("number", default: none), cont))
      }
      repetitions = nextrepetitions
    } else if type(child) == content and child.func() == terms.item {
      // handle the terms item
      let (cont, nextrepetitions) = _parse-content-with-pause(
        self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.description
      )
      if repetitions <= index or not need-cover {
        result.push(terms.item(child.term, cont))
      } else {
        cover-arr.push(terms.item(child.term, cont))
      }
      repetitions = nextrepetitions
    } else {
      if repetitions <= index or not need-cover {
        result.push(child)
      } else {
        cover-arr.push(child)
      }
    }
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
  let page-preamble(curr-subslide) = locate(loc => {
    if loc.page() == self.first-slide-number {
      // preamble
      utils.call-or-display(self, self.preamble)
      // pdfpc slide markers
      if self.pdfpc-file {
        pdfpc.pdfpc-file(loc)
      }
    }
    [
      #metadata((t: "NewSlide")) <pdfpc>
      #metadata((t: "Idx", v: loc.page() - 1)) <pdfpc>
      #metadata((t: "Overlay", v: curr-subslide - 1)) <pdfpc>
      #metadata((t: "LogicalSlide", v: states.slide-counter.at(loc).first())) <pdfpc>
    ]
  })
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
      header = update-counters + header
      page(..(self.page-args + (header: header, footer: footer)), setting(
        page-preamble(1) + body
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
    header = update-counters + header
    page(..(self.page-args + (header: header, footer: footer)), setting(
      page-preamble(1) + cont
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
        new-header = update-counters + new-header
      }
      result.push(page(
        ..(self.page-args + (header: new-header, footer: footer)),
        setting(page-preamble(i)  + cont),
      ))
    }
    // return the result
    result.sum()
  }
}

// build the touying singleton
#let s = (
  // handle mode
  handout: false,
  // appendix mode
  appendix: false,
  // enable pdfpc-file
  pdfpc-file: true,
  // first-slide page number, default is 1
  first-slide-number: 1,
  // global preamble
  preamble: [],
  // page args
  page-args: (
    paper: "presentation-16-9",
    header: none,
    footer: align(right, states.slide-counter.display() + " / " + states.last-slide-number),
    fill: rgb("#ffffff"),
  ),
  // register the methods
  methods: (
    // cover method
    cove: utils.wrap-method(hide),
    update-cover: (self: utils.empty-object, is-method: false, cover-fn) => {
      if is-method {
        self.methods.cover = cover-fn
      } else {
        self.methods.cover = utils.wrap-method(cover-fn)
      }
      self
    },
    enable-transparent-cover: (
      self: utils.empty-object, constructor: rgb, alpha: 80%) => {
      // it is based on the default cover method
      self.methods.cover = (self: utils.empty-object, body) => {
        utils.cover-with-rect(fill: utils.update-alpha(
          constructor: constructor, self.page-args.fill, alpha), body)
      }
      self
    },
    // dynamic control
    uncover: utils.uncover,
    only: utils.only,
    alternatives-match: utils.alternatives-match,
    alternatives: utils.alternatives,
    alternatives-fn: utils.alternatives-fn,
    alternatives-cases: utils.alternatives-cases,
    // handout mode
    enable-handout-mode: (self: utils.empty-object) => {
      self.handout = true
      self
    },
    // disable pdfpc-file mode
    disable-pdfpc-file: (self: utils.empty-object) => {
      self.pdfpc-file = false
      self
    },
    // default slide
    touying-slide: touying-slide,
    slide: touying-slide,
    // append the preamble
    append-preamble: (self: utils.empty-object, preamble) => {
      self.preamble += preamble
      self
    },
    // default init
    init: (self: utils.empty-object, body) => {
      // default text size
      set text(size: 20pt)
      body
    },
    // default outline
    touying-outline: (self: utils.empty-object, ..args) => {
      states.touying-outline(..args)
    },
    appendix: (self: utils.empty-object) => {
      self.appendix = true
      self
    }
  ),
)