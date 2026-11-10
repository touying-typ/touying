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
// The element behind shorthands such as `~` and `---`. It is not `symbol`, the type.
#let typst-builtin-symbol = [~].func()
#let typst-builtin-context = (context []).func()
#let typst-builtin-state-update = state("touying-probe").update(none).func()
#let typst-builtin-counter-update = counter("touying-probe").step().func()

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

/// Whether a content is laid out as nothing: metadata, a state or counter
/// update, or a sequence of those. Typst gathers list items across it.
///
/// - it (any): The content to check.
///
/// -> bool
#let is-tag-like(it) = {
  if type(it) != content { return false }
  let f = it.func()
  if f in (metadata, typst-builtin-state-update, typst-builtin-counter-update) {
    return true
  }
  f == typst-builtin-sequence and it.children.all(is-tag-like)
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


/// The depth of a heading, whether or not it has been materialized.
///
/// A heading built by `heading[..]` rather than `= ..` markup has no `depth`
/// field until a show rule sees it, and `heading(level: 2)[..]` sets only
/// `level`. `level` is `offset + depth`, so it is the fallback, not the first
/// choice.
///
/// - it (content): The heading.
///
/// -> int
#let heading-depth(it) = {
  let level = it.at("level", default: auto)
  it.at("depth", default: if type(level) == int { level } else { 1 })
}

/// Determine if a content is a heading up to specific depth.
///
/// - it (content): The content to check.
/// - depth (int): Maximum heading depth to consider. Default is `9999`.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and heading-depth(it) <= depth
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
  } else if f == enum.item {
    ("number",)
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
  } else if f == math.stretch {
    ("body",)
  } else if f == math.op {
    ("text",)
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
  underparen: ("body", "annotation"),
  overparen: ("body", "annotation"),
  undershell: ("body", "annotation"),
  overshell: ("body", "annotation"),
  class: ("body",),
  stretch: ("body",),
  op: ("text",),
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
//   - A space between items is insignificant, and so is metadata. A linebreak
//     written at the end of an item line is absorbed into that item; one
//     standing alone as a sibling ends the run, as does any other content.
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

/// Whether a content is an em dash.
/// Typst makes the same node of a typed `—` and of the `---` shorthand.
///
/// - it (any): The content to check.
///
/// -> bool
#let is-em-dash(it) = it in ([—], [---])

/// What `is-inline-prose` accepts. An allow-list, because an element not known
/// to flow in a line is safer treated as a block.
#let _pure-inline-prose-funcs = (
  text,
  strong,
  emph,
  link,
  ref,
  cite,
  footnote,
  smartquote,
  typst-builtin-symbol,
  box,
  highlight,
  underline,
  overline,
  strike,
  sub,
  super,
)

/// Whether a content is known to flow inside a line of text. A dash is not
/// prose, so two dashes in a row stay a horizontal line.
///
/// - it (any): The content to check.
///
/// -> bool
#let is-inline-prose(it) = {
  if type(it) != content or is-em-dash(it) { return false }
  let f = it.func()
  // These can be inline or block. Unlike `utils.is-block` there is no context
  // here to read the default from, so an element built by a call, which has no
  // `block` field, counts as inline.
  if f in (raw, math.equation, quote) {
    return not it.at("block", default: false)
  }
  f in _pure-inline-prose-funcs
}

/// Whether an em dash node splits slides, given the nearest non-space content
/// on each side of it (`none` at an edge).
///
/// Typst gives `---` and a typed em dash the same node, and a newline is a
/// space like any other, so only the neighbours tell them apart: a dash with
/// prose on both sides is part of the sentence.
///
/// - before (any): The nearest non-space content before the dash.
///
/// - after (any): The nearest non-space content after the dash.
///
/// -> bool
#let is-horizontal-line(before, after) = {
  not (
    is-inline-prose(before) and is-inline-prose(after)
  )
}

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

