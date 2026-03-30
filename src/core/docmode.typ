#import "../utils.typ"
#import "waypoints.typ": (
  _compute-waypoint-ranges, _cover-never, _resolve-waypoint-forest,
  _waypoint-known, waypoint-kinds,
)
#import "parser.typ": (
  _collect-waypoints, _find-reducer-meta,
  _parse-content-into-results-and-repetitions, _parse-touying-reducer,
)

/// Content that replaces the slide content when in document mode. Place it after your slide, before the next one.
///
/// You can use this to write a prose alternative to your slides' bullet points,
/// and even properly use figures etc which will be rendered in the document normally.
///
/// - body (content): The document-text content.
///
/// -> content
#let document-text(body) = [#metadata((
  kind: "touying-document-text",
  body: body,
))<touying-temporary-mark>]


/// Content that only appears in document mode.
///
/// Unlike `document-text`, this does NOT replace a preceding slide's content.
/// Use this for standalone sections or inline content that should only exist in the document
/// output (e.g., inline: footnotes, remarks; sections: appendices, methodology, acknowledgements, extended discussion).
///
/// - body (content): The document-only content.
///
/// -> content
#let document-only(body) = [#metadata((
  kind: "touying-document-only",
  body: body,
))<touying-temporary-mark>]


#let _wrap-section(
  items,
  images,
  blocks,
  wrap-images: true,
  wrap-image-figures: false,
  wrap-other-figures: false,
  wrap-other: false,
  wrap-align-direction: right,
) = {
  import "@preview/wrap-it:0.1.1": wrap-content

  // Flatten content to plain text — wrap-it needs splittable text
  let _to-text(c) = {
    if c == none { return "" }
    if type(c) == str { return c }
    if type(c) != content { return "" }
    if c.has("text") { return c.text }
    if c.has("children") { return c.children.map(_to-text).join("") }
    if c.has("body") { return _to-text(c.body) }
    if c.has("child") { return _to-text(c.child) }
    ""
  }

  let _scale-image = utils.rescale-image

  // For figures: scale the image with inv (via _scale-image), then render
  // the caption separately below at obstacle-width so it doesn't overflow.
  let _scale-img-figure(
    fig-el,
    img-el,
    col-fraction,
    content-width,
    align-direction,
  ) = {
    let obstacle-width = (col-fraction * 1pt).pt() * content-width
    let scaled-img = _scale-image(
      img-el,
      img-el,
      col-fraction,
      align-direction,
      container-width: content-width,
    )
    let caption = fig-el.at("caption", default: none)

    stack(
      spacing: 0.5em,
      scaled-img,
      if caption != none {
        box(width: obstacle-width, align(center, caption))
      },
    )
  }

  // Resolve content width via layout at the top level — before wrap-it
  // narrows the container — so _scale-image gets the true content area width.
  layout(size => {
    let content-width = size.width

    let raw-images = images.filter(i => not i.is-figure)
    let figure-images = images.filter(i => i.is-figure)

    // Collect all elements to wrap via wrap-it
    let to-wrap = ()
    if wrap-images {
      to-wrap += raw-images.map(i => _scale-image(
        i.element,
        i.element,
        i.col-fraction,
        wrap-align-direction,
        container-width: content-width,
      ))
    }
    if wrap-image-figures {
      to-wrap += figure-images.map(i => {
        let img = i.element.at("body", default: none)
        if img != none and img.func() == image {
          _scale-img-figure(
            i.element,
            img,
            i.col-fraction,
            content-width,
            wrap-align-direction,
          )
        } else {
          i.element
        }
      })
    }
    if wrap-other {
      to-wrap += blocks
    }

    let result = ()

    if to-wrap.len() > 0 {
      // Separate headings from wrappable content — wrap-it can't split headings.
      let headings = items.filter(r => (
        type(r) == content and r.func() == heading
      ))
      let body-parts = items.filter(r => {
        not (type(r) == content and r.func() == heading)
      })
      // Unwrap single-child blocks to expose splittable text to wrap-it
      let unwrapped = body-parts.map(r => {
        if type(r) == content and r.func() == block {
          let body = r.at("body", default: none)
          if body != none { body } else { r }
        } else {
          r
        }
      })

      result += headings
      let text = unwrapped.sum(default: none)
      let plain = _to-text(text)

      // Wrap each element around the text
      for (idx, el) in to-wrap.enumerate() {
        if idx < to-wrap.len() - 1 {
          result.push(wrap-content(el, plain, align: wrap-align-direction))
          plain = ""
        } else {
          result.push(wrap-content(el, plain, align: wrap-align-direction))
        }
      }
    } else {
      result += items
    }

    // Non-wrapped raw images → centered at end
    if not wrap-images {
      for img in raw-images {
        result.push(align(center, img.element))
      }
    }

    // Non-wrapped figures → centered at end
    if not wrap-image-figures {
      for fig in figure-images {
        result.push(align(center, fig.element))
      }
    }

    // Non-wrapped block content → centered at end
    if not wrap-other {
      for b in blocks {
        result.push(align(center, b))
      }
    }

    result.sum(default: none)
  })
}


