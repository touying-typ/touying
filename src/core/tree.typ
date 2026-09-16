// Content-tree fundamentals: recognising what a piece of Typst content is,
// taking it apart, and putting it back together again.

#import "../extern.typ": warning


/// Warn that a name is on its way out.
///
/// Use only on content emitting functions, as the emitted warning also requires emitting content.
/// Panic on value emitting functions instead.
///
/// - name (str): The deprecated name.
/// - version (str): The version that removes it.
/// - extra (str): A potential further explanation.
///
/// -> content
#let _deprecation-warning(name, version, extra: "") = warning(
  "`"
    + name
    + "` is deprecated and will be removed in touying "
    + version
    + "."
    + extra,
)



// -------------------------------------
//   Recognising content
// -------------------------------------

// get not-exposed element functions
#let typst-builtin-sequence = [].func()
#let typst-builtin-styled = text(red)[].func()
#let typst-builtin-space = [ ].func()
#let typst-builtin-math-symbol = ($x$).body.func()
#let typst-builtin-context = (context []).func()

/// Determine if a content is a sequence (i.e. created by concatenating content with `+` or implicit adjacency).
///
/// Example: `is-sequence([a])` returns `true`
///
/// - it (content): The content to check.
///
/// -> bool
#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}

/// Determine if a content is styled (i.e. wrapped by Typst's internal styled element when `set` or `show` rules are applied).
///
/// Example: `is-styled(text(fill: red)[Red])` returns `true`
///
/// - it (content): The content to check.
///
/// -> bool
#let is-styled(it) = {
  type(it) == content and it.func() == typst-builtin-styled
}

/// Determine if a content is a space (i.e. created by using whitespace in source code).
///
/// Example: `is-styled([ ])` returns `true`
///
/// - it (content): The content to check.
///
/// -> bool
#let is-space(it) = {
  type(it) == content and it.func() == typst-builtin-space
}

/// Determine if a content is a math symbol (i.e. wrapped by Typst's internal math symbol element when math is parsed).
///
/// Example: `is-math-symbol($x$)` returns `true`
///
/// - it (content): The content to check.
///
/// -> bool
#let is-math-symbol(it) = {
  type(it) == content and it.func() == typst-builtin-math-symbol
}

/// Determine if a content is a `metadata(...)` element.
///
/// Example: `is-metadata(metadata((a: 1)))` returns `true`
///
/// - it (content): The content to check.
///
/// -> bool
#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
///
/// - it (content): The content to check.
/// - kind (str): The kind string to match.
///
/// -> bool
#let is-kind(it, kind) = {
  (
    is-metadata(it)
      and type(it.value) == dictionary
      and it.value.at("kind", default: none) == kind
  )
}

/// Determine if a content is one of touying's own marks, of any kind.
///
/// - it (content): The content to check.
///
/// -> bool
#let is-touying-mark(it) = {
  if not (is-metadata(it) and type(it.value) == dictionary) {
    return false
  }
  let kind = it.value.at("kind", default: none)
  type(kind) == str and kind.starts-with("touying-")
}


/// Determine if a content is a heading up to specific depth.
///
/// - it (content): The content to check.
/// - depth (int): Maximum heading depth to consider. Default is `9999`.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}



// -------------------------------------
//   Handling content
// -------------------------------------

// convert all sequence to array recursively, and then flatten the array
#let sequence-to-array(it) = {
  if is-sequence(it) {
    it.children.map(sequence-to-array)
  } else {
    it
  }
}

/// All the contents that we treat as empty: sequence, space, parbreak, linebreak
#let empty-contents = ([], [ ], parbreak(), linebreak())

/// Remove leading and trailing empty elements from an array of content.
///
/// Example: `trim(([], [ ], parbreak(), linebreak(), [a], [ ], [b], [c], linebreak(), parbreak(), [ ], [ ]))` returns `([a], [ ], [b], [c])`
///
/// - arr (array): The array of content to trim.
/// - empty-contents (array): An array of content elements considered empty. Default is `([], [ ], parbreak(), linebreak())`.
///
/// -> array
#let trim(arr, empty-contents: empty-contents) = {
  let i = 0
  let j = arr.len() - 1
  while i != arr.len() and arr.at(i) in empty-contents {
    i += 1
  }
  while j != i - 1 and arr.at(j) in empty-contents {
    j -= 1
  }
  arr.slice(i, j + 1)
}


