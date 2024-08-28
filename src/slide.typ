#import "utils.typ"
#import "states.typ"
#import "pdfpc.typ"

/// ------------------------------------------------
/// Slide
/// ------------------------------------------------

// touying function wrapper mark
#let touying-fn-wrapper(fn, with-visible-subslides: false, ..args) = label-it(
  metadata((
    kind: "touying-fn-wrapper",
    fn: fn,
    args: args,
    with-visible-subslides: with-visible-subslides,
  )),
  "touying-temporary-mark",
)

/// Wrapper for a slide function
///
/// - `fn` (self => { .. }): The function that will be called to render the slide
#let touying-slide-wrapper(fn) = utils.label-it(
  metadata((
    kind: "touying-slide-wrapper",
    fn: fn,
  )),
  "touying-temporary-mark",
)

// touying pause mark
#let pause = [#metadata((kind: "touying-pause"))<touying-temporary-mark>]
// touying meanwhile mark
#let meanwhile = [#metadata((kind: "touying-meanwhile"))<touying-temporary-mark>]
// dynamic control mark
#let uncover = touying-fn-wrapper.with(utils.uncover, with-visible-subslides: true)
#let only = touying-fn-wrapper.with(utils.only, with-visible-subslides: true)
#let alternatives-match = touying-fn-wrapper.with(utils.alternatives-match)
#let alternatives = touying-fn-wrapper.with(utils.alternatives)
#let alternatives-fn = touying-fn-wrapper.with(utils.alternatives-fn)
#let alternatives-cases = touying-fn-wrapper.with(utils.alternatives-cases)
// touying equation mark
#let touying-equation(block: true, numbering: none, supplement: auto, scope: (:), body) = utils.label(
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
  )),
  "touying-temporary-mark",
)

// touying mitex mark
#let touying-mitex(block: true, numbering: none, supplement: auto, mitex, body) = utils.label(
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
  )),
  "touying-temporary-mark",
)

// touying reducer mark
#let touying-reducer(reduce: arr => arr.sum(), cover: arr => none, ..args) = utils.label-it(
  metadata((
    kind: "touying-reducer",
    reduce: reduce,
    cover: cover,
    kwargs: args.named(),
    args: args.pos(),
  )),
  "touying-temporary-mark",
)

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
  let children = it
    .split(regex("(#meanwhile;?)|(meanwhile)"))
    .intersperse("touying-meanwhile")
    .map(s => s.split(regex("(#pause;?)|(pause)")).intersperse("touying-pause"))
    .flatten()
    .map(s => s.split(regex("(\\\\\\s)|(\\\\\\n)")).intersperse("\\\n"))
    .flatten()
    .map(s => s.split(regex("&")).intersperse("&"))
    .flatten()
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
      eval(
        "$" + result.sum(default: "") + "$",
        scope: eqt.scope + (
          cover: (..args) => {
            let cover = eqt.scope.at("cover", default: cover)
            if args.pos().len() != 0 {
              cover(args.pos().first())
            }
          },
        ),
      ),
    ),
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
  let children = it
    .split(regex("\\\\meanwhile"))
    .intersperse("touying-meanwhile")
    .map(s => s.split(regex("\\\\pause")).intersperse("touying-pause"))
    .flatten()
    .map(s => s.split(regex("(\\\\\\\\\s)|(\\\\\\\\\n)")).intersperse("\\\\\n"))
    .flatten()
    .map(s => s.split(regex("&")).intersperse("&"))
    .flatten()
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
    ),
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
    ),
  )
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (result-arr, max-repetitions)
}