// Extract an image from content (direct image, figure containing one,
// or a sequence/block whose only meaningful child is an image).
// Returns a dictionary (element: content, img: image-element) or none.
// `element` is what should be displayed (figure with caption, or raw image).
// `img` is the raw image element (for reading width).
#let _extract-image(cont) = {
  if cont == none { return none }
  if type(cont) != content { return none }
  if cont.func() == image {
    return (element: cont, img: cont, is-figure: false)
  }
  if cont.func() == figure {
    let body = cont.at("body", default: none)
    if body != none and type(body) == content and body.func() == image {
      // Preserve the whole figure (including caption) as the display element
      return (element: cont, img: body, is-figure: true)
    }
  }
  // Sequence or block: dig into children to find a single image
  let children = if utils.is-sequence(cont) {
    cont.children.filter(c => c != [ ] and c != parbreak())
  } else if cont.func() == block {
    let body = cont.at("body", default: none)
    if body != none { (body,) } else { () }
  } else {
    ()
  }
  if children.len() == 1 {
    return _extract-image(children.first())
  }
  return none
}

// Check if content is block-level (table, grid, figure without image,
// box with explicit dimensions, or a block/sequence whose only meaningful
// child is block-level).
// These should be centered at the end of their subsection in document mode.
#let _is-block-content(cont) = {
  if cont == none or type(cont) != content { return false }
  let f = cont.func()
  if f == table or f == grid { return true }
  // Figure that does NOT contain an image (e.g. wrapping a canvas or table)
  if f == figure {
    let body = cont.at("body", default: none)
    if body == none or body.func() != image { return true }
    return false
  }
  // Box with explicit dimensions (e.g. cetz canvas output)
  if f == box {
    let w = cont.at("width", default: auto)
    let h = cont.at("height", default: auto)
    if w != auto or h != auto { return true }
  }
  // A bare `context` element as the sole body content is typically a computed
  // visual element (e.g. cetz canvas, styled block), not flowing text.
  if [#f].text == "context" { return true }
  // Block wrapping block-level content
  if f == block {
    let body = cont.at("body", default: none)
    if body != none { return _is-block-content(body) }
  }
  // Sequence with a single meaningful child — filter out spaces, parbreaks, and
  // other whitespace-like elements to find the "real" content.
  if utils.is-sequence(cont) {
    let _space-func = [#"a" b].children.at(1).func()
    let meaningful = cont.children.filter(c => {
      if c == [ ] or c == parbreak() { return false }
      if type(c) == content and c.func() == _space-func { return false }
      true
    })
    if meaningful.len() == 1 {
      return _is-block-content(meaningful.first())
    }
  }
  false
}

// Linearize slide bodies for document mode.
//
// Returns a dictionary:
// - content: the text bodies joined as content
// - images: array of (img: content, width: length) for meander wrapping
// - blocks: array of block-level content (tables, canvases, non-image figures)
//           to be centered at the end of the subsection
#let _document-linearize(self, composer, conts) = {
  let doc-cfg = self.at("document", default: (:))
  let any-wrapping = (
    doc-cfg.at("wrap-images", default: true)
      or doc-cfg.at("wrap-figures", default: false)
      or doc-cfg.at("wrap-graphics", default: false)
  )

  if not any-wrapping {
    return (content: conts.map(c => block(c)).join(), images: (), blocks: ())
  }

  // Compute column fractions from composer to scale images correctly.
  // E.g. (1fr, 1fr) → each column is 50% of page width.
  let col-fractions = ()
  if type(composer) == array and composer.len() == conts.len() {
    let total = composer.fold(0fr, (acc, c) => if type(c) == fraction {
      acc + c
    } else { acc })
    if total > 0fr {
      col-fractions = composer.map(c => if type(c) == fraction {
        c / total * 100%
      } else { 100% })
    }
  }

  let images = ()
  let text-parts = ()
  let block-parts = ()

  for (i, cont) in conts.enumerate() {
    let extracted = _extract-image(cont)
    if extracted != none {
      let col-frac = if col-fractions.len() > i { col-fractions.at(i) } else {
        100%
      }
      // Store the display element (figure with caption, or raw image)
      images.push((
        element: extracted.element,
        col-fraction: col-frac,
        is-figure: extracted.is-figure,
      ))
    } else if _is-block-content(cont) {
      block-parts.push(cont)
    } else {
      text-parts.push(cont)
    }
  }

  (
    content: text-parts.map(c => block(c)).join(),
    images: images,
    blocks: block-parts,
  )
}





