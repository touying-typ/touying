#import "../utils.typ"
#import "../extern.typ"
#import "tree.typ"
#import "subslides.typ": resolve-negative-subslides
#import "parser.typ": (
  _build-native-recall, _members-in-range, _prepare-render-context,
  _render-at-subslide, _resolve-string-to-members, _resolve-waypoint-to-members,
  check-current-mode-skip, unsupported-mark-message, waypoint-anchor,
  waypoint-kinds,
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


// The scope of #article-linearize / #article-keep-layout is a block, tagged by
// an invisible metadata child rather than by a label: a label here would
// collide with the one a reader attaches to the call, and Typst allows only
// one per element. In slide output the metadata renders nothing and the block
// is all that is left, so these wrap a container, not a sentence.
#let _linearize-mark(on) = metadata((kind: "touying-linearize", on: on))

/// The direct children of a marker block's body.
///
/// - node (any): The candidate wrapper.
///
/// -> array
#let _marker-children(node) = {
  if type(node) != content or node.func() != block { return () }
  let body = node.at("body", default: none)
  if body == none { return () }
  if tree.is-sequence(body) { body.children } else { (body,) }
}


/// The metadata value a marker block of this kind carries, or `none`.
///
/// - node (any): The candidate wrapper.
///
/// - kind (str): The mark kind.
///
/// -> dictionary, none
#let _marker-value(node, kind) = {
  for k in _marker-children(node) {
    if tree.is-kind(k, kind) { return k.value }
  }
  none
}


/// A marker block's body, with the mark itself taken out.
///
/// Only the block's own children are dropped, so a nested marker keeps its
/// mark until its own block is unwrapped.
///
/// - node (any): The marker wrapper.
///
/// - kind (str): The mark kind.
///
/// -> any
#let _marker-body(node, kind) = (
  _marker-children(node).filter(k => not tree.is-kind(k, kind)).sum(default: [])
)


#let _linearize-force(node) = {
  let v = _marker-value(node, "touying-linearize")
  if v == none { none } else { v.on }
}


/// Mark `body` as a graphic drawn by `fn`, so that `config-article(wrap: ..)`
/// can target it.
///
/// A drawing package's output is ordinary content by the time the article
/// collects its floats, with nothing left to name it by, so the mark travels
/// with it. `touying-reducer` applies this itself; use it for a static diagram
/// that is not animated.
///
/// Example: `#graphic-marker(cetz.canvas, cetz.canvas(..))`
///
/// - fn (function): The drawing function, such as `cetz.canvas`.
///
/// - body (content): The graphic.
///
/// -> content
#let graphic-marker(fn, body) = block[#metadata((
    kind: "touying-graphic-marker",
    func: fn,
  ))#body]


/// A `target` predicate matching graphics drawn by `fn`.
///
/// Example: `config-article(wrap: (overrides: ((target: graphic-marker-of(cetz.canvas), align: left),)))`
///
/// - fn (function): The drawing function the mark carries.
///
/// -> function
#let graphic-marker-of(fn) = el => {
  let v = _marker-value(el, "touying-graphic-marker")
  v != none and v.at("func", default: none) == fn
}


/// Take the graphic marks back out, once they have done their matching.
///
/// The wrapper is ours, so neither it nor the mark should reach the page or a
/// reader's `query`. A label the reader put on the call moves onto the graphic.
///
/// - cont (any): The content to clean.
///
/// -> any
#let _strip-graphic-markers(cont) = tree.map-tree(cont, node => {
  if _marker-value(node, "touying-graphic-marker") == none { return none }
  tree.relabel(
    _strip-graphic-markers(_marker-body(node, "touying-graphic-marker")),
    node.at("label", default: none),
  )
})


