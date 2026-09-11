#import "../utils.typ"
#import "../extern.typ"
#import "tree.typ"
#import "subslides.typ": resolve-negative-subslides
#import "parser.typ": (
  _build-native-recall, _members-in-range,
  _parse-content-into-results-and-repetitions, _prepare-render-context,
  _render-at-subslide, _resolve-string-to-members, _resolve-waypoint-to-members,
  check-current-mode-skip, unsupported-mark-message, waypoint-kinds,
)

/// Content that replaces the slide content when in article mode. Place it after your slide, before the next one.
///
/// You can use this to write a prose alternative to your slides' bullet points,
/// and even properly use figures etc which will be rendered in the article normally.
///
/// - body (content): The article-text content.
///
/// -> content
#let article-text(body) = [#metadata((
  kind: "touying-article-text",
  body: body,
))<touying-temporary-mark>]


/// Content that only appears in article mode.
///
/// Unlike `article-text`, this does NOT replace a preceding slide's content.
/// Use this for standalone sections or inline content that should only exist in the article
/// output (e.g., inline: footnotes, remarks; sections: appendices, methodology, acknowledgements, extended discussion).
///
/// Note that slide-breaking shorthands like `---` won't be interpreted inside this wrapper and just render as-is. A `pagebreak()` will still work though.
///
/// - body (content): The article-only content.
///
/// -> content
#let article-only(body) = [#metadata((
  kind: "touying-article-only",
  body: body,
))<touying-temporary-mark>]


/// Whether the article walker has to see a child on its own.
///
/// Everything between two such children is summed back into a single run
/// before it is parsed, so `tree.flatten-children` can keep the run under one
/// shared `styled` wrapper.
///
/// - it (content): The child to test.
///
/// -> bool
#let _is-structural(it) = {
  let core = tree.unstyled(it)
  if tree.is-metadata(core) { return true }
  if type(core) != content { return false }
  core.func() == heading or core in ([—], [---])
}