/// Add a label to a content.
///
/// Example: `label-it("key", [a])` is equivalent to `[a <key>]`
///
/// - it (content): The content to label.
/// - label-name (str, label): The name of the label, or a label.
///
/// -> content
#let label-it(it, label-name) = {
  if type(label-name) == label {
    [#it#label-name]
  } else {
    assert(type(label-name) == str, message: repr(label-name))
    [#it#label(label-name)]
  }
}


/// Put a label a discarded wrapper carried onto the content that replaces it.
///
/// A label sits on one element, so content that came apart into a sequence
/// gets a block to hold it, and so does an element that already carries a
/// label of its own: Typst allows only one per element.
///
/// - cont (any): The rebuilt content.
///
/// - lbl (label, none): The label to reattach, or `none` to do nothing.
///
/// -> any
#let relabel(cont, lbl) = {
  if lbl == none { return cont }
  let free = (
    type(cont) == content
      and not is-sequence(cont)
      and cont.at("label", default: none) == none
  )
  label-it(if free { cont } else { block(cont) }, lbl)
}



// -------------------------------------
//   Rebuilding content
// -------------------------------------

/// The positional signature of an element constructor, as field names in the
/// order it wants them. Empty for the constructors that take everything by
/// name, which is most of them.
///
/// `image` is deliberately absent even though its `source` is positional: an
/// image's source is a path resolved relative to the file it was written in,
/// so a rebuilt one looks for it next to whichever file rebuilt it. Failing
/// loudly is better than that.
///
/// Two kinds of entry are not plain field names. `..name` marks a field whose
/// array value is spread, as in `polygon(..vertices)`. A `"body"` entry marks
/// a constructor whose body is positional but not last, as in
/// `math.underbrace(body, annotation)`.
///
/// - f (function): The element function.
///
/// -> array
#let positional-fields(f) = {
  if f == align or f == place {
    ("alignment",)
  } else if f == columns {
    ("count",)
  } else if f == link {
    ("dest",)
  } else if f == rotate {
    ("angle",)
  } else if f == terms.item {
    ("term",)
  } else if f == math.class {
    ("class", "body")
  } else if f == math.frac {
    ("num", "denom")
  } else if f == math.root {
    // `radicand` is positional and `index` optional, so `sqrt(x)` is a `root`
    // carrying only `radicand`. `call-with-fields` skips an absent positional
    // field, which leaves the remaining ones in the right order either way.
    ("index", "radicand")
  } else if f == math.binom {
    // `lower` is variadic (`binom(n, k, j)` is valid), hence the spread.
    ("upper", "..lower")
  } else if f == math.accent {
    ("base", "accent")
  } else if f == math.vec or f == math.cases {
    ("..children",)
  } else if f == math.attach {
    // Only `base` is positional; every script is a named argument.
    ("base",)
  } else if f == math.mat {
    // One positional argument per row, each an array of cells.
    ("..rows",)
  } else if f == polygon {
    // `polygon.regular(..)` constructs a `polygon` with resolved vertices.
    ("..vertices",)
  } else if f == curve {
    ("..components",)
  } else if f == raw.line {
    ("number", "count", "text")
  } else if (
    f
      in (
        math.underbrace,
        math.overbrace,
        math.underbracket,
        math.overbracket,
        math.underparen,
        math.overparen,
        math.undershell,
        math.overshell,
      )
  ) {
    ("body", "annotation")
  } else {
    ()
  }
}


/// Fields an element carries once realized but its constructor does not accept,
/// keyed by `repr` of the element function.
///
/// Inside a show rule an element is realized: Typst has filled in the fields it
/// synthesizes from the surroundings (a caption's `kind`, `supplement`,
/// `counter`, ...). Handing those back to the constructor is an error, so they
/// are dropped when such an element is rebuilt.
#let _synthesized-fields = (
  "caption": ("kind", "supplement", "counter", "numbering"),
)


