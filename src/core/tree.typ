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



// -------------------------------------
//   Rebuilding content
// -------------------------------------

/// The positional signature of an element constructor, as field names in the
/// order it wants them. Empty for the constructors that take everything by
/// name, which is most of them.
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
    ("class",)
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
  } else if shape == "body" {
    (it.body,)
  } else {
    ()
  }
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