#let _scan-content-for-labeled-reducers(body) = {
  if type(body) != content { return () }
  if body.func() == metadata and type(body.value) == dictionary {
    let v = body.value
    if (
      v.at("kind", default: none) == "touying-reducer"
        and v.at("label", default: none) != none
    ) {
      return ((str(v.label), v),)
    }
    return ()
  }
  if utils.is-sequence(body) {
    let result = ()
    for child in body.children {
      result += _scan-content-for-labeled-reducers(child)
    }
    return result
  }
  // Recurse into styled nodes (show-rule wrappers)
  if utils.is-styled(body) {
    return _scan-content-for-labeled-reducers(body.child)
  }
  // Recurse into content elements with a .body field (headings, figures, blocks, etc.)
  if body.has("body") {
    return _scan-content-for-labeled-reducers(body.body)
  }
  // Recurse into content elements with a .children field (tables, grids, etc.)
  if body.has("children") {
    let result = ()
    for child in body.children {
      result += _scan-content-for-labeled-reducers(child)
    }
    return result
  }
  ()
}


#let _collect-labeled-reducers(..bodies) = {
  let result = ()
  for body in bodies.pos() {
    if type(body) == function { continue }
    result += _scan-content-for-labeled-reducers(body)
  }
  result
}


// Scan content for labeled non-reducer block elements.
// Returns an array of (label-string, content) pairs for any labeled block
// element that is NOT a touying-reducer (those are handled separately).
// Shallow scan: only finds top-level labeled elements, not nested ones.
#let _scan-content-for-labeled-blocks(body) = {
  if type(body) != content { return () }
  // Skip touying metadata nodes (reducers, pauses, etc.)
  if body.func() == metadata { return () }
  // Check if this element has a non-temporary label
  let lbl = body.fields().at("label", default: none)
  if (
    lbl != none and str(lbl) != "touying-temporary-mark" and str(lbl) != ""
  ) {
    return ((str(lbl), body),)
  }
  // Recurse into sequences
  if utils.is-sequence(body) {
    let result = ()
    for child in body.children {
      result += _scan-content-for-labeled-blocks(child)
    }
    return result
  }
  // Recurse into styled nodes
  if utils.is-styled(body) {
    return _scan-content-for-labeled-blocks(body.child)
  }
  // Do NOT recurse deeper: we want top-level labeled elements only
  ()
}


#let _collect-labeled-blocks(..bodies) = {
  let result = ()
  for body in bodies.pos() {
    if type(body) == function { continue }
    result += _scan-content-for-labeled-blocks(body)
  }
  result
}


/// Recall a labeled reducer graphic or arbitrary labeled block at a specific animation stage.
/// Intended for use inside `document-text` or `document-only` blocks in document mode.
///
/// Example:
///
/// ```typ
/// // In a slide, define an animated CeTZ diagram with a label:
/// #let my-diagram = touying-reducer.with(
///   reduce: cetz.canvas,
///   cover: cetz.draw.hide.with(bounds: true),
///   label: "my-diagram",
/// )
///
/// // Later, inside document-text or document-only:
/// #document-text[
///   Stage 1 only:
///   #touying-block-recall("my-diagram", subslide: 1)
///
///   Final state:
///   #touying-block-recall("my-diagram")
///
///   #touying-block-recall("my-diagram", subslide: 2)
/// ]
/// ```
///
/// - lbl (str, label): The label given to `touying-reducer`'s `label:` parameter,
///   or a regular Typst label for non-reducer labeled content.
///
/// - subslide (auto, int): Which animation stage to show.
///   - `auto` (default): the final / fully-revealed state.
///   - `int`: a specific 1-indexed subslide number.
///
/// - base (auto, int): Starting repetition counter for pause numbering.
///   - `auto` (default): `1` in document mode (no slide context).
///   - `int`: explicit offset, e.g. `base: 3` makes the first pause
///     create subslide 4 instead of 2.
///
/// -> content
#let touying-block-recall(lbl, subslide: auto, base: auto) = {
  let lbl-str = if type(lbl) == std.label { str(lbl) } else { str(lbl) }
  [#metadata((
    kind: "touying-block-recall",
    lbl-str: lbl-str,
    subslide: subslide,
    base: base,
  ))<touying-temporary-mark>]
}



