#import "utils.typ"
#import "utils.typ"
#import "pdfpc.typ"
#import "components.typ"

/// ------------------------------------------------
/// Slides
/// ------------------------------------------------

/// -> content
#let _delayed-wrapper(body) = [#metadata((
  kind: "touying-delayed-wrapper",
  body: body,
))<touying-temporary-mark>]

/// Update configurations for the presentation.
///
/// Example: `#let appendix(body) = touying-set-config((appendix: true), body)` and you can use `#show: appendix` to set the appendix for the presentation.
///
/// - config (dictionary): The new configurations for the presentation.
///
/// - body (content): The content of the slide.
///
/// -> content
#let touying-set-config(config, body) = [#metadata((
  kind: "touying-set-config",
  config: config,
  body: body,
))<touying-temporary-mark>]


/// Appendix for the presentation. The last-slide-counter will be frozen at the last slide before the appendix. It is simple wrapper for `touying-set-config`, just like `#show: touying-set-config.with((appendix: true))`.
///
/// Example: `#show: appendix`
///
/// - body (content): The content of the appendix.
///
/// -> content
#let appendix(body) = touying-set-config(
  (appendix: true),
  body,
)


/// Recall a slide by its label.
///
/// == Example
///
/// ```typ
/// #touying-recall("recall")
/// #touying-recall("recall", subslide: 2)
/// ```
///
/// - lbl (string): The label of the slide to recall
///
/// - subslide (none | int): The subslide index to recall. Default is `none`, which recalls all subslides.
///
/// -> content
#let touying-recall(lbl, subslide: none) = [#metadata((
  kind: "touying-slide-recaller",
  label: if type(lbl) == label {
    str(lbl)
  } else {
    lbl
  },
  subslide: subslide,
))<touying-temporary-mark>]

#let _get-last-heading-depth(current-headings) = {
  if current-headings != () {
    current-headings.at(-1).depth
  } else {
    0
  }
}

#let _get-last-heading-label(current-headings) = {
  if current-headings != () {
    if current-headings.at(-1).has("label") {
      str(current-headings.at(-1).label)
    }
  }
}

/// Get the appropriate slide function based on current heading context
///
/// - self (dictionary): The presentation context
/// - default (function): Default slide function to use if no specific one matches
///
/// -> function
#let _get-slide-fn(self, default: auto) = {
  let last-heading-depth = _get-last-heading-depth(self.headings)
  let last-heading-label = _get-last-heading-label(self.headings)
  if last-heading-label in ("touying:hidden", "touying:skip") {
    return if default == auto {
      self.slide-fn
    } else {
      default
    }
  }
  if last-heading-depth == 1 and self.new-section-slide-fn != none {
    self.new-section-slide-fn
  } else if last-heading-depth == 2 and self.new-subsection-slide-fn != none {
    self.new-subsection-slide-fn
  } else if (
    last-heading-depth == 3 and self.new-subsubsection-slide-fn != none
  ) {
    self.new-subsubsection-slide-fn
  } else if (
    last-heading-depth == 4 and self.new-subsubsubsection-slide-fn != none
  ) {
    self.new-subsubsubsection-slide-fn
  } else {
    if default == auto {
      self.slide-fn
    } else {
      default
    }
  }
}

/// Call the appropriate slide function with the given body content
///
/// - self (dictionary): The presentation context
/// - fn (function): The slide function to use (auto to determine automatically)
/// - body (content): The slide content to render
///
/// -> content
#let _call-slide-fn(self, fn, body) = {
  let slide-fn = if fn == auto {
    _get-slide-fn(self)
  } else {
    fn
  }
  let slide-wrapper = slide-fn(body)
  assert(
    utils.is-kind(slide-wrapper, "touying-slide-wrapper"),
    message: "you must use `touying-slide-wrapper` in your slide function",
  )
  return ((slide-wrapper.value.fn)(self), slide-wrapper.value.fn)
}