/// Call an element function with a dictionary of fields, passing positionally
/// the ones its constructor takes positionally.
///
/// The dictionary is used as given, so an edited field survives. Use this over
/// `reconstruct` when the fields have already been changed.
///
/// - f (function): The element function to call.
/// - fields (dictionary): The fields to pass. A `label` must already have been removed by the caller.
/// - extra (arguments): Trailing positional arguments, usually the new body.
///
/// -> content
#let call-with-fields(f, fields, ..extra) = {
  let fields = fields
  for name in _synthesized-fields.at(repr(f), default: ()) {
    let _ = fields.remove(name, default: none)
  }
  let leading = ()
  for name in positional-fields(f) {
    if name.starts-with("..") {
      leading += fields.remove(name.slice(2), default: ())
    } else {
      let value = fields.remove(name, default: none)
      // An absent field is one the element does not carry, such as a `place`
      // with no alignment. No listed field can legitimately hold `none`.
      if value != none { leading.push(value) }
    }
  }
  f(..leading, ..fields, ..extra)
}


/// Reconstruct a content with a new body.
///
/// - body-name (str): The property name of the body field.
/// - labeled (bool): Indicates whether the label of the content should be preserved.
/// - named (bool): Indicates whether to pass fields as named arguments.
/// - it (content): The content to reconstruct.
/// - new-body (content): The new body you want to replace the old body with.
///
/// -> content
#let reconstruct(
  body-name: "body",
  labeled: true,
  named: false,
  it,
  ..new-body,
) = {
  let fields = it.fields()
  let label = fields.remove("label", default: none)
  let _ = fields.remove(body-name, default: none)
  if named {
    // `call-with-fields` handles the constructors that want some field
    // positionally. When the body is one of those (`math.underbrace(body,
    // annotation)`) it has to go back into the dictionary so it lands at the
    // right index rather than after the annotation.
    let result = if body-name in positional-fields(it.func()) {
      fields.insert(body-name, new-body.pos().sum(default: []))
      call-with-fields(it.func(), fields)
    } else {
      call-with-fields(it.func(), fields, ..new-body)
    }
    if label != none and labeled {
      return [#result#label]
    } else {
      return result
    }
  } else {
    if label != none and labeled {
      return [#(it.func())(..fields.values(), ..new-body)#label]
    } else {
      return (it.func())(..fields.values(), ..new-body)
    }
  }
}


/// Reconstruct a table-like content with new children.
///
/// - named (bool): Whether to pass fields as named arguments. Default is `true`.
/// - labeled (bool): Whether to preserve the label of the content. Default is `true`.
/// - it (content): The content to reconstruct.
/// - new-children (array): The new children to replace the old children with.
///
/// -> content
#let reconstruct-table-like(named: true, labeled: true, it, new-children) = {
  reconstruct(
    body-name: "children",
    named: named,
    labeled: labeled,
    it,
    ..new-children,
  )
}


/// Reconstruct a styled content with a new body.
///
/// - it (content): The content to reconstruct.
/// - new-child (content): The new child you want to replace the old body with.
///
/// -> content
#let reconstruct-styled(it, new-child) = {
  typst-builtin-styled(new-child, it.styles)
}

/// Reconstruct a heading with a new body
///
/// - it (content): The heading to reconstruct,
/// - new-body (content): The new body for the heading.
/// - args ():
/// ->
#let reconstruct-heading(it, new-body, ..args) = {
  assert(
    type(it) == content and it.func() == heading,
    message: "it must be a heading",
  )
  // From `fields()`, not from named reads: an unrealized heading does not
  // know what it has not been given, and asking panics.
  let fields = it.fields()
  let lbl = fields.remove("label", default: none)
  let _ = fields.remove("body", default: none)
  fields += args.named()
  let result = heading(..fields, new-body)
  if lbl == none { result } else { label-it(result, lbl) }
}


// -------------------------------------
//   Walking content
// -------------------------------------

// Math elements whose sub-content sits in named fields, mapped to those field
// names in the order `children-of` returns them. Only fields actually present
// are visited: `attach` carries just the scripts it was given. `mat`'s `rows`
// and `cases`' delim-like fields hold arrays, which `children-of` flattens and
// `rebuild` puts back with the same shape.
//
// `vec`, `cases`, `lr`, `underline` and friends are absent on purpose: their
// content is already in `children` or `body`, which the generic shapes below
// handle.
// Keyed by `repr` of the element function: a dictionary needs string keys, and
// `repr(math.frac)` is just `"frac"`.
#let _math-multi-field = (
  frac: ("num", "denom"),
  mat: ("rows",),
  root: ("index", "radicand"),
  binom: ("upper", "lower"),
  // for math.accent: Only `base`, the `accent` field is a single-codepoint symbol, not content
  // to walk into, and rebuilding it from a walked value fails outright.
  accent: ("base",),
  attach: ("base", "t", "b", "tl", "tr", "bl", "br"),
  underbrace: ("body", "annotation"),
  overbrace: ("body", "annotation"),
  underbracket: ("body", "annotation"),
  overbracket: ("body", "annotation"),
  class: ("body",),
)


