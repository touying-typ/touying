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
// touying mitex mark
#let touying-mitex(block: true, numbering: none, supplement: auto, mitex, body) = {
  metadata((
    kind: "touying-mitex",
    block: block,
    numbering: numbering,
    supplement: supplement,
    mitex: mitex,
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

// parse touying mitex, and get the repetitions
#let _parse-touying-mitex(self: none, need-cover: true, base: 1, index: 1, eqt) = {
  let result-arr = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get eqt body
  let it = eqt.body
  // if it is a function, then call it with self
  if type(it) == function {
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))
  // parse the content
  let result = ()
  let cover-arr = ()
  let children = it.split(regex("\\\\meanwhile")).intersperse("touying-meanwhile")
    .map(s => s.split(regex("\\\\pause")).intersperse("touying-pause")).flatten()
    .map(s => s.split(regex("(\\\\\\\\\s)|(\\\\\\\\\n)")).intersperse("\\\\\n")).flatten()
    .map(s => s.split(regex("&")).intersperse("&")).flatten()
  for child in children {
    if child == "touying-pause" {
      repetitions += 1
    } else if child == "touying-meanwhile" {
      // clear the cover-arr when encounter #meanwhile
      if cover-arr.len() != 0 {
        result.push("\\phantom{" + cover-arr.sum() + "}")
        cover-arr = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the cover-arr when encounter linebreak or parbreak
      if cover-arr.len() != 0 {
        result.push("\\phantom{" + cover-arr.sum() + "}")
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
    result.push("\\phantom{" + cover-arr.sum() + "}")
    cover-arr = ()
  }
  result-arr.push(
    (eqt.mitex)(
      block: eqt.block,
      numbering: eqt.numbering,
      supplement: eqt.supplement,
      result.sum(default: ""),
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
      if type(child) == content and child.func() == metadata and type(child.value) == dictionary {
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
      it = it(self)
    }
    // parse the content
    let result = ()
    let cover-arr = ()
    let children = if utils.is-sequence(it) { it.children } else { (it,) }
    for child in children {
      if type(child) == content and child.func() == metadata and type(child.value) == dictionary {
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
        } else if kind == "touying-mitex" {
          // handle touying-mitex
          let (conts, nextrepetitions) = _parse-touying-mitex(
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
        // handle the sequence
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
      } else if utils.is-styled(child) {
        // handle styled
        let (conts, nextrepetitions) = _parse-content(
          self: self, need-cover: repetitions <= index, base: repetitions, index: index, child.child
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(utils.typst-builtin-styled(cont, child.styles))
        } else {
          cover-arr.push(utils.typst-builtin-styled(cont, child.styles))
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
        // handle the pad
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

#let _get-negative-pad(self) = {
  let margin = self.page-args.margin
  if type(margin) != dictionary and type(margin) != length and type(margin) != relative {
    return it => it
  }
  let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)
  if type(margin) == length or type(margin) == relative {
    return it => pad(x: -margin, cell(it))
  }
  let pad-args = (:)
  if "x" in margin {
    pad-args.x = -margin.x
  }
  if "left" in margin {
    pad-args.left = -margin.left
  }
  if "right" in margin {
    pad-args.right = -margin.right
  }
  if "rest" in margin {
    pad-args.rest = -margin.rest
  }
  it => pad(..pad-args, cell(it))
}

#let _get-page-extra-args(self) = {
  if self.show-notes-on-second-screen == right {
    let margin = self.page-args.margin
    assert(
      self.page-args.paper == "presentation-16-9" or self.page-args.paper == "presentation-4-3",
      message: "The paper of page should be presentation-16-9 or presentation-4-3"
    )
    let page-width = if self.page-args.paper == "presentation-16-9" { 841.89pt } else { 793.7pt }
    if type(margin) != dictionary and type(margin) != length and type(margin) != relative {
      return (:)
    }
    if type(margin) == length or type(margin) == relative {
      margin = (x: margin, y: margin)
    }
    if "right" not in margin {
      assert("x" in margin, message: "The margin should have right or x")
      margin.right = margin.x
    }
    margin.right += page-width
    return (margin: margin, width: 2 * page-width)
  } else {
    return (:)
  }
}

#let _get-header-footer(self) = {
  let header = utils.call-or-display(self, self.page-args.at("header", default: none))
  let footer = utils.call-or-display(self, self.page-args.at("footer", default: none))
  // speaker note
  if self.show-notes-on-second-screen == right {
    assert(
      self.page-args.paper == "presentation-16-9" or self.page-args.paper == "presentation-4-3",
      message: "The paper of page should be presentation-16-9 or presentation-4-3"
    )
    let page-width = if self.page-args.paper == "presentation-16-9" { 841.89pt } else { 793.7pt }
    let page-height = if self.page-args.paper == "presentation-16-9" { 473.56pt } else { 595.28pt }
    footer += place(
      left + bottom,
      dx: page-width,
      block(
        fill: rgb("#E6E6E6"),
        width: page-width,
        height: page-height,
        {
          set align(left + top)
          set text(size: 24pt, fill: black, weight: "regular")
          block(
            width: 100%, height: 88pt, inset: (left: 32pt, top: 16pt), outset: 0pt, fill: rgb("#CCCCCC"), 
            {
              states.current-section-title
              linebreak()
              [ --- ]
              states.current-slide-title
            },
          )
          pad(x: 48pt, states.current-slide-note)
          // clear the slide note
          states.slide-note-state.update(none)
        }
      )
    )
  }
  // negative padding
  if self.full-header or self.full-footer {
    let negative-pad = _get-negative-pad(self)
    if self.full-header {
      header = negative-pad(header)
    }
    if self.full-footer {
      footer = negative-pad(footer)
    }
  }
  (header, footer)
}

// touying-slide
#let touying-slide(
  self: none,
  repeat: auto,
  setting: body => body,
  composer: auto,
  section: none,
  subsection: none,
  title: none,
  ..bodies,
) = {
  assert(bodies.named().len() == 0, message: "unexpected named arguments:" + repr(bodies.named().keys()))
  let composer-with-side-by-side(..args) = {
    if type(composer) == function {
      composer(..args)
    } else {
      utils.side-by-side(columns: composer, ..args)
    }
  }
  let bodies = bodies.pos()
  let page-preamble(curr-subslide) = locate(loc => {
    [
      #metadata((t: "NewSlide")) <pdfpc>
      #metadata((t: "Idx", v: loc.page() - 1)) <pdfpc>
      #metadata((t: "Overlay", v: curr-subslide - 1)) <pdfpc>
      #metadata((t: "LogicalSlide", v: states.slide-counter.at(loc).first())) <pdfpc>
    ]
    if self.reset-footnote {
      counter(footnote).update(0)
    }
    if loc.page() == self.first-slide-number {
      // preamble
      utils.call-or-display(self, self.preamble)
      // pdfpc slide markers
      if self.pdfpc-file {
        pdfpc.pdfpc-file(loc)
      }
    }
    utils.call-or-display(self, self.page-preamble)
    if curr-subslide == 1 and title != none {
      utils.bookmark(level: 3, title)
    }
  })
  // update states
  let _update-states(repetitions) = {
    // 1. slide counter part
    //    if freeze-slide-counter is false, then update the slide-counter
    if not self.freeze-slide-counter {
      states.slide-counter.step()
      //  if appendix is false, then update the last-slide-counter
      if not self.appendix {
        states.last-slide-counter.step()
      }
    }
    // update page counter
    context counter(page).update(states.slide-counter.get())
    // 2. section and subsection part
    if not self.appendix or self.appendix-in-outline {
      // if section is not none, then create a new section
      let section = utils.unify-section(section)
      if section != none {
        states._new-section(duplicate: self.duplicate, short-title: section.short-title, section.title)
        utils.bookmark(level: 1, numbering: self.numbering, section.title)
      }
      // if subsection is not none, then create a new subsection
      let subsection = utils.unify-section(subsection)
      if subsection != none {
        states._new-subsection(duplicate: self.duplicate, short-title: subsection.short-title, subsection.title)
        utils.bookmark(level: 2, numbering: self.numbering, subsection.title)
      }
      states._sections-step(repetitions)
    }
    // 3. slide title part
    states.slide-title-state.update(title)
  }
  self.subslide = 1
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
  self.repeat = repeat
  // page header and footer
  let (header, footer) = _get-header-footer(self)
  let page-extra-args = _get-page-extra-args(self)
  // for speed up, do not parse the content if repeat is none
  if repeat == none {
    return {
      let conts = bodies.map(it => {
        if type(it) == function {
          it(self)
        } else {
          it
        }
      })
      header = _update-states(1) + header
      set page(..(self.page-args + page-extra-args + (header: header, footer: footer)))
      setting(
        page-preamble(1) + composer-with-side-by-side(..conts)
      )
    }
  }
  
  if self.handout {
    self.subslide = repeat
    let (conts, _) = _parse-content(self: self, index: repeat, ..bodies)
    header = _update-states(1) + header
    set page(..(self.page-args + page-extra-args + (header: header, footer: footer)))
    setting(
      page-preamble(1) + composer-with-side-by-side(..conts)
    )
  } else {
    // render all the subslides
    let result = ()
    let current = 1
    for i in range(1, repeat + 1) {
      self.subslide = i
      let (header, footer) = _get-header-footer(self)
      let new-header = header
      let (conts, _) = _parse-content(self: self, index: i, ..bodies)
      // update the counter in the first subslide
      if i == 1 {
        new-header = _update-states(repeat) + new-header
      }
      result.push({
        set page(..(self.page-args + page-extra-args + (header: new-header, footer: footer)))
        setting(page-preamble(i) + composer-with-side-by-side(..conts))
      })
    }
    // return the result
    result.sum()
  }
}

// touying-slides
#let touying-slides(self: none, slide-level: 1, body) = {
  // make sure 0 <= slide-level <= 2
  assert(type(slide-level) == int and 0 <= slide-level and slide-level <= 2, message: "slide-level should be 0, 1 or 2")
  // init
  let (section, subsection, title, slide) = (none, none, none, ())
  let last-title = none
  let children = if utils.is-sequence(body) { body.children } else { (body,) }
  // convert all sequence to array recursively, and then flatten the array
  let sequence-to-array(it) = {
    if utils.is-sequence(it) {
      it.children.map(sequence-to-array)
    } else {
      it
    }
  }
  children = children.map(sequence-to-array).flatten()
  // trim space of children
  children = utils.trim(children)
  if children.len() == 0 { return none }
  // begin
  let i = 0
  let is-end = false
  for child in children {
    i += 1
    if type(child) == content and child.func() == metadata and type(child.value) == dictionary and child.value.at("kind", default: none) == "touying-slides-end" {
      is-end = true
      break
    } else if type(child) == content and child.func() == metadata and type(child.value) == dictionary and child.value.at("kind", default: none) == "touying-slide-wrapper" {
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
    } else if type(child) == content and child.func() == heading and child.depth <= slide-level + 1 {
      slide = utils.trim(slide)
      if (child.depth == 1 and section != none) or (child.depth == 2 and subsection != none) or (child.depth > slide-level and title != none) or slide != () {
        (self.methods.slide)(self: self, section: section, subsection: subsection, ..(if last-title != none { (title: last-title) }), slide.sum(default: []))
        (section, subsection, title, slide) = (none, none, none, ())
        if child.depth <= slide-level {
          last-title = none
        }
      }
      let child-body = if child.body != [] { child.body } else { none }
      if child.depth == 1 {
        if slide-level >= 1 {
          if type(self.methods.at("touying-new-section-slide", default: none)) == function {
            (self.methods.touying-new-section-slide)(self: self, child-body)
          } else {
            section = child-body
          }
          last-title = none
        } else {
          title = child.body
          last-title = child-body
        }
      } else if child.depth == 2 {
        if slide-level >= 2 {
          if type(self.methods.at("touying-new-subsection-slide", default: none)) == function {
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
    logo: none,
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
  // freeze slide counter
  freeze-slide-counter: false,
  freeze-in-empty-page: true,
  // enable pdfpc-file
  pdfpc-file: true,
  // first-slide page number, which will affect preamble,
  // default is 1
  first-slide-number: 1,
  // global preamble
  preamble: none,
  // page preamble
  page-preamble: none,
  // reset footnote
  reset-footnote: true,
  // page args
  page-args: (
    paper: "presentation-16-9",
    header: none,
    footer: none,
    fill: rgb("#ffffff"),
    margin: (x: 3em, y: 2.8em),
  ),
  // full header / footer
  full-header: true,
  full-footer: true,
  // speaker notes
  show-notes-on-second-screen: none,
  // numbering
  numbering: none,
  // duplicate for section and subsection
  duplicate: false,
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
    empty-slide: (self: none, ..args) => {
      self = utils.empty-page(self)
      (self.methods.slide)(self: self, ..args)
    },
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
    // numbering
    numbering: (self: none, section: auto, subsection: auto, numbering) => {
      if section == auto and subsection == auto {
        self.numbering = numbering
        return self
      }
      let section-numbering = if section == auto { numbering } else { section }
      let subsection-numbering = if subsection == auto { numbering } else { subsection }
      self.numbering = (..args) => if args.pos().len() == 1 {
        states._typst-numbering(section-numbering, ..args)
      } else {
        states._typst-numbering(subsection-numbering, ..args)
      }
      self
    },
    // default init
    init: (self: none, body) => {
      // default text size
      set text(size: 20pt)
      set heading(outlined: false)
      show heading.where(level: 2): set block(below: 1em)
      body
    },
    // default outline
    touying-outline: (self: none, ..args) => {
      states.touying-outline(self: self, ..args)
    },
    appendix: (self: none) => {
      self.appendix = true
      self
    },
    appendix-in-outline: (self: none, value) => {
      self.appendix-in-outline = value
      self
    },
    show-notes-on-second-screen: (self: none, value) => {
      assert(value == none or value == right, message: "value should be none or right")
      self.show-notes-on-second-screen = value
      self
    },
    speaker-note: (self: none, pdfpc: false, setting: it => it, note) => {
      if pdfpc {
        pdfpc.speaker-note(note)
      }
      if self.show-notes-on-second-screen != none {
        states.slide-note-state.update(setting(note))
      }
    }
  ),
)