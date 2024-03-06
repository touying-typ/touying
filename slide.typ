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
#let _parse-touying-equation(self: none, need-cover: true, base: 1, index: 1, eqt) = {
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
#let _parse-touying-reducer(self: none, base: 1, index: 1, reducer) = {
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
#let _parse-content(self: none, need-cover: true, base: 1, index: 1, ..bodies) = {
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
      } else if utils.is-sequence(child) {
        // handle the list item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(cont)
        } else {
          cover-arr.push(cont)
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() in (list.item, enum.item, align) {
        // handle the list item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(utils.reconstruct(child, cont))
        } else {
          cover-arr.push(utils.reconstruct(child, cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() in (pad,) {
        // handle the list item
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.body
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(utils.reconstruct(named: true, child, cont))
        } else {
          cover-arr.push(utils.reconstruct(named: true, child, cont))
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
  self: none,
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  title: none,
  ..bodies,
) = {
  assert(bodies.named().len() == 0, message: "unexpected named arguments:" + repr(bodies.named().keys()))
  let setting-with-pad(body) = {
    pad(..self.padding, setting(body))
  }
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
      page(..(self.page-args + (header: header, footer: footer)), setting-with-pad(
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
    page(..(self.page-args + (header: header, footer: footer)), setting-with-pad(
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
        setting-with-pad(page-preamble(i) + composer(..conts)),
      ))
    }
    // return the result
    result.sum()
  }
}

// touying-slides
#let touying-slides(self: none, slide-level: 1, body) = {
  // init
  let (section, subsection, title, slide) = (none, none, none, ())
  let last-title = none
  let children = if utils.is-sequence(body) { body.children } else { (body,) }
  // flatten children
  children = children.map(it => {
    if utils.is-sequence(it) { it.children } else { it }
  }).flatten()
  // trim space of children
  children = utils.trim(children)
  if children.len() == 0 { return none }
  // begin
  let i = 0
  let is-end = false
  for child in children {
    i += 1
    if type(child) == content and child.func() == metadata and child.value.at("kind", default: none) == "touying-slides-end" {
      is-end = true
      break
    } else if type(child) == content and child.func() == metadata and child.value.at("kind", default: none) == "touying-wrapper" {
      slide = utils.trim(slide)
      if slide != () {
        (self.methods.slide)(self: self, section: section, subsection: subsection, ..(if last-title != none { (title: last-title) }), slide.sum())
        (section, subsection, title, slide) = (none, none, none, ())
      }
      if child.value.at("name") in self.slides {
        (child.value.at("fn"))(section: section, subsection: subsection, ..(if last-title != none { (title: last-title) }), ..child.value.at("args"))
      } else {
        (child.value.at("fn"))(..child.value.at("args"))
      }
      (section, subsection, title, slide) = (none, none, none, ())
    } else if type(child) == content and child.func() == heading and utils.heading-depth(child) in (1, 2, 3) {
      slide = utils.trim(slide)
      if (utils.heading-depth(child) == 1 and section != none) or (utils.heading-depth(child) == 2 and subsection != none) or (utils.heading-depth(child) > slide-level and title != none) or slide != () {
        (self.methods.slide)(self: self, section: section, subsection: subsection, ..(if last-title != none { (title: last-title) }), slide.sum(default: []))
        (section, subsection, title, slide) = (none, none, none, ())
        if utils.heading-depth(child) <= slide-level {
          last-title = none
        }
      }
      let child-body = if child.body != [] { child.body } else { none }
      if utils.heading-depth(child) == 1 {
        if slide-level >= 1 {
          if "touying-new-section-slide" in self.methods {
            (self.methods.touying-new-section-slide)(self: self, child-body)
          } else {
            section = child-body
          }
          last-title = none
        } else {
          title = child.body
          last-title = child-body
        }
      } else if utils.heading-depth(child) == 2 {
        if slide-level >= 2 {
          if "touying-new-subsection-slide" in self.methods {
            (self.methods.touying-new-subsection-slide)(self: self, child-body)
          } else {
            subsection = child-body
          }
          last-title = none
        } else {
          title = child.body
          last-title = child-body
        }
      } else {
        title = child.body
        last-title = child-body
      }
    } else {
      slide.push(child)
    }
  }
  slide = utils.trim(slide)
  if section != none or subsection != none or title != none or slide != () {
    (self.methods.slide)(self: self, section: section, subsection: subsection, ..(if last-title != none { (title: last-title) }), slide.sum(default: []))
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
  // slides mode
  slides: ("slide",),
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
    footer: none,
    fill: rgb("#ffffff"),
  ),
  padding: (x: 0em, y: 0em),
  // datetime format
  datetime-format: auto,
  // register the methods
  methods: (
    // info
    info: (self: none, ..args) => {
      self.info += args.named()
      self
    },
    // colors
    colors: (self: none, ..args) => {
      self.colors += args.named()
      self
    },
    // cover method
    cover: utils.wrap-method(hide),
    update-cover: (self: none, is-method: false, cover-fn) => {
      if is-method {
        self.methods.cover = cover-fn
      } else {
        self.methods.cover = utils.wrap-method(cover-fn)
      }
      self
    },
    enable-transparent-cover: (
      self: none, constructor: rgb, alpha: 85%) => {
      // it is based on the default cover method
      self.methods.cover = (self: none, body) => {
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
    enable-handout-mode: (self: none) => {
      self.handout = true
      self
    },
    // disable pdfpc-file mode
    disable-pdfpc-file: (self: none) => {
      self.pdfpc-file = false
      self
    },
    // default slide
    touying-slide: touying-slide,
    slide: touying-slide,
    touying-slides: touying-slides,
    slides: touying-slides,
    // append the preamble
    append-preamble: (self: none, preamble) => {
      self.preamble += preamble
      self
    },
    // datetime format
    datetime-format: (self: none, format) => {
      self.datetime-format = format
      self
    },
    // default init
    init: (self: none, body) => {
      // default text size
      set text(size: 20pt)
      show heading.where(level: 2): set block(below: 1em)
      body
    },
    // default outline
    touying-outline: (self: none, ..args) => {
      states.touying-outline(..args)
    },
    appendix: (self: none) => {
      self.appendix = true
      self
    },
    appendix-in-outline: (self: none, value) => {
      self.appendix-in-outline = value
      self
    }
  ),
)