/// Use headings to split a content block into slides
///
/// This function recursively processes content and splits it into individual slides
/// based on heading levels and other slide-breaking elements like pagebreaks.
///
/// - self (dictionary): The presentation context containing slide configuration
/// - recaller-map (dictionary): Map of slide labels to their content for recall functionality
/// - new-start (boolean): Whether this is the start of a new slide section
/// - is-first-slide (boolean): Whether this is the first slide of the presentation
/// - body (content): The content to be split into slides
///
/// -> content
#let split-content-into-slides(
  self: none,
  recaller-map: (:),
  new-start: true,
  is-first-slide: false,
  body,
) = {
  // Extract arguments
  assert(type(self) == dictionary, message: "`self` must be a dictionary")
  assert(
    "slide-level" in self and type(self.slide-level) == int,
    message: "`self.slide-level` must be an integer",
  )
  assert(
    "slide-fn" in self and type(self.slide-fn) == function,
    message: "`self.slide-fn` must be a function",
  )
  let slide-level = self.slide-level
  let slide-fn = auto
  let new-section-slide-fn = self.at("new-section-slide-fn", default: none)
  let new-subsection-slide-fn = self.at(
    "new-subsection-slide-fn",
    default: none,
  )
  let new-subsubsection-slide-fn = self.at(
    "new-subsubsection-slide-fn",
    default: none,
  )
  let new-subsubsubsection-slide-fn = self.at(
    "new-subsubsubsection-slide-fn",
    default: none,
  )
  let horizontal-line-to-pagebreak = self.at(
    "horizontal-line-to-pagebreak",
    default: true,
  )
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
  let call-slide-fn-and-reset(
    self,
    already-slide-wrapper: false,
    slide-fn,
    current-slide-cont,
    recaller-map,
  ) = {
    let last-heading-label = _get-last-heading-label(self.headings)
    // Skip handout-only slides when not in handout mode
    if last-heading-label == "touying:handout" and not self.handout {
      return (none, recaller-map, (), (), true, false)
    }
    let (slide-content, callable) = if already-slide-wrapper {
      (slide-fn(self), slide-fn)
    } else {
      _call-slide-fn(self, slide-fn, current-slide-cont)
    }
    if last-heading-label != none {
      recaller-map.insert(last-heading-label, (
        content: slide-content,
        callable: callable,
        slide-self: self,
      ))
    }
    (slide-content, recaller-map, (), (), true, false)
  }
  // The empty content list
  let empty-content-types = ([], [ ], parbreak(), linebreak())
  // The headings that we currently have
  let current-headings = ()
  // Recaller map
  let recaller-map = recaller-map
  // The current slide we are building
  let slide-parts = ()
  // The current slide content
  let slide-content = none
  // is new start
  let is-new-start = new-start
  // start part
  let start-part = ()
  // result
  let output-slides = ()

  // Is we have a horizontal line
  let horizontal-line = false
  // Iterate over the children
  for child in children {
    // Handle horizontal-line
    // split content when we have a horizontal line
    if (
      horizontal-line-to-pagebreak
        and horizontal-line
        and child not in ([—], [---], [–], [--], [-])
    ) {
      slide-parts = utils.trim(slide-parts)
      (
        slide-content,
        recaller-map,
        current-headings,
        slide-parts,
        new-start,
        is-first-slide,
      ) = call-slide-fn-and-reset(
        self + (headings: current-headings, is-first-slide: is-first-slide),
        slide-fn,
        slide-parts.sum(default: none),
        recaller-map,
      )
      if slide-content != none { output-slides.push(slide-content) }
      horizontal-line = false
    }
    // Main logic
    if utils.is-kind(child, "touying-slide-wrapper") {
      slide-parts = utils.trim(slide-parts)
      if (
        slide-parts != ()
          or _get-slide-fn(self + (headings: current-headings), default: none)
            != none
      ) {
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }
      let slide-self = (
        self + (headings: current-headings, is-first-slide: is-first-slide)
      )
      (
        slide-content,
        recaller-map,
        current-headings,
        slide-parts,
        new-start,
        is-first-slide,
      ) = call-slide-fn-and-reset(
        slide-self,
        already-slide-wrapper: true,
        child.value.fn,
        none,
        recaller-map,
      )
      if child.has("label") and child.label != <touying-temporary-mark> {
        recaller-map.insert(str(child.label), (
          content: slide-content,
          callable: child.value.fn,
          slide-self: slide-self,
        ))
      }
      if slide-content != none { output-slides.push(slide-content) }
    } else if utils.is-kind(child, "touying-slide-recaller") {
      slide-parts = utils.trim(slide-parts)
      if slide-parts != () or current-headings != () {
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }
      let lbl = child.value.label
      assert(
        lbl in recaller-map,
        message: "label not found in the recaller map for slides",
      )
      // recall the slide
      let recall-entry = recaller-map.at(lbl)
      let recall-subslide = child.value.at("subslide", default: none)
      if recall-subslide == none {
        output-slides.push(recall-entry.content)
      } else {
        let recalled-self = (
          recall-entry.slide-self
            + (
              freeze-slide-counter: true,
              _recall-subslide: recall-subslide,
              enable-frozen-states-and-counters: false,
            )
        )
        output-slides.push((recall-entry.callable)(recalled-self))
      }
    } else if child in (pagebreak(), pagebreak(weak: true)) {
      // split content when we have a pagebreak
      slide-parts = utils.trim(slide-parts)
      (
        slide-content,
        recaller-map,
        current-headings,
        slide-parts,
        new-start,
        is-first-slide,
      ) = call-slide-fn-and-reset(
        self + (headings: current-headings, is-first-slide: is-first-slide),
        slide-fn,
        slide-parts.sum(default: none),
        recaller-map,
      )
      if slide-content != none { output-slides.push(slide-content) }
    } else if horizontal-line-to-pagebreak and child in ([—], [---]) {
      horizontal-line = true
      continue
    } else if (
      horizontal-line-to-pagebreak
        and horizontal-line
        and child in ([–], [--], [-])
    ) {
      continue
    } else if utils.is-heading(child, depth: slide-level) {
      let last-heading-depth = _get-last-heading-depth(current-headings)
      slide-parts = utils.trim(slide-parts)
      if (
        _get-slide-fn(
          self + (headings: current-headings),
          default: none,
        )
          != none
          or child.depth <= last-heading-depth
          or slide-parts != ()
          or (
            child.depth == 1 and new-section-slide-fn != none
          )
          or (child.depth == 2 and new-subsection-slide-fn != none)
          or (
            child.depth == 3 and new-subsubsection-slide-fn != none
          )
          or (child.depth == 4 and new-subsubsubsection-slide-fn != none)
      ) {
        slide-parts = utils.trim(slide-parts)
        if slide-parts != () or current-headings != () {
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            slide-fn,
            slide-parts.sum(default: none),
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        }
      }

      current-headings.push(child)
      new-start = true

      if (
        not child.has("label")
          or str(child.label) not in ("touying:hidden", "touying:skip")
      ) {
        if (
          child.depth == 1
            and new-section-slide-fn != none
            and not self.receive-body-for-new-section-slide-fn
        ) {
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-section-slide-fn,
            none,
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        } else if (
          child.depth == 2
            and new-subsection-slide-fn != none
            and not self.receive-body-for-new-subsection-slide-fn
        ) {
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsection-slide-fn,
            none,
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        } else if (
          child.depth == 3
            and new-subsubsection-slide-fn != none
            and not self.receive-body-for-new-subsubsection-slide-fn
        ) {
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsubsection-slide-fn,
            none,
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        } else if (
          child.depth == 4
            and new-subsubsubsection-slide-fn != none
            and not self.receive-body-for-new-subsubsubsection-slide-fn
        ) {
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            self + (headings: current-headings, is-first-slide: is-first-slide),
            new-subsubsubsection-slide-fn,
            none,
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        }
      }
    } else if (
      self.at("auto-offset-for-heading", default: true)
        and utils.is-heading(child)
    ) {
      let fields = child.fields()
      let lbl = fields.remove("label", default: none)
      let _ = fields.remove("body", default: none)
      fields.offset = 0
      let new-heading = if lbl != none {
        [#heading(..fields, child.body)#child.label]
      } else {
        heading(..fields, child.body)
      }
      if new-start {
        slide-parts.push(new-heading)
      } else {
        start-part.push(new-heading)
      }
    } else if utils.is-kind(child, "touying-set-config") {
      slide-parts = utils.trim(slide-parts)
      if slide-parts != () or current-headings != () {
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          self + (headings: current-headings, is-first-slide: is-first-slide),
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }
      // Appendix content
      output-slides.push(
        split-content-into-slides(
          self: utils.merge-dicts(self, child.value.config),
          recaller-map: recaller-map,
          new-start: true,
          child.value.body,
        ),
      )
    } else {
      if utils.is-styled(child) {
        // Split the content into slides recursively for styled content
        let (inner-start-part, slide-content-part) = split-content-into-slides(
          self: self,
          recaller-map: recaller-map,
          new-start: false,
          child.child,
        )
        if slide-content-part != none {
          // The styled node contains slide-breaking content (e.g., headings that
          // trigger new slides).
          if is-first-slide {
            // On the first slide, calling with new-start: false causes content after
            // headings to land in start-part instead of slide-parts, resulting in
            // slides with missing bodies. Re-call with new-start: true to build
            // slides correctly, and flush any accumulated content beforehand.
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                self
                  + (headings: current-headings, is-first-slide: is-first-slide),
                slide-fn,
                slide-parts.sum(default: none),
                recaller-map,
              )
              if slide-content != none { output-slides.push(slide-content) }
            }
            output-slides.push(
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
            // Add the pre-heading content to the current slide, then flush and
            // emit the new slides directly instead of using _delayed-wrapper,
            // which would hide them when show-delayed-wrapper is false.
            if inner-start-part != none {
              let styled-start = utils.reconstruct-styled(child, inner-start-part)
              if new-start {
                slide-parts.push(styled-start)
              } else {
                start-part.push(styled-start)
              }
            }
            // Flush the current slide before adding new slides
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                self
                  + (headings: current-headings, is-first-slide: is-first-slide),
                slide-fn,
                slide-parts.sum(default: none),
                recaller-map,
              )
              if slide-content != none { output-slides.push(slide-content) }
            }
            // Add new slides, wrapped in the same styled node so that the
            // show/set rules cascade to subsequent slides (matching Typst semantics)
            output-slides.push(utils.reconstruct-styled(
              child,
              slide-content-part,
            ))
          }
        } else {
          // No slide-breaking content inside; use the original delayed-wrapper
          // approach so that subslide animations work correctly within the styled scope
          let styled-child = {
            if inner-start-part != none {
              utils.reconstruct-styled(child, inner-start-part)
            }
            _delayed-wrapper(utils.reconstruct-styled(child, none))
          }
          if new-start {
            slide-parts.push(styled-child)
          } else {
            start-part.push(styled-child)
          }
        }
      } else {
        if new-start {
          // Add the child to the current slide
          slide-parts.push(child)
        } else {
          start-part.push(child)
        }
      }
    }
  }

  // Handle the last slide
  slide-parts = utils.trim(slide-parts)
  if slide-parts != () or current-headings != () {
    (
      slide-content,
      recaller-map,
      current-headings,
      slide-parts,
      new-start,
      is-first-slide,
    ) = call-slide-fn-and-reset(
      self + (headings: current-headings, is-first-slide: is-first-slide),
      slide-fn,
      slide-parts.sum(default: none),
      recaller-map,
    )
    if slide-content != none { output-slides.push(slide-content) }
  }

  if is-new-start {
    return output-slides.sum(default: none)
  } else {
    return (start-part.sum(default: none), output-slides.sum(default: none))
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
/// - fn (function): The function that will be called like `(self: none, ..args) => { .. }`.
///
/// - last-subslide (int): The max repetitions for the slide. It is useful for functions like `uncover`, `only` and `alternatives-match` that need to update the max repetitions for the slide.
///
///   It is useful for functions like `uncover`, `only` and `alternatives-match` that need to update the max repetitions for the slide.
///
/// - repetitions (function): The repetitions for the function. It is useful for functions like `alternatives` with `start: auto`.
///
///   It accepts a `(repetitions, args)` and should return a (nextrepetitions, extra-args).
///
/// -> content
#let touying-fn-wrapper(
  fn,
  last-subslide: none,
  repetitions: none,
  ..args,
) = [#metadata((
  kind: "touying-fn-wrapper",
  fn: fn,
  args: args,
  last-subslide: last-subslide,
  repetitions: repetitions,
))<touying-temporary-mark>]

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
/// - fn (function): The function that will be called with an argument `self` like `self => { .. }`.
///
/// -> content
#let touying-slide-wrapper(fn) = [#metadata((
  kind: "touying-slide-wrapper",
  fn: fn,
))<touying-temporary-mark>]


