#import "utils.typ"
#import "utils.typ"
#import "pdfpc.typ"
#import "components.typ"

/// ------------------------------------------------
/// Slides
/// ------------------------------------------------

#let _delayed-wrapper(body) = utils.label-it(
  metadata((kind: "touying-delayed-wrapper", body: body)),
  "touying-temporary-mark",
)

/// Update configurations for the presentation.
///
/// Example: `#let appendix(body) = touying-set-config((appendix: true), body)` and you can use `#show: appendix` to set the appendix for the presentation.
///
/// - `config` (dict): The new configurations for the presentation.
///
/// - `body` (content): The content of the slide.
#let touying-set-config(config, body) = utils.label-it(
  metadata((
    kind: "touying-set-config",
    config: config,
    body: body,
  )),
  "touying-temporary-mark",
)


/// Appendix for the presentation. The last-slide-counter will be frozen at the last slide before the appendix. It is simple wrapper for `touying-set-config`, just like `#show: touying-set-config.with((appendix: true))`.
///
/// Example: `#show: appendix`
///
/// - `body` (content): The content of the appendix.
#let appendix(body) = touying-set-config(
  (appendix: true),
  body,
)


/// Recall a slide by its label
///
/// Example: `#touying-recall(<recall>)` or `#touying-recall("recall")`
///
/// - `lbl` (str): The label of the slide to recall
#let touying-recall(lbl) = utils.label-it(
  metadata((
    kind: "touying-slide-recaller",
    label: if type(lbl) == label {
      str(lbl)
    } else {
      lbl
    },
  )),
  "touying-temporary-mark",
)


/// Call touying slide function
#let _call-slide-fn(self, fn, body) = {
  let slide-wrapper = fn(body)
  assert(
    utils.is-kind(slide-wrapper, "touying-slide-wrapper"),
    message: "you must use `touying-slide-wrapper` in your slide function",
  )
  return (slide-wrapper.value.fn)(self)
}