/// The content-bearing fields `it` actually carries, in `children-of` order.
///
/// -> array
#let _math-fields(it) = {
  _math-multi-field.at(repr(it.func()), default: ()).filter(f => it.has(f))
}

/// How a piece of content holds its sub-content, as one of `"sequence"`,
/// `"styled"`, `"metadata"`, `"figure"`, `"term"`, `"children"`, `"body"`,
/// `"child"` or `"leaf"`.
/// Does not determine the element function.
/// And `"leaf"` marks a value that is not content.
///
/// - it (any): The content/object to classify.
///
/// -> str
#let shape-of(it) = {
  if type(it) != content { return "leaf" }
  let f = it.func()
  if f == typst-builtin-sequence {
    "sequence"
  } else if f == typst-builtin-styled {
    "styled"
  } else if f == metadata {
    "metadata"
  } else if f == figure {
    // A figure holds a caption as well as a body, and covering or rewriting
    // one has to reach both.
    "figure"
  } else if f == terms.item {
    "term"
  } else if repr(f) in _math-multi-field {
    // Math elements hold their sub-content in named fields of their own
    // (`frac`'s num/denom, `mat`'s rows, `attach`'s scripts) rather than in
    // `body`/`children`, so without this they look like leaves and a `#pause`
    // inside one is never reached by the walk.
    "math"
  } else if it.has("children") {
    "children"
  } else if it.has("body") {
    "body"
  } else if it.has("child") {
    "child"
  } else {
    "leaf"
  }
}


/// Returns the sub-content of `it`, in the order `rebuild` expects it back.
/// Can get the inner body/children fields whatever they are called.
///
/// - it (any): The content to open up.
///
/// -> array
#let children-of(it) = {
  let shape = shape-of(it)
  if shape == "sequence" or shape == "children" {
    it.children
  } else if shape == "styled" or shape == "child" {
    (it.child,)
  } else if shape == "figure" {
    let caption = it.at("caption", default: none)
    if caption == none { (it.body,) } else { (it.body, caption) }
  } else if shape == "term" {
    (it.term, it.description)
  } else if shape == "math" {
    // `mat`'s `rows` is an array of arrays; flatten so every cell is visited
    // like any other child. `rebuild` restores the shape from the element's
    // own fields, so nothing here has to remember it.
    _math-fields(it)
      .map(f => it.at(f))
      .map(v => if type(v) == array { v.flatten() } else { (v,) })
      .flatten()
  } else if shape == "body" {
    (it.body,)
  } else {
    ()
  }
}


/// Whether `it` is, or holds anywhere below it, one of touying's own marks.
///
/// Tells a walk whether a node has to be taken apart to reach a mark, or can
/// be handled whole.
///
/// - it (any): The node to search.
///
/// -> bool
#let has-touying-mark(it) = {
  if is-touying-mark(it) { return true }
  if type(it) == array { return it.any(has-touying-mark) }
  children-of(it).any(has-touying-mark)
}


