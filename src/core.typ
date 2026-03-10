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

/// Inject configuration changes into a block of content. Changes take effect only within `body`. Useful for implementing features like `#show: appendix`.
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


/// Begin the appendix of the presentation. The slide counter is frozen at the last non-appendix slide, so appendix slides do not affect the total slide count shown in footers.
///
/// Equivalent to `#show: touying-set-config.with((appendix: true))`.
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
/// Example:
///
/// ```typ
/// // Recall all subslides
/// #touying-recall(<my-slide>)
///
/// // Recall only a specific subslide
/// #touying-recall(<my-slide>, subslide: 2)
///
/// // Recall only the last (final) subslide
/// #touying-recall(<my-slide>, subslide: auto)
///
/// // Recall the last subslide of every waypoint
/// #touying-recall(<my-slide>, subslide: "waypoints")
///
/// // Recall the subslides covered by a waypoint
/// #touying-recall(<my-slide>, subslide: <my-waypoint>)
///
/// // Recall only the last subslide of a waypoint
/// #touying-recall(<my-slide>, subslide: get-last(<my-waypoint>))
/// ```
///
/// - lbl (str, label): The label of the slide to recall.
///
/// - subslide (none, auto, int, str, label, dictionary): Which subslide(s) to recall.
///
///   - `none` (default): recall all subslides.
///   - `auto`: recall only the last subslide (the final animation state).
///   - `int`: recall a specific subslide by number.
///   - `"waypoints"`: recall one subslide per waypoint — specifically, the
///     last subslide of each waypoint. This shows every animation phase at
///     its final state.
///   - `label`: recall the subslides covered by a waypoint in the original
///     slide. E.g. `subslide: <my-waypoint>`.
///   - Waypoint marker: `get-first(<wp>)`, `get-last(<wp>)`, `prev-wp(<wp>)`,
///     `next-wp(<wp>)` — resolves to a single subslide or waypoint range
///     using the recalled slide's waypoint map.
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

// Get the appropriate slide function based on current heading context
//
// - self (dictionary): The presentation context
// - default (function): Default slide function to use if no specific one matches
//
// -> function
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

// Call the appropriate slide function with the given body content
//
// - self (dictionary): The presentation context
// - fn (function): The slide function to use (auto to determine automatically)
// - body (content): The slide content to render
//
// -> content
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


// Use headings to split a content block into slides
//
// This function recursively processes content and splits it into individual slides
// based on heading levels and other slide-breaking elements like pagebreaks.
//
// - self (dictionary): The presentation context containing slide configuration
// - recaller-map (dictionary): Map of slide labels to their content for recall functionality
// - new-start (bool): Whether this is the start of a new slide section
// - is-first-slide (bool): Whether this is the first slide of the presentation
// - body (content): The content to be split into slides
//
// -> content
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
      horizontal-line-to-pagebreak and horizontal-line and child not in ([—], [---], [–], [--], [-])
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
        slide-parts != () or _get-slide-fn(self + (headings: current-headings), default: none) != none
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
        // Pass the raw subslide spec through to touying-slide, which will
        // resolve it after computing `repeat` and `waypoints`.
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
      horizontal-line-to-pagebreak and horizontal-line and child in ([–], [--], [-])
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
        not child.has("label") or str(child.label) not in ("touying:hidden", "touying:skip")
      ) {
        if (
          child.depth == 1 and new-section-slide-fn != none and not self.receive-body-for-new-section-slide-fn
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
          child.depth == 2 and new-subsection-slide-fn != none and not self.receive-body-for-new-subsection-slide-fn
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
      self.at("auto-offset-for-heading", default: true) and utils.is-heading(child)
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
      if slide-parts != () {
        // Flush the current slide only when there is actual body content.
        // If slide-parts is empty but current-headings is not, we skip
        // the empty-body flush to avoid creating ghost pages (invisible
        // slides that only contain hidden headings with no visible content).
        // The pending headings are instead forwarded into the recursive
        // processing by prepending them to the config body, so they are
        // correctly associated with the first real content inside the
        // touying-set-config block.
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
      // Forward any pending headings (accumulated before the touying-set-config
      // with no body content between them) into the recursive body so they are
      // associated with the first content inside the config block.
      let pending-headings = current-headings
      current-headings = ()
      slide-parts = ()
      let recursive-body = if pending-headings != () {
        pending-headings.sum(default: none) + child.value.body
      } else {
        child.value.body
      }
      // Process the content with the new configuration
      output-slides.push(
        split-content-into-slides(
          self: utils.merge-dicts(self, child.value.config),
          recaller-map: recaller-map,
          new-start: true,
          recursive-body,
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
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                  ),
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
              let styled-start = utils.reconstruct-styled(
                child,
                inner-start-part,
              )
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
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                  ),
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
/// - last-subslide (int): The max subslide count for the slide. Used by functions like `uncover`, `only`, and `alternatives-match` to determine the total number of subslides needed.
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
      message: "jump: n must be a non-zero integer when relative: true, got " + repr(n),
    )
  } else {
    assert(
      type(n) == int and n >= 1,
      message: "jump: n must be a positive integer when relative: false, got " + repr(n),
    )
  }
  [#metadata((
    kind: "touying-jump/pause/meanwhile",
    n: n,
    relative: relative,
  ))<touying-temporary-mark>]
}


/// Reveal the next subslide. Inserts a subslide break: content after `#pause` appears one subslide later. Equivalent to `#jump(1, relative: true)`.
///
/// -> content
#let pause = jump(1, relative: true)


/// Reset the subslide counter back to 1, allowing content after `#meanwhile` to appear simultaneously with content from subslide 1. Equivalent to `#jump(1)`.
///
/// -> content
#let meanwhile = jump(1)

/// ------------------------------------------------
/// Waypoints
/// (by Zral0kh)
/// ------------------------------------------------
///
/// Declare a named waypoint in the slide's subslide sequence.
///
/// A waypoint names a set of subslide positions so that it can be referred to
/// by label in `uncover`, `only`, `effect`, `alternatives`, and other animation
/// functions. This lets you avoid counting subslide numbers manually.
///
/// By default, a waypoint call also acts as a `#pause` (advancing to the next subslide).
/// Set `advance: false` to mark the current position without advancing.
///
/// A waypoint covers all subslides from its declaration until the next waypoint
/// is declared (or the end of the slide).
///
/// Note that your labels need to be slide-unique. They need not be globally
/// unique, but must be unique within a single slide.
///
/// You can use hierarchical labels with `:` separators (e.g. `<part:intro>`).
/// When referencing `<part>`, all waypoints starting with `part:` are combined.
///
/// Example:
///
/// ```typst
/// Some content
/// #waypoint(<reveal>)
/// #uncover(<reveal>)[Revealed content]
/// #waypoint(<highlight>)
/// #effect(text.with(fill: red), <highlight>)[Highlighted]
/// ```
///
/// - lbl (label): The label for this waypoint.
///
/// - advance (bool): If `true` (default), acts as a `#pause` before marking.
///   If `false`, marks the current subslide position without advancing.
///
/// -> content
#let waypoint(lbl, advance: true) = {
  assert(
    type(lbl) == label,
    message: "waypoint: expected a label, got " + str(type(lbl)),
  )
  [#metadata((
    kind: "touying-waypoint",
    label: str(lbl),
    advance: advance,
  ))<touying-temporary-mark>]
}


