#import "utils/utils.typ"
#import "utils/states.typ"
#import "utils/pdfpc.typ"

// touying pause mark
#let pause = metadata((kind: "touying-pause"))
// touying meanwhile mark
#let meanwhile = metadata((kind: "touying-meanwhile"))
// touying slides-end mark
#let slides-end = metadata((kind: "touying-slides-end"))
// touying equation mark
#let touying-equation(block: true, numbering: none, supplement: auto, scope: (:), body) = {
  metadata((
    kind: "touying-equation",
    block: block,
    numbering: numbering,
    supplement: supplement,
    scope: scope,
    body: {
      if type(body) == function {
        body
      } else if type(body) == str {
        body
      } else if type(body) == content and body.has("text") {
        body.text
      } else {
        panic("Unsupported type: " + str(type(body)))
      }
    },
  ))
}
// touying reducer mark
#let touying-reducer(reduce: arr => arr.sum(), cover: arr => none, ..args) = {
  metadata((
    kind: "touying-reducer",
    reduce: reduce,
    cover: cover,
    kwargs: args.named(),
    args: args.pos(),
  ))
}

// parse touying equation, and get the repetitions
#let _parse-touying-equation(self: utils.empty-object, need-cover: true, base: 1, index: 1, eqt) = {
  let result-arr = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  // get eqt body
  let it = eqt.body
  // if it is a function, then call it with self
  if type(it) == function {
    // subslide index
    self.subslide = index
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))
  // parse the content
  let result = ()
  let cover-arr = ()
  let children = it.split(regex("(#meanwhile;?)|(meanwhile)")).intersperse("touying-meanwhile")
    .map(s => s.split(regex("(#pause;?)|(pause)")).intersperse("touying-pause")).flatten()
    .map(s => s.split(regex("(\\\\\\s)|(\\\\\\n)")).intersperse("\\\n")).flatten()
    .map(s => s.split(regex("&")).intersperse("&")).flatten()
  for child in children {
    if child == "touying-pause" {
      repetitions += 1
    } else if child == "touying-meanwhile" {
      // clear the cover-arr when encounter #meanwhile
      if cover-arr.len() != 0 {
        result.push("cover(" + cover-arr.sum() + ")")
        cover-arr = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the cover-arr when encounter linebreak or parbreak
      if cover-arr.len() != 0 {
        result.push("cover(" + cover-arr.sum() + ")")
        cover-arr = ()
      }
      result.push(child)
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
    result.push("cover(" + cover-arr.sum() + ")")
    cover-arr = ()
  }
  result-arr.push(
    math.equation(
      block: eqt.block,
      numbering: eqt.numbering,
      supplement: eqt.supplement,
      eval("$" + result.sum(default: "") + "$", scope: eqt.scope + (cover: (..args) => {
        let cover = eqt.scope.at("cover", default: cover)
        if args.pos().len() != 0 {
          cover(args.pos().first())
        }
      })),
    )
  )
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (result-arr, max-repetitions)
}

// parse touying reducer, and get the repetitions
#let _parse-touying-reducer(self: utils.empty-object, base: 1, index: 1, reducer) = {
  let result-arr = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = reducer.cover
  // parse the content
  let result = ()
  let cover-arr = ()
  for child in reducer.args.flatten() {
      if type(child) == content and child.func() == metadata {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-pause" {
          repetitions += 1
        } else if kind == "touying-meanwhile" {
          // clear the cover-arr when encounter #meanwhile
          if cover-arr.len() != 0 {
            result.push(cover(cover-arr.sum()))
            cover-arr = ()
          }
          // then reset the repetitions
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        } else {
          if repetitions <= index {
            result.push(child)
          } else {
            cover-arr.push(child)
          }
        }
      } else {
        if repetitions <= index {
          result.push(child)
        } else {
          cover-arr.push(child)
        }
      }
  }
  // clear the cover-arr when end
  if cover-arr.len() != 0 {
    let r = cover(cover-arr)
    if type(r) == array {
      result += r
    } else {
      result.push(r)
    }
    cover-arr = ()
  }
  result-arr.push(
    (reducer.reduce)(
      ..reducer.kwargs,
      result,
    )
  )
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (result-arr, max-repetitions)
}