/// Put `it` back together around new sub-content, possibly keeping its label.
///
/// - labeled (bool): Whether to re-attach the label.
/// - it (content): The content to rebuild.
/// - new-children (array): Replacements, in the order that `children-of` returns them.
///
/// -> content
#let rebuild(labeled: true, it, new-children) = {
  let shape = shape-of(it)
  if shape == "sequence" {
    new-children.sum(default: [])
  } else if shape == "styled" {
    reconstruct-styled(it, new-children.first())
  } else if shape == "children" {
    reconstruct-table-like(it, labeled: labeled, new-children)
  } else if shape == "body" {
    reconstruct(named: true, labeled: labeled, it, new-children.first())
  } else if shape == "child" {
    reconstruct(
      named: true,
      body-name: "child",
      labeled: labeled,
      it,
      new-children.first(),
    )
  } else if shape == "math" {
    let fields = it.fields()
    let lbl = fields.remove("label", default: none)
    let rest = new-children
    // Hand each field back exactly as many children as it gave up, so an
    // array-valued field (`mat`'s rows) is rebuilt row by row.
    for f in _math-fields(it) {
      let old-value = it.at(f)
      if type(old-value) == array {
        let rebuilt = ()
        for row in old-value {
          if type(row) == array {
            rebuilt.push(rest.slice(0, row.len()))
            rest = rest.slice(row.len())
          } else {
            rebuilt.push(rest.first())
            rest = rest.slice(1)
          }
        }
        fields.insert(f, rebuilt)
      } else {
        fields.insert(f, rest.first())
        rest = rest.slice(1)
      }
    }
    // `root` is built directly: its `index` is positional *and* optional
    // (`sqrt(x)` is a `root` carrying only `radicand`), while
    // `call-with-fields` skips any positional field holding `none` — which
    // would slide `radicand` into the `index` slot. `math.root(none, x)` is
    // exactly `sqrt(x)`.
    let result = if it.func() == math.root {
      // `sqrt(x)` is a `root` with no `index` at all, and rebuilding it as
      // `root(none, x)` renders identically but is no longer `==` the
      // original, which `map-tree`'s identity short-circuit relies on.
      if "index" in fields {
        math.root(fields.index, fields.radicand)
      } else {
        math.sqrt(fields.radicand)
      }
    } else {
      call-with-fields(it.func(), fields)
    }
    if lbl != none and labeled { [#result#lbl] } else { result }
  } else if shape == "figure" or shape == "term" {
    // Two fields to replace at once, which `reconstruct` cannot express.
    let fields = it.fields()
    let lbl = fields.remove("label", default: none)
    let result = if shape == "term" {
      terms.item(new-children.at(0), new-children.at(1))
    } else {
      let _ = fields.remove("body", default: none)
      if new-children.len() > 1 { fields.caption = new-children.at(1) }
      call-with-fields(it.func(), fields, new-children.first())
    }
    if lbl != none and labeled { [#result#lbl] } else { result }
  } else {
    it
  }
}


/// Rewrite a content tree.
///
/// The function `visit` is called on every node on the way down. Return `none` to walk into
/// the node, or content to put in its place and stop.
/// Returning the empty sequence `[]` deletes it.
///
/// A node whose sub-content came back unchanged is returned as it was, so a
/// walk that rewrites one leaf leaves the rest of the tree identical rather
/// than rebuilding it. To change visitor partway down, call `map-tree` again
/// from inside `visit` and return the result.
///
/// - labeled (bool): Whether rebuilt nodes keep their label.
/// - it (any): The root.
/// - visit (function): `it => none | content`.
///
/// -> content
#let map-tree(labeled: true, it, visit) = {
  let potential-replacement = visit(it)
  if potential-replacement != none { return potential-replacement }

  let kids = children-of(it)
  if kids.len() == 0 { return it }
  let new-kids = kids.map(k => map-tree(k, visit, labeled: labeled))

  if new-kids == kids { return it }
  rebuild(it, new-kids, labeled: labeled)
}


/// The first node in `it` that `pred` accepts, or `none`.
///
/// - enter (function): Whether to look inside a node. Use it to stop the
///   search at a boundary rather than pruning matches afterwards.
/// - it (any): The root.
/// - pred (function): `it => bool`.
///
/// -> any
#let find-in-tree(enter: it => true, it, pred) = {
  if pred(it) { return it }
  if not enter(it) { return none }

  for child in children-of(it) {
    let hit = find-in-tree(child, pred, enter: enter)
    if hit != none { return hit }
  }

  none
}


/// Replace every metadata mark of one of `kinds` by what `resolve` makes of
/// its value.
///
/// - it (any): The root.
/// - kinds (array): Mark kinds to resolve.
/// - resolve (function): `value => content`. Returning `none` drops the mark.
///
/// -> content
#let resolve-marks(it, kinds, resolve) = map-tree(it, node => {
  if (
    is-metadata(node)
      and type(node.value) == dictionary
      and node.value.at("kind", default: none) in kinds
  ) {
    let resolved = resolve(node.value)
    if resolved == none { [] } else { resolved }
  }
})