// parse content into results and repetitions
#let _parse-content-into-results-and-repetitions(self: none, need-cover: true, base: 1, index: 1, ..bodies) = {
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
    let children = if utils.is-sequence(it) {
      it.children
    } else {
      (it,)
    }
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
            self: self,
            need-cover: repetitions <= index,
            base: repetitions,
            index: index,
            child.value,
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
            self: self,
            need-cover: repetitions <= index,
            base: repetitions,
            index: index,
            child.value,
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
            self: self,
            base: repetitions,
            index: index,
            child.value,
          )
          let cont = conts.first()
          if repetitions <= index or not need-cover {
            result.push(cont)
          } else {
            cover-arr.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-fn-wrapper" {
          // handle touying-fn-wrapper
          self.subslide = index
          if repetitions <= index or not need-cover {
            result.push((child.value.fn)(self: self, ..child.value.args))
          } else {
            cover-arr.push((child.value.fn)(self: self, ..child.value.args))
          }
          if child.value.with-visible-subslides {
            let visible-subslides = child.value.args.pos().at(0)
            max-repetitions = calc.max(max-repetitions, utils.last-required-subslide(visible-subslides))
          }
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
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child,
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
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.child,
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
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
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
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
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
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.description,
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

// get negative pad for header and footer
#let _get-negative-pad(self) = {
  let margin = self.page.margin
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

// get page extra args for show-notes-on-second-screen
#let _get-page-extra-args(self) = {
  if self.show-notes-on-second-screen == right {
    let margin = self.page.margin
    assert(
      self.page.paper == "presentation-16-9" or self.page.paper == "presentation-4-3",
      message: "The paper of page should be presentation-16-9 or presentation-4-3",
    )
    let page-width = if self.page.paper == "presentation-16-9" {
      841.89pt
    } else {
      793.7pt
    }
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
  let header = utils.call-or-display(self, self.page.at("header", default: none))
  let footer = utils.call-or-display(self, self.page.at("footer", default: none))
  // speaker note
  if self.show-notes-on-second-screen == right {
    assert(
      self.page.paper == "presentation-16-9" or self.page.paper == "presentation-4-3",
      message: "The paper of page should be presentation-16-9 or presentation-4-3",
    )
    let page-width = if self.page.paper == "presentation-16-9" {
      841.89pt
    } else {
      793.7pt
    }
    let page-height = if self.page.paper == "presentation-16-9" {
      473.56pt
    } else {
      595.28pt
    }
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
            width: 100%,
            height: 88pt,
            inset: (left: 32pt, top: 16pt),
            outset: 0pt,
            fill: rgb("#CCCCCC"),
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
        },
      ),
    )
  }
  // negative padding
  if self.at("zero-margin-header", default: true) or self.at("zero-margin-footer", default: true) {
    let negative-pad = _get-negative-pad(self)
    if self.at("zero-margin-header", default: true) {
      header = negative-pad(header)
    }
    if self.at("zero-margin-footer", default: true) {
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
  // update pdfpc
  let update-pdfpc(curr-subslide) = (
    context [
      #metadata((t: "NewSlide")) <pdfpc>
      #metadata((t: "Idx", v: here().page() - 1)) <pdfpc>
      #metadata((t: "Overlay", v: curr-subslide - 1)) <pdfpc>
      #metadata((t: "LogicalSlide", v: states.slide-counter.get().first())) <pdfpc>
    ]
  )
  let page-preamble(curr-subslide) = (
    context {
      // global preamble
      if here().page() == self.at("first-slide-number", default: 1) {
        utils.call-or-display(self, self.preamble)
        // pdfpc slide markers
        if self.at("with-pdfpc-file-label", default: true) {
          pdfpc.pdfpc-file(here())
        }
      }
      utils.call-or-display(self, self.page-preamble)
    }
  )
  // update states for every page
  let _update-states(repetitions) = {
    // 1. slide counter part
    //    if freeze-slide-counter is false, then update the slide-counter
    if not self.at("freeze-slide-counter", default: false) {
      states.slide-counter.step()
      //  if appendix is false, then update the last-slide-counter
      if not self.at("appendix", default: false) {
        states.last-slide-counter.step()
      }
    }
    // update page counter
    context counter(page).update(states.slide-counter.get())
  }
  self.subslide = 1
  // for single page slide, get the repetitions
  if repeat == auto {
    let (_, repetitions) = _parse-content-into-results-and-repetitions(
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
      header = _update-states(1) + update-pdfpc(1) + header
      set page(..(self.page + page-extra-args + (header: header, footer: footer)))
      setting(page-preamble(1) + composer-with-side-by-side(..conts))
    }
  }

  if self.handout {
    self.subslide = repeat
    let (conts, _) = _parse-content-into-results-and-repetitions(self: self, index: repeat, ..bodies)
    header = _update-states(1) + update-pdfpc(1) + header
    set page(..(self.page + page-extra-args + (header: header, footer: footer)))
    setting(page-preamble(1) + composer-with-side-by-side(..conts))
  } else {
    // render all the subslides
    let result = ()
    let current = 1
    for i in range(1, repeat + 1) {
      self.subslide = i
      let (header, footer) = _get-header-footer(self)
      let new-header = header
      let (conts, _) = _parse-content-into-results-and-repetitions(self: self, index: i, ..bodies)
      // update the counter in the first subslide
      if i == 1 {
        new-header = _update-states(repeat) + update-pdfpc(i) + new-header
      } else {
        new-header = update-pdfpc(i) + new-header
      }
      result.push({
        set page(..(self.page + page-extra-args + (header: new-header, footer: footer)))
        setting(page-preamble(i) + composer-with-side-by-side(..conts))
      })
    }
    // return the result
    result.sum()
  }
}