/// Get the first subslide number of a waypoint.
///
/// Returns a marker dictionary that will be resolved automatically when used as
/// a `visible-subslides` argument in `uncover`, `only`, `effect`, etc.
///
/// Example: `#only(get-first(<my-label>))[content]`
///
/// - lbl (label): The waypoint label.
///
/// -> dictionary
#let get-first(lbl) = {
  assert(
    type(lbl) == label,
    message: "get-first: expected a label, got " + str(type(lbl)),
  )
  (
    kind: "waypoint-first",
    label: str(lbl),
  )
}


/// Get the last subslide number of a waypoint.
///
/// Returns a marker dictionary that will be resolved automatically when used as
/// a `visible-subslides` argument in `uncover`, `only`, `effect`, etc.
///
/// Example: `#only(get-last(<my-label>))[content]`
///
/// - lbl (label): The waypoint label.
///
/// -> dictionary
#let get-last(lbl) = {
  assert(
    type(lbl) == label,
    message: "get-last: expected a label, got " + str(type(lbl)),
  )
  (
    kind: "waypoint-last",
    label: str(lbl),
  )
}


/// Create a "from-wp" range starting at a waypoint (inclusive to end of slide).
///
/// Returns a range marker visible from the waypoint's first subslide onward.
/// Does *not* create a waypoint — the referenced label must be defined
/// elsewhere (via `#waypoint()` or an implicit waypoint in `#uncover`, etc.).
///
/// Can be composed with `prev-wp` / `next-wp`:
/// `from-wp(next-wp(<my-label>))` starts at the waypoint after `<my-label>`.
///
/// Combine with `until-wp` in an array for bounded ranges:
/// `(from-wp(<a>), until-wp(<b>))` — visible from `<a>` to just before `<b>`.
///
/// - wp (label | dictionary): A waypoint label or a shifted reference
///   (e.g. `next-wp(<label>)`).
///
/// -> dictionary
#let from-wp(wp) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "from-wp: expected a label or waypoint marker, got " + str(type(wp)),
  )
  (
    kind: "waypoint-from",
    inner: if type(wp) == label {
      str(wp)
    } else {
      wp
    },
  )
}


/// Create an "until-wp" range ending just before a waypoint (exclusive).
///
/// Returns a range marker visible from subslide 1 up to (but not including)
/// the waypoint's first subslide.  Does *not* create a waypoint.
///
/// Can be composed with `prev-wp` / `next-wp`:
/// `until-wp(prev-wp(<my-label>))` ends before the waypoint preceding `<my-label>`.
///
/// Combine with `from-wp` in an array for bounded ranges:
/// `(from-wp(<a>), until-wp(<b>))` — visible from `<a>` to just before `<b>`.
///
/// - wp (label | dictionary): A waypoint label or a shifted reference.
///
/// -> dictionary
#let until-wp(wp) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "until-wp: expected a label or waypoint marker, got " + str(type(wp)),
  )
  (
    kind: "waypoint-until",
    inner: if type(wp) == label {
      str(wp)
    } else {
      wp
    },
  )
}


/// Shift a waypoint reference to a previous waypoint in subslide order.
///
/// Given a waypoint label, returns a reference to the waypoint `amount` steps
/// before it.  `prev-wp(<c>, amount: 2)` is equivalent to
/// `prev-wp(prev-wp(<c>))`.
///
/// When applied to a `from-wp` or `until-wp` marker, the shift is pushed inward:
/// `prev-wp(from-wp(<c>))` becomes `from-wp(prev-wp(<c>))`.
///
/// - wp (label | dictionary): A waypoint label or marker to shift.
///
/// - amount (int): How many waypoints to step back. Default is `1`.
///
/// -> dictionary
#let prev-wp(wp, amount: 1) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "prev-wp: expected a label or waypoint marker, got " + str(type(wp)),
  )
  if type(wp) == label {
    (kind: "waypoint-prev", inner: str(wp), amount: amount)
  } else if type(wp) == dictionary {
    let kind = wp.at("kind", default: none)
    if kind in ("waypoint-from", "waypoint-until") {
      // Push shift inward: prev-wp(from-wp(<x>)) → from-wp(prev-wp(<x>))
      (..wp, inner: prev-wp(wp.inner, amount: amount))
    } else {
      (kind: "waypoint-prev", inner: wp, amount: amount)
    }
  } else {
    (kind: "waypoint-prev", inner: wp, amount: amount)
  }
}


/// Shift a waypoint reference to a later waypoint in subslide order.
///
/// Given a waypoint label, returns a reference to the waypoint `amount` steps
/// after it.  `next-wp(<a>, amount: 2)` is equivalent to
/// `next-wp(next-wp(<a>))`.
///
/// When applied to a `from` or `until` marker, the shift is pushed inward:
/// `next-wp(until-wp(<a>))` becomes `until-wp(next-wp(<a>))`.
///
/// - wp (label | dictionary): A waypoint label or marker to shift.
///
/// - amount (int): How many waypoints to step forward. Default is `1`.
///
/// -> dictionary
#let next-wp(wp, amount: 1) = {
  assert(
    type(wp) in (label, str, dictionary),
    message: "next-wp: expected a label or waypoint marker, got " + str(type(wp)),
  )
  if type(wp) == label {
    (kind: "waypoint-next", inner: str(wp), amount: amount)
  } else if type(wp) == dictionary {
    let kind = wp.at("kind", default: none)
    if kind in ("waypoint-from", "waypoint-until") {
      // Push shift inward: next-wp(until-wp(<x>)) → until-wp(next-wp(<x>))
      (..wp, inner: next-wp(wp.inner, amount: amount))
    } else {
      (kind: "waypoint-next", inner: wp, amount: amount)
    }
  } else {
    (kind: "waypoint-next", inner: wp, amount: amount)
  }
}


/// Take effect in some subslides.
///
/// Example: `#effect(text.with(fill: red), "2-")[Something]` will display `[Something]` if the current slide is 2 or later.
///
/// You can also add an abbreviation by using `#let effect-red = effect.with(text.with(fill: red))` for your own effects.
///
/// - fn (function): The function that will be called in the subslide.
///      Or you can use a method function like `(self: none) => { .. }`.
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - cont (content): The content to display when visible.
///
/// - is-method (bool): Whether the function is a method function. Default is `false`.
#let effect(fn, visible-subslides, cont, is-method: false) = {
  if type(visible-subslides) == label {
    [#metadata((
      kind: "touying-implicit-waypoint",
      label: str(visible-subslides),
    ))<touying-temporary-mark>]
  }
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
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #uncover("2-")[Only visible from subslide 2]
/// )
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - uncover-cont (content): The content to display when visible.
///
/// - cover-fn (function, auto): An optional cover function to use instead of the default cover method from the theme. Useful when using `uncover` inside external package integrations (e.g. `fletcher.hide` for fletcher diagrams).
///
/// -> content
#let uncover(visible-subslides, uncover-cont, cover-fn: auto) = {
  if type(visible-subslides) == label {
    [#metadata((
      kind: "touying-implicit-waypoint",
      label: str(visible-subslides),
    ))<touying-temporary-mark>]
  }
  touying-fn-wrapper(
    utils.uncover,
    last-subslide: utils.last-required-subslide(visible-subslides),
    visible-subslides,
    uncover-cont,
    cover-fn: cover-fn,
  )
}