/// Use headings to split a content block into slides
#let split-content-into-slides(self: none, recaller-map: (:), new-start: true, is-first-slide: false, body) = {
  // Extract arguments
  assert(type(self) == dictionary, message: "`self` must be a dictionary")
  assert("slide-level" in self and type(self.slide-level) == int, message: "`self.slide-level` must be an integer")
  assert("slide-fn" in self and type(self.slide-fn) == function, message: "`self.slide-fn` must be a function")
  let slide-level = self.slide-level
  let slide-fn = self.slide-fn
  let new-section-slide-fn = self.at("new-section-slide-fn", default: none)
  let new-subsection-slide-fn = self.at("new-subsection-slide-fn", default: none)
  let new-subsubsection-slide-fn = self.at("new-subsubsection-slide-fn", default: none)
  let new-subsubsubsection-slide-fn = self.at("new-subsubsubsection-slide-fn", default: none)
  let horizontal-line-to-pagebreak = self.at("horizontal-line-to-pagebreak", default: true)
  let children = if utils.is-sequence(body) {
    body.children
  } else {
    (body,)
  }
  // convert all sequence to array recursively, and then flatten the array
  let sequence-to-array(it) = {
    if utils.is-sequence(it) {
      it.children.map(sequence-to-array)
    } else {
      it
    }
  }
  children = children.map(sequence-to-array).flatten()
  let get-last-heading-depth(current-headings) = {
    if current-headings != () {
      current-headings.at(-1).depth
    } else {
      0
    }
  }
  let get-last-heading-label(current-headings) = {
    if current-headings != () {
      if current-headings.at(-1).has("label") {
        str(current-headings.at(-1).label)
      }
    }
  }
  let call-slide-fn-and-reset(self, already-slide-wrapper: false, slide-fn, current-slide-cont, recaller-map) = {
    let cont = if already-slide-wrapper {
      slide-fn(self)
    } else {
      _call-slide-fn(self, slide-fn, current-slide-cont)
    }
    let last-heading-label = get-last-heading-label(self.headings)
    if last-heading-label != none {
      recaller-map.insert(last-heading-label, cont)
    }
    (cont, recaller-map, (), (), true, false)
  }
  // The empty content list
  let empty-contents = ([], [ ], parbreak(), linebreak())
  // The headings that we currently have
  let current-headings = ()
  // Recaller map
  let recaller-map = recaller-map
  // The current slide we are building
  let current-slide = ()
  // The current slide content
  let cont = none
  // is new start
  let is-new-start = new-start
  // start part
  let start-part = ()
  // result
  let result = ()

  // Is we have a horizontal line
  let horizontal-line = false
  // Iterate over the children
  for child in children {
    // Handle horizontal-line
    // split content when we have a horizontal line
    if horizontal-line-to-pagebreak and horizontal-line and child not in ([—], [–], [-]) {
      current-slide = utils.trim(current-slide)
      (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings, is-first-slide: is-first-slide),
        slide-fn,
        current-slide.sum(default: none),
        recaller-map,
      )
      result.push(cont)
      horizontal-line = false
    }
    // Main logic
    if utils.is-kind(child, "touying-slide-wrapper") {
      current-slide = utils.trim(current-slide)
      if current-slide != () {
        (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        result.push(cont)
      }
      (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings, is-first-slide: is-first-slide),
        already-slide-wrapper: true,
        child.value.fn,
        none,
        recaller-map,
      )
      if child.has("label") and child.label != <touying-temporary-mark> {
        recaller-map.insert(str(child.label), cont)
      }
      result.push(cont)
    } else if utils.is-kind(child, "touying-slide-recaller") {
      current-slide = utils.trim(current-slide)
      if current-slide != () or current-headings != () {
        (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        result.push(cont)
      }
      let lbl = child.value.label
      assert(lbl in recaller-map, message: "label not found in the recaller map for slides")
      // recall the slide
      result.push(recaller-map.at(lbl))
    } else if child == pagebreak() {
      // split content when we have a pagebreak
      current-slide = utils.trim(current-slide)
      (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
        self + (headings: current-headings, is-first-slide: is-first-slide),
        slide-fn,
        current-slide.sum(default: none),
        recaller-map,
      )
      result.push(cont)
    } else if horizontal-line-to-pagebreak and child == [—] {
      horizontal-line = true
      continue
    } else if horizontal-line-to-pagebreak and horizontal-line and child in ([–], [-]) {
      continue
    } else if utils.is-heading(child, depth: slide-level) {
      let last-heading-depth = get-last-heading-depth(current-headings)
      current-slide = utils.trim(current-slide)
      if child.depth <= last-heading-depth or current-slide != () or (
        child.depth == 1 and new-section-slide-fn != none
      ) or (child.depth == 2 and new-subsection-slide-fn != none) or (
        child.depth == 3 and new-subsubsection-slide-fn != none
      ) or (child.depth == 4 and new-subsubsubsection-slide-fn != none) {
        current-slide = utils.trim(current-slide)
        if current-slide != () or current-headings != () {
          (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            slide-fn,
            current-slide.sum(default: none),
            recaller-map,
          )
          result.push(cont)
        }
      }

      current-headings.push(child)
      new-start = true

      if not child.has("label") or str(child.label) != "touying:hidden" {
        if child.depth == 1 and new-section-slide-fn != none {
          (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-section-slide-fn,
            child.body,
            recaller-map,
          )
          result.push(cont)
        } else if child.depth == 2 and new-subsection-slide-fn != none {
          (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsection-slide-fn,
            child.body,
            recaller-map,
          )
          result.push(cont)
        } else if child.depth == 3 and new-subsubsection-slide-fn != none {
          (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsubsection-slide-fn,
            child.body,
            recaller-map,
          )
          result.push(cont)
        } else if child.depth == 4 and new-subsubsubsection-slide-fn != none {
          (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsubsubsection-slide-fn,
            child.body,
            recaller-map,
          )
          result.push(cont)
        }
      }
    } else if self.at("auto-offset-for-heading", default: true) and utils.is-heading(child) {
      let fields = child.fields()
      let lbl = fields.remove("label", default: none)
      let _ = fields.remove("body", default: none)
      fields.offset = 0
      let new-heading = if lbl != none {
        utils.label-it(heading(..fields, child.body), child.label)
      } else {
        heading(..fields, child.body)
      }
      if new-start {
        current-slide.push(new-heading)
      } else {
        start-part.push(new-heading)
      }
    } else if utils.is-kind(child, "touying-set-config") {
      current-slide = utils.trim(current-slide)
      if current-slide != () or current-headings != () {
        (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        result.push(cont)
      }
      // Appendix content
      result.push(
        split-content-into-slides(
          self: utils.merge-dicts(self, child.value.config),
          recaller-map: recaller-map,
          new-start: true,
          child.value.body,
        ),
      )
    } else if is-first-slide and utils.is-styled(child) {
      current-slide = utils.trim(current-slide)
      if current-slide != () or current-headings != () {
        (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          current-slide.sum(default: none),
          recaller-map,
        )
        result.push(cont)
      }
      result.push(
        utils.reconstruct-styled(
          child,
          split-content-into-slides(
            self: self,
            recaller-map: recaller-map,
            new-start: true,
            is-first-slide: is-first-slide,
            child.child,
          ),
        ),
      )
    } else {
      let child = if utils.is-styled(child) {
        // Split the content into slides recursively for styled content
        let (start-part, cont) = split-content-into-slides(
          self: self,
          recaller-map: recaller-map,
          new-start: false,
          child.child,
        )
        if start-part != none {
          utils.reconstruct-styled(child, start-part)
        }
        _delayed-wrapper(utils.reconstruct-styled(child, cont))
      } else {
        child
      }
      if new-start {
        // Add the child to the current slide
        current-slide.push(child)
      } else {
        start-part.push(child)
      }
    }
  }

  // Handle the last slide
  current-slide = utils.trim(current-slide)
  if current-slide != () or current-headings != () {
    (cont, recaller-map, current-headings, current-slide, new-start, is-first-slide) = call-slide-fn-and-reset(
      self + (headings: current-headings, is-first-slide: is-first-slide),
      slide-fn,
      current-slide.sum(default: none),
      recaller-map,
    )
    result.push(cont)
  }

  if is-new-start {
    return result.sum(default: none)
  } else {
    return (start-part.sum(default: none), result.sum(default: none))
  }
}