/// The width of the number column the enum would have if `items` were one
/// container.
///
/// A column is as wide as its widest number, so an enum split into several
/// containers has a different column in each, and the rows of one shift
/// sideways when the others are revealed. Reading the width off a container
/// laid out here, rather than numbering the items by hand, takes in explicit
/// numbers, `numbering` patterns and functions, `full`, and the parent numbers
/// of a nested enum without redoing any of them.
///
/// The bodies are emptied since only the column is wanted. What surrounds the
/// column does not depend on the rows, so it is taken off with a one-row
/// container whose number is zero wide.
///
/// Must be called from a context, as it lays out with the active styles.
///
/// - items (array): All the enum items of the run, in order.
///
/// -> length
#let get-enum-number-width(items) = {
  let blank = items.map(item => {
    let number = item.at("number", default: none)
    if number == none { enum.item([]) } else { enum.item(number, []) }
  })
  let with-numbers = measure(enum(..blank)).width
  let without-numbers = measure(
    enum(numbering: (..) => box(width: 0pt), enum.item([])),
  ).width
  with-numbers - without-numbers
}

/// The `numbering` that gives every number the same width, so that the column
/// is `width` wide whichever numbers a container holds.
///
/// Typst aligns the number in its cell, but the cell is only as wide as the
/// widest number, so the alignment is reapplied inside the fixed width. A
/// `number-align` without a horizontal part, such as `top`, aligns to the start.
///
/// The numbering and the alignment are read where the number is placed, inside
/// the enum, because a `set` in a show rule of enum only applies there.
///
/// - width (length): The column width, from `get-enum-number-width`.
///
/// -> function
#let build-fixed-width-numbering(width) = (..numbers) => context {
  let horizontal = enum.number-align.x
  box(
    width: width,
    align(
      if horizontal == none { start } else { horizontal },
      numbering(enum.numbering, ..numbers),
    ),
  )
}

/// Build the container Typst would have built from a run of items.
///
/// The kind is taken from the items themselves, which must all share it: a run
/// of mixed kinds is not one container and panics rather than silently
/// producing one. An empty run yields empty content.
///
/// `tight` has to be stated because a run emitted on its own has lost the
/// parbreak that would have told Typst to widen it. `first-number` likewise,
/// for a run that does not begin the enum: position in the container is what
/// numbers an item, so a rebuilt enum restarts without it. See
/// `get-enum-number-at` for working it out. It is ignored for a list and for
/// terms, which are not numbered.
///
/// - items (array): The run's items, in order. All of one kind, or it panics.
///
/// - tight (bool): Whether the container is tight.
///
/// - first-number (auto, int): The number the first item carries, for an
///   enum. `auto` leaves it to Typst, so `set enum(start: ..)` applies.
///
/// - number-width (none, length): Gives an enum a number column of exactly
///   this width, see `get-enum-number-width`.
///
/// -> content
#let build-list-like-from(
  items,
  tight: true,
  first-number: auto,
  number-width: none,
) = {
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
    enum(
      tight: tight,
      ..if first-number != auto { (start: first-number) },
      ..if number-width != none {
        (numbering: build-fixed-width-numbering(number-width))
      },
      ..items,
    )
  } else if kind == terms.item {
    terms(tight: tight, ..items)
  } else {
    list(tight: tight, ..items)
  }
}

/// The number the enum shows for the item at `rank` in a run.
///
/// Follows Typst's own rule: counting starts from `set enum(start: ..)`, or
/// from the number of items when the enum is reversed, and goes up (down when
/// reversed) by one per item, and an item given a number of its own (`5.` in
/// markup) resets the count to it. Needs context, for the `set` rules.
///
/// - items (array): The run's enum items, in order.
///
/// - rank (int): The item's position in the run, from 1.
///
/// -> int
#let get-enum-number-at(items, rank) = {
  let step = if enum.reversed { -1 } else { 1 }
  let start = enum.start
  let number = if start != auto {
    start - step
  } else if enum.reversed {
    items.len() + 1
  } else {
    0
  }
  for item in items.slice(0, rank) {
    let own = item.at("number", default: none)
    number = if own == none { number + step } else { own }
  }
  number
}

/// Build consecutive items of `run`, the first at `first-rank`, as the run in
/// one piece lays them out: as tight, and numbered on. Needs context for an enum.
#let build-list-like-part(items, run, first-rank, number-width: none) = {
  build-list-like-from(
    items,
    tight: run.tight,
    first-number: if run.kind == enum.item {
      get-enum-number-at(run.items, first-rank)
    } else { auto },
    number-width: number-width,
  )
}