/// Display content in some subslides only. No space is reserved when hidden.
///
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #only("2")[Only on subslide 2]
/// )
///
/// - visible-subslides (int, array, str, label, dictionary): Specifies when content is visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///    - A label, e.g. `<my-waypoint>` — creates an implicit waypoint and shows from there onward.
///    - A waypoint marker, e.g. `from-wp(<label>)`, `until-wp(<label>)`, `get-first(<label>)`, etc.
///
/// - only-cont (content): The content to display when visible.
///
/// -> content
#let only(visible-subslides, only-cont) = {
  if type(visible-subslides) == label {
    [#metadata((
      kind: "touying-implicit-waypoint",
      label: str(visible-subslides),
    ))<touying-temporary-mark>]
  }
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
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-match(
  subslides-contents,
  position: bottom + left,
  stretch: false,
) = {
  // Validate: alternatives-match doesn't support waypoints, only numeric subslide specs
  let keys = if type(subslides-contents) == dictionary {
    subslides-contents.keys()
  } else {
    subslides-contents.map(kv => kv.at(0))
  }
  for key in keys {
    if type(key) == label {
      panic(
        "alternatives-match: waypoint labels are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
    if (
      type(key) == dictionary and "kind" in key and str(key.kind).starts-with("waypoint-")
    ) {
      panic(
        "alternatives-match: waypoint markers are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
  }
  touying-fn-wrapper(
    utils.alternatives-match,
    last-subslide: if type(subslides-contents) == dictionary {
      calc.max(..subslides-contents.pairs().map(kv => utils.last-required-subslide(kv.at(0))))
    } else {
      calc.max(..subslides-contents.map(kv => utils.last-required-subslide(
        kv.at(0),
      )))
    },
    subslides-contents,
    position: position,
    stretch: false,
  )
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// You can also use waypoint labels via the `at` parameter:
///
/// ```typst
/// #alternatives(at: (<first>, <second>))[Content A][Content B]
/// ```
///
/// - start (int): The starting subslide number. Default is `auto`.
///
/// - repeat-last (bool): Whether the last alternative should persist on all remaining subslides. Default is `true`.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// - at (none | array): An array of waypoint labels (or waypoint markers like `get-first(<label>)`) or subslide specs, one per body.
///   When provided, each body is mapped to the corresponding waypoint range.
///   This is an alternative to the sequential `start`-based numbering.
///
/// -> content
#let alternatives(
  start: auto,
  repeat-last: true,
  position: bottom + left,
  stretch: false,
  at: none,
  ..args,
) = {
  if at != none {
    // Waypoint-based alternatives: map each label to its corresponding body
    let bodies = args.pos()
    assert(
      at.len() == bodies.len(),
      message: "alternatives: `at` array length ("
        + str(at.len())
        + ") must match number of bodies ("
        + str(bodies.len())
        + ")",
    )
    let subslides = at
    if repeat-last and subslides.len() > 0 {
      // Replace last entry with a from-wp() marker so it shows from that
      // waypoint onward (not just within its bounded range).
      let last-entry = subslides.last()
      subslides.at(-1) = if type(last-entry) == label {
        from-wp(last-entry)
      } else {
        last-entry
      }
    }
    let subslides-contents = subslides.zip(bodies)
    touying-fn-wrapper(
      utils.alternatives-match,
      last-subslide: calc.max(
        ..subslides.map(s => utils.last-required-subslide(s)),
      ),
      subslides-contents,
      position: position,
      stretch: stretch,
    )
  } else {
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
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
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
  // Validate integer parameters
  assert(
    type(start) == int,
    message: "alternatives-fn: start must be an integer, got " + str(type(start)),
  )
  if end != none {
    assert(
      type(end) == int,
      message: "alternatives-fn: end must be an integer or none, got " + str(type(end)),
    )
  }
  if count != none {
    assert(
      type(count) == int,
      message: "alternatives-fn: count must be an integer or none, got " + str(type(count)),
    )
  }
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
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-cases(
  cases,
  fn,
  position: bottom + left,
  stretch: false,
  ..kwargs,
) = {
  // Validate: alternatives-cases doesn't support waypoints, only numeric subslide specs
  for case in cases {
    if type(case) == label {
      panic(
        "alternatives-cases: waypoint labels are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
    if (
      type(case) == dictionary and "kind" in case and str(case.kind).starts-with("waypoint-")
    ) {
      panic(
        "alternatives-cases: waypoint markers are not supported. Use alternatives() with the at: parameter instead.",
      )
    }
  }
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
/// Each item is revealed on a successive subslide.  By default (`start: auto`),
/// revealing is relative to the current pause position — items appear one per
/// subslide starting from wherever the slide's animation has reached.
///
/// `start` also accepts a waypoint label (e.g. `<my-wp>`) or any waypoint
/// marker (`from-wp(<wp>)`, `get-first(<wp>)`, etc.) to anchor the reveal
/// sequence to a named position.
///
/// == Examples
///
/// ```typst
/// // Relative (auto) — items appear after any preceding #pause
/// #item-by-item[
///   - first
///   - second
///   - third
/// ]
///
/// // Anchored to a waypoint
/// #waypoint(<items>)
/// #item-by-item(start: <items>)[
///   - alpha
///   - beta
/// ]
///
/// // Explicit absolute subslide number (backward compatible)
/// #item-by-item(start: 3)[
///   - x
///   - y
/// ]
/// ```
///
/// - start (auto | int | label | dictionary): The subslide on which the first
///   item appears.  `auto` (default) makes it relative to the current pause
///   position.  An integer gives an absolute subslide number.  A label or
///   waypoint marker resolves to the waypoint's first subslide.
///
/// - cont (content): The content containing a list, enum, or terms element.
///
/// -> content
#let item-by-item(start: auto, cont) = {
  if (
    type(start) == dictionary and start.at("kind", default: none) in ("waypoint-from", "waypoint-until")
  ) {
    panic(
      "item-by-item: `start` must resolve to a single subslide position. "
        + "`from-wp` and `until-wp` are range markers and are not supported here. "
        + "Use a label, `get-first`, `get-last`, `prev-wp`, `next-wp` or simple slide numbers instead.",
    )
  }
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
  if start == auto {
    // Relative: items start from the current pause position.
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: repetitions => (
        repetitions + num-items - 1,
        (start: repetitions),
      ),
      start: start,
      cont,
    )
  } else if type(start) == int {
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: start + num-items - 1,
      start: start,
      cont,
    )
  } else if type(start) == str {
    let parts = utils._parse-subslide-indices(start)
    if parts.len() != 1 or type(parts.first()) != int {
      panic(
        "item-by-item: `start` string must be a single number (e.g. \"3\"), "
          + "not a range or multi-value spec. Got: \""
          + start
          + "\".",
      )
    }
    let n = parts.first()
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: n + num-items - 1,
      start: n,
      cont,
    )
  } else {
    // Label or waypoint marker — resolved at render time.
    // For a plain label, emit an implicit waypoint so users don't need to write
    // a separate #waypoint(<label>) before the call.  The _waypoint-known check
    // in the prepass ensures the waypoint is only registered once even if an
    // explicit #waypoint(<label>) is also present.
    // Dictionary markers (from-wp, next-wp, get-first, …) reference an existing
    // explicit waypoint, so no implicit waypoint is needed for those.
    if type(start) == label {
      [#metadata((
        kind: "touying-implicit-waypoint",
        label: str(start),
      ))<touying-temporary-mark>]
    }
    // At callback time, `repetitions` equals the waypoint's subslide number
    // (the implicit or explicit waypoint was processed just before this wrapper).
    // We need num-items subslides starting from there, so the last subslide
    // needed is repetitions + num-items - 1.
    // Return empty extra-args so the original label/marker `start` is preserved
    // for render-time resolution via resolve-waypoints.
    touying-fn-wrapper(
      utils.item-by-item,
      last-subslide: repetitions => (
        repetitions + num-items - 1,
        (:),
      ),
      start: start,
      cont,
    )
  }
}


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Multiple calls on the same slide are combined (accumulated), so all notes are shown together.
///
/// Example:
///
/// ```typ
/// #speaker-note[This is a speaker note]
/// ```
///
/// - mode (str): The mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - setting (function): A function that takes the note as input and returns a processed note.
///
/// - subslide (none, auto, int, array, str): Restricts the note to specific subslides, similar to `only`.
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


/// Animated math equation. Use `pause` and `meanwhile` inside the equation body to reveal terms step by step.
///
/// Write the equation as a raw block (backtick string) or a plain string. Use `pause` (without backslash or `#`) as a pseudo-command inside the equation to insert a pause marker.
///
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #touying-equation(`
///   f(x) &= pause x^2 + 2x + 1 \
///         &= pause (x + 1)^2
/// `)
/// )
///
/// - block (bool): Whether the equation is a block element. Default is `true`.
///
/// - numbering (none, str): The numbering of the equation. Default is `none`.
///
/// - supplement (auto, str): The supplement of the equation. Default is `auto`.
///
/// - scope (dictionary): Extra bindings passed to `eval()` when the body is a string or raw block.
///
/// - body (str, content, function): The equation content. Accepts a raw block (e.g. `` `f(x) = pause x^2` ``), a plain string, or a callback `self => str`.
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
/// - mitex (function): The mitex function. You can import it by code like `#import "@preview/mitex:0.2.6": mitex`.
///
/// - block (bool): Whether the equation is a block element. Default is `true`.
///
/// - numbering (none, str): The numbering of the equation. Default is `none`.
///
/// - supplement (auto, str): The supplement of the equation. Default is `auto`.
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


/// Animated code block. Use a comment-style `pause` or `meanwhile` on its own line to insert animation markers.
///
/// A line is treated as a `pause` or `meanwhile` marker when its only
/// meaningful characters (letters, digits, CJK) exactly spell "pause" or
/// "meanwhile". For example, `// pause`, `# pause`, and `#pause` are all
/// valid markers, while `pause = 1` or `def pause():` are not.
///
/// #example(
/// >>> #let is-dark = sys.inputs.at("x-color-theme", default: none) == "dark";
/// >>> #let text-color = if is-dark { std.white } else { std.black };
/// >>> #show: simple-theme.with(
/// >>>   aspect-ratio: "16-9",
/// >>>   config-page(width: 320pt, height: 180pt),
/// >>>   config-colors(neutral-lightest: none, neutral-darkest: text-color),
/// >>> )
/// >>> #set text(.5em)
/// <<< #show: simple-theme.with(aspect-ratio: "16-9")
/// = Slide
///
/// #touying-raw(```rust
///   fn main() {
///       // pause
///       println!("Hello, world!");
///   }
/// ```)
/// )
///
/// - block (bool): Whether the raw block is a block element. Default is `true`.
///
/// - lang (none, str): The language for syntax highlighting. When `none`, the language is inferred from the raw block body if possible. Default is `none`.
///
/// - fill-empty-lines (bool): Whether to replace hidden lines with empty lines to preserve the layout of visible lines. Default is `true`.
///
/// - simple (bool): When `true`, use `#pause;` and `#meanwhile;` as direct split markers (similar to how `touying-mitex` uses `\pause`). Default is `false`.
///
/// - body (str, content, function): The raw code content. Can be a raw block, a string, or a function receiving `self` as an argument.
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


/// Extend external packages with `pause` and `meanwhile` animation support.
///
/// Wraps an external drawing/diagram function (like `cetz.canvas` or `fletcher.diagram`) so that Touying can intercept `pause`/`meanwhile` markers inside its content array and hide/cover items across subslides.
///
/// Define package-specific wrappers once at the top of your document:
///
/// ```typst
/// // CeTZ
/// #let cetz-canvas = touying-reducer.with(
///   reduce: cetz.canvas,
///   cover: cetz.draw.hide.with(bounds: true),
/// )
///
/// // Fletcher
/// #let fletcher-diagram = touying-reducer.with(
///   reduce: fletcher.diagram,
///   cover: fletcher.hide,
/// )
/// ```
///
/// - reduce (function): The external drawing function. It should accept an array of drawing commands and return rendered content (e.g. `cetz.canvas` or `fletcher.diagram`).
///
/// - cover (function): Called with a drawing command when that command should be hidden on the current subslide. Should produce invisible but space-preserving content (e.g. `cetz.draw.hide.with(bounds: true)` or `fletcher.hide`).
///
/// - args (arguments): The positional and named arguments passed to the `reduce` function.
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
/// - need-cover (bool): Whether hidden content should be covered
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
/// - need-cover (bool): Whether hidden content should be covered
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
/// - need-cover (bool): Whether hidden content should be covered
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
      let meaningful = line.matches(meaningful-chars-pattern).map(m => m.text).join("")
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
      type(child) == content and child.func() == metadata and type(child.value) == dictionary
    ) {
      let kind = child.value.at("kind", default: none)
      if kind == "touying-jump/pause/meanwhile" {
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
      } else if kind == "touying-waypoint" {
        // Waypoint inside reducer: advance repetitions if this is the defining
        // occurrence (same logic as the outer parser). Never pushed to result
        // or hidden-parts — it is not a draw command.
        let wp = self.at("waypoints", default: (:))
        let lbl = child.value.label
        if (
          child.value.at("advance", default: true) and lbl in wp and wp.at(lbl).first == repetitions + 1
        ) {
          repetitions += 1
          max-repetitions = calc.max(max-repetitions, repetitions)
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


/// ------------------------------------------------
/// Waypoint Collection
/// ------------------------------------------------

/// Check whether a waypoint label is already known — either exactly or
/// because a child in the hierarchy was registered earlier (e.g. `<top:sub>`
/// makes `<top>` known without storing a synthetic parent entry).
#let _waypoint-known(waypoints, lbl) = {
  if lbl in waypoints {
    return true
  }
  let prefix = lbl + ":"
  waypoints.keys().any(k => k.starts-with(prefix))
}

/// Count the peak repetition produced by an animated block (touying-equation,
/// touying-mitex, touying-raw, touying-reducer). Returns the max-repetitions
/// value, mirroring what the corresponding `_parse-touying-*` function would
/// return without needing `self` or cover logic.
///
/// - kind (str): The metadata kind.
/// - value (dictionary): The metadata value.
/// - base (int): The starting repetition count.
///
/// -> int
#let _count-animated-block-repetitions(kind, value, base) = {
  let repetitions = base
  let max-repetitions = repetitions

  if kind == "touying-reducer" {
    // Reducer: iterate positional args looking for touying-jump/pause/meanwhile and touying-waypoint metadata
    for child in value.args.flatten() {
      if (
        type(child) == content and child.func() == metadata and type(child.value) == dictionary
      ) {
        let k = child.value.at("kind", default: none)
        if k == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            repetitions += child.value.n
            max-repetitions = calc.max(max-repetitions, repetitions)
          } else {
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = child.value.n
          }
        } else if k == "touying-waypoint" {
          if child.value.at("advance", default: true) {
            repetitions += 1
          }
        }
      }
    }
    return calc.max(max-repetitions, repetitions)
  }

  // Text-based blocks: equation, mitex, raw
  let body = value.body
  if type(body) == function {
    // Cannot evaluate callback bodies during pre-pass (no self context).
    return base
  }
  if type(body) != str {
    return base
  }

  if kind == "touying-equation" {
    let parts = body
      .split(regex("(#meanwhile;?)|(meanwhile)"))
      .intersperse("touying-meanwhile")
      .map(s => s.split(regex("(#pause;?)|(pause)")).intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      }
    }
  } else if kind == "touying-mitex" {
    let parts = body
      .split(regex("\\\\meanwhile"))
      .intersperse("touying-meanwhile")
      .map(s => s.split(regex("\\\\pause")).intersperse("touying-pause"))
      .flatten()
    for part in parts {
      if part == "touying-pause" {
        repetitions += 1
      } else if part == "touying-meanwhile" {
        max-repetitions = calc.max(max-repetitions, repetitions)
        repetitions = 1
      }
    }
  } else if kind == "touying-raw" {
    if value.at("simple", default: false) {
      let parts = body
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
        }
      }
    } else {
      let meaningful-chars-pattern = regex("[a-zA-Z0-9\u{4E00}-\u{9FFF}]+")
      for line in body.split("\n") {
        let meaningful = line.matches(meaningful-chars-pattern).map(m => m.text).join("")
        if meaningful == "pause" {
          repetitions += 1
        } else if meaningful == "meanwhile" {
          max-repetitions = calc.max(max-repetitions, repetitions)
          repetitions = 1
        }
      }
    }
  }
  calc.max(max-repetitions, repetitions)
}