/// Jump to a subslide position, either relatively or absolutely.
///
/// This is the unified core for both `#pause` and `#meanwhile`.
///
/// - When `relative: true` (relative mode): advances the subslide counter by `n`.
///   Positive `n` moves forward; negative `n` moves backward.
///   `n` must be a non-zero integer (zero would be a no-op with no visible effect).
///   `#pause` is equivalent to `#jump(1, relative: true)`.
///
/// - When `relative: false` (absolute mode, default): reveals all currently hidden
///   content and jumps to absolute subslide `n`.
///   `#meanwhile` is equivalent to `#jump(1)`.
///
/// Example:
///
/// ```typst
/// A #jump(1, relative: true) B   // same as A #pause B
/// A #jump(2, relative: true) C   // skip an extra subslide before C
/// A #pause B #jump(1) C          // C is always visible (same as #meanwhile)
/// A #pause B #jump(3) D          // D visible from subslide 3 onward
/// // A #pause B #pause C — normally C appears at subslide 3;
/// // adding #jump(-1, relative: true) before D makes D appear at subslide 2 (same as B):
/// A #pause B #pause C #jump(-1, relative: true) D
/// ```
///
/// - n (int): When `relative: true`, the number of subslides to advance (non-zero integer).
///   When `relative: false`, the absolute target subslide number (positive integer >= 1).
///
/// - relative (bool): If `true`, `n` is a relative offset from the current subslide counter.
///   If `false` (default), `n` is an absolute target subslide number.
///
/// -> content
#let jump(n, relative: false) = {
  if relative {
    assert(
      type(n) == int and n != 0,
      message: "jump: n must be a non-zero integer when relative: true, got "
        + repr(n),
    )
  } else {
    assert(
      type(n) == int and n >= 1,
      message: "jump: n must be a positive integer when relative: false, got "
        + repr(n),
    )
  }
  [#metadata((
    kind: "touying-jump",
    n: n,
    relative: relative,
  ))<touying-temporary-mark>]
}


/// Uncover content in the next subslide. Equivalent to `#jump(1, relative: true)`.
#let pause = jump(1, relative: true)


/// Display content simultaneously with the current subslide. Equivalent to `#jump(1)`.
#let meanwhile = jump(1)


/// Take effect in some subslides.
///
/// Example: `#effect(text.with(fill: red), "2-")[Something]` will display `[Something]` if the current slide is 2 or later.
///
/// You can also add an abbreviation by using `#let effect-red = effect.with(text.with(fill: red))` for your own effects.
///
/// - fn (function): The function that will be called in the subslide.
///      Or you can use a method function like `(self: none) => { .. }`.
///
/// - visible-subslides (int, array, string): `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read #link("https://polylux.dev/book/dynamic/complex.html", "polylux book")
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - cont (content): The content to display when the content is visible in the subslide.
///
/// - is-method (boolean): A boolean indicating whether the function is a method function. Default is `false`.
#let effect(fn, visible-subslides, cont, is-method: false) = {
  touying-fn-wrapper(
    utils.effect,
    last-subslide: utils.last-required-subslide(visible-subslides),
    fn,
    visible-subslides,
    is-method: is-method,
    cont,
  )
}


/// Uncover content in some subslides. Reserved space when hidden (like `#hide()`).
///
/// Example: `uncover("2-")[abc]` will display `[abc]` if the current slide is 2 or later
///
/// - visible-subslides (int, array, string): `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read #link("https://polylux.dev/book/dynamic/complex.html", "polylux book")
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - uncover-cont (content): The content to display when the content is visible in the subslide.
///
/// - cover-fn (function | auto): An optional cover function to use instead of the default cover method from the theme. Useful when using `uncover` inside external package integrations (e.g. `fletcher.hide` for fletcher diagrams).
///
/// -> content
#let uncover(visible-subslides, uncover-cont, cover-fn: auto) = {
  touying-fn-wrapper(
    utils.uncover,
    last-subslide: utils.last-required-subslide(visible-subslides),
    visible-subslides,
    uncover-cont,
    cover-fn: cover-fn,
  )
}


/// Display content in some subslides only.
/// Don't reserve space when hidden, content is completely not existing there.
///
/// - visible-subslides (int, array, string): `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read #link("https://polylux.dev/book/dynamic/complex.html", "polylux book")
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - only-cont (content): The content to display when the content is visible in the subslide.
///
/// -> content
#let only(visible-subslides, only-cont) = {
  touying-fn-wrapper(
    utils.only,
    last-subslide: utils.last-required-subslide(visible-subslides),
    visible-subslides,
    only-cont,
  )
}


/// Display content only in handout mode.
/// Don't reserve space when hidden, content is completely not existing there.
///
/// Example:
///
/// ```typst
/// #handout-only[This content is only visible in handout mode.]
/// ```
///
/// - cont (content): The content to display in handout mode.
///
/// -> content
#let handout-only(cont) = {
  touying-fn-wrapper(
    utils.handout-only,
    cont,
  )
}


/// `#alternatives` has a couple of "cousins" that might be more convenient in some situations. The first one is `#alternatives-match` that has a name inspired by match-statements in many functional programming languages. The idea is that you give it a dictionary mapping from subslides to content:
///
/// Example:
///
/// ```typst
/// #alternatives-match((
///   "1, 3-5": [this text has the majority],
///   "2, 6": [this is shown less often]
/// ))
/// ```
///
/// - subslides-contents (dictionary): A dictionary mapping from subslides to content.
///
/// - position (string): The position of the content. Default is `bottom + left`.
///
/// - stretch (boolean): A boolean indicating whether the content should be stretched to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-match(
  subslides-contents,
  position: bottom + left,
  stretch: false,
) = {
  touying-fn-wrapper(
    utils.alternatives-match,
    last-subslide: calc.max(..subslides-contents
      .pairs()
      .map(kv => utils.last-required-subslide(kv.at(0)))),
    subslides-contents,
    position: position,
    stretch: false,
  )
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// - start (int): The starting subslide number. Default is `auto`.
///
/// - repeat-last (boolean): A boolean indicating whether the last subslide should be repeated. Default is `true`.
///
/// - position (string): The position of the content. Default is `bottom + left`.
///
/// - stretch (boolean): A boolean indicating whether the content should be stretched to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives(
  start: auto,
  repeat-last: true,
  position: bottom + left,
  stretch: false,
  ..args,
) = {
  let extra = if start == auto {
    (
      last-subslide: repetitions => (
        repetitions + args.pos().len() - 1,
        (start: repetitions),
      ),
    )
  } else {
    (
      last-subslide: start + args.pos().len() - 1,
    )
  }
  touying-fn-wrapper(
    utils.alternatives,
    start: start,
    repeat-last: repeat-last,
    position: position,
    stretch: stretch,
    ..extra,
    ..args,
  )
}


/// You can have very fine-grained control over the content depending on the current subslide by using `#alternatives-fn`. It accepts a function (hence the name) that maps the current subslide index to some content.
///
/// Example: `#alternatives-fn(start: 2, count: 7, subslide => { numbering("(i)", subslide) })`
///
/// - start (int): The starting subslide number. Default is `1`.
///
/// - end (none, int): The ending subslide number. Default is `none`.
///
/// - count (none, int): The number of subslides. Default is `none`.
///
/// - position (string): The position of the content. Default is `bottom + left`.
///
/// - stretch (boolean): A boolean indicating whether the content should be stretched to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-fn(
  start: 1,
  end: none,
  count: none,
  position: bottom + left,
  stretch: false,
  ..kwargs,
  fn,
) = {
  let end = if end == none {
    if count == none {
      panic("You must specify either end or count.")
    } else {
      start + count
    }
  } else {
    end
  }
  touying-fn-wrapper(
    utils.alternatives-fn,
    last-subslide: end,
    start: start,
    end: end,
    count: count,
    position: position,
    stretch: stretch,
    ..kwargs,
    fn,
  )
}


/// You can use this function if you want to have one piece of content that changes only slightly depending of what "case" of subslides you are in.
///
/// Example:
///
/// ```typst
/// #alternatives-cases(("1, 3", "2"), case => [
///   #set text(fill: teal) if case == 1
///   Some text
/// ])
/// ```
///
/// - cases (array): An array of strings that specify the subslides for each case.
///
/// - fn (function): A function that maps the case to content. The argument `case` is the index of the cases array you input.
///
/// - position (string): The position of the content. Default is `bottom + left`.
///
/// - stretch (boolean): A boolean indicating whether the content should be stretched to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-cases(
  cases,
  fn,
  position: bottom + left,
  stretch: false,
  ..kwargs,
) = {
  touying-fn-wrapper(
    utils.alternatives-cases,
    last-subslide: calc.max(..cases.map(utils.last-required-subslide)),
    cases,
    fn,
    position: position,
    stretch: stretch,
    ..kwargs,
  )
}