/// Refuse a layout marker inside an `#article-only` or `#article-text` body.
///
/// Those bodies only ever reach the article, so there is no slide layout left
/// to decide about: whatever is written there is what the article gets.
///
/// - body (any): The enclosing mark's body.
///
/// - name (str): The enclosing mark, for the message.
///
/// -> any
#let _reject-layout-markers(body, name) = {
  if (
    tree.find-in-tree(body, c => tree.is-kind(c, "touying-linearize")) != none
  ) {
    panic(
      "`#article-linearize` and `#article-keep-layout` have no meaning inside `#"
        + name
        + "`, which only ever reaches the article. Write the layout you want "
        + "there directly.",
    )
  }
  body
}


/// Flatten the layout containers in `body` into the article's prose, whatever
/// `config-article(linearize: ..)` would decide for them.
///
/// Label the element itself rather than the call, so the label survives the
/// rebuild: `#article-linearize[#table(..) <tab:x>]`.
///
/// Example: `#article-linearize(components.side-by-side[a][b])`
///
/// - body (content): The content whose containers to flatten.
///
/// -> content
#let article-linearize(body) = block[#_linearize-mark(true)#body]


/// Keep the layout containers in `body` as they are, whatever
/// `config-article(linearize: ..)` would decide for them.
///
/// Same scoping and labelling as `article-linearize`.
///
/// Example: `#article-keep-layout[#table(columns: 2, [a], [b]) <tab:x>]`
///
/// - body (content): The content whose containers to leave alone.
///
/// -> content
#let article-keep-layout(body) = block[#_linearize-mark(false)#body]


/// A child as the article walk wants to see it: unstyled, and with a slide's
/// metadata taken out of the block it rides in.
///
/// `touying-slide-wrapper` wraps its metadata in a block so that a label on the
/// call (`#slide[..]<intro>`) has an element of its own rather than colliding
/// with `<touying-temporary-mark>`. Every `is-kind(.., "touying-slide-wrapper")`
/// test here predates that block and expects the bare node.
///
/// - it (any): The child.
///
/// -> any
#let _core-of(it) = {
  let core = tree.unstyled(it)
  if (
    type(core) == content
      and tree.is-kind(core.at("body", default: none), "touying-slide-wrapper")
  ) {
    return core.body
  }
  core
}

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
  let core = _core-of(it)
  if tree.is-metadata(core) { return true }
  if type(core) != content { return false }
  core.func() in (heading, pagebreak) or core in ([—], [---])
}


/// The payload `touying-slide` hides in a `touying-article-raw` metadata node
/// so that a theme's own `set` rules do not leak into the article.
///
/// - cont (content): The slide's return value.
///
/// -> dictionary
/// Whether this child starts a region an `#article-text` can claim.
///
/// A slide-level heading does, and so does a real `#pagebreak()`: the article
/// breaks there too, so content on the far side of one is not part of the same
/// run of prose. A bare `---` does not, since the article drops it.
///
/// - core (any): The child, already unstyled.
///
/// - slide-level (int): Headings this deep or shallower start a slide.
///
/// -> bool
#let _starts-region(core, slide-level) = (
  tree.is-heading(core, depth: slide-level)
    or (type(core) == content and core.func() == pagebreak)
)


#let _unwrap-article-raw(cont) = {
  let found = tree.find-in-tree(cont, c => tree.is-kind(
    c,
    "touying-article-raw",
  ))
  if found != none { found.value }
}