/// The gap Typst puts between two rows of a container built from items of the
/// given kind.
///
/// The gap is measured on a container of that kind laid out here, rather than
/// read from `list.spacing` etc.: show-set rules such as
/// `show list: set list(spacing: ..)` only apply inside the elements they
/// match, and this is called between the items, outside any container. The
/// measurement also covers the `auto` fallback to `par.spacing` (non-tight)
/// and `par.leading` (tight).
///
/// Must be called from a context, as it lays out with the active styles.
///
/// - kind (function): One of `list.item`, `enum.item`, `terms.item`.
///
/// - tight (bool): Whether the container is tight.
///
/// -> length
#let get-row-spacing-of-list-like(kind, tight: true) = {
  // Two rows of zero height (without marker, number or separator), so the
  // container's height is exactly the gap.
  let row = box(height: 0pt)
  let container = if kind == list.item {
    list(marker: none, tight: tight, row, row)
  } else if kind == enum.item {
    enum(numbering: (..) => none, tight: tight, row, row)
  } else if kind == terms.item {
    terms(
      separator: none,
      tight: tight,
      terms.item(row, row),
      terms.item(row, row),
    )
  } else {
    return if tight { par.leading } else { par.spacing }
  }
  measure(container).height
}

// Content that sits between list items without ending their container.
#let is-list-spacer(it) = (
  it == none or is-space(it) or is-parbreak(it) or is-tag-like(it)
)

// The spacing between a row of `run` and the next row of `other`: `auto` when
// there is none on one side, the row gap inside one run, paragraph spacing
// between two containers.
#let get-gap-between-list-likes(run, other) = {
  if run == none or other == none { return auto }
  if run.start != other.start { return par.spacing }
  get-row-spacing-of-list-like(run.kind, tight: run.tight)
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
/// - steps-over (function): `child => bool`, further children that do not end
///   a run, such as `is-tag-like`.
///
/// -> array
#let get-list-like-runs-among(children, steps-over: child => false) = {
  let empty-run = (kind: none, items: (), tight: true, start: 0, end: 0)

  let found-runs = ()
  let current = empty-run
  let break-is-pending = false

  let starts-new-run(child, old-kind) = (
    is-list-like-item(child) and old-kind != none and child.func() != old-kind
  )

  let breaks-run(child) = {
    not (
      is-list-like-item(child)
        or is-space(child)
        or is-parbreak(child)
        or steps-over(child)
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
    if stop-run or is-space(child) or steps-over(child) { continue }

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

/// Which run each list-like item belongs to and its 1-based position in it.
///
/// - children (array): A sequence's children, in order.
///
/// - runs (array): The runs of `children`, from `get-list-like-runs-among`.
///
/// -> dictionary Keyed by the item's index in `children`, as a string. Each
///   value is `(run: run, rank: int)`.
#let get-list-like-placements(children, runs) = {
  let placement = (:)
  for run in runs {
    let rank = 0
    for index in range(run.start, run.end) {
      if is-list-like-item(children.at(index)) {
        rank += 1
        placement.insert(str(index), (run: run, rank: rank))
      }
    }
  }
  placement
}

/// The enum runs that are shown in part: some of their items are visible and
/// some are covered.
///
/// - children (array): A sequence's children, in order.
///
/// - placement (dictionary): From `get-list-like-placements`.
///
/// - is-visible (function): `n => bool`, whether the n-th list-like item of
///   `children`, counting from 0, is visible.
///
/// -> dictionary Keyed by the run's start index, as a string. Each value is the
///   run.
#let get-split-enum-runs(children, placement, is-visible) = {
  let split-runs = (:)
  let seen = (:)
  let seen-count = 0
  for index in range(children.len()) {
    let place = placement.at(str(index), default: none)
    if place == none { continue }
    let key = str(place.run.start)
    let kinds = seen.at(key, default: (visible: false, covered: false))
    if is-visible(seen-count) { kinds.visible = true } else {
      kinds.covered = true
    }
    seen.insert(key, kinds)
    seen-count += 1
    if kinds.visible and kinds.covered and place.run.kind == enum.item {
      split-runs.insert(key, place.run)
    }
  }
  split-runs
}