/// ------------------------------------------------
/// Slide
/// ------------------------------------------------

/// Wrapper for a function to make it can receive `self` as an argument.
/// It is useful when you want to use `self` to get current subslide index, like `uncover` and `only` functions.
///
/// Example: `#let alternatives = touying-fn-wrapper.with(utils.alternatives)`
///
/// - `fn` ((self: none, ..args) => { .. }): The function that will be called.
///
/// - `with-visible-subslides` (bool): Whether the first argument of the function is the visible subslides.
///
///   It is useful for functions like `uncover` and `only`.
///
///   Touying will automatically update the max repetitions for the slide if the function is called with visible subslides.
#let touying-fn-wrapper(fn, with-visible-subslides: false, ..args) = utils.label-it(
  metadata((
    kind: "touying-fn-wrapper",
    fn: fn,
    args: args,
    with-visible-subslides: with-visible-subslides,
  )),
  "touying-temporary-mark",
)

/// Wrapper for a slide function to make it can receive `self` as an argument.
///
/// Notice: This function is necessary for the slide function to work in Touying.
///
/// Example:
///
/// ```typst
/// #let slide(..args) = touying-slide-wrapper(self => {
///   touying-slide(self: self, ..args)
/// })
/// ```
///
/// - `fn` (self => { .. }): The function that will be called with an argument `self`.
#let touying-slide-wrapper(fn) = utils.label-it(
  metadata((
    kind: "touying-slide-wrapper",
    fn: fn,
  )),
  "touying-temporary-mark",
)