/// Walk content children to collect waypoint declarations and track pause
/// positions. Returns `(repetitions, waypoints-dict)` where
/// `waypoints-dict` maps label strings to their raw subslide numbers.
///
/// This mirrors the pause-tracking logic of `_parse-content-into-results-and-repetitions`
/// but does NOT handle covering or visibility — it is a lightweight pre-pass.
#let _collect-waypoints-impl(children, repetitions, last-subslide, waypoints) = {
  // Helper: register a new advancing waypoint at the correct position.
  // Uses max(repetitions+1, last-subslide+1) so that waypoints placed after a
  // multi-subslide fn-wrapper (e.g. item-by-item) land AFTER its full range,
  // not just one step past the last sequential pause.
  let register-advancing-wp(lbl, repetitions, last-subslide, waypoints) = {
    let pos = calc.max(repetitions + 1, last-subslide + 1)
    repetitions = pos
    last-subslide = calc.max(last-subslide, pos)
    waypoints.insert(lbl, pos)
    (repetitions, last-subslide, waypoints)
  }

  for child in children {
    if utils.is-sequence(child) {
      (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
        child.children,
        repetitions,
        last-subslide,
        waypoints,
      )
    } else if (
      type(child) == content and child.func() == metadata and type(child.value) == dictionary
    ) {
      let kind = child.value.at("kind", default: none)
      if kind == "touying-jump/pause/meanwhile" {
        if child.value.relative {
          // Snap past any preceding fn-wrapper range before applying the
          // relative jump, so pauses after e.g. item-by-item land correctly.
          repetitions = calc.max(repetitions, last-subslide) + child.value.n
        } else {
          repetitions = child.value.n
        }
      } else if kind == "touying-waypoint" {
        if not _waypoint-known(waypoints, child.value.label) {
          if child.value.at("advance", default: true) {
            (repetitions, last-subslide, waypoints) = register-advancing-wp(
              child.value.label,
              repetitions,
              last-subslide,
              waypoints,
            )
          } else {
            waypoints.insert(child.value.label, repetitions)
          }
        }
      } else if kind == "touying-implicit-waypoint" {
        if not _waypoint-known(waypoints, child.value.label) {
          (repetitions, last-subslide, waypoints) = register-advancing-wp(
            child.value.label,
            repetitions,
            last-subslide,
            waypoints,
          )
        }
      } else if kind == "touying-set-config" {
        let inner = if utils.is-sequence(child.value.body) {
          child.value.body.children
        } else {
          (child.value.body,)
        }
        (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
          inner,
          repetitions,
          last-subslide,
          waypoints,
        )
      } else if kind in ("touying-equation", "touying-mitex", "touying-raw") {
        repetitions = _count-animated-block-repetitions(
          kind,
          child.value,
          repetitions,
        )
      } else if kind == "touying-reducer" {
        // Recurse into the reducer's positional args to find waypoints and track pauses.
        let inner-rep = repetitions
        let inner-max = repetitions
        for inner-child in child.value.args.flatten() {
          if (
            type(inner-child) == content and inner-child.func() == metadata and type(inner-child.value) == dictionary
          ) {
            let ik = inner-child.value.at("kind", default: none)
            if ik == "touying-jump/pause/meanwhile" {
              if inner-child.value.relative {
                inner-rep += inner-child.value.n
                inner-max = calc.max(inner-max, inner-rep)
              } else {
                inner-max = calc.max(inner-max, inner-rep)
                inner-rep = inner-child.value.n
              }
            } else if ik == "touying-waypoint" {
              if not _waypoint-known(waypoints, inner-child.value.label) {
                if inner-child.value.at("advance", default: true) {
                  inner-rep += 1
                }
                waypoints.insert(inner-child.value.label, inner-rep)
              }
            } else if ik == "touying-implicit-waypoint" {
              if not _waypoint-known(waypoints, inner-child.value.label) {
                inner-rep += 1
                waypoints.insert(inner-child.value.label, inner-rep)
              }
            }
          }
        }
        repetitions = calc.max(inner-max, inner-rep)
      } else if kind == "touying-fn-wrapper" {
        // fn-wrappers can span multiple subslides via their last-subslide field.
        // Update last-subslide so that subsequent waypoints are placed AFTER
        // this fn-wrapper's full animation range, not just at repetitions+1.
        let ls = child.value.at("last-subslide", default: none)
        if ls != none {
          if type(ls) == function {
            let (callback-ls, _) = ls(repetitions)
            last-subslide = calc.max(last-subslide, callback-ls)
          } else if type(ls) == int {
            last-subslide = calc.max(last-subslide, ls)
          }
        }
      }
    } else if utils.is-styled(child) {
      (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
        (child.child,),
        repetitions,
        last-subslide,
        waypoints,
      )
    } else if (
      type(child) == content and child.func() in (table.cell, grid.cell)
    ) {
      // Handle table/grid cells that may wrap jump or waypoint metadata
      if (
        type(child.body) == content and child.body.func() == metadata and type(child.body.value) == dictionary
      ) {
        let kind = child.body.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if child.body.value.relative {
            repetitions = calc.max(repetitions, last-subslide) + child.body.value.n
          } else {
            repetitions = child.body.value.n
          }
        } else if kind == "touying-waypoint" {
          if not _waypoint-known(waypoints, child.body.value.label) {
            if child.body.value.at("advance", default: true) {
              (repetitions, last-subslide, waypoints) = register-advancing-wp(
                child.body.value.label,
                repetitions,
                last-subslide,
                waypoints,
              )
            } else {
              waypoints.insert(child.body.value.label, repetitions)
            }
          }
        } else if kind == "touying-implicit-waypoint" {
          if not _waypoint-known(waypoints, child.body.value.label) {
            (repetitions, last-subslide, waypoints) = register-advancing-wp(
              child.body.value.label,
              repetitions,
              last-subslide,
              waypoints,
            )
          }
        }
      } else {
        // Cell body is not a direct metadata wrapper — recurse into it
        // to find any embedded waypoints/pauses.
        let body = child.at("body", default: none)
        if body != none {
          let inner = if utils.is-sequence(body) {
            body.children
          } else {
            (body,)
          }
          (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
            inner,
            repetitions,
            last-subslide,
            waypoints,
          )
        }
      }
    } else if type(child) == content {
      // Recurse into content with a body field
      let body = child.at("body", default: none)
      if body != none {
        let inner = if utils.is-sequence(body) {
          body.children
        } else {
          (body,)
        }
        (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
          inner,
          repetitions,
          last-subslide,
          waypoints,
        )
      }
      // Recurse into children (table, grid, stack, etc.)
      if child.has("children") {
        let ch = child.at("children", default: none)
        if ch != none and type(ch) == array {
          (repetitions, last-subslide, waypoints) = _collect-waypoints-impl(
            ch,
            repetitions,
            last-subslide,
            waypoints,
          )
        }
      }
    }
  }
  (repetitions, last-subslide, waypoints)
}


