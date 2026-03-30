#import "../utils.typ"
#import "../pdfpc.typ"
#import "../components.typ"
#import "waypoints.typ": (
  _compute-waypoint-ranges, _cover-never, _resolve-waypoint-forest,
  _waypoint-known, waypoint-kinds,
)
#import "parser.typ": (
  _collect-waypoints, _count-animated-block-repetitions, _find-reducer-meta,
  _parse-content-into-results-and-repetitions, _parse-touying-reducer,
)
#import "animation.typ": touying-slide-wrapper
#import "docmode.typ": (
  _collect-labeled-blocks, _collect-labeled-reducers, _document-linearize,
  _extract-image, _is-block-content, _scan-content-for-labeled-blocks,
  _scan-content-for-labeled-reducers, render-content-as-document,
)

#let _delayed-wrapper(body) = [#metadata((
  kind: "touying-delayed-wrapper",
  body: body,
))<touying-temporary-mark>]

/// Inject configuration changes into a block of content. Changes take effect only within `body`. Useful for implementing features like `#show: appendix` or changing the cover method on the fly.
///
/// Example: `#let appendix(body) = touying-set-config((appendix: true), defer:true, body)` and you can use `#show: appendix` to set the appendix for the presentation.
///
/// The keyword `defer` is useful for features like `appendix`, which should not take effect until the next slide starts. All following content is also then wrapped into the preamble, e.g. `counter-update`, set or other show rules. Putting content after a deferred config show rule will not render it visibly in the document.
/// You may even use `#show: touying-set-config.with((preamble: fn), defer:true)` to set a preamble function for the next slide or do similar config changes without calling the `slide` function explicitly.
/// Just relying on the deferred config change's ability to capture functions and running them also in the preamble is considered an antipattern.
///
/// - config (dictionary): The new configurations for the presentation.
///
/// - defer (bool): Whether to defer applying the config changes until the next slides preamble. Default is false (apply immediately).
///
/// - body (content): The content of the slide.
///
/// -> content
#let touying-set-config(config, defer: false, body) = [#metadata((
  kind: "touying-set-config",
  config: config,
  defer: defer,
  body: body,
))<touying-temporary-mark>]