/// Uncover content after the `#pause` mark in next subslide.
#let pause = [#metadata((kind: "touying-pause"))<touying-temporary-mark>]


/// Display content after the `#meanwhile` mark meanwhile.
#let meanwhile = [#metadata((kind: "touying-meanwhile"))<touying-temporary-mark>]


/// Uncover content in some subslides. Reserved space when hidden (like `#hide()`).
///
/// Example: `uncover("2-")[abc]` will display `[abc]` if the current slide is 2 or later
///
/// - `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read [polylux book](https://polylux.dev/book/dynamic/complex.html)
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - `uncover-cont` is the content to display when the content is visible in the subslide.
#let uncover(visible-subslides, uncover-cont) = {
  touying-fn-wrapper(utils.uncover, with-visible-subslides: true, visible-subslides, uncover-cont)
}


/// Display content in some subslides only.
/// Don't reserve space when hidden, content is completely not existing there.
///
/// - `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read [polylux book](https://polylux.dev/book/dynamic/complex.html)
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - `only-cont` is the content to display when the content is visible in the subslide.
#let only(visible-subslides, only-cont) = {
  touying-fn-wrapper(utils.only, with-visible-subslides: true, visible-subslides, only-cont)
}


/// `#alternatives` has a couple of "cousins" that might be more convenient in some situations. The first one is `#alternatives-match` that has a name inspired by match-statements in many functional programming languages. The idea is that you give it a dictionary mapping from subslides to content:
///
/// #example(```
/// #alternatives-match((
///   "1, 3-5": [this text has the majority],
///   "2, 6": [this is shown less often]
/// ))
/// ```)
///
/// - `subslides-contents` is a dictionary mapping from subslides to content.
///
/// - `position` is the position of the content. Default is `bottom + left`.
#let alternatives-match(subslides-contents, position: bottom + left) = {
  touying-fn-wrapper(utils.alternatives-match, subslides-contents, position: position)
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// - `start` is the starting subslide number. Default is `1`.
///
/// - `repeat-last` is a boolean indicating whether the last subslide should be repeated. Default is `true`.
#let alternatives(
  start: 1,
  repeat-last: true,
  ..args,
) = {
  touying-fn-wrapper(utils.alternatives, start: start, repeat-last: repeat-last, ..args)
}


/// You can have very fine-grained control over the content depending on the current subslide by using #alternatives-fn. It accepts a function (hence the name) that maps the current subslide index to some content.
///
/// Example: `#alternatives-fn(start: 2, count: 7, subslide => { numbering("(i)", subslide) })`
///
/// - `start` is the starting subslide number. Default is `1`.
///
/// - `end` is the ending subslide number. Default is `none`.
///
/// - `count` is the number of subslides. Default is `none`.
#let alternatives-fn(
  start: 1,
  end: none,
  count: none,
  ..kwargs,
  fn,
) = {
  touying-fn-wrapper(utils.alternatives-fn, start: start, end: end, count: count, ..kwargs, fn)
}


/// You can use this function if you want to have one piece of content that changes only slightly depending of what "case" of subslides you are in.
///
/// #example(```
/// #alternatives-cases(("1, 3", "2"), case => [
///   #set text(fill: teal) if case == 1
///   Some text
/// ])
/// ```)
///
/// - `cases` is an array of strings that specify the subslides for each case.
///
/// - `fn` is a function that maps the case to content. The argument `case` is the index of the cases array you input.
#let alternatives-cases(cases, fn, ..kwargs) = {
  touying-fn-wrapper(utils.alternatives-cases, cases, fn, ..kwargs)
}


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Example: `#speaker-note[This is a speaker note]`
///
/// - `self` is the current context.
///
/// - `mode` is the mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - `setting` is a function that takes the note as input and returns a processed note.
///
/// - `note` is the content of the speaker note.
#let speaker-note(mode: "typ", setting: it => it, note) = {
  touying-fn-wrapper(utils.speaker-note, mode: mode, setting: setting, note)
}