/// How many list, enum or terms items `it` holds.
///
/// Sees through the `styled` node a `#set` or `#show` inside the body creates,
/// which is otherwise indistinguishable from content with no items at all.
///
/// - it (any): The content to count.
///
/// -> int
#let count-items(it) = {
  if is-styled(it) { return count-items(it.child) }

  if is-sequence(it) {
    let meaningful = it.children.filter(c => c not in empty-contents)
    // A `#set` at the top of the body leaves the items inside a lone `styled`
    // child, with only spacing beside it.
    if (
      meaningful.len() == 1
        and (is-styled(meaningful.first()) or is-sequence(meaningful.first()))
    ) {
      return count-items(meaningful.first())
    }

    return meaningful
      .filter(c => (
        type(c) == content and c.func() in (list.item, enum.item, terms.item)
      ))
      .len()
  }

  if type(it) == content and it.func() in (list, enum, terms) {
    return it.children.len()
  }

  1 //fallback
}


// -------------------------------------
//   Styles
// -------------------------------------

/// What `it` is underneath any `styled` wrappers.
///
/// - it (any): The content to peel.
///
/// -> any
#let unstyled(it) = if is-styled(it) { unstyled(it.child) } else { it }


/// The `styled` wrappers around `it`, outermost first.
///
/// - it (any): The content to inspect.
///
/// -> array
#let styles-of(it) = if is-styled(it) {
  (it.styles,) + styles-of(it.child)
} else {
  ()
}


/// Put `content` back under the styles `from` was wrapped in.
///
/// - from (any): The content the styles came off.
///
/// - content (content): What to wrap.
///
/// -> content
#let restyle(from, content) = {
  let out = content
  // Innermost first, so the outermost wrapper ends up outermost again.
  for styles in styles-of(from).rev() {
    out = typst-builtin-styled(out, styles)
  }
  out
}


/// Flatten `it` into the list of children a walker classifies, keeping runs of
/// unclassified children under one shared `styled` wrapper.
///
/// Giving every child its own copy of the styles would not preserve the
/// document: Typst's realizer groups adjacent elements and a wrapper between
/// them stops it, so `#set par(..)` would break a paragraph apart and
/// `#set enum(..)` would restart the numbering at every boundary. Only the
/// children `structural` accepts are peeled out on their own.
///
/// - structural (function): `it => bool`, the children the caller needs to see
///   individually.
///
/// - it (any): The root.
///
/// -> array
#let flatten-children(structural: it => false, it) = {
  if is-styled(it) {
    let out = ()
    let run = ()
    for child in flatten-children(it.child, structural: structural) {
      if structural(child) {
        if run.len() > 0 {
          out.push(typst-builtin-styled(run.sum(default: []), it.styles))
          run = ()
        }
        out.push(typst-builtin-styled(child, it.styles))
      } else {
        run.push(child)
      }
    }
    if run.len() > 0 {
      out.push(typst-builtin-styled(run.sum(default: []), it.styles))
    }
    return out
  }
  if is-sequence(it) {
    return it
      .children
      .map(c => flatten-children(c, structural: structural))
      .flatten()
  }
  (it,)
}


/// Pull every node `pred` accepts out of `it`, returning them and what is left.
///
/// - it (any): The root.
///
/// - pred (function): `it => bool`.
///
/// -> dictionary
#let extract-nodes(it, pred) = {
  if it == none { return (found: (), rest: none) }
  if pred(it) { return (found: (it,), rest: none) }
  if is-styled(it) {
    let inner = extract-nodes(it.child, pred)
    return (
      found: inner.found,
      rest: if inner.rest == none { none } else {
        reconstruct-styled(it, inner.rest)
      },
    )
  }
  if is-sequence(it) {
    let found = ()
    let rest = ()
    for child in it.children {
      let inner = extract-nodes(child, pred)
      found += inner.found
      if inner.rest != none { rest.push(inner.rest) }
    }
    return (found: found, rest: rest.sum(default: none))
  }
  (found: (), rest: it)
}


// ============================================================================
// Item runs
//
// `list`, `enum` and `terms` are usually not written as containers. Typst
// builds one from a run of adjacent `list.item` / `enum.item` / `terms.item`
// children, and two facts about that construction drive everything below.
//
// What bounds a run, measured rather than assumed:
//
//   - Items of the same kind separated by a parbreak stay ONE container, which
//     Typst then makes non-tight: every row gap widens from `par.leading` to
//     `par.spacing` and the container starts lower.
//   - Items of DIFFERENT kinds are always separate containers, parbreak or no
//     parbreak, and each stays tight. A parbreak between them changes nothing.
//   - A space between items is insignificant. A linebreak written at the end of
//     an item line is absorbed into that item; one standing alone as a sibling
//     ends the run, as does any other content.
//
// And what a run owes its members: markers and numbers belong to the
// container and are assigned at layout time from an item's position in it. An
// item taken out of a run therefore loses its row, and a run rebuilt as its own
// container restarts its numbering at 1 unless told otherwise.
//
// These helpers describe the shape of such a run. Deciding what to do about it
// is the caller's business.============================================================================