/// Begin the appendix of the presentation. The slide counter is frozen at the last non-appendix slide, so appendix slides do not affect the total slide count shown in footers.
///
/// Equivalent to `#show: touying-set-config.with((appendix: true), defer: true)`.
///
/// Example: `#show: appendix`
///
/// - body (content): The content of the appendix.
///
/// -> content
#let appendix(body) = touying-set-config(
  (appendix: true),
  body,
  defer: true,
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
// - absorb-leading-preamble (bool): Whether to include the preamble content from before the next split
// - body (content): The content to be split into slides
//
// -> content
#let split-content-into-slides(
  self: none,
  recaller-map: (:),
  new-start: true,
  is-first-slide: false,
  absorb-leading-preamble: false,
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

  let _check-current-mode-skip(self, lbl) = {
    if lbl == none or not lbl.starts-with("touying:") { return false }

    let parts = lbl.slice("touying:".len()).split("-")
    // Only apply mode-filtering if the label actually names a mode.
    // Labels like touying:hidden / touying:skip carry no mode intent.
    let has-mode-keyword = (
      "presentation" in parts
        or "handout" in parts
        or "slides" in parts
        or "document" in parts
    )
    if not has-mode-keyword { return false }

    let in-presentation = "presentation" in parts and not self.handout
    let in-handout = "handout" in parts and self.handout
    let in-slides = (
      ("slides" in parts or in-presentation or in-handout)
        and not self.at("document-mode", default: false)
    )
    let in-document = (
      "document" in parts and self.at("document-mode", default: false)
    )

    not in-slides and not in-document
  }

  children = children.map(sequence-to-array).flatten()
  let call-slide-fn-and-reset(
    self,
    slide-fn,
    current-slide-cont,
    recaller-map,
    already-slide-wrapper: false,
  ) = {
    let last-heading-label = _get-last-heading-label(self.headings)

    // Skip sections with mode-specific labels when not in that mode
    if _check-current-mode-skip(self, last-heading-label) {
      // Return early without the slide.
      return (none, recaller-map, (), (), true, false)
    }
    let (slide-content, callable) = if already-slide-wrapper {
      (slide-fn(self), slide-fn)
    } else {
      _call-slide-fn(self, slide-fn, current-slide-cont)
    }
    //debug
    let dbg-node = [#metadata((
      fn: "inside-wrapper",
      self-headings: self.headings,
    ))<dbg>]
    slide-content = dbg-node + slide-content

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
  // leading preamble to collect content from before the slide break
  let leading-preamble = ()

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
      if slide-parts != () or current-headings != () {
        let flush-self = (
          self
            + (
              headings: current-headings,
              is-first-slide: is-first-slide,
              leading-preamble: leading-preamble,
            )
        )
        leading-preamble = ()
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          flush-self,
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }
      horizontal-line = false
      absorb-leading-preamble = false
    }
    // Main logic
    if utils.is-kind(child, "touying-slide-wrapper") {
      slide-parts = utils.trim(slide-parts)
      if (
        slide-parts != ()
          or _get-slide-fn(self + (headings: current-headings), default: none)
            != none
      ) {
        let flush-self = (
          self
            + (
              headings: current-headings,
              is-first-slide: is-first-slide,
              leading-preamble: leading-preamble,
            )
        )
        leading-preamble = ()
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          flush-self,
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }

      let slide-self = (
        self + (headings: current-headings, is-first-slide: is-first-slide)
      )

      //debug
      output-slides.push([#metadata((
        fn: "before-wrapper-call",
        current-headings: current-headings,
      ))<dbg>])

      // honor uses wishes like <touying:handout> etc. by skipping depending on the mode. Same as for the heading-based skipping logic.
      // we allow multiple: e.g. <touying:handout-presentation>, or even <touying:presentation-document>, you may write <touying:slides> as a short for <touying:presentation-handout>
      if child.has("label") {
        let slide_label = str(child.label)
        if _check-current-mode-skip(self, slide_label) {
          continue
        }
      }

      (
        slide-content,
        recaller-map,
        current-headings,
        slide-parts,
        new-start,
        is-first-slide,
      ) = call-slide-fn-and-reset(
        slide-self,
        child.value.fn,
        none,
        recaller-map,
        already-slide-wrapper: true,
      )
      if child.has("label") and child.label != <touying-temporary-mark> {
        recaller-map.insert(str(child.label), (
          content: slide-content,
          callable: child.value.fn,
          slide-self: slide-self,
        ))
      }
      if slide-content != none { output-slides.push(slide-content) }
      absorb-leading-preamble = false
    } else if utils.is-kind(child, "touying-slide-recaller") {
      slide-parts = utils.trim(slide-parts)
      if slide-parts != () or current-headings != () {
        let flush-self = (
          self
            + (
              headings: current-headings,
              is-first-slide: is-first-slide,
              leading-preamble: leading-preamble,
            )
        )
        leading-preamble = ()
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          flush-self,
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
      absorb-leading-preamble = false
    } else if child in (pagebreak(), pagebreak(weak: true)) {
      // split content when we have a pagebreak
      slide-parts = utils.trim(slide-parts)
      if slide-parts != () or current-headings != () {
        let flush-self = (
          self
            + (
              headings: current-headings,
              is-first-slide: is-first-slide,
              leading-preamble: leading-preamble,
            )
        )
        leading-preamble = ()
        (
          slide-content,
          recaller-map,
          current-headings,
          slide-parts,
          new-start,
          is-first-slide,
        ) = call-slide-fn-and-reset(
          flush-self,
          slide-fn,
          slide-parts.sum(default: none),
          recaller-map,
        )
        if slide-content != none { output-slides.push(slide-content) }
      }
      absorb-leading-preamble = false
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
          or (child.depth == 1 and new-section-slide-fn != none)
          or (child.depth == 2 and new-subsection-slide-fn != none)
          or (child.depth == 3 and new-subsubsection-slide-fn != none)
          or (child.depth == 4 and new-subsubsubsection-slide-fn != none)
      ) {
        slide-parts = utils.trim(slide-parts)
        if slide-parts != () or current-headings != () {
          let flush-self = (
            self
              + (
                headings: current-headings,
                is-first-slide: is-first-slide,
                leading-preamble: leading-preamble,
              )
          )
          leading-preamble = ()
          (
            slide-content,
            recaller-map,
            current-headings,
            slide-parts,
            new-start,
            is-first-slide,
          ) = call-slide-fn-and-reset(
            flush-self,
            slide-fn,
            slide-parts.sum(default: none),
            recaller-map,
          )
          if slide-content != none { output-slides.push(slide-content) }
        }
      }

      current-headings.push(child)
      new-start = true
      absorb-leading-preamble = false

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
      // When absorbing leading preamble and no heading seen yet, recurse with
      // the merged config applied to self and the leading preamble prepended.
      // Unlike styled nodes, config nodes have no .child — use .value.body.
      // There is also nothing to reconstruct-styled: the config cascades via self.
      if absorb-leading-preamble and current-headings == () {
        let inner-body = if leading-preamble != () {
          leading-preamble.sum(default: none) + child.value.body
        } else {
          child.value.body
        }
        leading-preamble = ()
        output-slides.push(
          split-content-into-slides(
            self: utils.merge-dicts(self, child.value.config),
            recaller-map: recaller-map,
            new-start: true,
            is-first-slide: is-first-slide,
            absorb-leading-preamble: true,
            inner-body,
          ),
        )
      } else {
        // now the big complicated logic ...
        slide-parts = utils.trim(slide-parts)
        let is-deferred = child.value.at("defer", default: false)
        // In probe mode (is-new-start=false), slide-parts starts empty by
        // design — that alone must not trigger deferred. Only explicit
        // defer:true, or actual-split mode (is-new-start) with no accumulated
        // content, goes through the deferred path.
        if is-deferred or (is-new-start and slide-parts == ()) {
          // Deferred path: flush current slide (if any body content), then
          // recursively process the config body as a fresh start with
          // absorb-leading-preamble so counter-updates/metadata before the
          // first heading are deferred, not ghost-flushed.
          // For explicitly-deferred configs (e.g. appendix), also flush when
          // current-headings is non-empty so the heading becomes a regular
          // slide instead of leaking into the appendix body.
          // For non-deferred configs that fire because slide-parts=(), do NOT
          // flush the heading — it belongs to the config body and goes into
          // pending-headings below.
          if slide-parts != () or (is-deferred and current-headings != ()) {
            let flush-self = (
              self
                + (
                  headings: current-headings,
                  is-first-slide: is-first-slide,
                  leading-preamble: leading-preamble,
                )
            )
            leading-preamble = ()
            (
              slide-content,
              recaller-map,
              current-headings,
              slide-parts,
              new-start,
              is-first-slide,
            ) = call-slide-fn-and-reset(
              flush-self,
              slide-fn,
              slide-parts.sum(default: none),
              recaller-map,
            )
            if slide-content != none { output-slides.push(slide-content) }
          }
          // Forward any pending headings and any accumulated leading-preamble
          // into the recursive body so counter-updates and state changes that
          // arrived before the first heading are not silently dropped.
          // (When slide-parts was non-empty the flush above already cleared
          // leading-preamble; when slide-parts was empty it was not cleared.)
          let pending-headings = current-headings
          current-headings = ()
          slide-parts = ()
          let recursive-body = {
            let parts = ()
            if leading-preamble != () {
              parts.push(leading-preamble.sum(default: none))
            }
            if pending-headings != () {
              parts.push(pending-headings.sum(default: none))
            }
            parts.push(child.value.body)
            parts.sum(default: none)
          }
          leading-preamble = ()
          output-slides.push(
            split-content-into-slides(
              self: utils.merge-dicts(self, child.value.config),
              recaller-map: recaller-map,
              new-start: true,
              absorb-leading-preamble: true,
              recursive-body,
            ),
          )
        } else {
          // Immediate path: slide-parts is non-empty and defer is false.
          // Handle like styled content — split the config body, recombine
          // pre-break content with the current slide, and emit the rest.
          // This keeps mid-slide config changes (e.g. cover method) on the
          // current slide so that #pause / #meanwhile still work.
          let merged-self = utils.merge-dicts(self, child.value.config)
          // Do NOT forward pending headings — they belong to the current
          // slide and will be used when flushing.  Only use the raw config
          // body for the probe so that start-part captures pre-break content.
          // Probe the body for slide breaks.
          let (
            inner-start-part,
            slide-content-part,
          ) = split-content-into-slides(
            self: merged-self,
            recaller-map: recaller-map,
            new-start: false,
            child.value.body,
          )
          if slide-content-part != none {
            // The config body contains slide-breaking content.
            // Recombine pre-break content (inner-start-part) with the current
            // slide, flush, then emit the remaining slides.
            // In probe mode (new-start=false) push to start-part so the
            // caller can collect it; in actual-split push to slide-parts.
            // no is-first-slide branch needed here, unlike style nodes. is-first-slide already there from outside.
            if inner-start-part != none {
              if new-start {
                slide-parts.push(inner-start-part)
              } else {
                start-part.push(inner-start-part)
              }
            }
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              let flush-self = (
                merged-self
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                    leading-preamble: leading-preamble,
                  )
              )
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                flush-self,
                slide-fn,
                slide-parts.sum(default: none),
                recaller-map,
              )
              if slide-content != none { output-slides.push(slide-content) }
            }
            current-headings = ()
            slide-parts = ()
            output-slides.push(slide-content-part)
          } else {
            // No slide breaks in the config body — all content stays on the
            // current slide.  Flush immediately with the merged config since
            // the config body wraps all remaining content (show-rule
            // semantics) and the for-loop has no more children after this.
            // In probe mode (new-start=false) push to start-part; in
            // actual-split push to slide-parts.
            if inner-start-part != none {
              if new-start {
                slide-parts.push(inner-start-part)
              } else {
                start-part.push(inner-start-part)
              }
            }
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              let flush-self = (
                merged-self
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                    leading-preamble: leading-preamble,
                  )
              )
              leading-preamble = ()
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                flush-self,
                slide-fn,
                slide-parts.sum(default: none),
                recaller-map,
              )
              if slide-content != none { output-slides.push(slide-content) }
            }
            current-headings = ()
            slide-parts = ()
          }
        }
      }
    } else if (
      utils.is-kind(child, "touying-document-text")
        or utils.is-kind(child, "touying-document-only")
    ) {
      // Document-only content — silently skip here, as this is not reachable in document mode
      continue
    } else if utils.is-kind(child, "touying-slides-only") {
      //for presentation, handout and both
      //debug
      let _ = [slides-only body: #repr(child.value.body)]
      // Slides-only content — inline the body in slides mode
      let (inner-start-part, slide-content-part) = split-content-into-slides(
        self: self,
        recaller-map: recaller-map,
        new-start: false,
        child.value.body,
      )
      if slide-content-part != none {
        panic(
          "touying-slides-only: only-content should not contain slide breaking elements."
            + repr(slide-content-part),
        )
      }
      slide-parts.push(inner-start-part)
    } else if utils.is-styled(child) {
      // When absorbing leading preamble and no heading seen yet, recurse into
      // the styled node with absorb-leading-preamble: true. The set/show rules
      // will propagate via reconstruct-styled on the output.
      if absorb-leading-preamble and current-headings == () {
        let inner-body = if leading-preamble != () {
          leading-preamble.sum(default: none) + child.child
        } else {
          child.child
        }
        leading-preamble = ()
        let inner-result = split-content-into-slides(
          self: self,
          recaller-map: recaller-map,
          new-start: true,
          is-first-slide: is-first-slide,
          absorb-leading-preamble: true,
          inner-body,
        )
        output-slides.push(utils.reconstruct-styled(child, inner-result))
      } else {
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
            // On the first slide, calling with new-start: false causes
            // content after headings to land in start-part instead of slide-parts,
            // resulting in slides with missing bodies. Re-call with new-start: true
            // to build slides correctly, and flush any accumulated content beforehand.
            // There is no previous slide to reconcile inner-start-part onto, so we
            // do NOT attempt to reconcile it here.
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              let flush-self = (
                self
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                    leading-preamble: leading-preamble,
                  )
              )
              leading-preamble = ()
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                flush-self,
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
            slide-parts = utils.trim(slide-parts)
            if slide-parts != () or current-headings != () {
              let flush-self = (
                self
                  + (
                    headings: current-headings,
                    is-first-slide: is-first-slide,
                    leading-preamble: leading-preamble,
                  )
              )
              leading-preamble = ()
              (
                slide-content,
                recaller-map,
                current-headings,
                slide-parts,
                new-start,
                is-first-slide,
              ) = call-slide-fn-and-reset(
                flush-self,
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
      }
    } else {
      if absorb-leading-preamble and current-headings == () {
        // Before any heading is seen, accumulate as preamble to inject into
        // the first real slide's content — avoids ghost slides from counter-updates
        // and metadata injected by touying-set-config bodies.
        leading-preamble.push(child)
      } else if new-start {
        slide-parts.push(child)
      } else {
        start-part.push(child)
      }
    }
  }

  // Handle the last slide
  slide-parts = utils.trim(slide-parts)
  if slide-parts != () or current-headings != () {
    let flush-self = (
      self
        + (
          headings: current-headings,
          is-first-slide: is-first-slide,
          leading-preamble: leading-preamble,
        )
    )
    leading-preamble = ()
    (
      slide-content,
      recaller-map,
      current-headings,
      slide-parts,
      new-start,
      is-first-slide,
    ) = call-slide-fn-and-reset(
      flush-self,
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


// Assemble a subsection's content with optional wrapping.
//
// - items: text/heading content
// - images: array of (element, width, is-figure) dicts
// - blocks: array of block-level content (tables, canvases, etc.)
// - wrap-images: wrap raw images via wrap-it (default: true)
// - wrap-image-figures: wrap image figures via wrap-it (default: false)
// - wrap-other-figures: wrap other figures via wrap-it (default: false)
// - wrap-other: wrap other content via wrap-it (default: false)
// - wrap-align-direction: direction to align wrapped content (default: right)

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
    // do the leading function calls first
    let leading-preamble = self
      .at("leading-preamble", default: ())
      .sum(default: none)
    utils.call-or-display(self, leading-preamble)

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
      (self.handout and not self.at("_handout-secondary", default: false))
        or self.subslide == 1
    ) {
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
    if (
      (self.handout and not self.at("_handout-secondary", default: false))
        or self.subslide == 1
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
  let (raw-waypoints, start-overrides, decl-reps) = _collect-waypoints(
    ..resolved-bodies,
  )
  // Resolve explicit `start` overrides (forest resolution) before anything
  // else, so that every waypoint has its final subslide position.
  let raw-waypoints = _resolve-waypoint-forest(raw-waypoints, start-overrides)
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
  // Ensure repeat covers all resolved waypoint positions (e.g. start: 5
  // requires at least 5 subslides even if the content has fewer pauses).
  if raw-waypoints.len() > 0 {
    repeat = calc.max(repeat, calc.max(..raw-waypoints.values()))
  }
  assert(type(repeat) == int, message: "The repeat should be an integer")
  self.repeat = repeat
  // Recompute waypoint ranges with the actual repeat count
  self.waypoints = _compute-waypoint-ranges(
    raw-waypoints,
    repeat,
    start-overrides,
    decl-reps,
  )
  // page header and footer
  let (header, footer, body-transform) = _get-header-footer(self)
  let page-extra-args = _get-page-extra-args(self)

  if self.at("document-mode", default: false) {
    // Document mode: render last subslide inline, no page breaks, no preambles.
    self.subslide = repeat
    let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
      self: self,
      index: repeat,
      show-delayed-wrapper: true,
      ..bodies,
    )
    // Store raw data for labeled reducers and labeled blocks (JIT rendering).
    let labeled-reducers = _collect-labeled-reducers(..resolved-bodies)
    let labeled-blocks = _collect-labeled-blocks(..resolved-bodies)
    let block-recall-map = (:)
    for (lbl-str, reducer-data) in labeled-reducers {
      block-recall-map.insert(lbl-str, (
        kind: "reducer",
        data: reducer-data,
        waypoints: self.waypoints,
        repeat: repeat,
      ))
    }
    for (lbl-str, block-content) in labeled-blocks {
      // Determine max subslide count for this block
      let (
        _,
        max-rep-raw,
        _,
        _,
        _,
      ) = _parse-content-into-results-and-repetitions(
        self: self + (waypoints: (:), subslide: 9999),
        base: 1,
        index: 9999,
        block-content,
      )
      let max-rep = calc.max(max-rep-raw, 1)
      block-recall-map.insert(lbl-str, (
        kind: "block",
        data: block-content,
        waypoints: self.waypoints,
        repeat: max-rep,
      ))
    }
    // Linearize: returns (content: .., images: .., blocks: ..)
    let result = _document-linearize(self, composer, conts)
    // If extracting, return the full dict so render-content-as-document
    // can collect images/blocks at subsection level.
    let has-extracted = result.images.len() > 0 or result.blocks.len() > 0
    if self.at("document-extract-content", default: false) and has-extracted {
      let content = if result.content != none {
        setting-fn(result.content)
      } else { none }
      return (
        content: content,
        images: result.images,
        blocks: result.blocks,
        block-recall-map: block-recall-map,
        waypoint-map: self.waypoints,
      )
    }
    return (
      content: setting-fn(result.content),
      block-recall-map: block-recall-map,
      waypoint-map: self.waypoints,
    )
  }

  let _resolve-handout-waypoint(self, lbl) = {
    let resolved = utils.resolve-waypoints(self, lbl)
    if type(resolved) == int {
      (resolved,)
    } else if type(resolved) == dictionary {
      // resolve waypoint to the first subslide. This is how waypoints are always resolved for single integer application like some `start`field.
      let first = resolved.at("beginning", default: resolved.at(
        "first",
        default: 1,
      ))
      // let last = resolved.at("until", default: resolved.at(
      //   "last",
      //   default: repeat,
      // ))
      (first,)
    } else {
      panic(
        "touying-slide: unexpected resolved waypoint type for handout-subslides: "
          + repr(resolved),
      )
    }
  }

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
      return {
        set page(
          ..(self.page + page-extra-args + (header: header, footer: footer)),
        )
        body-transform(setting-fn(
          subslide-preamble(self) + composer-with-side-by-side(..conts),
        ))
      }
    }

    if type(handout-subslides) == array {
      for (i, subslide-idx) in handout-subslides.enumerate() {
        if (
          type(subslide-idx) == label
            or (
              type(subslide-idx) == dictionary
                and subslide-idx.at("kind", default: "") in waypoint-kinds
            )
        ) {
          handout-subslides[i] = _resolve-handout-waypoint(self, subslide-idx) //resolve waypoint labels to first subslide, only for handout
        } else if type(subslide-idx) == int or type(subslide-idx) == str {
          // do nothing
        } else {
          panic(
            "touying-slide: if handout-subslides is an array, it must be integers, strings, or waypoint labels/markers, got type "
              + str(type(subslide-idx))
              + " for element "
              + repr(subslide-idx),
          )
        }
      }
    }
    //negative indices in string not defined/supported, and they can even have ! for inversion.
    let handout-subslides = utils.resolve-negative-subslides(
      self.repeat,
      handout-subslides,
    )

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
            subslide-self.page
              + page-extra-args
              + (header: new-header, footer: footer-i)
          ),
        )
        body-transform-i(setting-fn(
          subslide-preamble(subslide-self)
            + composer-with-side-by-side(..conts),
        ))
      })
    }

    result.sum(default: none)
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
      (utils.resolve-negative-subslides(self.repeat, recall-spec),)
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
        //waypoints resolve to the whole animation sequence. If specific slides are needed use the waypoint marker functions.
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
          "touying-recall: unexpected resolved waypoint type: "
            + repr(resolved),
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
        message: "touying-recall: subslide "
          + str(i)
          + " is out of range (1.."
          + str(repeat)
          + ")",
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
  if self.slide-fn != slide {
    let wrapper = (self.slide-fn)(
      config: config,
      repeat: repeat,
      setting: setting,
      composer: composer,
      ..bodies,
    )
    (wrapper.value.fn)(self)
  } else {
    touying-slide(
      self: self,
      config: config,
      repeat: repeat,
      setting: setting,
      composer: composer,
      ..bodies,
    )
  }
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