/// Collect all waypoint labels from slide bodies.
///
/// Returns a dictionary mapping label strings to their raw subslide numbers.
///
/// - bodies (content): The content bodies to scan.
///
/// -> dictionary
#let _collect-waypoints(..bodies) = {
  let (_, _, waypoints) = _collect-waypoints-impl(bodies.pos(), 1, 0, (:))
  waypoints
}


/// Compute waypoint ranges from raw waypoint positions.
///
/// Each waypoint covers subslides from its declared position until the next
/// waypoint starts (or the end of the slide for the last one).
///
/// - raw-waypoints (dictionary): Map of label → subslide number.
///
/// - total-repeat (int): Total number of subslides in the slide.
///
/// -> dictionary
#let _compute-waypoint-ranges(raw-waypoints, total-repeat) = {
  if raw-waypoints.len() == 0 {
    return (:)
  }
  // Sort waypoints by subslide number, then by insertion order for ties
  let sorted = raw-waypoints.pairs().sorted(key: p => p.at(1))
  let result = (:)
  for (i, (lbl, first)) in sorted.enumerate() {
    let last = if i + 1 < sorted.len() {
      sorted.at(i + 1).at(1) - 1
    } else {
      total-repeat
    }
    // Ensure last >= first (can happen if two waypoints share the same subslide)
    let last = calc.max(first, last)
    result.insert(lbl, (first: first, last: last))
  }
  result
}