/// Normalise `config-article(wrap: ..)` into an ordered list of float specs.
///
/// Each spec is `(match: element => bool, width: ratio, align: alignment)`, and
/// the first whose `match` accepts a candidate decides how it floats. A
/// candidate no spec accepts stays in the flow.
///
/// `overrides` come first, so a predicate can carve out a case an element name
/// cannot express, such as a figure that holds an image. Element names are
/// matched on the name of the element function, which is why the two forms
/// exist at all: a dictionary key is a string, while `target` has to be a
/// predicate, since Typst cannot tell an element function from a closure (both
/// are `function`) and offers no way to test content against a selector.
///
/// - article-cfg (dictionary): The `article` config group.
///
/// -> array
#let _wrap-config(article-cfg) = {
  let wrap = article-cfg.at("wrap", default: (:))
  if type(wrap) == bool { wrap = (overrides: ((target: _ => wrap),)) }
  assert(
    type(wrap) == dictionary,
    message: "config-article(wrap:) takes a dictionary. Got: " + repr(wrap),
  )
  let base-width = wrap.at("width", default: 50%)
  let base-align = wrap.at("align", default: right)

  let spec(v, match) = {
    if v == none or v == false { return none }
    if v == true { return (match: match, width: base-width, align: base-align) }
    if type(v) in (ratio, relative, length) {
      return (match: match, width: v, align: base-align)
    }
    if type(v) == alignment {
      return (match: match, width: base-width, align: v)
    }
    if type(v) == dictionary {
      return (
        match: match,
        width: v.at("width", default: base-width),
        align: v.at("align", default: base-align),
      )
    }
    panic(
      "config-article(wrap:): a float takes `false`, `true`, a width, an "
        + "alignment, or a dictionary of them. Got: "
        + repr(v),
    )
  }

  let specs = ()
  for rule in wrap.at("overrides", default: ()) {
    assert(
      type(rule) == dictionary and "target" in rule,
      message: "config-article(wrap:): every entry of `overrides` is a dictionary "
        + "with a `target` predicate. Got: "
        + repr(rule),
    )
    let target = rule.target
    assert(
      type(target) == function,
      message: "config-article(wrap:): `target` is a predicate taking an "
        + "element and returning a bool, such as "
        + "`el => el.func() == figure`. Got: "
        + repr(target),
    )
    let rest = rule
    let _ = rest.remove("target")
    let s = spec(if rest.len() == 0 { true } else { rest }, target)
    if s != none { specs.push(s) }
  }
  for (key, v) in wrap {
    if key in ("width", "align", "overrides") { continue }
    let s = spec(v, el => repr(el.func()) == key)
    if s != none { specs.push(s) }
  }
  specs
}


/// The first spec that accepts this element, or `none` if it stays in the flow.
///
/// - specs (array): From `_wrap-config`.
///
/// - element (any): The float candidate.
///
/// -> dictionary, none
#let _wrap-spec-for(specs, element) = {
  let el = tree.unstyled(element)
  if type(el) != content { return none }
  for s in specs {
    if (s.match)(el) { return s }
  }
  none
}