/// Display list, enum, or terms items one by one with animation.
///
/// Each item is revealed on a successive subslide. Items before `start` appear immediately;
/// from subslide `start`, one additional item is revealed per subslide.
///
/// == Example
///
/// ```typst
/// #item-by-item(start: 2)[
///   - first
///   - second
///   - third
/// ]
/// ```
///
/// - start (int): The subslide on which the first item appears. Default is `1`.
///
/// - cont (content): The content containing a list, enum, or terms element.
///
/// -> content
#let item-by-item(start: 1, cont) = {
  let num-items = if utils.is-sequence(cont) {
    cont
      .children
      .filter(c => (
        type(c) == content and c.func() in (list.item, enum.item, terms.item)
      ))
      .len()
  } else if cont.func() in (list, enum, terms) {
    cont.children.len()
  } else {
    1
  }
  touying-fn-wrapper(
    utils.item-by-item,
    last-subslide: start + num-items - 1,
    start,
    cont,
  )
}


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Multiple calls on the same slide are combined (accumulated), so all notes are shown together.
/// You can also use `#pause` inside the note body to reveal note content progressively.
///
/// == Example
///
/// ```typ
/// #speaker-note[This is a speaker note]
/// ```
///
/// - mode (string): The mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - setting (function): A function that takes the note as input and returns a processed note.
///
/// - subslide (none, auto, int, array, string): Restricts the note to specific subslides, similar to `only`.
///   - `auto` (default): automatically determined from the current pause position. A note placed after `#pause` will automatically appear only from that subslide onward.
///   - `none`: shown on all subslides regardless of position.
///   - int, array, or string: shown only on the specified subslides.
///
/// - note (content): The content of the speaker note. May contain `#pause` to reveal parts progressively.
///
/// -> content
#let speaker-note(
  mode: "typ",
  setting: it => it,
  subslide: auto,
  note,
) = [#metadata((
  kind: "touying-speaker-note",
  mode: mode,
  setting: setting,
  subslide: subslide,
  note: note,
))<touying-temporary-mark>]


/// Alert is a way to display a message to the audience. It can be used to draw attention to important information or to provide instructions.
///
/// -> content
#let alert(body) = touying-fn-wrapper(utils.alert, body)


/// Touying also provides a unique and highly useful feature—math equation animations, allowing you to conveniently use pause and meanwhile within math equations.
///
/// Example:
///
/// ```typst
/// #touying-equation(`
///   f(x) &= pause x^2 + 2x + 1  \
///         &= pause (x + 1)^2  \
/// `)
/// ```
///
/// - block (boolean): A boolean indicating whether the equation is a block. Default is `true`.
///
/// - numbering (none, string): The numbering of the equation. Default is `none`.
///
/// - supplement (string): The supplement of the equation. Default is `auto`.
///
/// - scope (dictionary): The scope when we use `eval()` function to evaluate the equation.
///
/// - body (string, content, function): The content of the equation. It should be a string, a raw text, or a function that receives `self` as an argument and returns a string.
///
/// -> content
#let touying-equation(
  block: true,
  numbering: none,
  supplement: auto,
  scope: (:),
  body,
) = [#metadata((
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
))<touying-temporary-mark>]


/// Touying can integrate with `mitex` to display math equations.
/// You can use `#touying-mitex` to display math equations with pause and meanwhile.
///
/// Example:
///
/// ```typst
/// #touying-mitex(mitex, `
///   f(x) &= \pause x^2 + 2x + 1  \\
///       &= \pause (x + 1)^2  \\
/// `)
/// ```
///
/// - mitex (function): The mitex function. You can import it by code like `#import "@preview/mitex:0.2.3": mitex`.
///
/// - block (boolean): A boolean indicating whether the equation is a block. Default is `true`.
///
/// - numbering (none, string): The numbering of the equation. Default is `none`.
///
/// - supplement (string): The supplement of the equation. Default is `auto`.
///
/// - body (string, content, function): The content of the equation. It should be a string, a raw text, or a function that receives `self` as an argument and returns a string.
///
/// -> content
#let touying-mitex(
  block: true,
  numbering: none,
  supplement: auto,
  mitex,
  body,
) = [#metadata((
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
))<touying-temporary-mark>]


/// Touying raw function for creating animated code blocks.
///
/// A line is treated as a `pause` or `meanwhile` marker when its only
/// meaningful characters (letters, digits, CJK) exactly spell "pause" or
/// "meanwhile". For example, `// pause`, `# pause`, and `#pause` are all
/// valid markers, while `pause = 1` or `def pause():` are not.
///
/// Example:
///
/// ```typst
/// #touying-raw(```rust
///   fn main() {
///       // pause
///       println!("Hello, world!");
///   }
/// ```)
/// ```
///
/// - block (boolean): Whether the raw block is a block element. Default is `true`.
///
/// - lang (none, string): The language for syntax highlighting. When `none`, the language is inferred from the raw block body if possible. Default is `none`.
///
/// - fill-empty-lines (boolean): Whether to replace hidden lines with empty lines to preserve the layout of visible lines. Default is `true`.
///
/// - simple (boolean): When `true`, use `#pause;` and `#meanwhile;` as direct split markers (similar to how `touying-mitex` uses `\pause`). Default is `false`.
///
/// - body (string, content, function): The raw code content. Can be a raw block, a string, or a function receiving `self` as an argument.
///
/// -> content
#let touying-raw(
  block: true,
  lang: none,
  fill-empty-lines: true,
  simple: false,
  body,
) = [#metadata((
  kind: "touying-raw",
  block: if type(body) == content and body.has("block") { body.block } else {
    block
  },
  lang: if lang == none and type(body) == content and body.has("lang") {
    body.lang
  } else {
    lang
  },
  fill-empty-lines: fill-empty-lines,
  simple: simple,
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
))<touying-temporary-mark>]


/// Touying reducer is a powerful tool to provide more powerful animation effects for other packages or functions.
///
/// For example, you can adds `pause` and `meanwhile` animations to cetz and fletcher packages.
///
/// Cetz: `#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))`
///
/// Fletcher: `#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)`
///
/// - reduce (function): The reduce function that will be called. It is usually a function that receives an array of content and returns the content it painted. Just like the `cetz.canvas` or `fletcher.diagram` function.
///
/// - cover (function): The cover function that will be called when some content is hidden. It is usually a function that receives the argument of the content that will be hidden. Just like the `cetz.draw.hide` or `fletcher.hide` function.
///
/// - args (array): The arguments of the reducer function.
///
/// -> content
#let touying-reducer(
  reduce: arr => arr.sum(),
  cover: arr => none,
  ..args,
) = [#metadata((
  kind: "touying-reducer",
  reduce: reduce,
  cover: cover,
  kwargs: args.named(),
  args: args.pos(),
))<touying-temporary-mark>]


