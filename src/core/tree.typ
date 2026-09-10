// Content-tree fundamentals: recognising what a piece of Typst content is,
// taking it apart, and putting it back together again.
//
// Nothing here knows anything about touying, so every other module can import
// it without risking a cycle.

#import "../extern.typ": warning


/// Warn that a name is on its way out.
///
/// The result is content, and Typst only reports the warning once that content
/// is laid out, so a deprecated function has to return this rather than call it
/// for its effect. A function that returns something other than content cannot
/// carry one at all.
///
/// - name (str): The deprecated name.
///
/// - version (str): The version that removes it.
///
/// -> content
#let _deprecation-warning(name, version) = warning(
  "`"
    + name
    + "` is deprecated and will be removed in touying "
    + version
    + ".",
)



// -------------------------------------
//   Recognising content
// -------------------------------------

#let typst-builtin-sequence = [].func()


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


#let typst-builtin-styled = text(red)[].func()


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


#let typst-builtin-space = [ ].func()


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


#let typst-builtin-math-symbol = ($x$).body.func()


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
///
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
///
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


/// Remove leading and trailing empty elements from an array of content.
///
/// Example: `trim(([], [ ], parbreak(), linebreak(), [a], [ ], [b], [c], linebreak(), parbreak(), [ ], [ ]))` returns `([a], [ ], [b], [c])`
///
/// - arr (array): The array of content to trim.
///
/// - empty-contents (array): An array of content elements considered empty. Default is `([], [ ], parbreak(), linebreak())`.
///
/// -> array
#let empty-contents = ([], [ ], parbreak(), linebreak())


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
///
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
///
/// - fields (dictionary): The fields to pass. A `label` must already have been
///   removed by the caller.
///
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
///
/// - labeled (bool): Indicates whether the label of the content should be preserved.
///
/// - named (bool): Indicates whether to pass fields as named arguments.
///
/// - it (content): The content to reconstruct.
///
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
///
/// - labeled (bool): Whether to preserve the label of the content. Default is `true`.
///
/// - it (content): The content to reconstruct.
///
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
///
/// - new-child (content): The new child you want to replace the old body with.
///
/// -> content
#let reconstruct-styled(it, new-child) = {
  typst-builtin-styled(new-child, it.styles)
}


#let reconstruct-heading(it, new-body, ..args) = {
  assert(
    type(it) == content and it.func() == heading,
    message: "it must be a heading",
  )
  let heading-args = (
    numbering: it.numbering,
    bookmarked: it.bookmarked,
    depth: it.depth,
    offset: it.offset,
    outlined: it.outlined,
    hanging-indent: it.hanging-indent,
    supplement: it.supplement,
  )
  // Every heading argument is a scalar or content, so a shallow merge is a
  // deep one.
  heading-args += args.named()

  if it.has("label") {
    return [#heading(
        ..heading-args,
        new-body,
      )#it.label]
  }
  heading(
    ..heading-args,
    new-body,
  )
}


// -------------------------------------
//   Walking content
// -------------------------------------

/// How a piece of content holds its sub-content, as one of `"sequence"`,
/// `"styled"`, `"metadata"`, `"figure"`, `"term"`, `"children"`, `"body"`,
/// `"child"` or `"leaf"`.
///
/// This is the taxonomy `children-of` and `rebuild` agree on, and the reason
/// they can be trusted to round-trip. It says nothing about what an element
/// *is*, only about where to look for content inside it, so a caller that
/// cares whether something is an image or a heading still asks `it.func()`.
///
/// - it (any): The content to classify.
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


/// The sub-content of `it`, in the order `rebuild` expects it back.
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


/// Put `it` back together around new sub-content, keeping its label.
///
/// - labeled (bool): Whether to re-attach the label.
///
/// - it (content): The content to rebuild.
///
/// - new-children (array): Replacements, as `children-of` returned them.
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
/// `visit` is called on every node on the way down. Return `none` to walk into
/// the node, or content to put in its place and stop. Returning `[]` deletes
/// it.
///
/// A node whose sub-content came back unchanged is returned as it was, so a
/// walk that rewrites one leaf leaves the rest of the tree identical rather
/// than rebuilding it. To change visitor partway down, call `map-tree` again
/// from inside `visit` and return the result.
///
/// - labeled (bool): Whether rebuilt nodes keep their label.
///
/// - it (any): The root.
///
/// - visit (function): `it => none | content`.
///
/// -> content
#let map-tree(labeled: true, it, visit) = {
  let replacement = visit(it)
  if replacement != none { return replacement }
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
///
/// - it (any): The root.
///
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
///
/// - kinds (array): Mark kinds to resolve.
///
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
  1
}
