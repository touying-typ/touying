#import "../utils.typ"
#import "../extern.typ"
#import "parser.typ": (
  _build-native-recall, _parse-content-into-results-and-repetitions,
  _prepare-render-context, _render-at-subslide, _resolve-marks-in-tree,
  _resolve-waypoint-to-int, waypoint-kinds,
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
/// Note that slide-breaking shorthands like `---` won't be interpreted inside this wrapper and just render as-is. A `pagebreak()` will still work though.
///
/// - body (content): The document-only content.
///
/// -> content
#let document-only(body) = [#metadata((
  kind: "touying-document-only",
  body: body,
))<touying-temporary-mark>]


/// Extract the payload dictionary from a touying-document-raw metadata wrapper.
/// In document mode, touying-slide wraps its result (content + maps) in metadata
/// so that theme styling (set text, set page, etc.) doesn't leak into the document.
/// This walks through styled wrappers and sequences to find and extract the payload.
///
/// Returns: the full payload dictionary (with content, images, blocks, etc.)
#let _unwrap-document-raw(cont) = {
  // This is where we stop unwrapping, finally found our payload!
  if utils.is-kind(cont, "touying-document-raw") {
    return cont.value
  }
  //unwrap all sorts of wrappers.
  if utils.is-styled(cont) {
    return _unwrap-document-raw(cont.child)
  }
  if type(cont) == content and cont.has("body") {
    return _unwrap-document-raw(cont.body)
  }
  // Sequence - look into children, there should only be one payload child, thus we return the first.
  if utils.is-sequence(cont) {
    for child in cont.children {
      let result = _unwrap-document-raw(child)
      if result != none {
        return result
      }
    }
  }
  //return none for all other cases
}


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
  let raw-images = images.filter(i => not i.is-figure)
  let figure-images = images.filter(i => i.is-figure)
  let other-figures = blocks.filter(b => b.func() == figure)
  let other-blocks = blocks.filter(b => b.func() != figure)

  let has-wrap-content = (
    (wrap-images and raw-images.len() > 0)
      or (wrap-image-figures and figure-images.len() > 0)
      or (wrap-other-figures and other-figures.len() > 0)
      or (wrap-other and other-blocks.len() > 0)
  )

  let result = ()

  // Separate headings and recall breadcrumbs from ordinary flow content.
  // Breadcrumbs (invisible metadata) must stay out of the wrapped body:
  // content placed inside the `layout()` callback below is measured/
  // reflowed by meander, and touying-recall's own `query()` lookups need
  // breadcrumbs to behave like ordinary top-level document content, not
  // something buried inside a layout measurement pass.
  let headings = items.filter(r => (
    type(r) == content and r.func() == heading
  ))
  let breadcrumbs = items.filter(r => utils.is-kind(
    r,
    "touying-recall-breadcrumb",
  ))
  let body-parts = items.filter(r => (
    not (type(r) == content and r.func() == heading)
      and not utils.is-kind(r, "touying-recall-breadcrumb")
  ))
  // Unwrap blocks to expose the inner content directly. Content gets nested
  // in `block(...)` at multiple points upstream (`_document-linearize` for
  // bare document-mode text, and again by touying-slide's own document-mode
  // rendering for `#slide[...]`/`#focus-slide[...]` bodies), and those
  // blocks can end up buried inside a `styled` node (from an intervening
  // `set`/`show` rule) or a sequence, not just at the top level — so this
  // has to walk the whole tree, not only the outermost wrapper, and rebuild
  // `styled` nodes in place to keep their styling. This must run
  // unconditionally (not only when meander wrapping is active): a leftover
  // `block()` carries its own above/below spacing resolved from wherever it
  // was constructed (e.g. a slide's own styling context), which doesn't
  // collapse with a preceding heading's spacing the way plain paragraph
  // flow does — meander needs it for its own reasons (a `block` is an
  // atomic, unsplittable unit to it), but plain (non-wrapped) sections need
  // it just as much to avoid that visible extra gap.
  let _unwrap-blocks(r) = {
    if type(r) != content { return r }
    if r.func() == block {
      let body = r.at("body", default: none)
      if body == none { return r }
      return _unwrap-blocks(body)
    }
    if utils.is-styled(r) {
      return (r.func())(_unwrap-blocks(r.child), r.styles)
    }
    if utils.is-sequence(r) {
      return r.children.map(_unwrap-blocks).sum(default: none)
    }
    r
  }
  let unwrapped = body-parts.map(_unwrap-blocks)

  if has-wrap-content {
    // Only pull in meander for sections that actually need wrapping around
    // an obstacle — most document-mode sections have no images/blocks to
    // wrap, and shouldn't pay for the import or the reflow layout pass.
    import "@preview/meander:0.4.4"

    result += headings
    result += breadcrumbs
    let body-content = unwrapped.sum(default: none)
    body-content = if body-content == none { [] } else { body-content }

    // Meander measures each obstacle in an unbounded context to compute its
    // page tiling, so a percentage width (e.g. `50%`) silently resolves to
    // `0pt` there — obstacles need an absolute size. Resolve the actual
    // content width via `layout` first and convert `col-fraction` to an
    // absolute length, the same trick the old wrap-it-based code used.
    result.push(layout(size => {
      let content-width = size.width
      let to-abs-width(col-fraction) = (col-fraction * 1pt).pt() * content-width

      // An image's own explicit `width` (e.g. `width: 80%`) is relative to
      // its column, not the full content area, so extract just the ratio
      // part to shrink the reserved obstacle to the image's actual size —
      // otherwise the reserved column stays at the full composer fraction
      // and wrapped text leaves a dead gap next to a narrower image instead
      // of flowing into the unused space.
      let width-ratio(element) = {
        let w = if type(element) == content {
          element.at("width", default: auto)
        } else {
          auto
        }
        if type(w) == ratio {
          (w * 1pt).pt()
        } else if type(w) == relative {
          (w.ratio * 1pt).pt()
        } else {
          1.0
        }
      }

      // Images/figures often carry their own explicit width that's narrower
      // than the obstacle column, so the element must also be aligned to
      // `wrap-align-direction` inside the box — otherwise it sits at the
      // box's default (left) edge, leaving a gap between it and the page
      // margin the box is actually anchored to.
      //
      // The image can't just be re-boxed at its already-shrunk final width:
      // its own ratio/relative `width` would resolve against that smaller
      // box a second time, shrinking it again (e.g. `width: 80%` inside an
      // 80%-sized box renders at 64%). And it can't be rebuilt without the
      // `width` field either — `image()`'s `source` is a path that resolves
      // lexically relative to the file it's written in, so reconstructing
      // the element from a different file (this one) breaks relative paths.
      // Instead, render it at its correct size inside a box matching its
      // *own* resolving context (the full column), then crop that box down
      // to the image's actual footprint with an aligned, clipped outer box.
      let cropped-to-fit(element, col-width, ratio) = box(
        width: col-width * ratio,
        clip: true,
        align(
          wrap-align-direction,
          box(width: col-width, align(wrap-align-direction, element)),
        ),
      )

      let to-wrap = ()
      if wrap-images {
        to-wrap += raw-images.map(i => cropped-to-fit(
          i.element,
          to-abs-width(i.col-fraction),
          width-ratio(i.element),
        ))
      }
      if wrap-image-figures {
        to-wrap += figure-images.map(i => box(
          width: to-abs-width(i.col-fraction),
          align(wrap-align-direction, i.element),
        ))
      }
      if wrap-other-figures {
        to-wrap += other-figures
      }
      if wrap-other {
        to-wrap += other-blocks
      }

      // Stack all wrapped elements into a single obstacle so they occupy one
      // column together, rather than computing per-element offsets.
      let obstacle = if to-wrap.len() == 1 {
        to-wrap.first()
      } else {
        stack(dir: ttb, spacing: 1em, ..to-wrap)
      }

      meander.reflow({
        import meander: *
        placed(top + wrap-align-direction, obstacle)
        container()
        content(body-content)
      })
    }))
  } else {
    result += headings
    result += breadcrumbs
    result += unwrapped
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

  // Non-wrapped other figures → centered at end
  if not wrap-other-figures {
    for fig in other-figures {
      result.push(align(center, fig))
    }
  }

  // Non-wrapped block content → centered at end
  if not wrap-other {
    for b in other-blocks {
      result.push(align(center, b))
    }
  }

  result.sum(default: none)
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
      or doc-cfg.at("wrap-image-figures", default: false)
      or doc-cfg.at("wrap-other-figures", default: false)
      or doc-cfg.at("wrap-other", default: false)
  )

  // Distinct top-level bodies (e.g. a composer's separate column contents)
  // are joined with an explicit parbreak() rather than wrapped in their own
  // block()s — a block's above/below spacing is resolved from wherever it's
  // constructed (e.g. a slide's own styling context) and doesn't collapse
  // with a preceding heading's spacing the way plain paragraph flow does,
  // and it can't be relied on for separation once _wrap-section's
  // _unwrap-blocks strips block wrappers back out downstream anyway.
  if not any-wrapping {
    return (
      content: if conts.len() == 0 { none } else { conts.join(parbreak()) },
      images: (),
      blocks: (),
    )
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
    content: if text-parts.len() == 0 { none } else {
      text-parts.join(parbreak())
    },
    images: images,
    blocks: block-parts,
  )
}