/// Parse touying equation content and extract animation repetitions
///
/// Processes equation content with pause and meanwhile markers, returning
/// the parsed equation and the total number of repetitions needed.
///
/// - self (dictionary): The presentation context
/// - need-cover (boolean): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - eqt-metadata (content): The equation metadata to parse
///
/// -> (array, int)
#let _parse-touying-equation(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  eqt-metadata,
) = {
  let eqt = eqt-metadata.value
  let parsed-results = ()
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
  let hidden-parts = ()
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
      // clear the hidden-parts when encounter #meanwhile
      if hidden-parts.len() != 0 {
        result.push("cover(" + hidden-parts.sum() + ")")
        hidden-parts = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the hidden-parts when encounter linebreak or parbreak
      if hidden-parts.len() != 0 {
        result.push("cover(" + hidden-parts.sum() + ")")
        hidden-parts = ()
      }
      result.push(child)
    } else {
      if repetitions <= index or not need-cover {
        result.push(child)
      } else {
        hidden-parts.push(child)
      }
    }
  }
  // clear the hidden-parts when end
  if hidden-parts.len() != 0 {
    result.push("cover(" + hidden-parts.sum() + ")")
    hidden-parts = ()
  }
  let equation = math.equation(
    block: eqt.block,
    numbering: eqt.numbering,
    supplement: eqt.supplement,
    eval(
      "$" + result.sum(default: "") + "$",
      scope: eqt.scope
        + (
          cover: (..args) => {
            let cover = eqt.scope.at("cover", default: cover)
            if args.pos().len() != 0 {
              cover(args.pos().first())
            }
          },
        ),
    ),
  )
  if (
    eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark>
  ) {
    equation = [#equation#eqt-metadata.label]
  }
  parsed-results.push(equation)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Parse touying mitex content and extract animation repetitions
///
/// Similar to _parse-touying-equation but for MiTeX equations.
///
/// - self (dictionary): The presentation context
/// - need-cover (boolean): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - eqt-metadata (content): The mitex metadata to parse
///
/// -> (array, int)
#let _parse-touying-mitex(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  eqt-metadata,
) = {
  let eqt = eqt-metadata.value
  let parsed-results = ()
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
  let hidden-parts = ()
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
      // clear the hidden-parts when encounter #meanwhile
      if hidden-parts.len() != 0 {
        result.push("\\phantom{" + hidden-parts.sum() + "}")
        hidden-parts = ()
      }
      // then reset the repetitions
      max-repetitions = calc.max(max-repetitions, repetitions)
      repetitions = 1
    } else if child == "\\\n" or child == "&" {
      // clear the hidden-parts when encounter linebreak or parbreak
      if hidden-parts.len() != 0 {
        result.push("\\phantom{" + hidden-parts.sum() + "}")
        hidden-parts = ()
      }
      result.push(child)
    } else {
      if repetitions <= index or not need-cover {
        result.push(child)
      } else {
        hidden-parts.push(child)
      }
    }
  }
  // clear the hidden-parts when end
  if hidden-parts.len() != 0 {
    result.push("\\phantom{" + hidden-parts.sum() + "}")
    hidden-parts = ()
  }
  let equation = (eqt.mitex)(
    block: eqt.block,
    numbering: eqt.numbering,
    supplement: eqt.supplement,
    result.sum(default: ""),
  )
  if (
    eqt-metadata.has("label") and eqt-metadata.label != <touying-temporary-mark>
  ) {
    equation = [#equation#eqt-metadata.label]
  }
  parsed-results.push(equation)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Parse touying raw content and extract animation repetitions
///
/// Processes raw code block content with pause and meanwhile markers, returning
/// the rendered raw block and the total number of repetitions needed.
///
/// A line acts as a pause or meanwhile marker when every meaningful character
/// on that line (letters, digits, CJK) spells exactly "pause" or "meanwhile".
/// This allows markers like `// pause`, `# pause`, or `#pause` while ignoring
/// lines like `pause = 1` or `def pause():`.
///
/// - self (dictionary): The presentation context
/// - need-cover (boolean): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - raw-metadata (content): The raw metadata to parse
///
/// -> (array, int)
#let _parse-touying-raw(
  self: none,
  need-cover: true,
  base: 1,
  index: 1,
  raw-metadata,
) = {
  let raw-data = raw-metadata.value
  // Pattern matching meaningful characters: letters, digits, and CJK Unified Ideographs
  let meaningful-chars-pattern = regex("[a-zA-Z0-9\u{4E00}-\u{9FFF}]+")
  let parsed-results = ()
  let repetitions = base
  let max-repetitions = repetitions
  let it = raw-data.body
  if type(it) == function {
    it = it(self)
  }
  assert(type(it) == str, message: "Unsupported type: " + str(type(it)))

  let result-text = ""

  if raw-data.simple {
    // Simple mode: split directly on #pause; and #meanwhile; markers.
    // Markers may appear anywhere in the text (including inline), so we work
    // directly with text segments rather than splitting into lines first —
    // that would introduce spurious newlines when markers are inline.
    let text-parts = ()
    let parts = it
      .split(regex("#meanwhile;"))
      .intersperse("touying-meanwhile")
      .map(s => s.split(regex("#pause;")).intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      } else {
        if repetitions <= index or not need-cover {
          text-parts.push(part)
        } else if raw-data.fill-empty-lines {
          // Preserve line structure: keep newlines, erase all other characters
          text-parts.push(part.replace(regex("[^\n]+"), ""))
        }
      }
    }
    result-text = text-parts.join("")
  } else {
    // Normal mode: process line by line.
    // A line is a pause/meanwhile marker when its only meaningful characters
    // (letters, digits, CJK Unified Ideographs) spell exactly "pause" or "meanwhile"
    let result-lines = ()
    let lines = it.split("\n")
    for line in lines {
      let meaningful = line
        .matches(meaningful-chars-pattern)
        .map(m => m.text)
        .join("")
      if meaningful == "pause" {
        repetitions += 1
      } else if meaningful == "meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      } else if repetitions <= index or not need-cover {
        result-lines.push(line)
      } else if raw-data.fill-empty-lines {
        result-lines.push("")
      }
    }
    result-text = result-lines.join("\n")
  }
  let raw-block = raw(result-text, lang: raw-data.lang, block: raw-data.block)
  if (
    raw-metadata.has("label") and raw-metadata.label != <touying-temporary-mark>
  ) {
    raw-block = [#raw-block#raw-metadata.label]
  }
  parsed-results.push(raw-block)
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}

/// Parse touying reducer content and extract animation repetitions
///
/// Processes reducer content (used for external packages like CeTZ, Fletcher)
/// with pause and meanwhile markers.
///
/// - self (dictionary): The presentation context
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - reducer (dictionary): The reducer configuration
///
/// -> (array, int)
#let _parse-touying-reducer(self: none, base: 1, index: 1, reducer) = {
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // get cover function from self
  let cover = reducer.cover
  // parse the content
  let result = ()
  let hidden-parts = ()
  for child in reducer.args.flatten() {
    if (
      type(child) == content
        and child.func() == metadata
        and type(child.value) == dictionary
    ) {
      let kind = child.value.at("kind", default: none)
      if kind == "touying-jump" {
        if child.value.relative {
          repetitions += child.value.n
          // Track the peak repetitions so that a subsequent negative jump doesn't
          // cause the slide count to be underestimated
          max-repetitions = calc.max(max-repetitions, repetitions)
          // If we jumped back into the visible zone, flush hidden-parts in order
          // (so they appear before subsequent visible content, not after it)
          if hidden-parts.len() != 0 and repetitions <= index {
            let r = cover(hidden-parts)
            if type(r) == array {
              result += r
            } else {
              result.push(r)
            }
            hidden-parts = ()
          }
        } else {
          // absolute jump: clear hidden-parts and jump to target subslide
          if hidden-parts.len() != 0 {
            let r = cover(hidden-parts)
            if type(r) == array {
              result += r
            } else {
              result.push(r)
            }
          }
          hidden-parts = ()
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = child.value.n
        }
      } else {
        if repetitions <= index {
          result.push(child)
        } else {
          hidden-parts.push(child)
        }
      }
    } else {
      if repetitions <= index {
        result.push(child)
      } else {
        hidden-parts.push(child)
      }
    }
  }
  // clear the hidden-parts when end
  if hidden-parts.len() != 0 {
    let r = cover(hidden-parts)
    if type(r) == array {
      result += r
    } else {
      result.push(r)
    }
  }
  hidden-parts = ()
  parsed-results.push(
    (reducer.reduce)(
      ..reducer.kwargs,
      result,
    ),
  )
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions)
}