///
/// This is the core parsing function that handles all types of content including
/// animations, pauses, meanwhile markers, and various content types. It recursively
/// processes content and determines what should be visible on each subslide.
///
/// - self (dictionary): The presentation context
/// - need-cover (bool): Whether hidden content should be covered
/// - base (int): Base repetition count
/// - index (int): Current subslide index
/// - show-delayed-wrapper (bool): Whether to show delayed wrapper content
/// - bodies (content): The content elements to parse
///
/// -> (array, int, int, int)
#let _parse-content-into-results-and-repetitions(
  self: none,
  need-cover: true,
  base: 1,
  base-last-subslide: 0,
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
    last-subslide,
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
      inner-has-fn-wrapper,
    ) = _parse-content-into-results-and-repetitions(
      self: self,
      need-cover: repetitions <= index,
      base: repetitions,
      base-last-subslide: last-subslide,
      index: index,
      body-content,
    )
    let cont = conts.first()
    // Two-pass: if fn-wrappers are present inside a pause zone, re-run the inner parse
    // with the outer need-cover so that fn-wrappers handle their own visibility and
    // non-fn-wrapper content is properly covered by the inner mechanism.
    let would-be-hidden = not (
      calc.min(repetitions, final-repetitions) <= index or not need-cover
    )
    if would-be-hidden and inner-has-fn-wrapper {
      let (
        conts2,
        inner-max-repetitions2,
        _,
        _,
        _,
      ) = _parse-content-into-results-and-repetitions(
        self: self,
        need-cover: need-cover,
        base: repetitions,
        base-last-subslide: last-subslide,
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
  // last-subslide by touying-fn-wrapper — inherit outer context so waypoints
  // placed after multi-subslide fn-wrappers fire correctly inside sub-sequences.
  let last-subslide = base-last-subslide
  // Whether any touying-fn-wrapper was found in this parse (directly or via
  // recursive calls).  Used by the two-pass escape hatch so that fn-wrappers
  // inside a pause zone can handle their own visibility.
  let has-fn-wrapper = false
  // get cover function from self
  let cover = self.methods.cover.with(self: self)

  // Main parsing loop: process each content item and handle animations
  for item in bodies {
    let it = item
    // Special handling for table/grid cells containing pause/meanwhile/waypoint markers
    // This is a workaround for syntax like #table([A], pause, [B])
    // Waypoints and implicit waypoints are also stripped so they don't occupy a cell slot.
    if type(it) == content and it.func() in (table.cell, grid.cell) {
      if (
        type(it.body) == content and it.body.func() == metadata and type(it.body.value) == dictionary
      ) {
        let kind = it.body.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if it.body.value.relative {
            repetitions = calc.max(repetitions, last-subslide) + it.body.value.n
          } else {
            // absolute jump
            max-repetitions = calc.max(max-repetitions, repetitions)
            repetitions = it.body.value.n
          }
          continue
        } else if kind == "touying-waypoint" {
          // Advance repetitions if this is the defining occurrence.
          // Fires on the standard sequential trigger (first == repetitions+1) OR
          // when a preceding fn-wrapper pushed last-subslide forward and this
          // waypoint sits immediately after it (first == last-subslide+1).
          let wp = self.at("waypoints", default: (:))
          let lbl = it.body.value.label
          if it.body.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 or (first == last-subslide + 1 and first > repetitions) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          continue
        } else if kind == "touying-implicit-waypoint" {
          let wp = self.at("waypoints", default: (:))
          let lbl = it.body.value.label
          if lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 or (first == last-subslide + 1 and first > repetitions) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
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

    // Reference element for detecting space nodes in the content tree.
    // [#"a" b] forces a sequence (text + space + text) so .children works.
    let _space-func = [#"a" b].children.at(1).func()

    // Helper: is this content element a list/enum/terms item?
    let _is-list-item(it) = (
      type(it) == content and (it.func() == list.item or it.func() == enum.item or it.func() == terms.item)
    )

    /// Flush the hidden-parts buffer as covered content.  `last-result` is the
    /// current visible result array at the flush point.  We only wrap in
    /// `block(spacing: par.leading)` when the last visible element AND the first
    /// hidden element are both list/enum/terms items — i.e. a list interrupted
    /// by `#pause`.  In all other cases (text→list, list→text, text→text) the
    /// default paragraph spacing is correct.
    let cover-hidden(cover-fn, items, last-result) = {
      // First non-space hidden element
      let first-pos = items.position(item => not (type(item) == content and item.func() == _space-func))
      let first-is-list = first-pos != none and _is-list-item(items.at(first-pos))

      // Last non-space visible element (walk result backwards).
      // We only skip space nodes — parbreaks and linebreaks are meaningful
      // separators.  A parbreak between the last visible list item and the
      // hidden zone means the user broke the implicit list with a blank line,
      // so paragraph spacing should be used instead of list spacing.
      let last-is-list = {
        let found = false
        for i in range(last-result.len()) {
          let item = last-result.at(last-result.len() - 1 - i)
          if type(item) == content and item.func() == _space-func {
            // skip space nodes only
          } else {
            found = _is-list-item(item)
            break
          }
        }
        found
      }
      let spacing-is-auto(it) = {
        if it.func() == list.item {
          list.spacing == auto
        } else if it.func() == enum.item {
          enum.spacing == auto
        } else if it.func() == terms.item {
          terms.spacing == auto
        } else {
          false
        }
      }
      let covered = cover-fn(items.sum())
      if first-is-list and last-is-list {
        let first-item = items.at(first-pos)
        // construct a block around the covered content that corrects spacing. looks for auto
        context block(
          spacing: if spacing-is-auto(first-item) {
            // would yield `auto` which is a par.spacing for the block.
            if self.at("nontight-list-enum-and-terms", default: true) {
              //cannot set list thightness via set rule somehow. if user uses magic.nontight locally we can't detect that, so we just assume he only uses the config. thus this might break.
              par.spacing
            } else {
              par.leading
            }
          } else {
            if first-item.func() == list.item {
              list.spacing
            } else if first-item.func() == enum.item {
              enum.spacing
            } else if first-item.func() == terms.item {
              terms.spacing
            } else {
              par.spacing
            }
          },
          covered,
        )
      } else {
        covered
      }
    }

    // Flatten sequences and handle each child element
    let children = if utils.is-sequence(it) {
      it.children
    } else {
      (it,)
    }

    // Process each child element for animation markers and content types
    for child in children {
      if (
        type(child) == content and child.func() == metadata and type(child.value) == dictionary
      ) {
        let kind = child.value.at("kind", default: none)
        if kind == "touying-jump/pause/meanwhile" {
          if child.value.relative {
            // Snap past any preceding fn-wrapper range before applying the
            // relative jump, so that a #pause after e.g. item-by-item lands
            // after the full animation, not after its first subslide.
            repetitions = calc.max(repetitions, last-subslide) + child.value.n
            // Track the peak repetitions so that a subsequent negative jump doesn't
            // cause the slide count to be underestimated
            max-repetitions = calc.max(max-repetitions, repetitions)
            // If we jumped back into the visible zone, flush hidden-parts in order
            // (so they appear before subsequent visible content, not after it)
            if hidden-parts.len() != 0 and repetitions <= index {
              result.push(cover-hidden(cover, hidden-parts, result))
              hidden-parts = ()
            }
          } else {
            // absolute: reveal all hidden content then jump to target subslide
            if hidden-parts.len() != 0 {
              result.push(cover-hidden(cover, hidden-parts, result))
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
          has-fn-wrapper = true
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
        } else if kind == "touying-waypoint" {
          // Waypoint marker: advance repetitions if this is the defining occurrence.
          // Fires on the standard sequential trigger (first == repetitions+1) OR
          // when a preceding fn-wrapper pushed last-subslide forward and this
          // waypoint sits immediately after it (first == last-subslide+1).
          let wp = self.at("waypoints", default: (:))
          let lbl = child.value.label
          if child.value.at("advance", default: true) and lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 or (first == last-subslide + 1 and first > repetitions) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output.
        } else if kind == "touying-implicit-waypoint" {
          // Implicit waypoint: advance repetitions if this is the defining occurrence.
          // Fires on the standard sequential trigger (first == repetitions+1) OR
          // when a preceding fn-wrapper pushed last-subslide forward and this
          // waypoint sits immediately after it (first == last-subslide+1).
          let wp = self.at("waypoints", default: (:))
          let lbl = child.value.label
          if lbl in wp {
            let first = wp.at(lbl).first
            if first == repetitions + 1 or (first == last-subslide + 1 and first > repetitions) {
              repetitions = first
              max-repetitions = calc.max(max-repetitions, repetitions)
            }
          }
          // No visible output.
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
          result.push(cover-hidden(cover, hidden-parts, result))
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
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        // Two-pass: if fn-wrappers are present and sequence would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (cont, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
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
          last-subslide,
          index,
          need-cover,
          (child, cont) => utils.typst-builtin-styled(cont, child.styles),
        )
        // Propagate meanwhile effect from inside the styled element
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result or calc.min(repetitions, final-repetitions) <= index or not need-cover
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
          last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result or calc.min(repetitions, final-repetitions) <= index or not need-cover
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
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          ..child.children,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
        // Two-pass: if fn-wrappers are present and container would be hidden,
        // re-run with outer need-cover so fn-wrappers handle their own visibility.
        let would-be-hidden = not (
          calc.min(repetitions, final-repetitions) <= index or not need-cover
        )
        let (conts, inner-max-repetitions) = if (
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
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
          would-be-hidden and inner-has-fn-wrapper
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
          last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result or calc.min(repetitions, final-repetitions) <= index or not need-cover
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
          last-subslide,
          index,
          need-cover,
          (child, cont) => terms.item(child.term, cont),
        )
        // Propagate meanwhile effect from inside the terms item
        if final-repetitions < repetitions {
          if hidden-parts.len() != 0 {
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          force-to-result or calc.min(repetitions, final-repetitions) <= index or not need-cover
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
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
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
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
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
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
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
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
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
          inner-has-fn-wrapper,
        ) = _parse-content-into-results-and-repetitions(
          self: self,
          need-cover: repetitions <= index,
          base: repetitions,
          base-last-subslide: last-subslide,
          index: index,
          child.body,
        )
        has-fn-wrapper = has-fn-wrapper or inner-has-fn-wrapper
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
          would-be-hidden and inner-has-fn-wrapper
        ) {
          let (
            conts2,
            inner-max-repetitions2,
            _,
            _,
            _,
          ) = _parse-content-into-results-and-repetitions(
            self: self,
            need-cover: need-cover,
            base: repetitions,
            base-last-subslide: last-subslide,
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
            result.push(cover-hidden(cover, hidden-parts, result))
            hidden-parts = ()
          }
          max-repetitions = calc.max(max-repetitions, repetitions)
        }
        if (
          would-be-hidden and inner-has-fn-wrapper
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
      result.push(cover-hidden(cover, hidden-parts, result))
      hidden-parts = ()
    }
    parsed-results.push(result.sum(default: []))
  }
  max-repetitions = calc.max(max-repetitions, repetitions)
  return (parsed-results, max-repetitions, last-subslide, repetitions, has-fn-wrapper)
}

// get negative pad for header and footer
#let _get-negative-pad(self) = {
  let margin = self.page.margin
  if (
    type(margin) != dictionary and type(margin) != length and type(margin) != relative and type(margin) != ratio
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
      type(margin) != dictionary and type(margin) != length and type(margin) != relative
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

// Internal slide rendering function. Called by theme slide functions via `touying-slide-wrapper`.
// See the public `slide` function for parameter documentation.
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
    // Weak zero-height spacing that acts as a layout anchor for the current
    // slide.  When a slide body consists entirely of context (lazily evaluated)
    // elements, Typst may not commit to the new page in the first layout pass.
    // This causes hidden headings placed at the start of the *next* slide's
    // preamble to receive the wrong page number, which in turn makes context
    // queries like `display-current-heading` return the wrong heading.
    // Adding `v(0pt, weak: true)` forces Typst to finalize the current page
    // without adding any visible space (the weak flag suppresses it when
    // adjacent to other spacing).
    // See: https://github.com/touying-typ/touying/issues/388
    v(0pt, weak: true)
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
    if (
      (self.handout and not self.at("_handout-secondary", default: false)) or self.subslide == 1
    ) {
      slide-preamble(self)
    }
    [#metadata((kind: "touying-new-subslide")) <touying-metadata>]
    if (
      self.at("enable-frozen-states-and-counters", default: true) and not self.handout and self.repeat > 1
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
    if (
      (self.handout and not self.at("_handout-secondary", default: false)) or self.subslide == 1
    ) {
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
  // Pre-collect waypoints so label resolution works during the initial parse pass.
  // If any body is a function (callback-style slide), call it with the current self
  // to materialise content. The global #waypoint/#uncover/#only functions only emit
  // metadata and do not rely on self.waypoints, so this is safe.
  let self-for-prepass = self + (_waypoint-prepass: true)
  let resolved-bodies = bodies.map(b => if type(b) == function {
    b(self-for-prepass)
  } else { b })
  // Set preliminary single-point ranges (first == last == raw subslide number);
  // proper ranges are computed after `repeat` is known.
  let raw-waypoints = _collect-waypoints(..resolved-bodies)
  self.waypoints = (:)
  for (lbl, sub) in raw-waypoints.pairs() {
    self.waypoints.insert(lbl, (first: sub, last: sub))
  }
  // for single page slide, get the repetitions
  if repeat == auto {
    let (
      _,
      repetitions,
      last-subslide,
      _,
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
  // Recompute waypoint ranges with the actual repeat count
  self.waypoints = _compute-waypoint-ranges(raw-waypoints, repeat)
  // page header and footer
  let (header, footer, body-transform) = _get-header-footer(self)
  let page-extra-args = _get-page-extra-args(self)

  if self.handout {
    let handout-subslides = self.at("handout-subslides", default: none)
    if handout-subslides == none {
      // Original behavior: render only the last subslide
      self.subslide = repeat
      let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
        self: self,
        index: repeat,
        show-delayed-wrapper: true,
        ..bodies,
      )
      header = page-preamble(self) + header
      set page(
        ..(self.page + page-extra-args + (header: header, footer: footer)),
      )
      body-transform(setting-fn(
        subslide-preamble(self) + composer-with-side-by-side(..conts),
      ))
    } else {
      // Render only the subslides that match handout-subslides
      let handout-subslide-indices = range(1, repeat + 1).filter(
        i => utils.check-visible(i, handout-subslides),
      )
      // Fall back to the last subslide if none match
      if handout-subslide-indices.len() == 0 {
        handout-subslide-indices = (repeat,)
      }
      let result = ()
      for (pos, i) in handout-subslide-indices.enumerate() {
        let is-first = pos == 0
        let is-last = pos == handout-subslide-indices.len() - 1
        let subslide-self = self
        subslide-self.subslide = i
        // Disable frozen states for handout multi-subslide rendering
        subslide-self.enable-frozen-states-and-counters = false
        // For non-first subslides, mark as a secondary handout page so that
        // slide/page preambles and the slide counter are not repeated, while
        // keeping handout: true so that handout-only content remains visible.
        if not is-first {
          subslide-self._handout-secondary = true
        }
        let (header-i, footer-i, body-transform-i) = _get-header-footer(
          subslide-self,
        )
        let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
          self: subslide-self,
          index: i,
          show-delayed-wrapper: is-last,
          ..bodies,
        )
        let new-header = page-preamble(subslide-self) + header-i
        result.push({
          set page(
            ..(
              subslide-self.page + page-extra-args + (header: new-header, footer: footer-i)
            ),
          )
          body-transform-i(setting-fn(
            subslide-preamble(subslide-self) + composer-with-side-by-side(..conts),
          ))
        })
      }
      result.sum(default: none)
    }
  } else if self.at("_recall-subslide", default: none) != none {
    // Render specific subslide(s) requested by touying-recall.
    // The spec is resolved here because `repeat` and `self.waypoints`
    // are only available after the pre-pass above.
    let recall-spec = self._recall-subslide
    let recall-indices = if recall-spec == auto {
      // auto → last subslide only
      (repeat,)
    } else if type(recall-spec) == int {
      // Explicit single subslide
      (recall-spec,)
    } else if type(recall-spec) == str and recall-spec == "waypoints" {
      // "waypoints" → last subslide of every waypoint
      let wp-map = self.at("waypoints", default: (:))
      if wp-map.len() == 0 {
        (repeat,)
      } else {
        let sorted = wp-map.pairs().sorted(key: p => p.at(1).first)
        sorted.map(p => p.at(1).last).dedup()
      }
    } else if type(recall-spec) == label or type(recall-spec) == dictionary {
      // Waypoint label or marker — resolve using the slide's waypoint map
      let resolved = utils.resolve-waypoints(self, recall-spec)
      if type(resolved) == int {
        (resolved,)
      } else if type(resolved) == dictionary {
        let first = resolved.at("beginning", default: resolved.at(
          "first",
          default: 1,
        ))
        let last = resolved.at("until", default: resolved.at(
          "last",
          default: repeat,
        ))
        range(first, last + 1)
      } else {
        panic(
          "touying-recall: unexpected resolved waypoint type: " + repr(resolved),
        )
      }
    } else {
      panic(
        "touying-recall: subslide must be none, auto, int, \"waypoints\", label, or waypoint marker, got "
          + str(type(recall-spec)),
      )
    }
    // Validate and render each requested subslide
    let result = ()
    for i in recall-indices {
      assert(
        i >= 1 and i <= repeat,
        message: "touying-recall: subslide " + str(i) + " is out of range (1.." + str(repeat) + ")",
      )
      self.subslide = i
      let (header, footer, body-transform) = _get-header-footer(self)
      let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
        self: self,
        index: i,
        show-delayed-wrapper: i == repeat,
        ..bodies,
      )
      let new-header = page-preamble(self) + header
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
    result.sum()
  } else {
    // render all the subslides
    let result = ()
    for i in range(1, repeat + 1) {
      self.subslide = i
      let (header, footer, body-transform) = _get-header-footer(self)
      let delayed-args = if i == repeat {
        (show-delayed-wrapper: true)
      }
      let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
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
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto, int): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array, int, auto): The composer arranges multiple content bodies side by side.
///
///   - `auto`: use the theme default (`components.side-by-side`)
///   - array, e.g. `(1fr, 2fr, 1fr)`: column widths for `side-by-side`
///   - int: equal columns shorthand
///   - function: fully custom layout, e.g. `grid.with(columns: 2)`
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` splits the slide into three columns.
///
///   If you want to customize the composer, you can pass a function like `#slide(composer: grid.with(columns: 2))[A][B]`.
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


/// Empty slide with no default heading or section context.
///
/// Unlike `slide`, this function does not look at heading context or trigger `new-section-slide-fn` / `new-subsection-slide-fn`. Use it to create isolated slides outside the normal slide hierarchy (e.g. a standalone title card).
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto, int): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
/// - setting (function): Set/show rules to apply for the slide. Receives the composed body and returns it.
///
/// - composer (function, array, int, auto): Arranges multiple body blocks side-by-side. Same semantics as `slide`.
///
/// - bodies (arguments): The content blocks of the slide.
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