/// Alert is a way to display a message to the audience. It can be used to draw attention to important information or to provide instructions.
#let alert(body) = touying-fn-wrapper(utils.alert, body)


/// Touying also provides a unique and highly useful feature—math equation animations, allowing you to conveniently use pause and meanwhile within math equations.
///
/// #example(```
/// #touying-equation(`
///   f(x) &= pause x^2 + 2x + 1  \
///         &= pause (x + 1)^2  \
/// `)
/// ```)
///
/// - `block` is a boolean indicating whether the equation is a block. Default is `true`.
///
/// - `numbering` is the numbering of the equation. Default is `none`.
///
/// - `supplement` is the supplement of the equation. Default is `auto`.
///
/// - `scope` is the scope when we use `eval()` function to evaluate the equation.
///
/// - `body` is the content of the equation. It should be a string, a raw text or a function that receives `self` as an argument and returns a string.
#let touying-equation(block: true, numbering: none, supplement: auto, scope: (:), body) = utils.label-it(
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


/// Touying can integrate with `mitex` to display math equations.
/// You can use `#touying-mitex` to display math equations with pause and meanwhile.
///
/// #example(```
/// #touying-mitex(mitex, `
///   f(x) &= \pause x^2 + 2x + 1  \\
///       &= \pause (x + 1)^2  \\
/// `)
/// ```)
///
/// - `mitex` is the mitex function. You can import it by code like `#import "@preview/mitex:0.2.3": mitex`
///
/// - `block` is a boolean indicating whether the equation is a block. Default is `true`.
///
/// - `numbering` is the numbering of the equation. Default is `none`.
///
/// - `supplement` is the supplement of the equation. Default is `auto`.
///
/// - `body` is the content of the equation. It should be a string, a raw text or a function that receives `self` as an argument and returns a string.
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


/// Touying reducer is a powerful tool to provide more powerful animation effects for other packages or functions.
///
/// For example, you can adds `pause` and `meanwhile` animations to cetz and fletcher packages.
///
/// Cetz: `#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))`
///
/// Fletcher: `#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)`
///
/// - `reduce` is the reduce function that will be called. It is usually a function that receives an array of content and returns a content it painted. Just like the `cetz.canvas` or `fletcher.diagram` function.
///
/// - `cover` is the cover function that will be called when some content is hidden. It is usually a function that receives an the argument of the content that will be hidden. Just like the `cetz.draw.hide` or `fletcher.hide` function.
///
/// - `..args` is the arguments of the reducer function.
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
#let _parse-touying-equation(self: none, need-cover: true, base: 1, index: 1, eqt-metadata) = {
  let eqt = eqt-metadata.value
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
  let equation = math.equation(
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
  )
  if eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark> {
    equation = utils.label-it(equation, eqt-metadata.label)
  }
  result-arr.push(equation)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (result-arr, max-repetitions)
}