///
/// This is the core parsing function that handles all types of content including
/// animations, pauses, meanwhile markers, and various content types. It recursively
/// processes content and determines what should be visible on each subslide.
///
/// - self (dictionary): The presentation context
/// - need-cover (boolean): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - show-delayed-wrapper (boolean): Whether to show delayed wrapper content
/// - bodies (content): The content elements to parse
///
/// -> (array, int, int, int)
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
      "repeat" in self
        and "subslide" in self
        and "label-only-on-last-subslide" in self
        and func in self.label-only-on-last-subslide
        and self.subslide != self.repeat
    )
  }
  // Helper function to parse child content and reconstruct
  // Returns a 5-tuple:
  //   - reconstructed-content: the reconstructed container content
  //   - max-repetitions: maximum repetitions found inside the content
  //   - next-last-subslide: maximum last-subslide of any fn-wrappers found (0 if none)
  //   - final-repetitions: repetitions count after processing all inner content
  //   - force-to-result: true when fn-wrappers were found inside a pause zone and the
  //       returned `reconstructed-content` was produced with proper inner covering;
  //       the caller MUST push this content directly to `result` (not `hidden-parts`).
  let parse-and-reconstruct(
    self,
    child,
    body-field,
    repetitions,
    index,
    need-cover,
    reconstruct-fn,
  ) = {
    let body-content = if body-field == "body-or-none" {
      child.at("body", default: none)
    } else {
      child.at(body-field)
    }
    let (
      conts,
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
    ) = _parse-content-into-results-and-repetitions(
      self: self,
      need-cover: repetitions <= index,
      base: repetitions,
      index: index,
      body-content,
    )
    let cont = conts.first()
    // Two-pass: if fn-wrappers are present inside a pause zone, re-run the inner parse
    // with the outer need-cover so that fn-wrappers handle their own visibility and
    // non-fn-wrapper content is properly covered by the inner mechanism.
    //
    // `next-last-subslide > 0` indicates that at least one touying-fn-wrapper was found
    // inside the container (fn-wrappers set last-subslide to the max subslide they cover,
    // which is always >= 1 -- see uncover/only/alternatives implementations).
    let would-be-hidden = not (
      calc.min(repetitions, final-repetitions) <= index or not need-cover
    )
    if would-be-hidden and next-last-subslide > 0 {
      let (
        conts2,
        inner-max-repetitions2,
        _,
        _,
      ) = _parse-content-into-results-and-repetitions(
        self: self,
        need-cover: need-cover,
        base: repetitions,
        index: index,
        body-content,
      )
      let cont2 = conts2.first()
      return (
        reconstruct-fn(child, cont2),
        inner-max-repetitions2,
        next-last-subslide,
        final-repetitions,
        true,
      )
    }
    return (
      reconstruct-fn(child, cont),
      inner-max-repetitions,
      next-last-subslide,
      final-repetitions,
      false,
    )
  }
  // Content function sets for different handling categories
  let list-item-functions = (list.item, enum.item, align, link)
  let table-like-functions = (table, grid, stack)
  let reconstructable-functions = (
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
  )
  let bodies = bodies.pos()
  let parsed-results = ()
  // repetitions
  let repetitions = base
  let max-repetitions = repetitions
  // last-subslide by touying-fn-wrapper
  let last-subslide = 0
  // get cover function from self
  let cover = self.methods.cover.with(self: self)

  // Main parsing loop: process each content item and handle animations
  for item in bodies {
    let it = item
    // Special handling for table/grid cells containing pause/meanwhile markers
    // This is a workaround for syntax like #table([A], pause, [B])
    if type(it) == content and it.func() in (table.cell, grid.cell) {
      if (
        type(it.body) == content
          and it.body.func() == metadata
          and type(it.body.value) == dictionary
      ) {
        let kind = it.body.value.at("kind", default: none)
        if kind == "touying-jump" {
          if it.body.value.relative {
            repetitions += it.body.value.n
          } else {
            // absolute jump
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = it.body.value.n
          }
          continue
        }
      }
    }
    // if it is a function, then call it with self
    if type(it) == function {
      // subslide index
      it = it(self)
    }
    // parse the content
    let result = ()
    let hidden-parts = ()

    // Flatten sequences and handle each child element
    let children = if utils.is-sequence(it) {
      it.children
    } else {
      (it,)
    }

    // Process each child element for animation markers and content types
    for child in children {
      if (
        type(child) == content
          and child.func() == metadata
          and type(child.value) == dictionary
      ) {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-jump" {
          if child.value.relative {
            repetitions += child.value.n // relative: advance by n (pause = jump(1, relative: true))
            // Track the peak repetitions so that a subsequent negative jump doesn't
            // cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
            // If we jumped back into the visible zone, flush hidden-parts in order
            // (so they appear before subsequent visible content, not after it)
            if hidden-parts.len() != 0 and repetitions <= index {
              result.push(cover(hidden-parts.sum()))
              hidden-parts = ()
            }
          } else {
            // absolute: reveal all hidden content then jump to target subslide
            if hidden-parts.len() != 0 {
              result.push(cover(hidden-parts.sum()))
              hidden-parts = ()
            }
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = child.value.n
          }
        } else if kind == "touying-equation" {
          // Handle animated equations with pause/meanwhile markers
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
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-mitex" {
          // Handle animated MiTeX equations with pause/meanwhile markers
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
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-raw" {
          // Handle animated raw code blocks with pause/meanwhile markers
          let (conts, nextrepetitions) = _parse-touying-raw(
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
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-reducer" {
          // Handle external package reducers (CeTZ, Fletcher) with animations
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
            hidden-parts.push(cont)
          }
          repetitions = nextrepetitions
        } else if kind == "touying-fn-wrapper" {
          // Handle function wrappers (uncover, only, alternatives, etc.)
          // These always escape the pause zone: they handle their own subslide
          // visibility internally, so they must never be pushed to hidden-parts.
          let nextrepetitions = repetitions
          let extra-args = (:)
          if child.value.last-subslide != none {
            if type(child.value.last-subslide) == function {
              let (callback-last-subslide, callback-extra-args) = (
                child.value.last-subslide
              )(
                repetitions,
              )
              // Use calc.max to prevent callback from decreasing last-subslide
              // (mirrors the non-callback else-branch)
              last-subslide = calc.max(last-subslide, callback-last-subslide)
              extra-args = callback-extra-args
            } else {
              last-subslide = calc.max(last-subslide, child.value.last-subslide)
            }
          }
          result.push((child.value.fn)(
            self: self,
            ..child.value.args,
            ..extra-args,
          ))
          repetitions = nextrepetitions
        } else if kind == "touying-speaker-note" {
          // Handle speaker notes with optional #pause markers inside the note body.
          // Speaker notes always escape the pause zone (like fn-wrappers): they emit
          // only side effects (state updates, pdfpc metadata) and produce no visible content.
          let outer-rep = repetitions // pause count at this position in the outer slide

          // Inner subslide index: how far into the note's own pauses we advance.
          // If the outer slide is at repetition outer-rep and we're rendering subslide index,
          // the note's inner subslide is (index - outer-rep + 1), clamped to >= 1.
          let inner-index = calc.max(1, index - outer-rep + 1)

          // Use _parse-content-into-results-and-repetitions to handle nested pauses
          // (e.g. #pause inside a list item). Override cover to omit hidden content
          // entirely (notes don't need visual placeholders for covered text).
          let note-self = utils.merge-dicts(
            self,
            (methods: (cover: (self: none, body) => [])),
          )
          let (
            note-conts,
            note-max-rep,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: note-self,
            need-cover: true,
            base: 1,
            index: inner-index,
            child.value.note,
          )
          let note-cont = note-conts.first()

          // Account for subslides needed by inner pauses in the note body.
          max-repetitions = calc.max(
            max-repetitions,
            outer-rep + note-max-rep - 1,
          )

          // Determine the effective outer subslide filter.
          let effective-subslide = if child.value.subslide == auto {
            str(outer-rep) + "-"
          } else {
            child.value.subslide
          }

          // Always push to result (never hidden-parts): produces no visible content.
          result.push(utils.speaker-note(
            self: self,
            mode: child.value.mode,
            setting: child.value.setting,
            subslide: effective-subslide,
            note-cont,
          ))
        } else if kind == "touying-delayed-wrapper" {
          if show-delayed-wrapper {
            if repetitions <= index or not need-cover {
              result.push(child.value.body)
            } else {
              hidden-parts.push(child.value.body)
            }
          }
        } else {
          if repetitions <= index or not need-cover {
            result.push(child)
          } else {
            hidden-parts.push(child)
          }
        }
      } else if child == linebreak() or child == parbreak() {
        // clear the hidden-parts when encounter linebreak or parbreak
        if hidden-parts.len() != 0 {
          result.push(cover(hidden-parts.sum()))
          hidden-parts = ()
        }
        result.push(child)
      } else if utils.is-sequence(child) {
        // handle the sequence
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child,
        )
        // Two-pass: if fn-wrappers are present and sequence would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and next-last-subslide > 0
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            index: index,
            child,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the sequence
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and next-last-subslide > 0
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(cont)
        } else {
          hidden-parts.push(cont)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if utils.is-styled(child) {
        // handle styled
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "child",
          repetitions,
          index,
          need-cover,
          (child, cont) => utils.typst-builtin-styled(cont, child.styles),
        )
        // Propagate meanwhile effect from inside the styled element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if (
        type(child) == content and child.func() in list-item-functions
      ) {
        // handle the list item
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "body",
          repetitions,
          index,
          need-cover,
          (child, cont) => utils.reconstruct(
            child,
            labeled: labeled(child.func()),
            cont,
          ),
        )
        // Propagate meanwhile effect from inside the list item
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if (
        type(child) == content and child.func() in table-like-functions
      ) {
        // handle the table-like
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          ..child.children,
        )
        // Two-pass: if fn-wrappers are present and container would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (conts, inner-max-repetitions) = if (
          would-be-hidden and next-last-subslide > 0
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            index: index,
            ..child.children,
          )
          (conts2, inner-max-repetitions2)
        } else {
          (conts, inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the table/grid/stack
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        let reconstructed-table = utils.reconstruct-table-like(
          child,
          labeled: labeled(child.func()),
          conts,
        )
        if (
          would-be-hidden and next-last-subslide > 0
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed-table)
        } else {
          hidden-parts.push(reconstructed-table)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if (
        type(child) == content and child.func() in reconstructable-functions
      ) {
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "body-or-none",
          repetitions,
          index,
          need-cover,
          (child, cont) => utils.reconstruct(
            named: true,
            labeled: labeled(child.func()),
            child,
            cont,
          ),
        )
        // Propagate meanwhile effect from inside the reconstructable element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == terms.item {
        // handle the terms item
        let (
          reconstructed,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
          force-to-result,
        ) = parse-and-reconstruct(
          self,
          child,
          "description",
          repetitions,
          index,
          need-cover,
          (child, cont) => terms.item(child.term, cont),
        )
        // Propagate meanwhile effect from inside the terms item
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(reconstructed)
        } else {
          hidden-parts.push(reconstructed)
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == columns {
        // handle columns
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let args = if child.has("gutter") {
          (gutter: child.gutter)
        }
        let count = if child.has("count") {
          child.count
        } else {
          2
        }
        // Two-pass: if fn-wrappers are present and columns would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and next-last-subslide > 0
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the columns
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and next-last-subslide > 0
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(columns(count, ..args, cont))
        } else {
          hidden-parts.push(columns(count, ..args, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == place {
        // handle place
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let fields = child.fields()
        let _ = fields.remove("alignment", default: none)
        let _ = fields.remove("body", default: none)
        let alignment = if child.has("alignment") {
          child.alignment
        } else {
          start
        }
        // Two-pass: if fn-wrappers are present and place would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and next-last-subslide > 0
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the place
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and next-last-subslide > 0
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(place(alignment, ..fields, cont))
        } else {
          hidden-parts.push(place(alignment, ..fields, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else if type(child) == content and child.func() == rotate {
        // handle rotate
        let (
          conts,
          inner-max-repetitions,
          next-last-subslide,
          final-repetitions,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          index: index,
          child.body,
        )
        let fields = child.fields()
        let _ = fields.remove("angle", default: none)
        let _ = fields.remove("body", default: none)
        let angle = if child.has("angle") {
          child.angle
        } else {
          0deg
        }
        // Two-pass: if fn-wrappers are present and rotate would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and next-last-subslide > 0
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            index: index,
            child.body,
          )
          (conts2.first(), inner-max-repetitions2)
        } else {
          (conts.first(), inner-max-repetitions)
        }
        // Propagate meanwhile effect from inside the rotate
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover(hidden-parts.sum()))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and next-last-subslide > 0
            or calc.min(repetitions, final-repetitions) <= index
            or not need-cover
        ) {
          result.push(rotate(angle, ..fields, cont))
        } else {
          hidden-parts.push(rotate(angle, ..fields, cont))
        }
        repetitions = final-repetitions
        max-repetitions = calc.max(max-repetitions, inner-max-repetitions)
        last-subslide = calc.max(last-subslide, next-last-subslide)
      } else {
        if repetitions <= index or not need-cover {
          result.push(child)
        } else {
          hidden-parts.push(child)
        }
      }
    }
    // clear the hidden-parts when end
    if hidden-parts.len() != 0 {
      result.push(cover(hidden-parts.sum()))
      hidden-parts = ()
    }
    parsed-results.push(result.sum(default: []))
  }
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions, last-subslide, repetitions)
}