/// The payload `touying-slide` hides in a `touying-article-raw` metadata node
/// so that a theme's own `set` rules do not leak into the article.
///
/// - cont (content): The slide's return value.
///
/// -> dictionary
#let _unwrap-article-raw(cont) = {
  let found = tree.find-in-tree(cont, c => tree.is-kind(
    c,
    "touying-article-raw",
  ))
  if found != none { found.value }
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
  wrap-width: 50%,
) = {
  let raw-images = images.filter(i => not i.is-figure)
  let figure-images = images.filter(i => i.is-figure)
  // `_unstyled`, because block content extracted from a slide carries the
  // document-level `styled` wrappers the walker put back around it.
  let other-figures = blocks.filter(b => tree.unstyled(b).func() == figure)
  let other-blocks = blocks.filter(b => tree.unstyled(b).func() != figure)

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
  let is-heading = r => (
    type(r) == content and tree.unstyled(r).func() == heading
  )
  let headings = items.filter(is-heading)
  let breadcrumbs = items.filter(r => tree.is-kind(
    r,
    "touying-recall-breadcrumb",
  ))
  let body-parts = items.filter(r => (
    not is-heading(r) and not tree.is-kind(r, "touying-recall-breadcrumb")
  ))
  // Unwrap blocks to expose the inner content directly. Content gets nested
  // in `block(...)` at multiple points upstream (`_article-linearize` for
  // bare article-mode text, and again by touying-slide's own article-mode
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
  // A generated block reports `body` and nothing else; anything a user wrote
  // carries at least one more field, and stripping it would take that field,
  // the block's styling and its label with it.
  let _unwrap-blocks(r) = tree.map-tree(r, node => if (
    type(node) == content
      and node.func() == block
      and node.fields().keys() == ("body",)
  ) {
    _unwrap-blocks(node.body)
  })
  let unwrapped = body-parts.map(_unwrap-blocks)

  if has-wrap-content {
    // Only pull in meander for sections that actually need wrapping around
    // an obstacle — most article-mode sections have no images/blocks to
    // wrap, and shouldn't pay for the import or the reflow layout pass.
    import "@preview/meander:0.4.4"

    result += headings
    result += breadcrumbs
    let body-content = unwrapped.sum(default: none)
    body-content = if body-content == none { [] } else { body-content }

    // Meander measures each obstacle in an unbounded context to compute its
    // page tiling, so a percentage width silently resolves to `0pt` there.
    // Resolve the real content width with `layout` first.
    result.push(layout(size => {
      let float-width = size.width * wrap-width

      // Article mode linearizes; it does not carry the deck's layout over. So
      // a float takes `wrap-width` of the page whatever width was written for
      // the slide, and the image is made to fill it.
      //
      // Not by rebuilding the image: an `image`'s source is a path resolved
      // relative to the file it was written in, so one reconstructed here
      // would look for it next to this file. Instead it is boxed at the width
      // where its own percentage resolves to the target, which is what the
      // older `utils.rescale-image` did.
      let fill-images(element) = tree.map-tree(element, node => {
        if type(node) == content and node.func() == image {
          let declared = node.at("width", default: auto)
          let ratio = if type(declared) == ratio {
            (declared * 1pt).pt()
          } else if type(declared) == relative {
            (declared.ratio * 1pt).pt()
          } else { 1.0 }
          box(
            width: float-width,
            clip: true,
            box(width: float-width / calc.max(ratio, 0.01), node),
          )
        }
      })

      let to-wrap = ()
      if wrap-images {
        to-wrap += raw-images.map(i => fill-images(i.element))
      }
      if wrap-image-figures {
        to-wrap += figure-images.map(i => box(
          width: float-width,
          align(wrap-align-direction, fill-images(i.element)),
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
  // A `#set` or `#show` in force wraps the image in a `styled` node. Classify
  // underneath it, but hand the wrapper back on the element that renders, so
  // the rules still apply to it.
  if tree.is-styled(cont) {
    let inner = _extract-image(cont.child)
    if inner == none { return none }
    return (..inner, element: tree.restyle(cont, inner.element))
  }
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
  let children = if tree.is-sequence(cont) {
    cont.children.filter(c => c not in tree.empty-contents)
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
// These should be centered at the end of their subsection in article mode.
#let _is-block-content(cont) = {
  if cont == none or type(cont) != content { return false }
  if tree.is-styled(cont) { return _is-block-content(cont.child) }
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
  if tree.is-sequence(cont) {
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

// Linearize slide bodies for article mode.
//
// Returns a dictionary:
// - content: the text bodies joined as content
// - images: array of (img: content, width: length) for meander wrapping
// - blocks: array of block-level content (tables, canvases, non-image figures)
//           to be centered at the end of the subsection
#let _article-linearize(self, composer, conts) = {
  let article-cfg = self.at("article", default: (:))
  let any-wrapping = (
    article-cfg.at("wrap-images", default: true)
      or article-cfg.at("wrap-image-figures", default: false)
      or article-cfg.at("wrap-other-figures", default: false)
      or article-cfg.at("wrap-other", default: false)
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

  let images = ()
  let text-parts = ()
  let block-parts = ()

  let wrap-images = article-cfg.at("wrap-images", default: true)

  for cont in conts {
    let extracted = _extract-image(cont)
    if extracted != none {
      // The display element may be a figure, or wrapped in a `styled` node.
      images.push((
        element: extracted.element,
        is-figure: extracted.is-figure,
      ))
    } else if _is-block-content(cont) {
      block-parts.push(cont)
    } else if wrap-images {
      // An image written in the flow floats too, not only one that happens to
      // sit alone in a composer column: whether a deck put it in a column is
      // layout, and article mode does not carry the deck's layout over.
      //
      // `extract-nodes` walks sequences and styles but not into a body, so an
      // image inside a figure or a box stays where it is and is left to
      // `wrap-image-figures` and `wrap-other`.
      let pulled = tree.extract-nodes(cont, c => (
        type(c) == content and c.func() == image
      ))
      for img in pulled.found {
        images.push((element: img, is-figure: false))
      }
      if pulled.rest != none { text-parts.push(pulled.rest) }
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
// article — the same diagnostic configs.typ's `_default-preamble` runs per
// slide (gated on `is-first-slide`), which article mode never activates
// (entrypoint.typ's article-mode branch never sets that flag). Run once,
// at the end of the whole article, instead of per-slide.
#let _leak-check(self) = context {
  let marks = query(<touying-temporary-mark>)
  if marks.len() > 0 {
    let page-num = marks.at(0).location().page()
    let kind = marks.at(0).value.kind
    let fn = if "fn" in marks.at(0).value { marks.at(0).value.fn } else {
      none
    }
    let warning-msg = unsupported-mark-message(
      kind,
      fn,
      "page " + str(page-num) + " of the article",
    )
    if self.at("enable-mark-warning", default: true) {
      panic(warning-msg)
    } else {
      extern.warning(warning-msg)
    }
  }
}

// Render content as a continuous article instead of splitting into slides.
//
// In article mode, headings remain normal headings, slide wrappers render
// their body inline (no page breaks), and animation primitives (pause,
// meanwhile, uncover, only, etc.) show the final state.
//
// Bare (non-`#slide[...]`) content is routed through the real parser
// (`_parse-content-into-results-and-repetitions`, the same function
// `touying-slide`'s own article-mode branch uses) exactly like slide-
// wrapped content already is — this is what gives it full container
// recursion and full kind coverage (reducers, equations, waypoints,
// fn-wrappers, etc.) for free, rather than a separate, hand-rolled,
// necessarily-incomplete reimplementation of the same dispatch.
//
// - self (dictionary): The presentation context (must have article-mode: true and optionally article config like wrap-images)
// - body (content): The content to render
//
// -> content

// Drop what a mode label excludes. A labelled heading takes its whole section
// with it - everything up to the next heading of the same or higher level -
// because in slides mode skipping the heading skips the slide it would have
// produced, and that slide carries the section's content.
#let _filter-mode-children(self, children) = {
  let out = ()
  let skipping-depth = none
  for child in children {
    // The child may still be wrapped in the `styled` node a top-level
    // `#set`/`#show` put it in, so classify on what it really is.
    let core = tree.unstyled(child)
    let is-heading = type(core) == content and core.func() == heading
    if skipping-depth != none {
      if is-heading and core.depth <= skipping-depth {
        skipping-depth = none
      } else {
        continue
      }
    }
    let lbl = if type(core) == content and core.has("label") {
      str(core.label)
    }
    if lbl != none and check-current-mode-skip(self, lbl) {
      if is-heading { skipping-depth = core.depth }
      continue
    }
    out.push(child)
  }
  out
}

#let render-content-as-article(self: none, body) = {
  let children = tree.flatten-children(body, structural: _is-structural)
  children = _filter-mode-children(self, children)

  // Same convention split-content-into-slides uses to turn a bare "---"/"—"
  // into a slide break — in article mode there are no slide boundaries to
  // break, so it's a silent no-op instead (see the per-child checks below).
  // Wrap it in #article-only[...] to force a literal dash through instead.
  let horizontal-line-to-pagebreak = self.at(
    "horizontal-line-to-pagebreak",
    default: true,
  )

  let article-cfg = self.at("article", default: (:))
  let wrap-images = article-cfg.at("wrap-images", default: true)
  let wrap-image-figures = article-cfg.at("wrap-image-figures", default: false)
  let wrap-other-figures = article-cfg.at("wrap-other-figures", default: false)
  let wrap-other = article-cfg.at("wrap-other", default: false)
  let wrap-width = article-cfg.at("wrap-width", default: 50%)
  let wrap-align-direction = article-cfg.at(
    "wrap-align-direction",
    default: right,
  )
  let any-wrapping = (
    wrap-images or wrap-image-figures or wrap-other-figures or wrap-other
  )

  // Build the article-mode whole-slide-label set: labels attached to
  // headings or explicit #slide[...] wrappers, which touying-recall must
  // treat as a no-op (with a warning) rather than the generic recall
  // fallback — see parser.typ's inlined "touying-slide-recaller" branch,
  // which reads self.article-whole-slide-labels. Mirrors
  // split-content-into-slides's two registration sites
  // (slides.typ:298-304, :442-448) at a much smaller scope: article mode
  // never needs to replay a slide, just to recognize "was this ever a
  // whole-slide target."
  let whole-slide-labels = ()
  for child in children {
    let core = tree.unstyled(child)
    let lbl = if type(core) == content and core.func() == heading {
      core.at("label", default: none)
    } else if tree.is-kind(core, "touying-slide-wrapper") {
      core.at("label", default: none)
    } else {
      none
    }
    if lbl != none and lbl != <touying-temporary-mark> {
      whole-slide-labels.push(lbl)
    }
  }
  let self = self + (article-whole-slide-labels: whole-slide-labels)

  // Enable content extraction in slides when any wrapping is on
  let extract-self = if any-wrapping {
    self + (article-extract-content: true)
  } else {
    self
  }

  // Render one accumulated "run" of bare (non-special) document children by
  // routing it through the real parser, exactly like touying-slide's own
  // article-mode branch does for explicit #slide[...] content (mirrors
  // slides.typ:1816-1822: probe for repeat, then render at the final
  // subslide with delayed-wrapper content shown). Waypoint pre-computation
  // is intentionally skipped here (unlike touying-slide) — bare
  // article-mode content has no tested use case for named waypoint
  // ranges, and self.waypoints defaults safely to (:) everywhere it's read.
  // Pull top-level "touying-recall-breadcrumb" metadata nodes out of a
  // joined content tree. Breadcrumbs are invisible bookkeeping, not part of
  // the visible content article-text/article-only are meant to replace or
  // supplement — if they stayed buried inside the single joined block
  // _render-run produces, a subsequent "keep only headings" filter (see
  // article-text handling below) would discard them along with the
  // visible content they happen to share a run with, making touying-recall
  // unable to find them from anywhere inside that article-text/-only body.
  // Breadcrumbs are always emitted as direct top-level pushes alongside
  // whatever else the parser produces (never nested inside other pushed
  // content), so a single level of sequence-unwrapping is enough to find
  // them all.
  let _extract-breadcrumbs(cont) = tree.extract-nodes(cont, c => tree.is-kind(
    c,
    "touying-recall-breadcrumb",
  ))

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
    let linearized = _article-linearize(render-self, none, (extracted.rest,))
    (
      items: if linearized.content != none {
        (block(linearized.content),)
      } else {
        ()
      },
      images: linearized.images,
      blocks: linearized.blocks,
      breadcrumbs: extracted.found,
    )
  }

  // Resolve touying-render/touying-recall metadata nodes found anywhere in
  // a content body. The tree-walk itself (sequences, styled nodes,
  // wrapper/table-like content) is shared with touying-fn-wrapper's own
  // nesting support in parser.typ (see _resolve-marks-in-tree there) —
  // this only supplies the per-kind resolution logic.
  let _resolve-block-recalls(body) = tree.resolve-marks(
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
            + "article mode (there is no subslide progression to gate "
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
      let spec = v.subslides
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
        // article mode has no enclosing slide context to track — so every
        // resolved member must be shifted by (render-base - 1) to land in
        // the same absolute numbering as `repeat` above. A multi-member
        // spec has no stepping to do here (there's no outer progression to
        // step across) — matching `subslides: auto`'s own "final,
        // fully-revealed state" reduction just above, this shows its last
        // (highest) member.
        _resolve-waypoint-to-members((waypoints: cwp), spec, repeat).last()
        +render-base - 1
      } else if type(spec) == str and spec == "h" {
        render-base
      } else if type(spec) == str and spec == "!h" {
        _members-in-range("!" + str(render-base), render-base, repeat).last()
      } else if type(spec) == str {
        _resolve-string-to-members(spec, render-base, repeat).last()
      } else {
        resolve-negative-subslides(repeat, spec, base: render-base)
      }
      _render-at-subslide(
        self,
        v.content,
        reducer-data,
        cwp,
        render-base,
        target,
      )
    } else {
      // touying-recall used inside article-text/article-only: never a
      // whole-slide target here (recaller-map isn't consulted in article
      // mode), always the native-ref fallback (labeled reducer or arbitrary
      // labeled content).
      let raw-label = v.raw-label
      if type(raw-label) != label {
        panic(
          "touying-recall: a native label (e.g. <my-label>) is required to "
            + "recall a labeled reducer or other content in article mode — "
            + "a string label can only target a registered whole-slide recall.",
        )
      }
      _build-native-recall(
        raw-label,
        v.at("subslides", default: none),
        v.at("base", default: auto),
      )
    },
  )

  // touying-set-config's target self can change partway through the
  // article, so it's threaded as a local variable (not recomputed from
  // the original `self`) across the whole walk below — later runs and
  // #slide[...] calls see the merged config, matching the old per-child
  // behavior where touying-set-config recursed with a locally-merged self.
  let use-self = if any-wrapping { extract-self } else { self }

  if not any-wrapping {
    // Simple path: no wrapping or block extraction. Local closures in
    // Typst can't mutate variables from the enclosing scope, so the
    // "flush the accumulated run" step is inlined at each call site below
    // rather than factored into a helper.
    let result = ()
    let current-run = ()
    for child in children {
      // A top-level `#set`/`#show` leaves every child wrapped in a `styled`
      // node, so classify on `core` and put the styles back with `_restyle`
      // around anything pulled out of a mark's payload.
      let core = tree.unstyled(child)
      if tree.is-kind(core, "touying-article-text") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        // article-text replaces the preceding run's visible content, but
        // breadcrumbs are invisible bookkeeping (not part of what it's
        // replacing) and must survive so touying-recall inside its own
        // body can still find them.
        let headings = result.filter(item => (
          type(item) == content and tree.unstyled(item).func() == heading
        ))
        result = headings
        result += r.breadcrumbs
        result.push(tree.restyle(child, _resolve-block-recalls(
          core.value.body,
        )))
      } else if tree.is-kind(core, "touying-article-only") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        result.push(tree.restyle(child, _resolve-block-recalls(
          core.value.body,
        )))
      } else if tree.is-kind(core, "touying-set-config") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        use-self = utils.merge-dicts(use-self, core.value.config)
      } else if tree.is-kind(core, "touying-slide-wrapper") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        let slide-result = (core.value.fn)(use-self)
        let payload = _unwrap-article-raw(slide-result)
        let raw-content = payload.at("content", default: none)
        // Not wrapped in an extra block(): a rendered slide's own content is
        // already block-level (themes wrap slide bodies themselves), and an
        // additional block() here doesn't collapse its spacing with the
        // preceding heading's own below-spacing the way normal paragraph
        // flow does — it visibly doubles the gap when this is the first
        // thing under a heading (see e.g. "With Explicit Slide"/"Focus
        // Slide" in the article-mode test).
        if raw-content != none { result.push(tree.restyle(child, raw-content)) }
      } else if tree.is-kind(core, "touying-slides-only") {
        // Stripped in article mode — an article-mode/slide-mode
        // distinction the shared parser has no notion of, so it must be
        // filtered out here rather than left for the parser to see.
      } else if horizontal-line-to-pagebreak and core in ([—], [---]) {
        // A bare slide-separator dash — no-op in article mode (no slide
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
    // Same as the simple path above: classify on `core`, re-style anything
    // pulled out of a mark's payload.
    let core = tree.unstyled(child)
    let is-section-heading = type(core) == content and core.func() == heading
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
          wrap-width: wrap-width,
        ))
      }
      current-items = ()
      current-images = ()
      current-blocks = ()
    }

    if tree.is-kind(core, "touying-article-text") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      // article-text replaces the preceding run's visible content, but
      // breadcrumbs are invisible bookkeeping (not part of what it's
      // replacing) and must survive so touying-recall inside its own body
      // can still find them.
      let headings = current-items.filter(item => (
        type(item) == content and tree.unstyled(item).func() == heading
      ))
      current-items = headings
      current-images = () //nothing to do for article-text here
      current-blocks = ()
      current-items += r.breadcrumbs
      current-items.push(tree.restyle(
        child,
        _resolve-block-recalls(core.value.body),
      ))
    } else if tree.is-kind(core, "touying-article-only") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      current-items.push(tree.restyle(
        child,
        _resolve-block-recalls(core.value.body),
      ))
    } else if tree.is-kind(core, "touying-set-config") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      use-self = utils.merge-dicts(use-self, core.value.config)
    } else if tree.is-kind(core, "touying-slide-wrapper") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      let slide-result = (core.value.fn)(use-self)
      let payload = _unwrap-article-raw(slide-result)
      let raw-content = payload.at("content", default: none)
      // See the matching comment in the simple path above: no extra
      // block() wrap here either. (_wrap-section's own _unwrap-blocks
      // would strip it anyway when meander wrapping is active — this just
      // avoids the double-spacing bug in the common case where it isn't.)
      if raw-content != none {
        current-items.push(tree.restyle(child, raw-content))
      }
      // Content extracted for wrapping needs the same treatment as the
      // slide's own body above: a top-level `#show table: ..` must reach a
      // table that came out of a `#slide[..]`, not just a bare one.
      current-images += payload
        .at("images", default: ())
        .map(img => img + (element: tree.restyle(child, img.element)))
      current-blocks += payload
        .at("blocks", default: ())
        .map(b => tree.restyle(child, b))
    } else if is-section-heading {
      current-items.push(child)
    } else if tree.is-kind(core, "touying-slides-only") {
      // Stripped in article mode — an article-mode/slide-mode
      // distinction the shared parser has no notion of, so it must be
      // filtered out here rather than left for the parser to see.
    } else if horizontal-line-to-pagebreak and core in ([—], [---]) {
      // A bare slide-separator dash — no-op in article mode (no slide
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
      wrap-width: wrap-width,
    ))
  }

  sections.join() + _leak-check(self)
}