/// The three list-like functions whose adjacent children Typst gathers into a container.
#let list-like-item-funcs = (list.item, enum.item, terms.item)

/// Whether a content is a `list`, `enum` or `terms` item.
///
/// - it (any): The content to check.
///
/// -> bool
#let is-list-like-item(it) = (
  type(it) == content and it.func() in list-like-item-funcs
)

/// Whether a content is a parbreak.
///
/// - it (any): The content to check.
///
/// -> bool
#let is-parbreak(it) = type(it) == content and it.func() == parbreak

/// The name of a value's type, as a diagnostic would want to print it.
///
/// For content this is its element function, spelled out where `repr` is no
/// help: it calls all three item functions "item". For anything else it is the
/// Typst type.
///
/// - it (any): The value to name.
///
/// -> str
#let get-elem-type-name(it) = {
  if type(it) != content {
    return repr(type(it))
  }
  let elem-func = it.func()
  if elem-func == list.item {
    "list.item"
  } else if elem-func == enum.item {
    "enum.item"
  } else if elem-func == terms.item {
    "terms.item"
  } else {
    repr(elem-func)
  }
}

/// Build the container Typst would have built from a run of items.
///
/// The kind is taken from the items themselves, which must all share it: a run
/// of mixed kinds is not one container and panics rather than silently
/// producing one. An empty run yields empty content.
///
/// `tight` has to be stated because a run emitted on its own has lost the
/// parbreak that would have told Typst to widen it. `first-number` likewise:
/// position in the container is what numbers an item, so a rebuilt enum
/// restarts at 1 without it. It is ignored for a list and for terms, which are
/// not numbered.
///
/// - items (array): The run's items, in order. All of one kind, or it panics.
///
/// - tight (bool): Whether the container is tight.
///
/// - first-number (int): The number the first item carries, for an enum.
///
/// -> content
#let build-list-like-from(items, tight: true, first-number: 1) = {
  if items.len() == 0 {
    return []
  }

  let first = items.first()
  let kind = if is-list-like-item(first) { first.func() } else { none }
  let is-one-kind = items.all(item => (
    is-list-like-item(item) and item.func() == kind
  ))
  assert(
    is-one-kind,
    message: "build-list-like-from: expected items of one kind, got "
      + repr(items.map(get-elem-type-name)),
  )

  if kind == enum.item {
    enum(tight: tight, start: first-number, ..items)
  } else if kind == terms.item {
    terms(tight: tight, ..items)
  } else {
    list(tight: tight, ..items)
  }
}

/// The gap Typst puts between two rows of a container built from items of the
/// given kind.
///
/// With the container's `spacing` set the user named it. Left `auto` it comes
/// from the paragraph metrics instead, which is `par.spacing` when the
/// container is non-tight and `par.leading` when it is tight.
///
/// Must be called from a context, as it reads the active container and
/// paragraph styles.
///
/// - kind (function): One of `list.item`, `enum.item`, `terms.item`.
///
/// - tight (bool): Whether the container is tight.
///
/// -> length
#let get-row-spacing-of-list-like(kind, tight: true) = {
  let spacing = if kind == list.item {
    list.spacing
  } else if kind == enum.item {
    enum.spacing
  } else if kind == terms.item {
    terms.spacing
  } else {
    auto
  }
  if spacing != auto {
    spacing
  } else if tight {
    par.leading
  } else {
    par.spacing
  }
}