// get negative pad for header and footer
#let _get-negative-pad(self) = {
  let margin = self.page.margin
  if (
    type(margin) != dictionary
      and type(margin) != length
      and type(margin) != relative
      and type(margin) != ratio
  ) {
    return it => it
  }

  let cell = block.with(
    width: 100%,
    height: 100%,
    above: 0pt,
    below: 0pt,
    breakable: false,
  )

  return it => context {
    let page-width = page.width
    let to-abs(val) = {
      if type(val) == ratio {
        val * page-width
      } else if type(val) == relative {
        val.ratio * page-width + val.length
      } else {
        val
      }
    }

    if type(margin) == length {
      pad(x: -margin, cell(it))
    } else if (
      type(margin) == ratio or type(margin) == relative
    ) {
      pad(x: -to-abs(margin), cell(it))
    } else {
      let pad-args = (:)
      if "x" in margin {
        pad-args.x = -to-abs(margin.x)
      }
      if "left" in margin {
        pad-args.left = -to-abs(margin.left)
      }
      if "right" in margin {
        pad-args.right = -to-abs(margin.right)
      }
      if "rest" in margin {
        pad-args.x = -to-abs(margin.rest)
      }
      pad(..pad-args, cell(it))
    }
  }
}

// get bottom pad for footer
#let _get-bottom-pad(self) = {
  let cell = block.with(
    width: 100%,
    height: 100%,
    above: 0pt,
    below: 0pt,
    breakable: false,
  )
  let (_, page-height) = utils.get-page-dimensions(self)
  it => pad(bottom: page-height, cell(it))
}

// Scale content down to new-height, preserving aspect ratio.
// Returns a box of dimensions (width * new-height / height) × new-height
// containing the original content scaled proportionally.
#let _miniaturize(width, height, new-height, outer-style: (), content) = {
  let factor = new-height / height * 100%
  let new-width = width * factor
  box(
    stroke: black,
    width: new-width,
    height: new-height,
    ..outer-style,
    scale(
      x: factor,
      y: factor,
      reflow: true,
      box(width: width, height: height, align(left + top, content)),
    ),
  )
}