// parse touying mitex, and get the repetitions
#let _parse-touying-mitex(self: none, need-cover: true, base: 1, index: 1, eqt-metadata) = {
  let eqt = eqt-metadata.value
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
  let equation = (eqt.mitex)(
    block: eqt.block,
    numbering: eqt.numbering,
    supplement: eqt.supplement,
    result.sum(default: ""),
  )
  if eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark> {
    equation = utils.label-it(equation, eqt-metadata.label)
  }
  result-arr.push(equation)
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
#let _parse-content-into-results-and-repetitions(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  show-delayed-wrapper: false,
  ..bodies,
) = {
  let labeled(func) = {
    return not (
      "repeat" in self and "subslide" in self and "label-only-on-last-subslide" in self and func in self.label-only-on-last-subslide and self.subslide != self.repeat
    )
  }
  let bodies = bodies.pos()
  let result-arr = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = self.methods.cover.with(self: self)
  for it in bodies {
    // a hack for code like #table([A], pause, [B])
    if type(it) == content and it.func() in (table.cell, grid.cell) {
      if type(it.body) == content and it.body.func() == metadata and type(it.body.value) == dictionary {
        let kind = it.body.value.at("kind", default: none)
        if kind == "touying-pause" {
          repetitions += 1
        } else if kind == "touying-meanwhile" {
          // reset the repetitions
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        }
        continue
      }
    }
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
            child,
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
            child,
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
          if repetitions <= index or not need-cover {
            result.push((child.value.fn)(self: self, ..child.value.args))
          } else {
            cover-arr.push((child.value.fn)(self: self, ..child.value.args))
          }
          if child.value.with-visible-subslides {
            let visible-subslides = child.value.args.pos().at(0)
            max-repetitions = calc.max(max-repetitions, utils.last-required-subslide(visible-subslides))
          }
        } else if kind == "touying-delayed-wrapper" {
          if show-delayed-wrapper {
            if repetitions <= index or not need-cover {
              result.push(child.value.body)
            } else {
              cover-arr.push(child.value.body)
            }
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
      } else if type(child) == content and child.func() in (list.item, enum.item, align, link) {
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
          result.push(utils.reconstruct(child, labeled: labeled(child.func()), cont))
        } else {
          cover-arr.push(utils.reconstruct(child, labeled: labeled(child.func()), cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() in (table, grid, stack) {
        // handle the table-like
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          ..child.children,
        )
        if repetitions <= index or not need-cover {
          result.push(utils.reconstruct-table-like(child, labeled: labeled(child.func()), conts))
        } else {
          cover-arr.push(utils.reconstruct-table-like(child, labeled: labeled(child.func()), conts))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() in (
        pad,
        figure,
        quote,
        strong,
        emph,
        footnote,
        highlight,
        overline,
        underline,
        strike,
        smallcaps,
        sub,
        super,
        box,
        block,
        hide,
        move,
        scale,
        circle,
        ellipse,
        rect,
        square,
        table.cell,
        grid.cell,
        math.equation,
        heading,
      ) {
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          // Some functions (e.g. square) may have no body
          child.at("body", default: none),
        )
        let cont = conts.first()
        if repetitions <= index or not need-cover {
          result.push(utils.reconstruct(named: true, labeled: labeled(child.func()), child, cont))
        } else {
          cover-arr.push(utils.reconstruct(named: true, labeled: labeled(child.func()), child, cont))
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
      } else if type(child) == content and child.func() == columns {
        // handle columns
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let cont = conts.first()
        let args = if child.has("gutter") {
          (gutter: child.gutter)
        }
        let count = if child.has("count") {
          child.count
        } else {
          2
        }
        if repetitions <= index or not need-cover {
          result.push(columns(count, ..args, cont))
        } else {
          cover-arr.push(columns(count, ..args, cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() == place {
        // handle place
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let cont = conts.first()
        let fields = child.fields()
        let _ = fields.remove("alignment", default: none)
        let _ = fields.remove("body", default: none)
        let alignment = if child.has("alignment") {
          child.alignment
        } else {
          start
        }
        if repetitions <= index or not need-cover {
          result.push(place(alignment, ..fields, cont))
        } else {
          cover-arr.push(place(alignment, ..fields, cont))
        }
        repetitions = nextrepetitions
      } else if type(child) == content and child.func() == rotate {
        // handle rotate
        let (conts, nextrepetitions) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let cont = conts.first()
        let fields = child.fields()
        let _ = fields.remove("angle", default: none)
        let _ = fields.remove("body", default: none)
        let angle = if child.has("angle") {
          child.angle
        } else {
          0deg
        }
        if repetitions <= index or not need-cover {
          result.push(rotate(angle, ..fields, cont))
        } else {
          cover-arr.push(rotate(angle, ..fields, cont))
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
  if self.show-notes-on-second-screen in (bottom, right) {
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
    let page-height = if self.page.paper == "presentation-16-9" {
      473.56pt
    } else {
      595.28pt
    }
    if type(margin) != dictionary and type(margin) != length and type(margin) != relative {
      return (:)
    }
    if type(margin) == length or type(margin) == relative {
      margin = (x: margin, y: margin)
    }
    if self.show-notes-on-second-screen == bottom {
      if "bottom" not in margin {
        assert("y" in margin, message: "The margin should have bottom or y")
        margin.bottom = margin.y
      }
      margin.bottom += page-height
      return (margin: margin, height: 2 * page-height)
    } else if self.show-notes-on-second-screen == right {
      if "right" not in margin {
        assert("x" in margin, message: "The margin should have right or x")
        margin.right = margin.x
      }
      margin.right += page-width
      return (margin: margin, width: 2 * page-width)
    }
    return (:)
  } else {
    return (:)
  }
}

#let _get-header-footer(self) = {
  let header = utils.call-or-display(self, self.page.at("header", default: none))
  let footer = utils.call-or-display(self, self.page.at("footer", default: none))
  // speaker note
  if self.show-notes-on-second-screen in (bottom, right) {
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
    let show-notes = (self.methods.show-notes)(self: self, width: page-width, height: page-height)
    if self.show-notes-on-second-screen == bottom {
      footer += place(
        left + bottom,
        show-notes,
      )
    } else if self.show-notes-on-second-screen == right {
      footer += place(
        left + bottom,
        dx: page-width,
        show-notes,
      )
    }
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


/// Touying slide function, the core function of touying. It usually is used to create a slide with animation effects and works with `touying-slide-wrapper` function.
///
/// Example:
///
/// ```
/// #let slide(
///   config: (:),
///   repeat: auto,
///   setting: body => body,
///   composer: auto,
///   ..bodies,
/// ) = touying-slide-wrapper(self => {
///   touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
/// })
/// ```
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let touying-slide(
  self: none,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }
  assert(bodies.named().len() == 0, message: "unexpected named arguments:" + repr(bodies.named().keys()))
  let setting-with-auto-offset-for-heading(body) = {
    set heading(offset: self.at("slide-level", default: 0)) if self.at("auto-offset-for-heading", default: true)
    setting(body)
  }
  let composer-with-side-by-side(..args) = {
    if type(composer) == function {
      composer(..args)
    } else {
      components.side-by-side(columns: composer, ..args)
    }
  }
  let bodies = bodies.pos()

  // preambles
  let slide-preamble(self) = {
    if self.at("is-first-slide", default: false) {
      utils.call-or-display(self, self.at("preamble", default: none))
      utils.call-or-display(self, self.at("default-preamble", default: none))
    }
    [#metadata((kind: "touying-new-slide")) <touying-metadata>]
    // add headings for the first subslide
    if self.at("headings", default: ()) != () {
      place(
        hide({
          set heading(offset: 0)
          let headings = self.at("headings", default: ()).map(it => if it.has("label") {
            if str(it.label) in ("touying:hidden", "touying:unnumbered", "touying:unoutlined", "touying:unbookmarked") {
              let fields = it.fields()
              let _ = fields.remove("label", default: none)
              let _ = fields.remove("body", default: none)
              if str(it.label) == "touying:hidden" {
                fields.numbering = none
                fields.outlined = false
                fields.bookmarked = false
              }
              if str(it.label) == "touying:unnumbered" {
                fields.numbering = none
              }
              if str(it.label) == "touying:unoutlined" {
                fields.outlined = false
              }
              if str(it.label) == "touying:unbookmarked" {
                fields.bookmarked = false
              }
              utils.label-it(heading(..fields, it.body), it.label)
            } else {
              it
            }
          } else {
            it
          })
          headings.sum(default: none)
        }),
      )
    }
    utils.call-or-display(self, self.at("slide-preamble", default: none))
    utils.call-or-display(self, self.at("default-slide-preamble", default: none))
  }
  // preamble for the subslides
  let subslide-preamble(self) = {
    if self.handout or self.subslide == 1 {
      slide-preamble(self)
    }
    [#metadata((kind: "touying-new-subslide")) <touying-metadata>]
    if self.at("enable-frozen-states-and-counters", default: true) and not self.handout and self.repeat > 1 {
      if self.subslide == 1 {
        // save the states and counters
        context {
          utils.saved-frozen-states.update(self.frozen-states.map(s => s.get()))
          utils.saved-default-frozen-states.update(self.default-frozen-states.map(s => s.get()))
          utils.saved-frozen-counters.update(self.frozen-counters.map(s => s.get()))
          utils.saved-default-frozen-counters.update(self.default-frozen-counters.map(s => s.get()))
        }
      } else {
        // restore the states and counters
        context {
          self
            .frozen-states
            .zip(utils.saved-frozen-states.get())
            .map(pair => pair.at(0).update(pair.at(1)))
            .sum(default: none)
          self
            .default-frozen-states
            .zip(utils.saved-default-frozen-states.get())
            .map(pair => pair.at(0).update(pair.at(1)))
            .sum(default: none)
          self
            .frozen-counters
            .zip(utils.saved-frozen-counters.get())
            .map(pair => pair.at(0).update(pair.at(1)))
            .sum(default: none)
          self
            .default-frozen-counters
            .zip(utils.saved-default-frozen-counters.get())
            .map(pair => pair.at(0).update(pair.at(1)))
            .sum(default: none)
        }
      }
    }
    utils.call-or-display(self, self.at("subslide-preamble", default: none))
    utils.call-or-display(self, self.at("default-subslide-preamble", default: none))
  }
  // update states for every page
  let page-preamble(self) = {
    [#metadata((kind: "touying-new-page")) <touying-metadata>]
    // 1. slide counter part
    //    if freeze-slide-counter is false, then update the slide-counter
    if self.subslide == 1 {
      if not self.at("freeze-slide-counter", default: false) {
        utils.slide-counter.step()
        //  if appendix is false, then update the last-slide-counter
        if not self.at("appendix", default: false) {
          utils.last-slide-counter.step()
        }
      }
    }
    utils.call-or-display(self, self.at("page-preamble", default: none))
    utils.call-or-display(self, self.at("default-page-preamble", default: none))
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
  assert(type(repeat) == int, message: "The repeat should be an integer")
  self.repeat = repeat
  // page header and footer
  let (header, footer) = _get-header-footer(self)
  let page-extra-args = _get-page-extra-args(self)

  if self.handout {
    self.subslide = repeat
    let (conts, _) = _parse-content-into-results-and-repetitions(
      self: self,
      index: repeat,
      show-delayed-wrapper: true,
      ..bodies,
    )
    header = page-preamble(self) + header
    set page(..(self.page + page-extra-args + (header: header, footer: footer)))
    setting-with-auto-offset-for-heading(subslide-preamble(self) + composer-with-side-by-side(..conts))
  } else {
    // render all the subslides
    let result = ()
    let current = 1
    for i in range(1, repeat + 1) {
      self.subslide = i
      let (header, footer) = _get-header-footer(self)
      let delayed-args = if i == repeat {
        (show-delayed-wrapper: true)
      }
      let (conts, _) = _parse-content-into-results-and-repetitions(self: self, index: i, ..delayed-args, ..bodies)
      let new-header = page-preamble(self) + header
      // update the counter in the first subslide only
      result.push({
        set page(..(self.page + page-extra-args + (header: new-header, footer: footer)))
        setting-with-auto-offset-for-heading(subslide-preamble(self) + composer-with-side-by-side(..conts))
      })
    }
    // return the result
    result.sum()
  }
}


/// Touying slide function.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Touying empty slide function.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let empty-slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})