/// The runs of items Typst would gather into list-like containers, in order.
///
/// A run is a maximal stretch of same-kind items together with the spaces and
/// parbreaks between them. Children that are part of no run are not returned;
/// each run carries the bounds to find them by.
///
/// Each run is a dictionary:
/// - `kind` (function): the run's item function.
/// - `items` (array): its items, spacers dropped.
/// - `tight` (bool): whether Typst builds it tight, i.e. whether no parbreak
///   falls between two of its items.
/// - `start` (int), `end` (int): the run's bounds in `children`, so
///   `children.slice(start, end)` is what it was built from.
///
/// - children (array): A sequence's children, in order. Content that is not a
///   sequence has to be wrapped as a one-element array by the caller.
///
/// -> array
#let get-list-like-runs-among(children) = {
  let empty-run = (kind: none, items: (), tight: true, start: 0, end: 0)

  let found-runs = ()
  let current = empty-run
  let break-is-pending = false

  let starts-new-run(child, old-kind) = (
    is-list-like-item(child) and old-kind != none and child.func() != old-kind
  )

  let breaks-run(child) = {
    not (
      is-list-like-item(child) or is-space(child) or is-parbreak(child)
    )
  }

  for (index, child) in children.enumerate() {
    let start-new-run = starts-new-run(child, current.kind)
    let stop-run = breaks-run(child)

    if (start-new-run or stop-run) and current.items.len() != 0 {
      found-runs.push(current)
      current = empty-run
      break-is-pending = false
    }
    if stop-run or is-space(child) { continue }

    if is-parbreak(child) {
      break-is-pending = true
      continue
    }

    if current.items.len() == 0 {
      current.kind = child.func()
      current.start = index
    } else if break-is-pending {
      current.tight = false
    }

    break-is-pending = false
    current.items.push(child)
    current.end = index + 1
  }

  if current.items.len() != 0 {
    found-runs.push(current)
  }
  found-runs
}

/// Determine whether any container built from `children` is non-tight.
///
/// True when a parbreak falls between two same-kind items, which is what makes
/// Typst widen the container they form. Items of different kinds are separate
/// containers, each tight, so a parbreak between those does not count.
///
/// - children (array): A sequence's children, in order.
///
/// -> bool
#let contains-nontight-list-like(children) = {
  get-list-like-runs-among(children).any(run => not run.tight)
}

/// The run of items `children.slice(0, end)` ends in, if it ends in one.
///
/// Same result shape as one entry of `get-list-like-runs-among`, with `kind`
/// `none` and `items` empty when there is no such run.
///
/// `opaque` widens what the walk may step over, on top of the spaces and
/// parbreaks it always steps over. It is for a caller that has replaced part of
/// a run with a node of its own and knows that node still stands in for items of
/// that run.
///
/// - children (array): Children in order. Unlike the other helpers here this
///   one also takes a caller's own accumulated array, which may hold values
///   that are not content at all; those simply end the run.
///
/// - end (int): Index just past the last element to consider.
///
/// - opaque (function): `el-func => bool`, further element functions to step over.
///
/// -> dictionary
#let get-list-like-run-ending-at(children, end, opaque: el-func => false) = {
  let run = (kind: none, items: (), tight: true, start: end, end: end)
  let break-is-pending = false

  let continues-run(child, open-kind) = (
    is-list-like-item(child)
      and (open-kind == none or child.func() == open-kind)
  )

  // Neither spacers nor whatever the caller declared opaque end the run.
  let is-steppable(child) = (
    is-space(child)
      or is-parbreak(child)
      or (
        type(child) == content
          and not is-list-like-item(child)
          and opaque(
            child.func(),
          )
      )
  )

  // Walk back until something ends the run, widening it if a parbreak turns out
  // to sit between two of its items.
  let index = end
  while index > 0 {
    let child = children.at(index - 1)

    if is-parbreak(child) and run.kind != none {
      break-is-pending = true
    }

    if is-steppable(child) {
      index -= 1
      continue
    }

    if not continues-run(child, run.kind) { break }

    run.kind = child.func()
    if break-is-pending { run.tight = false }
    break-is-pending = false
    index -= 1
    run.start = index
  }

  run.items = children.slice(run.start, end).filter(is-list-like-item)
  run
}

/// The last element of `children` that is not a space, or `none`.
///
/// Only spaces are skipped. A parbreak or linebreak is a meaningful separator
/// and is what the caller wants to be told about.
///
/// - children (array): A sequence's children, in order.
///
/// -> any
#let find-last-non-space(children) = {
  for child in children.rev() {
    if not is-space(child) { return child }
  }
  none
}

/// The first element of `children` that is not a space, or `none`.
///
/// - children (array): A sequence's children, in order.
///
/// -> any
#let find-first-non-space(children) = {
  for child in children {
    if not is-space(child) { return child }
  }
  none
}