// get page extra args for show-notes-on-second-screen
#let _get-page-extra-args(self) = {
  if self.show-notes-on-second-screen in (bottom, right) {
    let margin = self.page.margin
    let (page-width, page-height) = utils.get-page-dimensions(self)
    if (
      type(margin) != dictionary
        and type(margin) != length
        and type(margin) != relative
    ) {
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
  let header = utils.call-or-display(self, self.page.at(
    "header",
    default: none,
  ))
  let footer = utils.call-or-display(self, self.page.at(
    "footer",
    default: none,
  ))
  let body-transform = body => body
  // negative padding
  if self.at("zero-margin-header", default: true) {
    let negative-pad = _get-negative-pad(self)
    header = negative-pad(header)
  }
  if self.at("zero-margin-footer", default: true) {
    let negative-pad = _get-negative-pad(self)
    footer = negative-pad(footer)
  }
  if self.at("show-notes-on-second-screen", default: none) == bottom {
    let bottom-pad = _get-bottom-pad(self)
    footer = bottom-pad(footer)
  }
  // speaker note (full-screen notes mode with slide thumbnail)
  if self.at("show-only-notes", default: false) {
    let (page-width, page-height) = utils.get-page-dimensions(self)
    let show-only-notes = (self.methods.show-only-notes)(
      self: self,
      width: page-width,
      height: page-height,
      cutout: true,
    )

    let margin-left = if type(self.page.margin) != dictionary {
      self.page.margin
    } else if "left" in self.page.margin {
      self.page.margin.left
    } else if "x" in self.page.margin {
      self.page.margin.x
    } else {
      0pt
    }

    let margin-right = if type(self.page.margin) != dictionary {
      self.page.margin
    } else if "right" in self.page.margin {
      self.page.margin.right
    } else if "x" in self.page.margin {
      self.page.margin.x
    } else {
      0pt
    }

    let margin-top = if type(self.page.margin) != dictionary {
      self.page.margin
    } else if "top" in self.page.margin {
      self.page.margin.top
    } else if "y" in self.page.margin {
      self.page.margin.y
    } else {
      0pt
    }

    let margin-bottom = if type(self.page.margin) != dictionary {
      self.page.margin
    } else if "bottom" in self.page.margin {
      self.page.margin.bottom
    } else if "y" in self.page.margin {
      self.page.margin.y
    } else {
      0pt
    }

    let cutout-height = show-only-notes.cutout-height
    let inset = (left: margin-left, right: margin-right)

    // header: place notes background + thumbnail of slide header
    header = {
      place(
        left + bottom,
        dx: -margin-left,
        dy: margin-top,
        show-only-notes.background,
      )
      place(
        right + top,
        dx: margin-right,
        _miniaturize(
          page-width,
          page-height,
          cutout-height,
          outer-style: (fill: white),
          box(
            width: 100%,
            height: 100%,
            inset: (bottom: page-height - margin-top, ..inset),
            align(horizon, header),
          ),
        ),
      )
    }

    // footer: place notes foreground + thumbnail of slide footer
    footer = {
      place(
        right + bottom,
        dx: margin-right,
        dy: -(page-height - cutout-height),
        _miniaturize(
          page-width,
          page-height,
          cutout-height,
          box(
            width: 100%,
            height: 100%,
            inset: (top: page-height - margin-bottom, ..inset),
            align(horizon, footer),
          ),
        ),
      )
      place(
        left + bottom,
        dx: -margin-left,
        show-only-notes.foreground,
      )
    }

    // body-transform: miniaturize the slide body and place in top-right corner
    body-transform = body => place(
      right + top,
      dx: margin-right,
      dy: -margin-top,
      _miniaturize(
        page-width,
        page-height,
        cutout-height,
        box(
          width: 100%,
          height: 100%,
          inset: (top: margin-top, bottom: margin-bottom, ..inset),
          body,
        ),
      ),
    )
  } else if self.show-notes-on-second-screen in (bottom, right) {
    // speaker note (second-screen mode)
    let (page-width, page-height) = utils.get-page-dimensions(self)
    let show-only-notes = (self.methods.show-only-notes)(
      self: self,
      width: page-width,
      height: page-height,
    )
    let margin-left = if type(self.page.margin) != dictionary {
      self.page.margin
    } else if "left" in self.page.margin {
      self.page.margin.left
    } else if "x" in self.page.margin {
      self.page.margin.x
    } else {
      0pt
    }
    if self.show-notes-on-second-screen == bottom {
      footer += place(
        left + bottom,
        dx: -margin-left,
        show-only-notes,
      )
    } else if self.show-notes-on-second-screen == right {
      footer += place(
        left + bottom,
        dx: page-width - margin-left,
        show-only-notes,
      )
    }
  }
  (header, footer, body-transform)
}

#let _rewind-states(states, location) = {
  for s in states {
    if type(s) == dictionary {
      (s.update)((s.at)(selector(location)))
    } else {
      s.update(s.at(selector(location)))
    }
  }
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
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function | array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
///
/// -> content
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
  assert(
    bodies.named().len() == 0,
    message: "unexpected named arguments:" + repr(bodies.named().keys()),
  )
  let setting-fn(body) = {
    set heading(offset: self.at("slide-level", default: 0)) if self.at(
      "auto-offset-for-heading",
      default: true,
    )
    show: body => {
      if self.at("show-strong-with-alert", default: true) {
        show strong: self.methods.alert.with(self: self)
        body
      } else {
        body
      }
    }
    setting(body)
  }
  let composer-with-side-by-side(..args) = {
    let effective-composer = if composer != auto {
      composer
    } else {
      self.at("default-composer", default: auto)
    }
    if type(effective-composer) == function {
      effective-composer(..args)
    } else {
      components.side-by-side(columns: effective-composer, ..args)
    }
  }
  let bodies = bodies.pos()

  // Slide and subslide preamble functions for setup and metadata
  let slide-preamble(self) = {
    if self.at("is-first-slide", default: false) {
      utils.call-or-display(self, self.at("preamble", default: none))
      utils.call-or-display(self, self.at("default-preamble", default: none))
    }
    [#metadata((kind: "touying-new-slide")) <touying-metadata>]
    // add headings for the first subslide
    if self.at("headings", default: ()) != () {
      set heading(offset: 0)
      show heading: none
      let headings = self
        .at("headings", default: ())
        .map(it => if it.has("label") {
          if (
            str(it.label)
              in (
                "touying:hidden",
                "touying:unnumbered",
                "touying:unoutlined",
                "touying:unbookmarked",
              )
          ) {
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
            [#heading(..fields, it.body)#it.label]
          } else {
            it
          }
        } else {
          it
        })
      headings.sum(default: none)
    }
    utils.call-or-display(self, self.at("slide-preamble", default: none))
    utils.call-or-display(self, self.at(
      "default-slide-preamble",
      default: none,
    ))
  }
  // preamble for the subslides
  let subslide-preamble(self) = {
    if self.handout or self.subslide == 1 {
      slide-preamble(self)
    }
    [#metadata((kind: "touying-new-subslide")) <touying-metadata>]
    if (
      self.at("enable-frozen-states-and-counters", default: true)
        and not self.handout
        and self.repeat > 1
    ) {
      if self.subslide == 1 {
        context {
          utils.loc-prior-newslide.update(here())
        }
      } else {
        context {
          let loc-prior-newslide = utils.loc-prior-newslide.get()
          _rewind-states(self.frozen-states, loc-prior-newslide)
          _rewind-states(self.default-frozen-states, loc-prior-newslide)
          _rewind-states(self.frozen-counters, loc-prior-newslide)
          _rewind-states(self.default-frozen-counters, loc-prior-newslide)
        }
      }
    }
    utils.call-or-display(self, self.at("subslide-preamble", default: none))
    utils.call-or-display(self, self.at(
      "default-subslide-preamble",
      default: none,
    ))
  }
  // update states for every page
  let page-preamble(self) = {
    [#metadata((kind: "touying-new-page")) <touying-metadata>]
    // 1. slide counter part
    //    if freeze-slide-counter is false, then update the slide-counter
    if self.handout or self.subslide == 1 {
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
    let (
      _,
      repetitions,
      last-subslide,
      _,
    ) = _parse-content-into-results-and-repetitions(
      self: self,
      base: 1,
      index: 1,
      ..bodies,
    )
    repeat = calc.max(repetitions, last-subslide)
  }
  assert(type(repeat) == int, message: "The repeat should be an integer")
  self.repeat = repeat
  // page header and footer
  let (header, footer, body-transform) = _get-header-footer(self)
  let page-extra-args = _get-page-extra-args(self)

  if self.handout {
    self.subslide = repeat
    let (conts, _, _, _) = _parse-content-into-results-and-repetitions(
      self: self,
      index: repeat,
      show-delayed-wrapper: true,
      ..bodies,
    )
    header = page-preamble(self) + header
    set page(..(self.page + page-extra-args + (header: header, footer: footer)))
    body-transform(setting-fn(
      subslide-preamble(self) + composer-with-side-by-side(..conts),
    ))
  } else if self.at("_recall-subslide", default: none) != none {
    // render only the specific subslide requested by touying-recall
    let i = self._recall-subslide
    assert(
      i >= 1 and i <= repeat,
      message: "subslide "
        + str(i)
        + " is out of range (1.."
        + str(repeat)
        + ")",
    )
    self.subslide = i
    let (header, footer, body-transform) = _get-header-footer(self)
    let (conts, _, _, _) = _parse-content-into-results-and-repetitions(
      self: self,
      index: i,
      show-delayed-wrapper: i == repeat,
      ..bodies,
    )
    let new-header = page-preamble(self) + header
    set page(
      ..(self.page + page-extra-args + (header: new-header, footer: footer)),
    )
    body-transform(setting-fn(
      subslide-preamble(self) + composer-with-side-by-side(..conts),
    ))
  } else {
    // render all the subslides
    let result = ()
    for i in range(1, repeat + 1) {
      self.subslide = i
      let (header, footer, body-transform) = _get-header-footer(self)
      let delayed-args = if i == repeat {
        (show-delayed-wrapper: true)
      }
      let (conts, _, _, _) = _parse-content-into-results-and-repetitions(
        self: self,
        index: i,
        ..delayed-args,
        ..bodies,
      )
      let new-header = page-preamble(self) + header
      // update the counter in the first subslide only
      result.push({
        set page(
          ..(
            self.page + page-extra-args + (header: new-header, footer: footer)
          ),
        )
        body-transform(setting-fn(
          subslide-preamble(self) + composer-with-side-by-side(..conts),
        ))
      })
    }
    // return the result
    result.sum()
  }
}


/// Touying slide function.
///
/// - config (dict): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function | array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
///
/// -> content
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})


/// Touying empty slide function.
///
/// - config (dict): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function | array): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
///
/// -> content
#let empty-slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})