// parse a sequence into content, and get the repetitions
#let _parse-content(self: utils.empty-object, need-cover: true, base: 1, index: 1, ..bodies) = {
  let bodies = bodies.pos()
  let result-arr = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  for it in bodies {
    // if it is a function, then call it with self
    if type(it) == function {
      // subslide index
      self.subslide = index
      it = it(self)
    }
    // parse the content
    let result = ()
    let cover-arr = ()
    let children = if utils.is-sequence(it) { it.children } else { (it,) }
    for child in children {
      if type(child) == content and child.func() == metadata {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-pause" {
          repetitions += 1
        } else if kind == "touying-meanwhile" {
          // clear the cover-arr when encounter #meanwhile
          if cover-arr.len() != 0 {
            result.push(cover(cover-arr.sum()))
            cover-arr = ()
          }
          // then reset the repetitions
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        } else if kind == "touying-equation" {
          // handle touying-equation
          let (conts, nextrepetitions) = _parse-touying-equation(
            self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.value
          )
          let cont = conts.first()
          if repetitions <= index or not need-cover {
            result.push(cont)
          } else {
            cover-arr.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-reducer" {
          // handle touying-reducer
          let (conts, nextrepetitions) = _parse-touying-reducer(
            self: self, base: repetitions, index: index, child.value
          )
          let cont = conts.first()
          if repetitions <= index or not need-cover {
            result.push(cont)
          } else {
            cover-arr.push(cont)
          }
          repetitions = nextrepetitions
        } else {
          if repetitions <= index or not need-cover {
            result.push(child)
          } else {
            cover-arr.push(child)
          }
        }
      } else if child == linebreak() or child == parbreak() {
        // clear the cover-arr when encounter linebreak or parbreak
        if cover-arr.len() != 0 {
          result.push(cover(cover-arr.sum()))
          cover-arr = ()
        }
        result.push(child)
      } else if type(child) == content and child.func() == list.item {
        // handle the list item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(list.item(cont))
        } else {
          cover-arr.push(list.item(cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() == enum.item {
        // handle the enum item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(enum.item(child.at("number", default: none), cont))
        } else {
          cover-arr.push(enum.item(child.at("number", default: none), cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() == terms.item {
        // handle the terms item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.description
        )
        let cont = conts.first()
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
    result-arr.push(result.sum(default: []))
  }
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (result-arr, max-repetitions)
}

// touying-slide
#let touying-slide(
  self: utils.empty-object,
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  ..bodies,
) = {
  assert(bodies.named().len() == 0, message: "unexpected named arguments:" + repr(bodies.named().keys()))
  let bodies = bodies.pos()
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
  // update states
  let _update-states(repetitions) = {
    states.slide-counter.step()
    if not self.appendix or self.appendix-in-outline {
      // if section is not none, then create a new section
      let section = utils.unify-section(section)
      if section != none {
        states._new-section(short-title: section.short-title, section.title)
      }
      // if subsection is not none, then create a new subsection
      let subsection = utils.unify-section(subsection)
      if subsection != none {
        states._new-subsection(short-title: subsection.short-title, subsection.title)
      }
    }
    // if appendix is false, then update the last-slide-counter and sections step
    if not self.appendix {
      states.last-slide-counter.step()
      states._sections-step(repetitions)
    }
  }
  // page header and footer
  let header = utils.call-or-display(self, self.page-args.at("header", default: none))
  let footer = utils.call-or-display(self, self.page-args.at("footer", default: none))
  // for speed up, do not parse the content if repeat is none
  if repeat == none {
    return {
      header = _update-states(1) + header
      page(..(self.page-args + (header: header, footer: footer)), setting(
        page-preamble(1) + composer(..bodies)
      ))
    }
  }
  // for single page slide, get the repetitions
  if repeat == auto {
    let (_, repetitions) = _parse-content(
      self: self,
      base: 1,
      index: 1,
      ..bodies,
    )
    repeat = repetitions
  }
  if self.handout {
    let (conts, _) = _parse-content(self: self, index: repeat, ..bodies)
    header = _update-states(1) + header
    page(..(self.page-args + (header: header, footer: footer)), setting(
      page-preamble(1) + composer(..conts)
    ))
  } else {
    // render all the subslides
    let result = ()
    let current = 1
    for i in range(1, repeat + 1) {
      let new-header = header
      let (conts, _) = _parse-content(self: self, index: i, ..bodies)
      // update the counter in the first subslide
      if i == 1 {
        new-header = _update-states(repeat) + new-header
      }
      result.push(page(
        ..(self.page-args + (header: new-header, footer: footer)),
        setting(page-preamble(i) + composer(..conts)),
      ))
    }
    // return the result
    result.sum()
  }
}

// touying-slides
#let touying-slides(
  self: utils.empty-object,
  repeat: auto,
  setting: body => body,
  cutting-out: false,
  ..args,
  body,
) = {
  assert(repeat == none or repeat == auto, message: "unexpected repeat argument: " + repr(repeat))
  let section = none
  let subsection = none
  let slide = ()
  let children = if utils.is-sequence(body) { body.children } else { (body,) }
  // trim space of children
  while children.first() == [ ] or children.first() == parbreak() or children.first() == linebreak() {
    children = children.slice(1)
  }
  let i = 0
  let is-end = false
  for child in children {
    i += 1
    if type(child) == content and child.func() == metadata and child.value.at("kind", default: none) == "touying-slides-end" {
      is-end = true
      break
    } else if type(child) == content and child.func() == heading and (child.level == 1 or child.level == 2) {
      if not cutting-out or not slide.all(it => it == [ ] or it == parbreak() or it == linebreak()) {
        if slide != () {
          (self.methods.slide-in-slides)(
            self: self,
            repeat: repeat,
            setting: setting,
            section: section,
            subsection: subsection,
            ..args,
            slide.sum(),
          )
        }
        section = none
        subsection = none
        slide = ()
      }
      if child.level == 1 {
        section = if child.body != [] { child.body } else { none }
      } else {
        subsection = if child.body != [] { child.body } else { none }
      }
    } else {
      slide.push(child)
    }
  }
  if section != none or subsection != none or slide != () {
    (self.methods.slide-in-slides)(
      self: self,
      repeat: repeat,
      setting: setting,
      section: section,
      subsection: subsection,
      ..args,
      slide.sum(default: []),
    )
  }
  if is-end {
    children.slice(i).sum(default: none)
  }
}

// build the touying singleton
#let s = (
  // info interface
  info: (
    title: none,
    short-title: auto,
    subtitle: none,
    short-subtitle: auto,
    author: none,
    date: none,
    institution: none,
  ),
  // colors interface
  colors: (
    neutral: rgb("#303030"),
    neutral-light: rgb("#a0a0a0"),
    neutral-lighter: rgb("#d0d0d0"),
    neutral-lightest: rgb("#ffffff"),
    neutral-dark: rgb("#202020"),
    neutral-darker: rgb("#101010"),
    neutral-darkest: rgb("#000000"),
    primary: rgb("#303030"),
    primary-light: rgb("#a0a0a0"),
    primary-lighter: rgb("#d0d0d0"),
    primary-lightest: rgb("#ffffff"),
    primary-dark: rgb("#202020"),
    primary-darker: rgb("#101010"),
    primary-darkest: rgb("#000000"),
    secondary: rgb("#303030"),
    secondary-light: rgb("#a0a0a0"),
    secondary-lighter: rgb("#d0d0d0"),
    secondary-lightest: rgb("#ffffff"),
    secondary-dark: rgb("#202020"),
    secondary-darker: rgb("#101010"),
    secondary-darkest: rgb("#000000"),
    tertiary: rgb("#303030"),
    tertiary-light: rgb("#a0a0a0"),
    tertiary-lighter: rgb("#d0d0d0"),
    tertiary-lightest: rgb("#ffffff"),
    tertiary-dark: rgb("#202020"),
    tertiary-darker: rgb("#101010"),
    tertiary-darkest: rgb("#000000"),
  ),
  // handle mode
  handout: false,
  // appendix mode
  appendix: false,
  appendix-in-outline: true,
  // enable pdfpc-file
  pdfpc-file: true,
  // first-slide page number, which will affect preamble,
  // default is 1
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
  // datetime format
  datetime-format: auto,
  // register the methods
  methods: (
    // info
    info: (self: utils.empty-object, ..args) => {
      self.info += args.named()
      self
    },
    // colors
    colors: (self: utils.empty-object, ..args) => {
      self.colors += args.named()
      self
    },
    // cover method
    cover: utils.wrap-method(hide),
    update-cover: (self: utils.empty-object, is-method: false, cover-fn) => {
      if is-method {
        self.methods.cover = cover-fn
      } else {
        self.methods.cover = utils.wrap-method(cover-fn)
      }
      self
    },
    enable-transparent-cover: (
      self: utils.empty-object, constructor: rgb, alpha: 85%) => {
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
    // alert interface
    alert: utils.wrap-method(text.with(weight: "bold")),
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
    touying-slides: touying-slides,
    slides: touying-slides,
    slide-in-slides: (self: utils.empty-object, section: none, subsection: none, body, ..args) => {
      if section != none {
        let no-footer-self = self
        no-footer-self.page-args.footer = none
        touying-slide(
          self: no-footer-self,
          section: section,
          subsection: subsection,
          ..args,
          align(center + horizon, heading(level: 1, section) + body)
        )
      } else if subsection != none {
        touying-slide(self: self, ..args, heading(level: 2, subsection) + parbreak() + body)
      } else {
        touying-slide(self: self, ..args, body)
      }
    },
    // append the preamble
    append-preamble: (self: utils.empty-object, preamble) => {
      self.preamble += preamble
      self
    },
    // datetime format
    datetime-format: (self: utils.empty-object, format) => {
      self.datetime-format = format
      self
    },
    // default init
    init: (self: utils.empty-object, body) => {
      // default text size
      set text(size: 20pt)
      show heading.where(level: 2): set block(below: 1em)
      body
    },
    // default outline
    touying-outline: (self: utils.empty-object, ..args) => {
      states.touying-outline(..args)
    },
    appendix: (self: utils.empty-object) => {
      self.appendix = true
      self
    },
    appendix-in-outline: (self: utils.empty-object, value) => {
      self.appendix-in-outline = value
      self
    }
  ),
)