#let _wrap-section(
  items,
  images,
  blocks,
  wrap: (),
) = {
  // Every candidate is matched the same way, whether it came out of the flow
  // as an image or was pulled aside as a block. `tree.unstyled` inside
  // _wrap-spec-for, because content extracted from a slide carries the
  // document-level `styled` wrappers the walker put back around it.
  let candidates = images.map(i => i.element) + blocks
  let floated = candidates
    .map(c => (element: c, spec: _wrap-spec-for(wrap, c)))
    .filter(c => c.spec != none)
  let unfloated = candidates.filter(c => _wrap-spec-for(wrap, c) == none)

  let has-wrap-content = floated.len() > 0

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
    // The obstacle widths are a share of the text width, which only a
    // measurement can resolve. It has to be meander's own: wrapping `reflow`
    // in a `layout` moves the origin its `place(top + left)` anchors to from
    // the page to the current flow position, so its page offset comes out as
    // zero, it sizes the first page as if it started at the top, and the text
    // runs past the bottom margin by however far down the page the section
    // began. `query.parent-size` resolves the same width from inside.
    result.push(meander.reflow({
      import meander: *
      callback(env: (size: query.parent-size()), env => {
        //rescale an image bc its relative width cannot change so we wrap it inside a container such the resulting size is correct.
        let fill-images(element, float-width) = tree.map-tree(element, node => {
          if (type(node) == std.content and node.func() == image) {
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

        let floats = floated.map(c => {
          let w = env.size.width * c.spec.width
          let filled = fill-images(_strip-graphic-markers(c.element), w)
          // A bare image already fills the width exactly. Anything else is
          // boxed to it, so the width means the same thing for a table or a
          // canvas as it does for an image.
          (
            align: c.spec.align,
            body: if tree.unstyled(_strip-graphic-markers(c.element)).func()
              == image { filled } else {
              box(width: w, align(c.spec.align, filled))
            },
          )
        })

        // Each kind can take its own side, so the floats are grouped by side
        // and each group stacked into one obstacle: meander offsets
        // obstacles, not the elements inside them.
        let sides = ()
        for f in floats {
          if f.align not in sides { sides.push(f.align) }
        }
        for side in sides {
          let group = floats.filter(f => f.align == side).map(f => f.body)
          placed(top + side, if group.len() == 1 { group.first() } else {
            stack(dir: ttb, spacing: 1em, ..group)
          })
        }
        container()
      })
      content(body-content)
    }))
  } else {
    result += headings
    result += breadcrumbs
    result += unwrapped
  }

  // Whatever no spec accepts → centered at the end of the section
  for c in unfloated {
    result.push(align(center, _strip-graphic-markers(c)))
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

/// Whether a table or grid declares a header or a footer.
///
/// That is the one explicit statement that its rows and columns carry meaning,
/// which is what separates data from a plain layout device: `components.cols`
/// and `side-by-side` build a grid and never declare one. A header *column*
/// cannot be declared in Typst yet, so a table that has only those reads as
/// layout here.
///
/// - cont (content): A table or grid element.
///
/// -> bool
#let _has-header(cont) = {
  cont.children.any(c => (
    type(c) == content
      and c.func() in (table.header, table.footer, grid.header, grid.footer)
  ))
}


/// The cells of a table or grid, in order, with the lines dropped.
///
/// - cont (content): A table or grid element.
///
/// -> array
#let _cells-of(cont) = {
  let _cell-bodies(kids) = kids
    .filter(c => type(c) == content and c.func() in (table.cell, grid.cell))
    .map(c => c.at("body", default: none))
  let out = ()
  for c in cont.children {
    if type(c) != content { continue }
    // A header or footer holds its cells one level down, so flattening past
    // it, which only happens when asked, must not drop what it says.
    if c.func() in (table.header, table.footer, grid.header, grid.footer) {
      out += _cell-bodies(c.children)
    } else {
      out += _cell-bodies((c,))
    }
  }
  out.filter(c => c != none)
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

  // A container that only arranges content, with no structure of its own, is
  // flattened into the prose: the article linearizes, it does not carry the
  // deck's layout over. `columns` is always one. A table or grid is one only
  // until it declares a header or footer, which is where its rows and columns
  // start to mean something.
  let linearize-cfg = article-cfg.at("linearize", default: auto)
  let wanted(cont, force) = {
    let f = cont.func()
    let key = if f == table { "table" } else if f == grid { "grid" } else if (
      f == columns
    ) { "columns" } else { return false }
    if force != none { return force }
    let setting = if type(linearize-cfg) == dictionary {
      linearize-cfg.at(key, default: auto)
    } else {
      linearize-cfg
    }
    if setting == auto {
      f == columns or not _has-header(cont)
    } else {
      setting
    }
  }
  let flatten(cont, force: none) = tree.map-tree(cont, node => {
    if type(node) != content { return none }
    // A figure is a captioned, referenceable unit, so its body stays whole
    // however it is built. Returning it unchanged also stops the descent.
    if node.func() == figure { return node }
    // #article-linearize / #article-keep-layout force the decision for exactly
    // their own block. The block is ours and goes away with the mark, unless
    // the reader labelled the call, in which case it stays to carry the label.
    let marked = _linearize-force(node)
    if marked != none {
      let inner = flatten(
        _marker-body(node, "touying-linearize"),
        force: marked,
      )
      // The marker's own block goes with the mark. A label the reader put on
      // the call is carried over to whatever now stands in its place.
      return tree.relabel(inner, node.at("label", default: none))
    }
    if not wanted(node, force) { return none }
    let inner = if node.func() == columns {
      // The column break belongs to the columns being removed: left in a
      // single-column flow it would break the page instead.
      let body = node.at("body", default: none)
      if body == none { none } else {
        tree.map-tree(body, n => if (
          type(n) == content and n.func() == colbreak
        ) { [] })
      }
    } else {
      _cells-of(node).join(parbreak())
    }
    // Flattened again, so a grid nested in a grid comes apart too.
    if inner == none { [] } else {
      // A label on the container outlives it, so #link and query still reach
      // what the reader named. A Typst reference needs a figure either way.
      tree.relabel(flatten(inner, force: force), node.at(
        "label",
        default: none,
      ))
    }
  })
  let conts = conts.map(flatten)

  let wrap = _wrap-config(article-cfg)
  let any-wrapping = wrap.len() > 0

  // Distinct top-level bodies (e.g. a composer's separate column contents)
  // are joined with an explicit parbreak() rather than wrapped in their own
  // block()s — a block's above/below spacing is resolved from wherever it's
  // constructed (e.g. a slide's own styling context) and doesn't collapse
  // with a preceding heading's spacing the way plain paragraph flow does,
  // and it can't be relied on for separation once _wrap-section's
  // _unwrap-blocks strips block wrappers back out downstream anyway.
  if not any-wrapping {
    return (
      content: if conts.len() == 0 { none } else {
        _strip-graphic-markers(conts.join(parbreak()))
      },
      images: (),
      blocks: (),
    )
  }

  let images = ()
  let text-parts = ()
  let block-parts = ()

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
    } else {
      // A float written in running prose floats too, not only one that happens
      // to sit alone in a composer column: whether a deck put it in a column is
      // layout, and article mode does not carry the deck's layout over. Only
      // what a spec accepts is pulled out, so anything nothing floats stays
      // where it was written rather than moving to the section's end.
      //
      // `extract-nodes` walks sequences and styles but not into a body, so an
      // image inside a figure or a box stays where it is, to be matched as the
      // figure or the box it sits in.
      let pulled = tree.extract-nodes(cont, c => (
        _wrap-spec-for(wrap, c) != none
      ))
      for el in pulled.found {
        images.push((
          element: el,
          is-figure: tree.unstyled(el).func() == figure,
        ))
      }
      if pulled.rest != none { text-parts.push(pulled.rest) }
    }
  }

  (
    content: if text-parts.len() == 0 { none } else {
      _strip-graphic-markers(text-parts.join(parbreak()))
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
// - self (dictionary): The presentation context (must have article-mode: true and optionally article config like `wrap`)
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
    let core = _core-of(child)
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

/// Splice the body of every `touying-set-config` node back into the walk.
///
/// `#show: appendix` compiles to a config node carrying the rest of the
/// document as its body. Article mode has no slide preamble to defer to, so
/// the config simply applies from that node on, and the body would otherwise
/// be dropped. Splicing beats recursing here: it keeps one walk, one leak
/// check, and one decision about wrapping.
///
/// - children (array): Flattened top-level children.
///
/// -> array
#let _expand-set-config(children) = {
  let out = ()
  for child in children {
    out.push(child)
    let core = _core-of(child)
    if tree.is-kind(core, "touying-set-config") {
      // restyle first, so a top-level `#set` wrapping the config node still
      // wraps its body; flatten-children then groups the run under one shared
      // styled node rather than one per child.
      out += _expand-set-config(tree.flatten-children(
        tree.restyle(child, core.value.body),
        structural: _is-structural,
      ))
    }
  }
  out
}


/// Place the waypoint link anchors, the article-mode counterpart of the
/// parser's own pass.
///
/// A waypoint owns the content from its marker up to the next waypoint, or to
/// the end of its slide, and its anchor sits at the end of that run — the same
/// position slides mode uses, minus the subslide gate, since article mode
/// renders the body once. A heading no deeper than `slide-level` starts a new
/// slide and so closes any open run, because a waypoint never reaches past the
/// slide it was written in.
///
/// -> array
#let _place-waypoint-anchors(self, children, slide-level) = {
  let out = ()
  let slide-label = none
  let open-waypoint = none

  for child in children {
    let core = _core-of(child)
    let is-slide-heading = (
      type(core) == content
        and core.func() == heading
        and core.depth <= slide-level
    )

    let is-waypoint = tree.is-kind(core, "touying-waypoint")
    if is-slide-heading or is-waypoint {
      if open-waypoint != none {
        let anchor = waypoint-anchor(slide-label, open-waypoint)
        if anchor != none { out.push(anchor) }
        open-waypoint = none
      }

      if is-slide-heading {
        slide-label = if core.has("label") { core.label }
      } else {
        open-waypoint = core.value.label
      }
    }

    out.push(child)
  }

  if open-waypoint != none {
    let anchor = waypoint-anchor(slide-label, open-waypoint)
    if anchor != none { out.push(anchor) }
  }

  out
}


#let render-content-as-article(self: none, body) = {
  let children = tree.flatten-children(body, structural: _is-structural)
  children = _filter-mode-children(self, children)
  children = _expand-set-config(children)

  // #article-text claims the slide it is written in, and a slide starts at a
  // heading no deeper than this (slides.typ:686 uses the same test). Deeper
  // headings are content inside the slide, so they do not bound it.
  let slide-level = self.at("slide-level", default: 2)

  children = _place-waypoint-anchors(self, children, slide-level)

  let article-cfg = self.at("article", default: (:))
  let wrap = _wrap-config(article-cfg)
  let any-wrapping = wrap.len() > 0

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
    let core = _core-of(child)
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

  /// - bare (bool): Parse only. A heading is emitted as its own item, so it
  ///   must not be wrapped in a block or handed to the linearizer, which
  ///   would treat it as extractable block content. It still has to be parsed:
  ///   a touying mark inside a heading is consumed here or not at all.
  let _render-run(self, run, bare: false) = {
    if run.len() == 0 {
      return (items: (), images: (), blocks: (), breadcrumbs: ())
    }
    let joined = run.sum(default: none)
    // Prepare this run exactly like an explicit slide: named waypoints must be
    // resolved before `uncover(<wp>)` and friends parse the final state. A bare
    // article run used to skip this step and failed on every named waypoint.
    let (reducer-data, cwp, repeat, _) = _prepare-render-context(
      self,
      joined,
      1,
    )
    let render-self = self + (waypoints: cwp, repeat: repeat, subslide: repeat)
    let cont = _render-at-subslide(
      render-self,
      joined,
      reducer-data,
      cwp,
      1,
      repeat,
      show-delayed-wrapper: true,
    )
    let extracted = _extract-breadcrumbs(cont)
    if bare {
      return (
        items: if extracted.rest != none { (extracted.rest,) } else { () },
        images: (),
        blocks: (),
        breadcrumbs: extracted.found,
      )
    }
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
        // Article mode has no enclosing slide waypoint map to inherit. This
        // content's own map was collected from `render-base`, so its members
        // already use the same absolute numbering as `repeat`. A multi-member
        // spec has no outer progression to step across here, so show its last
        // (highest) member, matching `auto`'s final-state reduction above.
        _resolve-waypoint-to-members(
          (waypoints: cwp),
          spec,
          repeat,
          base: render-base,
        ).last()
      } else if type(spec) == str and spec == "h" {
        render-base
      } else if type(spec) == str and spec == "!h" {
        _members-in-range("!" + str(render-base), render-base, repeat).last()
      } else if type(spec) == str {
        _resolve-string-to-members(spec, render-base, repeat).last()
      } else {
        // `repeat` is the absolute final index, so convert it to a plain
        // stage count before resolving negative indices against `base`.
        resolve-negative-subslides(
          repeat - render-base + 1,
          spec,
          base: render-base,
        )
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
    // An #article-text claims its whole section, so it cannot be applied where
    // it is written: content after it belongs to the same section and has to
    // go too. It is held here and applied when the section closes.
    let slide-start = 0
    let slide-text = none
    let slide-crumbs = ()
    for child in children {
      // A top-level `#set`/`#show` leaves every child wrapped in a `styled`
      // node, so classify on `core` and put the styles back with `_restyle`
      // around anything pulled out of a mark's payload.
      let core = _core-of(child)
      let is-section-heading = type(core) == content and core.func() == heading
      let starts-region = _starts-region(core, slide-level)
      if tree.is-kind(core, "touying-article-text") {
        // Rendered, not discarded: a touying-recall inside the article-text
        // body resolves against breadcrumbs left by the content it replaces.
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        slide-crumbs += r.breadcrumbs
        if slide-text != none {
          extern.warning(
            "#article-text: only one per slide, the later one is ignored. "
              + "Start a new slide to write another.",
          )
        } else {
          slide-text = tree.restyle(child, _reject-layout-markers(
            _resolve-block-recalls(core.value.body),
            "article-text",
          ))
        }
      } else if tree.is-kind(core, "touying-article-only") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        slide-crumbs += r.breadcrumbs
        result.push(tree.restyle(child, _reject-layout-markers(
          _resolve-block-recalls(core.value.body),
          "article-only",
        )))
      } else if tree.is-kind(core, "touying-set-config") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        slide-crumbs += r.breadcrumbs
        // The body was spliced into `children` by _expand-set-config, so only
        // the config itself is handled here.
        use-self = utils.merge-dicts(use-self, core.value.config)
      } else if tree.is-kind(core, "touying-slide-wrapper") {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        slide-crumbs += r.breadcrumbs
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
      } else if is-section-heading or starts-region {
        let r = _render-run(use-self, current-run)
        current-run = ()
        result += r.items
        result += r.breadcrumbs
        slide-crumbs += r.breadcrumbs
        // A deeper heading is content inside the slide, so it neither ends the
        // region nor limits the reach of a pending #article-text.
        if starts-region and slide-text != none {
          result = (
            result.slice(0, slide-start) + slide-crumbs + (slide-text,)
          )
        }
        let h = _render-run(use-self, (child,), bare: true)
        result += h.items
        result += h.breadcrumbs
        if starts-region {
          slide-start = result.len()
          slide-text = none
          slide-crumbs = ()
        } else {
          slide-crumbs += h.breadcrumbs
        }
      } else if tree.is-kind(core, "touying-slides-only") {
        // Stripped in article mode — an article-mode/slide-mode
        // distinction the shared parser has no notion of, so it must be
        // filtered out here rather than left for the parser to see.
      } else if core in ([—], [---]) {
        // A bare slide separator. It breaks slides, so it means nothing in an
        // article and is dropped, whatever `horizontal-line-to-pagebreak`
        // says: that config is about slide output. Inside #article-text or
        // #article-only it survives, because those bodies are emitted whole
        // rather than walked.
      } else {
        current-run.push(child)
      }
    }
    let r = _render-run(use-self, current-run)
    result += r.items
    result += r.breadcrumbs
    slide-crumbs += r.breadcrumbs
    if slide-text != none {
      result = result.slice(0, slide-start) + slide-crumbs + (slide-text,)
    }
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
  // See the simple path above: an #article-text claims its whole slide, so it
  // is held until the slide ends rather than applied where written. A slide
  // spans several of these float sections (every heading starts a new one), so
  // the reach is recorded as an index into `sections`.
  let slide-sections-start = 0
  let slide-head = ()
  let slide-text = none
  let slide-crumbs = ()
  for child in children {
    // Same as the simple path above: classify on `core`, re-style anything
    // pulled out of a mark's payload.
    let core = _core-of(child)
    let is-section-heading = type(core) == content and core.func() == heading
    let starts-region = _starts-region(core, slide-level)
    if (
      (is-section-heading or starts-region)
        and (current-items.len() > 0 or current-run.len() > 0)
    ) {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      slide-crumbs += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      if current-items.len() > 0 {
        sections.push(_wrap-section(
          current-items,
          current-images,
          current-blocks,
          wrap: wrap,
        ))
      }
      current-items = ()
      current-images = ()
      current-blocks = ()
    }

    // The region ends here, so a pending #article-text takes it over: every
    // float section the region produced goes, along with the floats and blocks
    // pulled out of them, and only the boundary itself and the breadcrumbs
    // stay behind.
    if starts-region {
      if slide-text != none {
        sections = sections.slice(0, slide-sections-start)
        sections.push(_wrap-section(
          slide-head + slide-crumbs + (slide-text,),
          (),
          (),
          wrap: wrap,
        ))
      }
      slide-text = none
      slide-crumbs = ()
    }

    if tree.is-kind(core, "touying-article-text") {
      // Rendered, not discarded: a touying-recall inside the article-text body
      // resolves against breadcrumbs left by the content it replaces.
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      slide-crumbs += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      if slide-text != none {
        extern.warning(
          "#article-text: only one per slide, the later one is ignored. "
            + "Start a new slide to write another.",
        )
      } else {
        slide-text = tree.restyle(
          child,
          _reject-layout-markers(
            _resolve-block-recalls(core.value.body),
            "article-text",
          ),
        )
      }
    } else if tree.is-kind(core, "touying-article-only") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      slide-crumbs += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      current-items.push(tree.restyle(
        child,
        _reject-layout-markers(
          _resolve-block-recalls(core.value.body),
          "article-only",
        ),
      ))
    } else if tree.is-kind(core, "touying-set-config") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      slide-crumbs += r.breadcrumbs
      current-images += r.images
      current-blocks += r.blocks
      // The body was spliced into `children` by _expand-set-config, so only
      // the config itself is handled here.
      use-self = utils.merge-dicts(use-self, core.value.config)
    } else if tree.is-kind(core, "touying-slide-wrapper") {
      let r = _render-run(use-self, current-run)
      current-run = ()
      current-items += r.items
      current-items += r.breadcrumbs
      slide-crumbs += r.breadcrumbs
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
    } else if is-section-heading or starts-region {
      let h = _render-run(use-self, (child,), bare: true)
      current-items += h.items
      current-items += h.breadcrumbs
      if starts-region {
        // Re-emitted verbatim if an #article-text takes the region over, so a
        // #pagebreak() still breaks there.
        slide-sections-start = sections.len()
        slide-head = h.items
      } else {
        slide-crumbs += h.breadcrumbs
      }
    } else if tree.is-kind(core, "touying-slides-only") {
      // Stripped in article mode — an article-mode/slide-mode
      // distinction the shared parser has no notion of, so it must be
      // filtered out here rather than left for the parser to see.
    } else if core in ([—], [---]) {
      // See the simple path above: a slide separator means nothing in an
      // article, and survives only inside #article-text or #article-only.
    } else {
      current-run.push(child)
    }
  }
  let r = _render-run(use-self, current-run)
  current-items += r.items
  current-items += r.breadcrumbs
  slide-crumbs += r.breadcrumbs
  current-images += r.images
  current-blocks += r.blocks
  if current-items.len() > 0 {
    sections.push(_wrap-section(
      current-items,
      current-images,
      current-blocks,
      wrap: wrap,
    ))
  }
  // The document ends the last slide, so the same takeover as at a
  // slide-level heading applies here.
  if slide-text != none {
    sections = sections.slice(0, slide-sections-start)
    sections.push(_wrap-section(
      slide-head + slide-crumbs + (slide-text,),
      (),
      (),
      wrap: wrap,
    ))
  }

  sections.join() + _leak-check(self)
}