// Check for leaked <touying-temporary-mark> metadata anywhere in the final
// document — the same diagnostic configs.typ's `_default-preamble` runs per
// slide (gated on `is-first-slide`), which document mode never activates
// (entrypoint.typ's document-mode branch never sets that flag). Run once,
// at the end of the whole document, instead of per-slide.
#let _leak-check(self) = context {
  let marks = query(<touying-temporary-mark>)
  if marks.len() > 0 {
    let page-num = marks.at(0).location().page()
    let kind = marks.at(0).value.kind
    let fn = if "fn" in marks.at(0).value { marks.at(0).value.fn } else {
      none
    }
    let warning-msg = (
      "Unsupported mark `"
        + kind
        + if fn != none {
          "` from `" + repr(fn)
        }
        + "` at page "
        + str(page-num)
        + " of the document. You can't use it inside some functions like "
        + "`context`. You may want to use the callback-style `utils."
        + repr(fn)
        + "` function instead."
    )
    if self.at("enable-mark-warning", default: true) {
      panic(warning-msg)
    } else {
      extern.warning(warning-msg)
    }
  }
}

// Render content as a continuous document instead of splitting into slides.
//
// In document mode, headings remain normal headings, slide wrappers render
// their body inline (no page breaks), and animation primitives (pause,
// meanwhile, uncover, only, etc.) show the final state.
//
// Bare (non-`#slide[...]`) content is routed through the real parser
// (`_parse-content-into-results-and-repetitions`, the same function
// `touying-slide`'s own document-mode branch uses) exactly like slide-
// wrapped content already is — this is what gives it full container
// recursion and full kind coverage (reducers, equations, waypoints,
// fn-wrappers, etc.) for free, rather than a separate, hand-rolled,
// necessarily-incomplete reimplementation of the same dispatch.
//
// - self (dictionary): The presentation context (must have document-mode: true and optionally document config like wrap-images)
// - body (content): The content to render
//
// -> content
#let render-content-as-document(self: none, body) = {
  let children = if utils.is-sequence(body) {
    body.children
  } else {
    (body,)
  }
  children = children.map(utils.sequence-to-array).flatten()

  // Same convention split-content-into-slides uses to turn a bare "---"/"—"
  // into a slide break — in document mode there are no slide boundaries to
  // break, so it's a silent no-op instead (see the per-child checks below).
  // Wrap it in #document-only[...] to force a literal dash through instead.
  let horizontal-line-to-pagebreak = self.at(
    "horizontal-line-to-pagebreak",
    default: true,
  )

  let doc-cfg = self.at("document", default: (:))
  let wrap-images = doc-cfg.at("wrap-images", default: true)
  let wrap-image-figures = doc-cfg.at("wrap-image-figures", default: false)
  let wrap-other-figures = doc-cfg.at("wrap-other-figures", default: false)
  let wrap-other = doc-cfg.at("wrap-other", default: false)
  let wrap-align-direction = doc-cfg.at("wrap-align-direction", default: right)
  let any-wrapping = (
    wrap-images or wrap-image-figures or wrap-other-figures or wrap-other
  )

  // Build the document-mode whole-slide-label set: labels attached to
  // headings or explicit #slide[...] wrappers, which touying-recall must
  // treat as a no-op (with a warning) rather than the generic recall
  // fallback — see parser.typ's inlined "touying-slide-recaller" branch,
  // which reads self.document-whole-slide-labels. Mirrors
  // split-content-into-slides's two registration sites
  // (slides.typ:298-304, :442-448) at a much smaller scope: document mode
  // never needs to replay a slide, just to recognize "was this ever a
  // whole-slide target."
  let whole-slide-labels = ()
  for child in children {
    let lbl = if type(child) == content and child.func() == heading {
      child.at("label", default: none)
    } else if utils.is-kind(child, "touying-slide-wrapper") {
      child.at("label", default: none)
    } else {
      none
    }
    if lbl != none and lbl != <touying-temporary-mark> {
      whole-slide-labels.push(lbl)
    }
  }
  let self = self + (document-whole-slide-labels: whole-slide-labels)

  // Enable content extraction in slides when any wrapping is on
  let extract-self = if any-wrapping {
    self + (document-extract-content: true)
  } else {
    self
  }

  // Render one accumulated "run" of bare (non-special) document children by
  // routing it through the real parser, exactly like touying-slide's own
  // document-mode branch does for explicit #slide[...] content (mirrors
  // slides.typ:1816-1822: probe for repeat, then render at the final
  // subslide with delayed-wrapper content shown). Waypoint pre-computation
  // is intentionally skipped here (unlike touying-slide) — bare
  // document-mode content has no tested use case for named waypoint
  // ranges, and self.waypoints defaults safely to (:) everywhere it's read.
  // Pull top-level "touying-recall-breadcrumb" metadata nodes out of a
  // joined content tree. Breadcrumbs are invisible bookkeeping, not part of
  // the visible content document-text/document-only are meant to replace or
  // supplement — if they stayed buried inside the single joined block
  // _render-run produces, a subsequent "keep only headings" filter (see
  // document-text handling below) would discard them along with the
  // visible content they happen to share a run with, making touying-recall
  // unable to find them from anywhere inside that document-text/-only body.
  // Breadcrumbs are always emitted as direct top-level pushes alongside
  // whatever else the parser produces (never nested inside other pushed
  // content), so a single level of sequence-unwrapping is enough to find
  // them all.
  let _extract-breadcrumbs(cont) = {
    if cont == none { return (breadcrumbs: (), rest: none) }
    if utils.is-kind(cont, "touying-recall-breadcrumb") {
      return (breadcrumbs: (cont,), rest: none)
    }
    if utils.is-sequence(cont) {
      let breadcrumbs = ()
      let rest = ()
      for c in cont.children {
        if utils.is-kind(c, "touying-recall-breadcrumb") {
          breadcrumbs.push(c)
        } else {
          rest.push(c)
        }
      }
      return (breadcrumbs: breadcrumbs, rest: rest.sum(default: none))
    }
    (breadcrumbs: (), rest: cont)
  }

  let _render-run(self, run) = {
    if run.len() == 0 {
      return (items: (), images: (), blocks: (), breadcrumbs: ())
    }
    let joined = run.sum(default: none)
    // touying-slide always sets self.subslide before any parsing, even the
    // probe pass (slides.typ:1759) — utils.uncover/only and friends read
    // self.subslide directly, so it must be present from the start.
    let probe-self = self + (subslide: 1)
    let (_, repetitions, last-subslide, _, _) = (
      _parse-content-into-results-and-repetitions(
        self: probe-self,
        base: 1,
        index: 1,
        joined,
      )
    )
    let repeat = calc.max(repetitions, last-subslide, 1)
    let render-self = self + (repeat: repeat, subslide: repeat)
    let (conts, _, _, _, _) = _parse-content-into-results-and-repetitions(
      self: render-self,
      index: repeat,
      show-delayed-wrapper: true,
      joined,
    )
    let cont = conts.sum(default: none)
    let extracted = _extract-breadcrumbs(cont)
    let linearized = _document-linearize(render-self, none, (extracted.rest,))
    (
      items: if linearized.content != none {
        (block(linearized.content),)
      } else {
        ()
      },
      images: linearized.images,
      blocks: linearized.blocks,
      breadcrumbs: extracted.breadcrumbs,
    )
  }

  // Resolve touying-render/touying-recall metadata nodes found anywhere in
  // a content body. The tree-walk itself (sequences, styled nodes,
  // wrapper/table-like content) is shared with touying-fn-wrapper's own
  // nesting support in parser.typ (see _resolve-marks-in-tree there) —
  // this only supplies the per-kind resolution logic.
  let _resolve-block-recalls(body) = _resolve-marks-in-tree(
    body,
    ("touying-render", "touying-slide-recaller"),
    v => if v.kind == "touying-render" {
      let render-base = if v.at("base", default: auto) == auto { 1 } else {
        v.at("base")
      }
      if (
        v.at("start", default: auto) != auto
          or v.at("repeat-last", default: true) != true
      ) {
        extern.warning(
          "touying-render: start:/repeat-last: have no effect in "
            + "document mode (there is no subslide progression to gate "
            + "against). Wrap this call in #slides-only[...] to "
            + "suppress this warning once you've confirmed that's what "
            + "you want.",
        )
      }
      let (reducer-data, cwp, repeat, _) = _prepare-render-context(
        self,
        v.content,
        render-base,
      )
      let spec = v.subslide
      let target = if spec == auto {
        repeat
      } else if (
        type(spec) == label
          or (
            type(spec) == dictionary
              and spec.at("kind", default: "") in waypoint-kinds
          )
      ) {
        // cwp is always this content's own *local* (base=1) waypoint map —
        // document mode has no enclosing slide context to track — so the
        // resolved position must be shifted by (render-base - 1) to land
        // in the same absolute numbering as `repeat` above.
        _resolve-waypoint-to-int((waypoints: cwp), spec) + render-base - 1
      } else {
        utils.resolve-negative-subslides(repeat, spec, base: render-base)
      }
      _render-at-subslide(self, v.content, reducer-data, cwp, render-base, target)
    } else {
      // touying-recall used inside document-text/document-only: never a
      // whole-slide target here (recaller-map isn't consulted in document
      // mode), always the native-ref fallback (labeled reducer or arbitrary
      // labeled content).
      let raw-label = v.raw-label
      if type(raw-label) != label {
        panic(
          "touying-recall: a native label (e.g. <my-label>) is required to "
            + "recall a labeled reducer or other content in document mode — "
            + "a string label can only target a registered whole-slide recall.",
        )
      }
      _build-native-recall(
        raw-label,
        v.at("subslide", default: none),
        v.at("base", default: auto),
      )
    },
  )

  // touying-set-config's target self can change partway through the
  // document, so it's threaded as a local variable (not recomputed from
  // the original `self`) across the whole walk below — later runs and
  // #slide[...] calls see the merged config, matching the old per-child
  // behavior where touying-set-config recursed with a locally-merged self.
  let use-self = if any-wrapping { extract-self } else { self }

  // Note: unlike the pre-recall-feature version of this function, this is
  // now a single pass, not two — the old two-pass "collect everything,
  // then resolve document-text/document-only" structure existed only to
  // support forward-references into a pre-scanned block-recall-map, which
  // no longer exists (recall is native-label/query-based now, and query()
  // doesn't care about document order). document-text/document-only still
  // get resolved via _resolve-block-recalls (still needed for
  // touying-render's inline content and touying-recall's fallback), just
  // without a separate first pass.

  if not any-wrapping {
    // Simple path: no wrapping or block extraction. Local closures in
    // Typst can't mutate variables from the enclosing scope, so the
    // "flush the accumulated run" step is inlined at each call site below
    // rather than factored into a helper.
    let result = ()
    let current-run = ()
    for child in children {
      if utils.is-kind(child, "touying-document-text") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        // document-text replaces the preceding run's visible content, but
        // breadcrumbs are invisible bookkeeping (not part of what it's
        // replacing) and must survive so touying-recall inside its own
        // body can still find them.
        let headings = result.filter(item => (
          type(item) == content and item.func() == heading
        ))
        result = headings
        result += r.breadcrumbs
        result.push(_resolve-block-recalls(child.value.body))
      } else if utils.is-kind(child, "touying-document-only") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        result.push(_resolve-block-recalls(child.value.body))
      } else if utils.is-kind(child, "touying-set-config") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        use-self = utils.merge-dicts(use-self, child.value.config)
      } else if utils.is-kind(child, "touying-slide-wrapper") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        let slide-result = (child.value.fn)(use-self)
        let payload = _unwrap-document-raw(slide-result)
        let raw-content = payload.at("content", default: none)
        // Not wrapped in an extra block(): a rendered slide's own content is
        // already block-level (themes wrap slide bodies themselves), and an
        // additional block() here doesn't collapse its spacing with the
        // preceding heading's own below-spacing the way normal paragraph
        // flow does — it visibly doubles the gap when this is the first
        // thing under a heading (see e.g. "With Explicit Slide"/"Focus
        // Slide" in the document-mode test).
        if raw-content != none { result.push(raw-content) }
      } else if utils.is-kind(child, "touying-slides-only") {
        // Stripped in document mode — a document-mode/slide-mode
        // distinction the shared parser has no notion of, so it must be
        // filtered out here rather than left for the parser to see.
      } else if horizontal-line-to-pagebreak and child in ([—], [---]) {
        // A bare slide-separator dash — no-op in document mode (no slide
        // boundaries to break). See slides.typ's own horizontal-line
        // handling for the slide-mode equivalent.
      } else {
        current-run.push(child)
      }
    }
    let r = _render-run(use-self, current-run)
    result += r.items
    result += r.breadcrumbs
    return result.sum(default: none) + _leak-check(self)
  }

  // Content-extraction path: group by headings, wrap stuff with meander,
  // and place block-level content (e.g. tables, canvases) centered at
  // section end. Same inlined-flush constraint as above applies here.
  let sections = ()
  let current-items = ()
  let current-images = ()
  let current-blocks = ()
  let current-run = ()
  for child in children {
    let is-section-heading = (
      type(child) == content and child.func() == heading
    )
    if (
      is-section-heading and (current-items.len() > 0 or current-run.len() > 0)
    ) {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
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
      current-items = ()
      current-images = ()
      current-blocks = ()
    }

    if utils.is-kind(child, "touying-document-text") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-images += r.images
      current-blocks += r.blocks
      // document-text replaces the preceding run's visible content, but
      // breadcrumbs are invisible bookkeeping (not part of what it's
      // replacing) and must survive so touying-recall inside its own body
      // can still find them.
      let headings = current-items.filter(item => (
        type(item) == content and item.func() == heading
      ))
      current-items = headings
      current-items += r.breadcrumbs
      current-items.push(_resolve-block-recalls(child.value.body))
    } else if utils.is-kind(child, "touying-document-only") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      current-items.push(_resolve-block-recalls(child.value.body))
    } else if utils.is-kind(child, "touying-set-config") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      use-self = utils.merge-dicts(use-self, child.value.config)
    } else if utils.is-kind(child, "touying-slide-wrapper") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      let slide-result = (child.value.fn)(use-self)
      let payload = _unwrap-document-raw(slide-result)
      let raw-content = payload.at("content", default: none)
      // See the matching comment in the simple path above: no extra
      // block() wrap here either. (_wrap-section's own _unwrap-blocks
      // would strip it anyway when meander wrapping is active — this just
      // avoids the double-spacing bug in the common case where it isn't.)
      if raw-content != none { current-items.push(raw-content) }
      current-images += payload.at("images", default: ())
      current-blocks += payload.at("blocks", default: ())
    } else if is-section-heading {
      current-items.push(child)
    } else if utils.is-kind(child, "touying-slides-only") {
      // Stripped in document mode — a document-mode/slide-mode
      // distinction the shared parser has no notion of, so it must be
      // filtered out here rather than left for the parser to see.
    } else if horizontal-line-to-pagebreak and child in ([—], [---]) {
      // A bare slide-separator dash — no-op in document mode (no slide
      // boundaries to break). See slides.typ's own horizontal-line
      // handling for the slide-mode equivalent.
    } else {
      current-run.push(child)
    }
  }
  let r = _render-run(use-self, current-run)
  current-items += r.items
  current-items += r.breadcrumbs
  current-images += r.images
  current-blocks += r.blocks
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

  sections.join() + _leak-check(self)
}