// Render content as a continuous document instead of splitting into slides.
//
// In document mode, headings remain normal headings, slide wrappers render
// their body inline (no page breaks), and animation primitives (pause,
// meanwhile, uncover, only, etc.) show the final state.
//
// - self (dictionary): The presentation context (must have document-mode: true and optionally document config like wrap-images)
// - body (content): The content to render
//
// -> content

// Scan a single content value for touying-reducer metadata nodes that carry
// a non-none `label` field.  Returns an array of (label-string, reducer-data-dict).

// Scan content bodies for touying-reducer metadata with non-none labels.
// Returns an array of (label-string, reducer-data-dict) pairs.

// Internal slide rendering function. Called by theme slide functions via `touying-slide-wrapper`.
// See the public `slide` function for parameter documentation.

#let render-content-as-document(self: none, body) = {
  let children = if utils.is-sequence(body) {
    body.children
  } else {
    (body,)
  }
  // Flatten nested sequences
  let sequence-to-array(it) = {
    if utils.is-sequence(it) {
      it.children.map(sequence-to-array)
    } else {
      it
    }
  }
  children = children.map(sequence-to-array).flatten()

  let doc-cfg = self.at("document", default: (:))
  let wrap-images = doc-cfg.at("wrap-images", default: true)
  let wrap-image-figures = doc-cfg.at("wrap-image-figures", default: false)
  let wrap-other-figures = doc-cfg.at("wrap-other-figures", default: false)
  let wrap-other = doc-cfg.at("wrap-other", default: false)
  let wrap-align-direction = doc-cfg.at("wrap-align-direction", default: right)
  let any-wrapping = (
    wrap-images or wrap-image-figures or wrap-other-figures or wrap-other
  )
  // Enable content extraction in slides when any wrapping is on
  let extract-self = if any-wrapping {
    self + (document-extract-content: true)
  } else {
    self
  }

  // Process a single child, returning (items, images, blocks, block-recall-map)
  let _empty = (
    items: (),
    images: (),
    blocks: (),
    block-recall-map: (:),
    waypoint-map: (:),
  )
  let _process-child(self, extract-self, child) = {
    if utils.is-kind(child, "touying-slide-wrapper") {
      let slide-result = (child.value.fn)(extract-self)
      let (brm, wpm) = if type(slide-result) == dictionary {
        (
          slide-result.at("block-recall-map", default: (:)),
          slide-result.at("waypoint-map", default: (:)),
        )
      } else { ((:), (:)) }
      if any-wrapping and type(slide-result) == dictionary {
        // Got structured result with extracted images/blocks
        let items = if slide-result.content != none {
          (block(slide-result.content),)
        } else { () }
        return (
          items: items,
          images: slide-result.at("images", default: ()),
          blocks: slide-result.at("blocks", default: ()),
          block-recall-map: brm,
          waypoint-map: wpm,
        )
      }
      // Plain content (no extraction or nothing extracted)
      let cont = if type(slide-result) == dictionary {
        slide-result.content
      } else { slide-result }
      return (
        items: (block(cont),),
        images: (),
        blocks: (),
        block-recall-map: brm,
        waypoint-map: wpm,
      )
    } else if utils.is-kind(child, "touying-fn-wrapper") {
      let wrapper = child.value
      let last = if (
        wrapper.last-subslide != none and type(wrapper.last-subslide) == int
      ) {
        wrapper.last-subslide
      } else {
        9999
      }
      let doc-self = self + (subslide: last, handout: true)
      return (
        items: ((wrapper.fn)(self: doc-self, ..wrapper.args),),
        images: (),
        blocks: (),
        block-recall-map: (:),
        waypoint-map: (:),
      )
    } else if utils.is-kind(child, "touying-document-text") {
      // Handled specially in the main loop (replaces preceding text)
      return _empty
    } else if utils.is-kind(child, "touying-document-only") {
      // Standalone document-mode content — emit inline
      return (
        items: (child.value.body,),
        images: (),
        blocks: (),
        block-recall-map: (:),
        waypoint-map: (:),
      )
    } else if utils.is-kind(child, "touying-slides-only") {
      // for presentation, handout and both
      // Slides-only content — strip in document mode
      return _empty
    } else if utils.is-kind(child, "touying-jump/pause/meanwhile") {
      return _empty
    } else if utils.is-kind(child, "touying-set-config") {
      let new-self = utils.merge-dicts(self, child.value.config)
      return (
        items: (render-content-as-document(self: new-self, child.value.body),),
        images: (),
        blocks: (),
        block-recall-map: (:),
        waypoint-map: (:),
      )
    } else if utils.is-kind(child, "touying-slide-recaller") {
      return _empty
    } else if utils.is-kind(child, "touying-render") {
      let v = child.value
      let render-base = if v.at("base", default: auto) == auto { 1 } else {
        v.at("base")
      }
      let inline-content = v.content
      let reducer-data = _find-reducer-meta(inline-content)
      let (raw-wp, so, dr) = _collect-waypoints(inline-content)
      let resolved-wp = _resolve-waypoint-forest(raw-wp, so)
      let max-rep-raw = if reducer-data != none {
        let (_, mrr) = _parse-touying-reducer(
          self: self + (waypoints: (:), subslide: 9999),
          base: render-base,
          index: 9999,
          reducer-data,
        )
        mrr
      } else {
        let (_, mrr, _, _, _) = _parse-content-into-results-and-repetitions(
          self: self + (waypoints: (:), subslide: 9999),
          base: render-base,
          index: 9999,
          inline-content,
        )
        mrr
      }
      let repeat = calc.max(max-rep-raw, ..resolved-wp.values(), 1)
      let cwp = _compute-waypoint-ranges(resolved-wp, repeat, so, dr)
      let target = if v.subslide == auto { repeat } else { v.subslide }
      let render-self = self + (waypoints: cwp, subslide: target)
      let cont = if reducer-data != none {
        let (r, _) = _parse-touying-reducer(
          self: render-self,
          base: render-base,
          index: target,
          reducer-data,
        )
        r.sum(default: none)
      } else {
        let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
          self: render-self,
          base: render-base,
          index: target,
          inline-content,
        )
        conts.sum(default: none)
      }
      return (
        items: if cont != none { (cont,) } else { () },
        images: (),
        blocks: (),
        block-recall-map: (:),
        waypoint-map: (:),
      )
    } else if utils.is-styled(child) {
      let inner = render-content-as-document(self: self, child.child)
      return (
        items: (utils.reconstruct-styled(child, inner),),
        images: (),
        blocks: (),
        block-recall-map: (:),
        waypoint-map: (:),
      )
    } else {
      // Scan non-slide content for labeled reducers and labeled blocks so they
      // are available to touying-block-recall in later document-text blocks.
      // Store raw data (JIT): rendering happens on demand in _resolve-block-recalls.
      let found-reducers = _scan-content-for-labeled-reducers(child)
      let found-blocks = _scan-content-for-labeled-blocks(child)
      let brm = (:)
      let wpm = (:)
      if found-reducers.len() > 0 or found-blocks.len() > 0 {
        // Collect waypoints from the entire child content so that waypoint-based
        // subslide references work in touying-block-recall.
        let (raw-waypoints, start-overrides, decl-reps) = _collect-waypoints(
          child,
        )
        let resolved-waypoints = _resolve-waypoint-forest(
          raw-waypoints,
          start-overrides,
        )

        // --- Reducers ---
        for (lbl-str, reducer-data) in found-reducers {
          // First pass: determine repeat count (without waypoints)
          let (_, max-rep-raw) = _parse-touying-reducer(
            self: self + (waypoints: (:), subslide: 9999),
            base: 1,
            index: 9999,
            reducer-data,
          )
          let max-rep = calc.max(max-rep-raw, ..resolved-waypoints.values(), 1)
          let waypoints = _compute-waypoint-ranges(
            resolved-waypoints,
            max-rep,
            start-overrides,
            decl-reps,
          )
          wpm = waypoints
          // Store raw data for JIT rendering
          brm.insert(lbl-str, (
            kind: "reducer",
            data: reducer-data,
            waypoints: waypoints,
            repeat: max-rep,
          ))
        }

        // --- Labeled non-reducer blocks ---
        for (lbl-str, block-content) in found-blocks {
          // Determine repeat count by parsing with infinite index
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
          let max-rep = calc.max(max-rep-raw, ..resolved-waypoints.values(), 1)
          let waypoints = _compute-waypoint-ranges(
            resolved-waypoints,
            max-rep,
            start-overrides,
            decl-reps,
          )
          if wpm == (:) { wpm = waypoints }
          // Store raw data for JIT rendering
          brm.insert(lbl-str, (
            kind: "block",
            data: block-content,
            waypoints: waypoints,
            repeat: max-rep,
          ))
        }
      }
      return (
        items: (child,),
        images: (),
        blocks: (),
        block-recall-map: brm,
        waypoint-map: wpm,
      )
    }
  }

  // Resolve touying-block-recall metadata nodes in a content body using the
  // accumulated block-recall-map.  Returns the body with recalls replaced by
  // rendered content.
  let _resolve-block-recalls(body, block-recall-map, waypoint-map) = {
    // Fast path: nothing to resolve
    if block-recall-map.len() == 0 { return body }

    let _resolve-br-waypoint(self, lbl) = {
      let resolved = utils.resolve-waypoints(self, lbl)
      if type(resolved) == int {
        (resolved,)
      } else if type(resolved) == dictionary {
        let first = resolved.at("beginning", default: resolved.at(
          "first",
          default: 1,
        ))
        (first,)
      } else {
        panic(
          "touying-slide: unexpected resolved waypoint type for handout-subslides: "
            + repr(resolved),
        )
      }
    }

    // Core rendering: given content, its waypoints, and a subslide spec,
    // render the content at the requested subslide(s).
    // `reducer-data` is the reducer metadata dict if this is a reducer, or none for plain content.
    // `base`: starting repetition counter for pause numbering.
    let _render-content(
      inline-content,
      reducer-data,
      content-waypoints,
      repeat,
      subslide-spec,
      base: 1,
    ) = {
      let render-at(i) = {
        let render-self = self + (waypoints: content-waypoints, subslide: i)
        if reducer-data != none {
          let (r, _) = _parse-touying-reducer(
            self: render-self,
            base: base,
            index: i,
            reducer-data,
          )
          r.sum(default: none)
        } else {
          let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
            self: render-self,
            base: base,
            index: i,
            inline-content,
          )
          conts.sum(default: none)
        }
      }

      if subslide-spec == auto {
        return render-at(repeat)
      }

      // Resolve waypoint labels/markers
      let wp-self = self + (waypoints: content-waypoints)
      let subslide-spec = subslide-spec
      if type(subslide-spec) == array {
        for (i, idx) in subslide-spec.enumerate() {
          if (
            type(idx) == label
              or (
                type(idx) == dictionary
                  and idx.at("kind", default: "") in waypoint-kinds
              )
          ) {
            subslide-spec.at(i) = _resolve-br-waypoint(wp-self, idx)
          }
        }
      } else if (
        type(subslide-spec) == label
          or (
            type(subslide-spec) == dictionary
              and subslide-spec.at("kind", default: "") in waypoint-kinds
          )
      ) {
        subslide-spec = _resolve-br-waypoint(wp-self, subslide-spec)
      }

      // Resolve negative indices (e.g. -1 = last subslide)
      let subslide-spec = utils.resolve-negative-subslides(
        repeat,
        subslide-spec,
      )

      if type(subslide-spec) == int {
        return render-at(subslide-spec)
      }

      // Array or range spec: render matching subslides
      let subslide-indices = range(1, repeat + 1).filter(
        i => utils.check-visible(i, subslide-spec),
      )
      if subslide-indices.len() == 0 {
        subslide-indices = (repeat,)
      }
      return subslide-indices.map(i => render-at(i)).sum(default: none)
    }

    // Prepare content + waypoints + repeat from inline content (for touying-render).
    let _prepare-inline-content(inline-content) = {
      let reducer-data = _find-reducer-meta(inline-content)
      let (raw-waypoints, start-overrides, decl-reps) = _collect-waypoints(
        inline-content,
      )
      let resolved-waypoints = _resolve-waypoint-forest(
        raw-waypoints,
        start-overrides,
      )
      let max-rep-raw = if reducer-data != none {
        let (_, mrr) = _parse-touying-reducer(
          self: self + (waypoints: (:), subslide: 9999),
          base: 1,
          index: 9999,
          reducer-data,
        )
        mrr
      } else {
        let (_, mrr, _, _, _) = _parse-content-into-results-and-repetitions(
          self: self + (waypoints: (:), subslide: 9999),
          base: 1,
          index: 9999,
          inline-content,
        )
        mrr
      }
      let repeat = calc.max(max-rep-raw, ..resolved-waypoints.values(), 1)
      let content-waypoints = _compute-waypoint-ranges(
        resolved-waypoints,
        repeat,
        start-overrides,
        decl-reps,
      )
      (inline-content, content-waypoints, repeat)
    }

    if type(body) != content { return body }

    // touying-block-recall: look up label in block-recall-map, then delegate to _render-content
    if (
      body.func() == metadata
        and type(body.value) == dictionary
        and body.value.at("kind", default: none) == "touying-block-recall"
    ) {
      let v = body.value
      let lbl-str = v.lbl-str
      if lbl-str not in block-recall-map {
        panic(
          "touying-block-recall: label \""
            + lbl-str
            + "\" not found in block-recall-map. Available labels: "
            + repr(block-recall-map.keys()),
        )
      }
      let entry = block-recall-map.at(lbl-str)
      let render-waypoints = entry.at("waypoints", default: waypoint-map)
      let reducer-data = if entry.kind == "reducer" { entry.data } else { none }
      let render-base = v.at("base", default: auto)
      // In document mode, auto resolves to 1 (no slide context)
      let render-base = if render-base == auto { 1 } else { render-base }
      return _render-content(
        entry.data,
        reducer-data,
        render-waypoints,
        entry.repeat,
        v.subslide,
        base: render-base,
      )
    }

    // touying-render: inline content variable rendering
    if (
      body.func() == metadata
        and type(body.value) == dictionary
        and body.value.at("kind", default: none) == "touying-render"
    ) {
      let v = body.value
      let render-base = v.at("base", default: auto)
      // In document mode, auto resolves to 1 (no slide context)
      let render-base = if render-base == auto { 1 } else { render-base }
      let (inline-content, content-waypoints, repeat) = _prepare-inline-content(
        v.content,
      )
      let reducer-data = _find-reducer-meta(v.content)
      return _render-content(
        inline-content,
        reducer-data,
        content-waypoints,
        repeat,
        v.subslide,
        base: render-base,
      )
    }
    // Recurse into sequences
    if utils.is-sequence(body) {
      let parts = body.children.map(c => _resolve-block-recalls(
        c,
        block-recall-map,
        waypoint-map,
      ))
      return parts.sum(default: [])
    }
    // Recurse into styled nodes
    if utils.is-styled(body) {
      let resolved-child = _resolve-block-recalls(
        body.child,
        block-recall-map,
        waypoint-map,
      )
      if resolved-child != body.child {
        return utils.typst-builtin-styled(resolved-child, body.styles)
      }
      return body
    }
    // Recurse into any content with a .body field.
    // Some functions (rotate, place, columns, scale, align) have positional-first
    // params that can't be spread as named args, so they need special reconstruction.
    if type(body) == content and body.has("body") {
      let inner = body.at("body", default: none)
      if inner != none {
        let resolved-inner = _resolve-block-recalls(
          inner,
          block-recall-map,
          waypoint-map,
        )
        if resolved-inner != inner {
          let f = body.func()
          if f == rotate {
            let fields = body.fields()
            let _ = fields.remove("angle", default: none)
            let _ = fields.remove("body", default: none)
            let _ = fields.remove("label", default: none)
            let angle = if body.has("angle") { body.angle } else { 0deg }
            return rotate(angle, ..fields, resolved-inner)
          } else if f == place {
            let fields = body.fields()
            let _ = fields.remove("alignment", default: none)
            let _ = fields.remove("body", default: none)
            let _ = fields.remove("label", default: none)
            let alignment = if body.has("alignment") { body.alignment } else {
              start
            }
            return place(alignment, ..fields, resolved-inner)
          } else if f == columns {
            let args = if body.has("gutter") { (gutter: body.gutter) } else {
              (:)
            }
            let count = if body.has("count") { body.count } else { 2 }
            return columns(count, ..args, resolved-inner)
          } else if f == scale {
            let fields = body.fields()
            let _ = fields.remove("body", default: none)
            let _ = fields.remove("label", default: none)
            let factor = fields.remove("factor", default: auto)
            return scale(factor, ..fields, resolved-inner)
          } else if f == align {
            let alignment = if body.has("alignment") { body.alignment } else {
              start
            }
            return align(alignment, resolved-inner)
          } else {
            return utils.reconstruct(
              named: true,
              labeled: true,
              body,
              resolved-inner,
            )
          }
        }
      }
    }
    // Recurse into content with .children (table, grid, stack)
    if type(body) == content and body.has("children") {
      let kids = body.children
      let any-changed = false
      let new-kids = ()
      for kid in kids {
        let resolved-kid = _resolve-block-recalls(
          kid,
          block-recall-map,
          waypoint-map,
        )
        new-kids.push(resolved-kid)
        if resolved-kid != kid { any-changed = true }
      }
      if any-changed {
        return utils.reconstruct-table-like(
          named: true,
          labeled: true,
          body,
          new-kids,
        )
      }
    }
    body
  }

  // --- Pass 1: process all children and collect the full block-recall-map ---
  // This lets touying-block-recall reference labels from slides that appear
  // later in the document (forward references).
  let processed = ()
  let block-recall-map = (:)
  let waypoint-map = (:)
  let use-self = if any-wrapping { extract-self } else { self }
  for child in children {
    if (
      utils.is-kind(child, "touying-document-text")
        or utils.is-kind(child, "touying-document-only")
    ) {
      processed.push(none) // placeholder — resolved in pass 2
    } else {
      let r = _process-child(self, use-self, child)
      processed.push(r)
      block-recall-map = utils.merge-dicts(block-recall-map, r.block-recall-map)
      if waypoint-map == (:) {
        waypoint-map = r.waypoint-map
      }
    }
  }

  // --- Pass 2: build output using the complete block-recall-map ---
  if not any-wrapping {
    // Simple path: no wrapping or block extraction
    let result = ()
    for (idx, child) in children.enumerate() {
      if utils.is-kind(child, "touying-document-text") {
        let headings = result.filter(r => (
          type(r) == content and r.func() == heading
        ))
        result = headings
        result.push(_resolve-block-recalls(
          child.value.body,
          block-recall-map,
          waypoint-map,
        ))
        continue
      }
      if utils.is-kind(child, "touying-document-only") {
        result.push(_resolve-block-recalls(
          child.value.body,
          block-recall-map,
          waypoint-map,
        ))
        continue
      }
      result += processed.at(idx).items
    }
    return result.sum(default: none)
  }

  // Content-extraction path: group by headings, wrap stuff with wrap-it,
  // and place rest block-level content (e.g. tables, canvases) centered at section end.
  let sections = ()
  let current-items = ()
  let current-images = ()
  let current-blocks = ()

  for (idx, child) in children.enumerate() {
    let is-section-heading = (
      type(child) == content and child.func() == heading
    )

    if is-section-heading and current-items.len() > 0 {
      sections.push(_wrap-section(
        current-items,
        current-images,
        current-blocks,
        wrap-images: wrap-images,
        wrap-image-figures: wrap-image-figures,
        wrap-other-figures: wrap-other-figures,
        wrap-other: wrap-other,
        wrap-align-direction: wrap-align-direction,
      ))
      current-items = ()
      current-images = ()
      current-blocks = ()
    }

    if utils.is-kind(child, "touying-document-text") {
      let headings = current-items.filter(r => (
        type(r) == content and r.func() == heading
      ))
      current-items = headings
      current-items.push(_resolve-block-recalls(
        child.value.body,
        block-recall-map,
        waypoint-map,
      ))
      continue
    }

    if utils.is-kind(child, "touying-document-only") {
      current-items.push(_resolve-block-recalls(
        child.value.body,
        block-recall-map,
        waypoint-map,
      ))
      continue
    }

    let r = processed.at(idx)
    current-items += r.items
    current-images += r.images
    current-blocks += r.blocks
  }
  if current-items.len() > 0 {
    sections.push(_wrap-section(
      current-items,
      current-images,
      current-blocks,
      wrap-images: wrap-images,
      wrap-image-figures: wrap-image-figures,
      wrap-other-figures: wrap-other-figures,
      wrap-other: wrap-other,
      wrap-align-direction: wrap-align-direction,
    ))
  }

  sections.join()
}
