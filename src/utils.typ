#import "pdfpc.typ"

/// Add a dictionary to another dictionary recursively.
///
/// Example: `add-dicts((a: (b: 1)), (a: (c: 2)))` returns `(a: (b: 1, c: 2))`
///
/// - dict-a (dictionary): The base dictionary.
///
/// - dict-b (dictionary): The dictionary to merge into `dict-a`.
///
/// -> dictionary
#let add-dicts(dict-a, dict-b) = {
  let res = dict-a
  for key in dict-b.keys() {
    if (
      key in res
        and type(res.at(key)) == dictionary
        and type(dict-b.at(key)) == dictionary
    ) {
      res.insert(key, add-dicts(res.at(key), dict-b.at(key)))
    } else {
      res.insert(key, dict-b.at(key))
    }
  }
  return res
}


/// Merge some dictionaries recursively.
///
/// Example: `merge-dicts((a: (b: 1)), (a: (c: 2)))` returns `(a: (b: 1, c: 2))`
///
/// - init-dict (dictionary): The initial dictionary to start from.
///
/// - dicts (array): Additional dictionaries to merge in order.
///
/// -> dictionary
#let merge-dicts(init-dict, ..dicts) = {
  assert(
    dicts.named().len() == 0,
    message: "You must provide dictionaries as positional arguments",
  )
  let res = init-dict
  for dict in dicts.pos() {
    res = add-dicts(res, dict)
  }
  return res
}

// -------------------------------------
// Slide counter
// -------------------------------------
#let slide-counter = counter("touying-slide-counter")
#let last-slide-counter = counter("touying-last-slide-counter")
#let last-slide-number = context last-slide-counter.final().first()

/// Get the progress of the current slide.
///
/// `utils.last-slide-number` gives the total slide count and can be used directly in headers or footers.
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
/// #touying-progress(ratio => {
///   "Progress: " + str(int(ratio * 100)) + "%"
/// })
/// )
///
/// - callback (function): A function `ratio => { .. }` receiving a float between `0.0` and `1.0`.
///
/// -> content
#let touying-progress(callback) = (
  context {
    if last-slide-counter.final().first() == 0 {
      callback(1.0)
      return
    }
    let ratio = calc.min(
      1.0,
      slide-counter.get().first() / last-slide-counter.final().first(),
    )
    callback(ratio)
  }
)

// slide note state
#let slide-note-state = state("touying-slide-note-state", none)
#let current-slide-note = context slide-note-state.get()

// state to store the location of the newslide for handling frozen states
#let loc-prior-newslide = state("touying-loc-prior-newslide", none)


/// Remove leading and trailing empty elements from an array of content.
///
/// Example: `trim(([], [ ], parbreak(), linebreak(), [a], [ ], [b], [c], linebreak(), parbreak(), [ ], [ ]))` returns `([a], [ ], [b], [c])`
///
/// - arr (array): The array of content to trim.
///
/// - empty-contents (array): An array of content elements considered empty. Default is `([], [ ], parbreak(), linebreak())`.
///
/// -> array
#let trim(arr, empty-contents: ([], [ ], parbreak(), linebreak())) = {
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
    if label != none and labeled {
      return [#(it.func())(..fields, ..new-body)#label]
    } else {
      return (it.func())(..fields, ..new-body)
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


#let typst-builtin-sequence = ([A] + [ ] + [B]).func()

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


#let typst-builtin-styled = [#set text(fill: red)].func()

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


/// Determine if a content is a heading in a specific depth.
///
/// - it (content): The content to check.
///
/// - depth (int): Maximum heading depth to consider. Default is `9999`.
///
/// -> bool
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}


/// Call a `self => {..}` function and return the result, or wrap plain content in `[]`.
///
/// - self (dictionary): The presentation context.
///
/// - it (content, function): The content to display, or a callback `self => content`.
///
/// -> content
#let call-or-display(self, it) = {
  if type(it) == function {
    it = it(self)
  }
  return [#it]
}


/// Wrap a function with a `self` parameter to make it callable as a method.
///
/// Returns a new function of the form `(self: none, ..args) => fn(..args)`.
///
/// Example: `#let hide = method-wrapper(hide)` to get a `hide` method.
///
/// - fn (function): The function to wrap.
///
/// -> function
#let method-wrapper(fn) = (self: none, ..args) => fn(..args)


/// Extract all method functions from `self` and bind `self` as their first named argument.
///
/// Returns a dictionary of ready-to-call functions where the `self` argument has already been applied. Use destructuring to get individual methods.
///
/// Example: `#let (uncover, only) = utils.methods(self)` to get `uncover` and `only` methods.
///
/// - self (dictionary): The presentation context (must have a `methods` key containing a dictionary of functions).
///
/// -> dictionary
#let methods(self) = {
  assert(type(self) == dictionary, message: "self must be a dictionary")
  assert(
    "methods" in self and type(self.methods) == dictionary,
    message: "self.methods must be a dictionary",
  )
  // Animation methods that manage their own subslide visibility.
  // In callback-style slides the parser's pause/cover logic (driven by
  // #waypoint jumps) would incorrectly hide method-resolved content based on
  // source position.  Wrapping the result in a fn-wrapper escapes pause zones
  // (the parser always pushes fn-wrappers to `result`).
  //
  // The type check ensures non-content results (e.g. CeTZ draw-command arrays)
  // are returned as-is so external packages keep working.
  let animation-keys = (
    "uncover",
    "only",
    "effect",
    "alternatives",
    "alternatives-match",
    "alternatives-fn",
    "alternatives-cases",
    "item-by-item",
  )
  let methods = (:)
  for key in self.methods.keys() {
    if type(self.methods.at(key)) == function {
      if key in animation-keys {
        methods.insert(key, (..args) => {
          let result = self.methods.at(key)(self: self, ..args)
          if type(result) == content {
            [#metadata((
              kind: "touying-fn-wrapper",
              fn: (self: none) => result,
              args: arguments(),
              last-subslide: none,
              repetitions: none,
            ))<touying-temporary-mark>]
          } else {
            result
          }
        })
      } else {
        methods.insert(key, (..args) => self.methods.at(key)(
          self: self,
          ..args,
        ))
      }
    }
  }
  return methods
}


// -------------------------------------
// Headings
// -------------------------------------


/// Capitalize a string.
///
/// - s (str): The string to convert.
///
/// -> str
#let capitalize(s) = {
  assert(type(s) == str, message: "s must be a string")
  if s.len() == 0 {
    return s
  }
  let lowercase = lower(s)
  upper(lowercase.at(0)) + lowercase.slice(1)
}


/// Convert a string into title case.
///
/// - s (str): The string to convert.
///
/// -> str
#let titlecase(s) = {
  assert(type(s) == str, message: "s must be a string")
  if s.len() == 0 {
    return s
  }
  s.split(" ").map(capitalize).join(" ")
}


/// Convert a heading with label to a short display form.
///
/// If the heading has a special Touying label (e.g. `touying:hidden`), returns the heading body as-is.
/// If the heading has a user label (e.g. `section:my-section`), strips the namespace prefix and applies title case via `convert-label-to-short-heading`.
///
/// - it (content): The heading content element.
///
/// -> content
#let short-heading(self: none, it) = {
  if it == none {
    return
  }
  let convert-label-to-short-heading = if (
    type(self) == dictionary
      and "methods" in self
      and "convert-label-to-short-heading" in self.methods
  ) {
    self.methods.convert-label-to-short-heading
  } else {
    (self: none, lbl) => titlecase(
      lbl.replace(regex("^[^:]*:"), "").replace("_", " ").replace("-", " "),
    )
  }
  convert-label-to-short-heading = convert-label-to-short-heading.with(
    self: self,
  )
  assert(
    type(it) == content and it.func() == heading,
    message: "it must be a heading",
  )
  if not it.has("label") {
    return it.body
  }
  let lbl = str(it.label)
  if (
    lbl
      in (
        "touying:hidden",
        "touying:skip",
        "touying:unnumbered",
        "touying:unoutlined",
        "touying:unbookmarked",
      )
  ) {
    return it.body
  }
  return convert-label-to-short-heading(lbl)
}


/// Get the current heading on or before the current page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - hierachical (bool): Whether to return the heading hierarchically. If `true`, returns the last heading according to the hierarchical structure. If `false`, returns the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// -> content
#let current-heading(level: auto, hierachical: true, depth: 9999) = {
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = query(heading).filter(h => (
      h.location().page() <= current-page
        and h.level <= depth
        and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = query(heading).filter(h => (
    h.location().page() <= current-page and h.level <= depth
  ))
  if headings == () {
    return
  }
  if level == auto {
    return headings.last()
  }
  let current-level = headings.last().level
  let current-heading = headings.pop()
  while headings.len() > 0 and level < current-level {
    current-level = headings.last().level
    current-heading = headings.pop()
  }
  if level == current-level {
    return current-heading
  }
}


/// Display the current heading on the page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - numbered (bool): Whether to display the heading numbering. Default is `true`.
///
/// - hierachical (bool): Whether to return the heading hierarchically. If `true`, returns the last heading according to the hierarchical structure. If `false`, returns the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - setting (function): The setting of the heading. Default is `body => body`.
///
/// - style (function): The style of the heading. If `style` is a function, it will use the function to style the heading. For example, `style: current-heading => current-heading.body`.
///
///   If you set it to `style: auto`, it will be controlled by `show heading` rules.
///
/// -> content
#let display-current-heading(
  self: none,
  level: auto,
  hierachical: true,
  depth: 9999,
  style: (setting: body => body, numbered: true, current-heading) => setting({
    if numbered and current-heading.numbering != none {
      (
        std.numbering(
          current-heading.numbering,
          ..counter(heading).at(current-heading.location()),
        )
          + h(.3em)
      )
    }
    current-heading.body
  }),
  ..setting-args,
) = (
  context {
    let current-heading = current-heading(
      level: level,
      hierachical: hierachical,
      depth: depth,
    )
    if current-heading != none {
      if style == none {
        current-heading
      } else if style == auto {
        let current-level = current-heading.level
        if current-level == 1 {
          text(.715em, current-heading)
        } else if current-level == 2 {
          text(.835em, current-heading)
        } else {
          current-heading
        }
      } else {
        style(..setting-args, current-heading)
      }
    }
  }
)


/// Display the current heading number on the page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - numbering (str, auto): The numbering of the heading. If `auto`, uses the heading's own numbering. If a string, uses that as the numbering pattern.
///
/// - hierachical (bool): Whether to return the heading hierarchically. If `true`, returns the last heading according to the hierarchical structure. If `false`, returns the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// -> content
#let display-current-heading-number(
  level: auto,
  numbering: auto,
  hierachical: true,
  depth: 9999,
) = (
  context {
    let current-heading = current-heading(
      level: level,
      hierachical: hierachical,
      depth: depth,
    )
    if (
      current-heading != none
        and numbering == auto
        and current-heading.numbering != none
    ) {
      std.numbering(
        current-heading.numbering,
        ..counter(heading).at(current-heading.location()),
      )
    } else if current-heading != none and numbering != auto {
      std.numbering(
        numbering,
        ..counter(heading).at(current-heading.location()),
      )
    }
  }
)


/// Display the current short heading on the page.
///
/// - level (int, auto): The level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - hierachical (bool): Whether to return the heading hierarchically. If `true`, returns the last heading according to the hierarchical structure. If `false`, returns the last heading on or before the current page with the same level.
///
/// - depth (int): The maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - style (function): The style of the heading. If `style` is a function, it will use the function to style the heading. For example, `style: (self: none, current-heading) => utils.short-heading(self: self, current-heading)`.
///
/// -> content
#let display-current-short-heading(
  self: none,
  level: auto,
  hierachical: true,
  depth: 9999,
  setting: body => body,
  style: (self: none, current-heading) => short-heading(
    self: self,
    current-heading,
  ),
  ..setting-args,
) = (
  context {
    let current-heading = current-heading(
      level: level,
      hierachical: hierachical,
      depth: depth,
    )
    if current-heading != none {
      if style == none {
        current-heading
      } else {
        style(self: self, ..setting-args, current-heading)
      }
    }
  }
)


/// Display the date from `self.info.date` formatted with `self.datetime-format`.
///
/// Returns the date as a formatted string when `self.info.date` is a `datetime`, or returns it as-is when it is already `content`.
///
/// - self (dictionary): The presentation context (must have `self.info.date`).
///
/// -> content, str
#let display-info-date(self) = {
  assert("info" in self, message: "self must have an info field")
  if type(self.info.date) == datetime {
    self.info.date.display(self.at("datetime-format", default: auto))
  } else {
    self.info.date
  }
}


/// Convert content to markup text, partly from
/// [typst-examples-book](https://sitandr.github.io/typst-examples-book/book/typstonomicon/extract_markup_text.html).
///
/// - it (content, str): The content to convert.
///
/// - mode (str): The output mode: `"typ"` for Typst markup or `"md"` for Markdown.
///
/// - indent (int): The number of spaces to indent. Default is `0`.
///
/// -> str
#let markup-text(it, mode: "typ", indent: 0) = {
  assert(mode == "typ" or mode == "md", message: "mode must be 'typ' or 'md'")
  let indent-markup-text = markup-text.with(mode: mode, indent: indent + 2)
  let markup-text = markup-text.with(mode: mode, indent: indent)
  if type(it) == str {
    it
  } else if type(it) == content {
    if it.func() == raw {
      if it.block {
        (
          "\n"
            + indent * " "
            + "```"
            + it.lang
            + it
              .text
              .split("\n")
              .map(l => "\n" + indent * " " + l)
              .sum(default: "")
            + "\n"
            + indent * " "
            + "```"
        )
      } else {
        "`" + it.text + "`"
      }
    } else if it == [ ] {
      " "
    } else if it.func() == enum.item {
      "\n" + indent * " " + "+ " + indent-markup-text(it.body)
    } else if it.func() == list.item {
      "\n" + indent * " " + "- " + indent-markup-text(it.body)
    } else if it.func() == terms.item {
      (
        "\n"
          + indent * " "
          + "/ "
          + markup-text(it.term)
          + ": "
          + indent-markup-text(it.description)
      )
    } else if it.func() == linebreak {
      "\n" + indent * " "
    } else if it.func() == parbreak {
      "\n\n" + indent * " "
    } else if it.func() == strong {
      if mode == "md" {
        "**" + markup-text(it.body) + "**"
      } else {
        "*" + markup-text(it.body) + "*"
      }
    } else if it.func() == emph {
      if mode == "md" {
        "*" + markup-text(it.body) + "*"
      } else {
        "_" + markup-text(it.body) + "_"
      }
    } else if it.func() == link and type(it.dest) == str {
      if mode == "md" {
        "[" + markup-text(it.body) + "](" + it.dest + ")"
      } else {
        "#link(\"" + it.dest + "\")[" + markup-text(it.body) + "]"
      }
    } else if it.func() == heading {
      if mode == "md" {
        it.depth * "#" + " " + markup-text(it.body) + "\n"
      } else {
        it.depth * "=" + " " + markup-text(it.body) + "\n"
      }
    } else if it.has("children") {
      it.children.map(markup-text).join()
    } else if it.has("body") {
      markup-text(it.body)
    } else if it.has("text") {
      if type(it.text) == str {
        it.text
      } else {
        markup-text(it.text)
      }
    } else if it.func() == smartquote {
      if it.double {
        "\""
      } else {
        "'"
      }
    } else {
      ""
    }
  } else {
    repr(it)
  }
}

// Code: HEIGHT/WIDTH FITTING and cover-with-rect
// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/pull/91
// Author: ntjess

#let _size-to-pt(size, container-dimension) = {
  let to-convert = size
  if type(size) == ratio {
    to-convert = container-dimension * size
  }
  measure(v(to-convert)).height
}

#let _limit-content-width(width: none, body, container-size) = {
  let mutable-width = width
  if width == none {
    mutable-width = calc.min(container-size.width, measure(body).width)
  } else {
    mutable-width = _size-to-pt(width, container-size.width)
  }
  box(width: mutable-width, body)
}


/// Fit content to specified height.
///
/// Example: `#utils.fit-to-height(100%)[BIG]`
///
/// - width (length, fraction, relative): Will determine the width of the content after scaling. So, if you want the scaled content to fill half of the slide width, you can use `width: 50%`.
///
/// - prescale-width (length, fraction, relative): Allows you to make Typst's layout assume that the given content is to be laid out in a container of a certain width before scaling. For example, you can use `prescale-width: 200%` assuming the slide's width is twice the original.
///
/// - grow (bool): Indicates whether the content should be scaled up if it is smaller than the available height. Default is `true`.
///
/// - shrink (bool): Indicates whether the content should be scaled down if it is larger than the available height. Default is `true`.
///
/// - height (length): The height to fit the content to.
///
/// - body (content): The content to fit.
///
/// -> content
#let fit-to-height(
  width: none,
  prescale-width: none,
  grow: true,
  shrink: true,
  height,
  body,
) = {
  context {
    layout(container-size => {
      let available-height = _size-to-pt(height, container-size.height)
      // Provide a sensible initial width, which will define initial scale parameters.
      // Note this is different from the post-scale width, which is a limiting factor
      // on the allowable scaling ratio
      let boxed-content = _limit-content-width(
        width: prescale-width,
        body,
        container-size,
      )

      // post-scaling width
      let mutable-width = width
      if width == none {
        mutable-width = container-size.width
      }
      mutable-width = _size-to-pt(mutable-width, container-size.width)

      let size = measure(boxed-content)
      if size.height == 0pt or size.width == 0pt {
        return body
      }
      let h-ratio = available-height / size.height
      let w-ratio = mutable-width / size.width
      let ratio = calc.min(h-ratio, w-ratio) * 100%

      if ((shrink and (ratio < 100%)) or (grow and (ratio > 100%))) {
        let new-width = size.width * ratio
        scale(
          x: ratio,
          y: ratio,
          origin: top + left,
          boxed-content,
          reflow: true,
        )
      } else {
        body
      }
    })
  }
}


/// Fit content to specified width.
///
/// Example: `#utils.fit-to-width(100%)[BIG]`
///
/// - grow (bool): Indicates whether the content should be scaled up if it is smaller than the available width. Default is `true`.
///
/// - shrink (bool): Indicates whether the content should be scaled down if it is larger than the available width. Default is `true`.
///
/// - width (length, fraction, relative): The width to fit the content to.
///
/// - body (content): The content to fit.
///
/// -> content
#let fit-to-width(grow: true, shrink: true, width, content) = {
  layout(layout-size => {
    let content-width = measure(content).width
    let width = _size-to-pt(width, layout-size.width)
    if (
      content-width != 0pt
        and (
          (shrink and (width < content-width))
            or (grow and (width > content-width))
        )
    ) {
      let ratio = width / content-width * 100%
      scale(
        // The box keeps content from prematurely wrapping
        box(content, width: content-width),
        origin: top + left,
        x: ratio,
        y: ratio,
        reflow: true,
      )
    } else {
      content
    }
  })
}


/// Cover content with a rectangle of a specified color. If you set the fill to the background color of the page, you can use this to create a semi-transparent overlay.
///
/// Example: `#utils.cover-with-rect(fill: "red")[Hidden]`
///
/// - cover-args (args): The arguments to pass to the rectangle.
///
/// - fill (color): The color to fill the rectangle with.
///
/// - inline (bool): Indicates whether the content should be displayed inline. Default is `true`.
///
/// - body (content): The content to cover.
///
/// -> content
#let cover-with-rect(..cover-args, fill: auto, inline: true, body) = {
  if fill == auto {
    panic(
      "`auto` fill value is not supported until typst provides utilities to"
        + " retrieve the current page background",
    )
  }
  if type(fill) == str {
    fill = rgb(fill)
  }

  let to-display = layout(layout-size => {
    context {
      let body-size = measure(body)
      let bounding-width = calc.min(body-size.width, layout-size.width)
      let wrapped-body-size = measure(box(body, width: bounding-width))
      let named = cover-args.named()
      if "width" not in named {
        named.insert("width", wrapped-body-size.width)
      }
      if "height" not in named {
        named.insert("height", wrapped-body-size.height)
      }
      if "outset" not in named {
        // This outset covers the tops of tall letters and the bottoms of letters with
        // descenders. Alternatively, we could use
        // `set text(top-edge: "bounds", bottom-edge: "bounds")` to get the same effect,
        // but this changes text alignment and also misaligns bullets in enums/lists.
        // In contrast, `outset` preserves spacing and alignment at the cost of adding
        // a slight, visible border when the covered object is right next to the edge
        // of a color change.
        named.insert("outset", (top: 0.15em, bottom: 0.25em))
      }
      stack(
        spacing: -wrapped-body-size.height,
        body,
        rect(fill: fill, ..named, ..cover-args.pos()),
      )
    }
  })
  if inline {
    box(to-display)
  } else {
    to-display
  }
}

/// Update the alpha channel of a color.
///
/// Example: `update-alpha(rgb("#ff0000"), 0.5)` returns a red color with 50% opacity.
///
/// - color (color): The color to update.
///
/// - alpha (ratio): The new alpha value as a percentage (e.g. `50%` for half-transparent).
///
/// -> color
#let update-alpha(color, alpha) = (
  color.opacify(100%).transparentize(100% - alpha)
)


/// Cover content with a semi-transparent rectangle matching the page background color.
///
/// Example: `config-methods(cover: utils.semi-transparent-cover)`
///
/// - alpha (ratio): The opacity of the covering rectangle (higher means more opaque/more hidden). Default is `85%`.
///
/// - body (content): The content to cover.
///
/// -> content
#let semi-transparent-cover(self: none, alpha: 85%, body) = {
  cover-with-rect(
    fill: update-alpha(
      self.page.at("fill", default: rgb("#ffffff")),
      alpha,
    ),
    body,
  )
}

// recursively checks if `it` has a text in it
#let _contains-text(it, transparentize-table) = {
  if type(it) != content {
    return false
  }
  if it.func() in (text, math.equation) {
    return true
  }
  if it.has("body") {
    return _contains-text(it.body, transparentize-table)
  }
  if it.has("child") {
    return _contains-text(it.child, transparentize-table)
  }
  if it.has("children") {
    if it.func() == table {
      return transparentize-table
    }
    for child in it.children {
      if _contains-text(child, transparentize-table) {
        return true
      }
    }
  }
  return false
}

/// Cover content with a text-color-changing mechanism.
///
/// Example: `config-methods(cover: utils.color-changing-cover.with(color: gray))`
///
/// - color (color): The color to apply to text when covered. Default is `gray`.
///
/// - fallback-hide (bool): Whether to hide the content if it does not contain text. Default is `true`.
///
/// - transparentize-table (bool): Whether to transparentize table content. Default is `false`.
///
/// - it (content): The content to cover.
///
/// -> content
#let color-changing-cover(
  self: none,
  color: gray,
  fallback-hide: true,
  transparentize-table: false,
  it,
) = {
  show regex(".+"): set text(color)
  if not _contains-text(it, transparentize-table) {
    hide(it)
  } else {
    it
  }
}


/// Cover content with an alpha-changing mechanism.
///
/// Example: `config-methods(cover: utils.alpha-changing-cover.with(alpha: 25%))`
///
/// - alpha (ratio): The opacity to apply to text colors when covered. Default is `25%`.
///
/// - fallback-hide (bool): Whether to hide the content if it does not contain text. Default is `true`.
///
/// - transparentize-table (bool): Whether to transparentize table content. Default is `false`.
///
/// - it (content): The content to cover.
///
/// -> content
#let alpha-changing-cover(
  self: none,
  alpha: 25%,
  fallback-hide: true,
  transparentize-table: false,
  it,
) = context {
  show regex(".+"): it => context {
    text(update-alpha(text.fill, alpha), it)
  }
  if not _contains-text(it, transparentize-table) {
    hide(it)
  } else {
    it
  }
}


/// Applies the theme's primary color to text content. Used as the default `alert` method.
///
/// Example: `config-methods(alert: utils.alert-with-primary-color)`
///
/// -> content
#let alert-with-primary-color(self: none, body) = text(
  fill: self.colors.primary,
  body,
)


/// Apply alert styling to content using the theme's alert method. Equivalent to `(self.methods.alert)(self: self, body)`.
///
/// -> content
#let alert(self: none, body) = (self.methods.alert)(self: self, body)


// Code: check visible subslides and dynamic control
// Attribution: This file is based on the code from https://github.com/andreasKroepelin/polylux/blob/main/logic.typ
// Author: Andreas Kröpelin

#let _parse-subslide-indices(s) = {
  let parts = s.split(",").map(p => p.trim())
  let parse-part(part) = {
    let match-until = part.match(regex("^-([[:digit:]]+)$"))
    let match-beginning = part.match(regex("^([[:digit:]]+)-$"))
    let match-range = part.match(regex("^([[:digit:]]+)-([[:digit:]]+)$"))
    let match-single = part.match(regex("^([[:digit:]]+)$"))
    if match-until != none {
      let parsed = int(match-until.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      (until: parsed)
    } else if match-beginning != none {
      let parsed = int(match-beginning.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      (beginning: parsed)
    } else if match-range != none {
      let parsed-first = int(match-range.captures.first())
      let parsed-last = int(match-range.captures.last())
      // assert(parsed-first > 0, "parsed idx is non-positive")
      // assert(parsed-last > 0, "parsed idx is non-positive")
      (beginning: parsed-first, until: parsed-last)
    } else if match-single != none {
      let parsed = int(match-single.captures.first())
      // assert(parsed > 0, "parsed idx is non-positive")
      parsed
    } else {
      panic("failed to parse visible slide idx:" + part)
    }
  }
  parts.map(parse-part)
}


/// Check if a subslide index is visible given a visibility specification.
///
/// Example: `check-visible(3, "2-")` returns `true`
///
/// - idx (int): The current subslide index.
///
/// - visible-subslides (int, array, str): Specifies which subslides are visible.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///
/// -> bool
#let check-visible(idx, visible-subslides) = {
  if type(visible-subslides) == int {
    idx == visible-subslides
  } else if type(visible-subslides) == array {
    visible-subslides.any(s => check-visible(idx, s))
  } else if type(visible-subslides) == str {
    if visible-subslides.starts-with("!") {
      // Negation: "!2-4" means everything except subslides 2-4
      not check-visible(idx, visible-subslides.slice(1))
    } else {
      let parts = _parse-subslide-indices(visible-subslides)
      check-visible(idx, parts)
    }
  } else if (
    type(visible-subslides) == content and visible-subslides.has("text")
  ) {
    let parts = _parse-subslide-indices(visible-subslides.text)
    check-visible(idx, parts)
  } else if type(visible-subslides) == dictionary {
    let kind = visible-subslides.at("kind", default: none)
    if kind == "not" {
      // Negation: visible everywhere except where inner is visible.
      not check-visible(idx, visible-subslides.inner)
    } else {
      let lower-okay = if "beginning" in visible-subslides {
        visible-subslides.beginning <= idx
      } else {
        true
      }

      let upper-okay = if "until" in visible-subslides {
        visible-subslides.until >= idx
      } else {
        true
      }

      lower-okay and upper-okay
    }
  } else {
    panic(
      "you may only provide a single integer, an array of integers, or a string",
    )
  }
}


/// Look up a waypoint label (with hierarchical prefix matching).
///
/// When looking up `<top>`, this also matches any child labels like
/// `<top:sub>`, `<top:sub:deep>`, etc.  The returned range spans from
/// the earliest `first` to the latest `last` across all matches.
///
/// Returns `(first: int, last: int)` or `none` when the label is unknown.
#let _lookup-waypoint-range(waypoints, lbl-str) = {
  let prefix = lbl-str + ":"
  let matches = waypoints
    .pairs()
    .filter(p => p.at(0) == lbl-str or p.at(0).starts-with(prefix))
  if matches.len() > 0 {
    let first = calc.min(..matches.map(p => p.at(1).first))
    let last = calc.max(..matches.map(p => p.at(1).last))
    (first: first, last: last)
  } else {
    none
  }
}


/// Resolve a (possibly shifted) waypoint reference to a concrete label string.
///
/// Handles nested `prev-wp` / `next-wp` chains by walking to adjacent
/// waypoints in subslide order.  Returns `none` during a waypoint pre-pass
/// when the label cannot be resolved.
#let _resolve-waypoint-label(waypoints, wp, prepass: false) = {
  if type(wp) == str {
    wp
  } else if type(wp) == label {
    str(wp)
  } else if type(wp) == dictionary {
    let kind = wp.at("kind", default: none)
    if kind in ("waypoint-prev", "waypoint-next") {
      let base = _resolve-waypoint-label(waypoints, wp.inner, prepass: prepass)
      if base == none { return none }
      // Build sorted label list by first-subslide
      let sorted = waypoints.pairs().sorted(key: p => p.at(1).first)
      let labels = sorted.map(p => p.at(0))
      let idx = labels.position(l => l == base)
      // If no exact match, try hierarchical prefix match (e.g. <parent>
      // when only <parent:a>, <parent:b> exist).  Directional: next-wp
      // anchors to the last child (to skip past the group), prev-wp
      // anchors to the first child (to land before the group).
      // When an exact parent label exists, it is used directly.
      if idx == none {
        let prefix = base + ":"
        let children = labels
          .enumerate()
          .filter(p => p.at(1).starts-with(prefix))
        if children.len() > 0 {
          idx = if kind == "waypoint-next" {
            children.last().at(0)
          } else {
            children.first().at(0)
          }
        }
      }
      if idx == none {
        if prepass { return none }
        assert(false, message: "Unknown waypoint label: <" + base + ">")
      }
      let amount = wp.at("amount", default: 1)
      let step = if kind == "waypoint-prev" { -amount } else { amount }
      let new-idx = idx + step
      if new-idx < 0 or new-idx >= labels.len() {
        if prepass { return none }
        let dir = if kind == "waypoint-prev" { "previous" } else { "next" }
        assert(
          false,
          message: "No "
            + dir
            + " waypoint "
            + str(amount)
            + " step(s) from <"
            + base
            + ">",
        )
      }
      labels.at(new-idx)
    } else if kind in ("waypoint-first", "waypoint-last") {
      // get-first / get-last — extract embedded label
      wp.label
    } else if kind in ("waypoint-from", "waypoint-until") {
      // from-wp / until-wp — recurse into inner
      _resolve-waypoint-label(waypoints, wp.inner, prepass: prepass)
    } else {
      if prepass { return none }
      panic("Cannot resolve waypoint label from " + repr(wp))
    }
  } else {
    if prepass { return none }
    panic("Cannot resolve waypoint label from " + repr(wp))
  }
}


/// Resolve waypoint labels in a visible-subslides specification.
///
/// Recursively replaces label references and waypoint marker dictionaries
/// (`get-first`, `get-last`, `from-wp`, `until-wp`, `prev-wp`, `next-wp`) with
/// their resolved subslide numbers / ranges using the waypoint mapping from
/// `self.waypoints`.
///
/// Supports hierarchical labels: if `<part>` is not an exact match, all
/// waypoints whose name starts with `part:` are combined into a single range.
///
/// When an array contains `from-wp` / `until-wp` markers the elements are
/// combined into a bounded range (min of beginnings, max of ends):
/// `(from-wp(<a>), until-wp(<b>))` yields the range from `<a>` to just before `<b>`.
///
/// - self (dictionary): The presentation context containing `waypoints`.
///
/// - visible-subslides: The visible-subslides specification to resolve.
///
/// -> int | str | array | dictionary
#let resolve-waypoints(self, visible-subslides) = {
  let waypoints = self.at("waypoints", default: (:))
  let prepass = self.at("_waypoint-prepass", default: false)

  // --- label ----------------------------------------------------------
  if type(visible-subslides) == label {
    let lbl = str(visible-subslides)
    let range = _lookup-waypoint-range(waypoints, lbl)
    if range == none {
      if prepass { return (beginning: 1, until: 1) }
      assert(false, message: "Unknown waypoint label: <" + lbl + ">")
    }
    (beginning: range.first, until: range.last)

    // --- dictionary (waypoint markers) ----------------------------------
  } else if type(visible-subslides) == dictionary {
    let kind = visible-subslides.at("kind", default: none)

    if kind == "waypoint-first" {
      let lbl = visible-subslides.label
      let range = _lookup-waypoint-range(waypoints, lbl)
      if range == none {
        if prepass { return 1 }
        assert(false, message: "Unknown waypoint label: <" + lbl + ">")
      }
      range.first
    } else if kind == "waypoint-last" {
      let lbl = visible-subslides.label
      let range = _lookup-waypoint-range(waypoints, lbl)
      if range == none {
        if prepass { return 1 }
        assert(false, message: "Unknown waypoint label: <" + lbl + ">")
      }
      range.last
    } else if kind == "waypoint-from" {
      let inner = visible-subslides.inner
      let inner-kind = if type(inner) == dictionary {
        inner.at("kind", default: none)
      } else { none }
      if inner-kind in ("waypoint-first", "waypoint-last") {
        // Resolve get-first/get-last to a concrete subslide number
        let resolved = resolve-waypoints(self, inner)
        (beginning: resolved)
      } else {
        let lbl = _resolve-waypoint-label(
          waypoints,
          inner,
          prepass: prepass,
        )
        if lbl == none {
          if prepass { return (beginning: 1) }
          assert(
            false,
            message: "Cannot resolve waypoint reference in from-wp()",
          )
        }
        let range = _lookup-waypoint-range(waypoints, lbl)
        if range == none {
          if prepass { return (beginning: 1) }
          assert(false, message: "Unknown waypoint label: <" + lbl + ">")
        }
        (beginning: range.first)
      }
    } else if kind == "waypoint-until" {
      let inner = visible-subslides.inner
      let inner-kind = if type(inner) == dictionary {
        inner.at("kind", default: none)
      } else { none }
      if inner-kind in ("waypoint-first", "waypoint-last") {
        // Resolve get-first/get-last to a concrete subslide number
        let resolved = resolve-waypoints(self, inner)
        (until: resolved - 1)
      } else {
        let lbl = _resolve-waypoint-label(
          waypoints,
          inner,
          prepass: prepass,
        )
        if lbl == none {
          if prepass { return (until: 1) }
          assert(
            false,
            message: "Cannot resolve waypoint reference in until-wp()",
          )
        }
        let range = _lookup-waypoint-range(waypoints, lbl)
        if range == none {
          if prepass { return (until: 1) }
          assert(false, message: "Unknown waypoint label: <" + lbl + ">")
        }
        (until: range.first - 1)
      }
    } else if kind in ("waypoint-prev", "waypoint-next") {
      let lbl = _resolve-waypoint-label(
        waypoints,
        visible-subslides,
        prepass: prepass,
      )
      if lbl == none {
        if prepass { return (beginning: 1, until: 1) }
        assert(
          false,
          message: "Cannot resolve shifted waypoint reference",
        )
      }
      let range = _lookup-waypoint-range(waypoints, lbl)
      if range == none {
        if prepass { return (beginning: 1, until: 1) }
        assert(false, message: "Unknown waypoint label: <" + lbl + ">")
      }
      (beginning: range.first, until: range.last)
    } else if kind == "waypoint-not" {
      // Negate: resolve inner waypoint to a range, then wrap for check-visible.
      let inner = visible-subslides.inner
      let inner-kind = if type(inner) == dictionary {
        inner.at("kind", default: none)
      } else { none }
      if inner-kind != none {
        // Inner is another waypoint marker — resolve it first.
        let resolved = resolve-waypoints(self, inner)
        (kind: "not", inner: resolved)
      } else {
        // Inner is a plain label string — look up its range directly.
        let lbl = _resolve-waypoint-label(waypoints, inner, prepass: prepass)
        if lbl == none {
          if prepass { return (kind: "not", inner: (beginning: 1, until: 1)) }
          assert(
            false,
            message: "Cannot resolve waypoint reference in not-wp()",
          )
        }
        let range = _lookup-waypoint-range(waypoints, lbl)
        if range == none {
          if prepass { return (kind: "not", inner: (beginning: 1, until: 1)) }
          assert(false, message: "Unknown waypoint label: <" + lbl + ">")
        }
        (kind: "not", inner: (beginning: range.first, until: range.last))
      }
    } else {
      visible-subslides
    }

    // --- array ----------------------------------------------------------
  } else if type(visible-subslides) == array {
    // If the array contains from/until range markers, span the full range.
    let has-range-markers = visible-subslides.any(s => (
      type(s) == dictionary
        and s.at("kind", default: "") in ("waypoint-from", "waypoint-until")
    ))
    if has-range-markers {
      // Range construction: combine from/until markers into a single range.
      // Multiple `from-wp`s → take earliest (min); multiple `until-wp`s → take latest (max).
      // This spans the whole duration from the first `from-wp` to the last `until-wp`.
      let resolved = visible-subslides.map(s => resolve-waypoints(self, s))
      let beginning = none
      let end = none
      for r in resolved {
        if type(r) == dictionary {
          if "beginning" in r {
            beginning = if beginning == none {
              r.beginning
            } else {
              calc.min(beginning, r.beginning)
            }
          }
          if "until" in r {
            end = if end == none { r.until } else { calc.max(end, r.until) }
          }
        }
      }
      let result = (:)
      if beginning != none {
        result.insert("beginning", beginning)
      }
      if end != none {
        result.insert("until", end)
      }
      result
    } else {
      visible-subslides.map(s => resolve-waypoints(self, s))
    }

    // --- pass-through (int, str, etc.) ----------------------------------
  } else {
    visible-subslides
  }
}


#let last-required-subslide(visible-subslides) = {
  if type(visible-subslides) == label {
    // Labels are resolved at render time; the pauses that define waypoints
    // already contribute to the repetitions count.  Return 1 (not 0) so that
    // the parser's two-pass escape hatch (next-last-subslide > 0) recognises
    // that a fn-wrapper exists inside a nested sequence.  A value of 1 never
    // inflates the repeat count because repetitions is always >= 1.
    1
  } else if type(visible-subslides) == int {
    visible-subslides
  } else if type(visible-subslides) == array {
    calc.max(..visible-subslides.map(s => last-required-subslide(s)))
  } else if type(visible-subslides) == str {
    if visible-subslides.starts-with("!") {
      // Negation cannot introduce new subslides, only use existing ones.
      0
    } else {
      let parts = _parse-subslide-indices(visible-subslides)
      last-required-subslide(parts)
    }
  } else if type(visible-subslides) == dictionary {
    let kind = visible-subslides.at("kind", default: none)
    if (
      kind
        in (
          "waypoint-first",
          "waypoint-last",
          "waypoint-from",
          "waypoint-until",
          "waypoint-prev",
          "waypoint-next",
          "waypoint-not",
        )
    ) {
      // Will be resolved at render time; pauses determine repeat count.
      // Return 1 (not 0) so fn-wrapper escape hatch triggers (see label branch).
      1
    } else {
      let last = 0
      if "beginning" in visible-subslides {
        last = calc.max(last, visible-subslides.beginning)
      }
      if "until" in visible-subslides {
        last = calc.max(last, visible-subslides.until)
      }
      last
    }
  } else {
    panic(
      "you may only provide `auto`, a single integer, an array of integers, a string or a waypoint label or marker",
    )
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
/// - visible-subslides (int, array, str): A single integer, an array of integers, or a string specifying the visible subslides.
///
///    Supported formats:
///
///    - A single integer, e.g. `3` — only subslide 3.
///    - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///    - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///
/// - cont (content): The content to display when the content is visible in the subslide.
///
/// - is-method (bool): Whether the function is a method function. Default is `false`.
///
/// -> content
#let effect(
  self: none,
  fn,
  visible-subslides,
  cont,
  is-method: false,
  resolved-subslides: none,
) = {
  if is-method {
    fn
  } else {
    let visible-subslides = if resolved-subslides != none {
      resolved-subslides
    } else { visible-subslides }
    let visible-subslides = resolve-waypoints(self, visible-subslides)
    if check-visible(self.subslide, visible-subslides) {
      fn(cont)
    } else {
      cont
    }
  }
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
/// - visible-subslides (int, array, str): A single integer, an array of integers, or a string specifying the visible subslides.
///
///   Supported formats:
///
///   - A single integer, e.g. `3` — only subslide 3.
///   - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///   - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///
/// - uncover-cont (content): The content to display when visible.
///
/// - cover-fn (function, auto): An optional cover function to use instead of the default cover method from the theme. Useful when using `uncover` inside external package integrations (e.g. `fletcher.hide` for fletcher diagrams).
///
/// -> content
#let uncover(
  self: none,
  visible-subslides,
  uncover-cont,
  cover-fn: auto,
  resolved-subslides: none,
) = {
  let visible-subslides = if resolved-subslides != none {
    resolved-subslides
  } else { visible-subslides }
  let visible-subslides = resolve-waypoints(self, visible-subslides)
  let cover = if cover-fn != auto { cover-fn } else {
    self.methods.cover.with(self: self)
  }
  if check-visible(self.subslide, visible-subslides) {
    uncover-cont
  } else {
    cover(uncover-cont)
  }
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
/// - visible-subslides (int, array, str): A single integer, an array of integers, or a string specifying the visible subslides.
///
///   Supported formats:
///
///   - A single integer, e.g. `3` — only subslide 3.
///   - An array, e.g. `(1, 2, 4)` — equivalent to `"1, 2, 4"`.
///   - A string with ranges, e.g. `"-2, 4, 6-8, 10-"` — subslides 1, 2, 4, 6, 7, 8, 10, and all after 10.
///
/// - only-cont (content): The content to display when visible.
///
/// -> content
#let only(
  self: none,
  visible-subslides,
  only-cont,
  resolved-subslides: none,
) = {
  let visible-subslides = if resolved-subslides != none {
    resolved-subslides
  } else { visible-subslides }
  let visible-subslides = resolve-waypoints(self, visible-subslides)
  if check-visible(self.subslide, visible-subslides) {
    only-cont
  }
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
#let handout-only(self: none, cont) = {
  if self.handout {
    cont
  }
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
/// - position (alignment): The position of the content. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-match(
  self: none,
  subslides-contents,
  position: bottom + left,
  stretch: false,
) = {
  let subslides-contents = if type(subslides-contents) == dictionary {
    subslides-contents.pairs()
  } else {
    subslides-contents
  }

  let contents = subslides-contents.map(it => it.last())

  // Pre-resolve all subslide specs (handles waypoint labels, markers, etc.)
  let resolved = subslides-contents.map(((s, _)) => resolve-waypoints(self, s))

  if stretch {
    context {
      let sizes = contents.map(c => measure(c))
      let max-width = calc.max(..sizes.map(sz => sz.width))
      let max-height = calc.max(..sizes.map(sz => sz.height))
      for (i, (_, content)) in subslides-contents.enumerate() {
        // First-match-wins: skip if an earlier entry already matches this subslide
        let earlier-match = resolved
          .slice(0, i)
          .any(
            s => check-visible(self.subslide, s),
          )
        if not earlier-match and check-visible(self.subslide, resolved.at(i)) {
          box(
            width: max-width,
            height: max-height,
            align(position, content),
          )
        }
      }
    }
  } else {
    for (i, (_, content)) in subslides-contents.enumerate() {
      // First-match-wins: skip if an earlier entry already matches this subslide
      let earlier-match = resolved
        .slice(0, i)
        .any(
          s => check-visible(self.subslide, s),
        )
      if not earlier-match and check-visible(self.subslide, resolved.at(i)) {
        content
      }
    }
  }
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// - start (int): The starting subslide number. Default is `1`.
///
/// - repeat-last (bool): Whether the last alternative should persist on all remaining subslides. Default is `true`.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives(
  self: none,
  start: 1,
  repeat-last: true,
  ..args,
) = {
  let contents = args.pos()
  let kwargs = args.named()
  let subslides = range(start, start + contents.len())
  if repeat-last {
    subslides.last() = (beginning: subslides.last())
  }
  alternatives-match(self: self, subslides.zip(contents), ..kwargs)
}


/// You can have very fine-grained control over the content depending on the current subslide by using #alternatives-fn. It accepts a function (hence the name) that maps the current subslide index to some content.
///
/// Example: `#alternatives-fn(start: 2, count: 7, subslide => { numbering("(i)", subslide) })`
///
/// - start (int): The starting subslide number. Default is `1`.
///
/// - end (int, none): The ending subslide number. Default is `none`.
///
/// - count (int, none): The number of subslides. Default is `none`.
///
/// - position (alignment): The alignment of alternatives within the reserved space. Default is `bottom + left`.
///
/// - stretch (bool): Whether to stretch all alternatives to the maximum width and height. Default is `false`.
///
///   Important: If you use a zero-length content like a context expression, you should set `stretch: false`.
///
/// -> content
#let alternatives-fn(
  self: none,
  start: 1,
  end: none,
  count: none,
  ..kwargs,
  fn,
) = {
  let end = if end == none {
    if count == none {
      panic("You must specify either end or count.")
    } else {
      start + count
    }
  } else {
    end
  }

  let subslides = range(start, end)
  let contents = subslides.map(fn)
  alternatives-match(self: self, subslides.zip(contents), ..kwargs.named())
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
#let alternatives-cases(self: none, cases, fn, ..kwargs) = {
  let idcs = range(cases.len())
  let contents = idcs.map(fn)
  alternatives-match(self: self, cases.zip(contents), ..kwargs.named())
}


/// Display list, enum, or terms items one by one with animation.
///
/// Each item is revealed on a successive subslide.  By default (`start: auto`),
/// revealing is relative to the current pause position.  `start` also accepts
/// a waypoint label or marker to anchor the reveal sequence. From the anchor one additional item is revealed per subslide.
///
///  #example(
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
/// #item-by-item[
///   - first
///   - second
///   - third
/// ]
/// )
///
/// - start (auto | int | label | dictionary): The subslide on which the first\n///   item appears.  Resolved from a waypoint when a label or marker is given.
///
/// - cont (content): The content containing a list, enum, or terms element.
///
/// -> content
#let item-by-item(self: none, start: 1, cont) = {
  let cover = self.methods.cover.with(self: self)
  let item-funcs = (list.item, enum.item, terms.item)

  // Resolve waypoint-based start to a concrete subslide number.
  let start = if type(start) == int {
    start
  } else if (
    type(start) == label
      or (
        type(start) == dictionary and start.at("kind", default: none) != none
      )
  ) {
    let resolved = resolve-waypoints(self, start)
    if type(resolved) == int {
      resolved
    } else if type(resolved) == dictionary and "beginning" in resolved {
      resolved.beginning
    } else if type(resolved) == dictionary and "first" in resolved {
      resolved.first
    } else {
      1
    }
  } else if type(start) == str {
    let parts = _parse-subslide-indices(start)
    if parts.len() == 1 and type(parts.first()) == int {
      parts.first()
    } else {
      panic(
        "item-by-item: `start` string must be a single number (e.g. \"3\"), "
          + "not a range or multi-value spec. Got: \""
          + start
          + "\".",
      )
    }
  } else {
    panic(
      "item-by-item: `start` must be an integer, a string with a single number, "
        + "a waypoint label, or a single-position waypoint marker "
        + "(get-first, get-last, prev-wp, next-wp). Got: "
        + type(start),
    )
  }

  if is-sequence(cont) {
    // Markup list/enum/terms: items appear as list.item/enum.item/terms.item in a sequence
    let item-count = 0
    let result = ()
    for child in cont.children {
      if type(child) == content and child.func() in item-funcs {
        if check-visible(self.subslide, (beginning: start + item-count)) {
          result.push(child)
        } else {
          result.push(cover(child))
        }
        item-count += 1
      } else {
        result.push(child)
      }
    }
    result.sum(default: [])
  } else if cont.func() == list or cont.func() == enum {
    // Programmatic list/enum container
    let new-items = cont
      .children
      .enumerate()
      .map(((idx, item)) => {
        if check-visible(self.subslide, (beginning: start + idx)) {
          item
        } else {
          reconstruct(item, cover(item.body))
        }
      })
    reconstruct-table-like(cont, new-items)
  } else if cont.func() == terms {
    // Programmatic terms container
    let new-items = cont
      .children
      .enumerate()
      .map(((idx, item)) => {
        if check-visible(self.subslide, (beginning: start + idx)) {
          item
        } else {
          terms.item(cover(item.term), cover(item.description))
        }
      })
    reconstruct-table-like(cont, new-items)
  } else {
    // Fallback: show content as-is
    cont
  }
}


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Multiple calls on the same slide are combined (accumulated), so all notes are shown together.
///
/// Example: `#speaker-note[This is a speaker note]`
///
/// - self (dictionary): The current presentation context.
///
/// - mode (str): The mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - setting (function): A function that takes the note as input and returns a processed note.
///
/// - subslide (none, auto, int, array, str): Restricts the note to specific subslides, similar to `only`.
///   - `none`: shown on all subslides.
///   - `auto`: automatically determined from the current pause position (default when called via `#speaker-note`).
///   - int, array, or string: shown only on the specified subslides.
///
/// - note (content): The content of the speaker note.
///
/// -> content
#let speaker-note(
  self: none,
  mode: "typ",
  setting: it => it,
  subslide: none,
  note,
) = {
  let show-only-notes = self.at("show-only-notes", default: false)
  assert(
    show-only-notes in (false, true),
    message: "`show-only-notes` should be `false` or `true`",
  )
  let show-notes-on-second-screen = self.at(
    "show-notes-on-second-screen",
    default: none,
  )
  assert(
    show-notes-on-second-screen in (none, bottom, right),
    message: "`show-notes-on-second-screen` should be `none`, `bottom` or `right`",
  )
  let is-visible = (
    subslide == none
      or subslide == auto
      or check-visible(self.subslide, subslide)
  )
  if is-visible {
    if self.at("enable-pdfpc", default: true) {
      let raw-text = if type(note) == content and note.has("text") {
        note.text
      } else {
        markup-text(note, mode: mode).trim()
      }
      pdfpc.speaker-note(raw-text)
    }
    if show-only-notes or show-notes-on-second-screen != none {
      slide-note-state.update(old => if old == none {
        setting(note)
      } else {
        old + parbreak() + setting(note)
      })
    }
  }
}


/// Convert an aspect ratio string to page configuration arguments.
///
/// For the built-in Typst presentation paper sizes ("16-9" and "4-3"), returns
/// a `paper` key. For other ratios (e.g. "16-10", "3-2"), returns explicit
/// `width` and `height` keys computed from the 16-9 base width (841.89pt).
///
/// Example:
///
/// ```typst
/// config-page(..utils.page-args-from-aspect-ratio("16-10"))
/// ```
///
/// - aspect-ratio (str): The aspect ratio string in `"W-H"` format where `W`
///   and `H` are positive numbers. E.g., `"16-9"`, `"4-3"`, `"16-10"`.
///
/// -> dictionary
#let page-args-from-aspect-ratio(aspect-ratio) = {
  let known = ("16-9", "4-3")
  if aspect-ratio in known {
    (paper: "presentation-" + aspect-ratio)
  } else {
    let parts = aspect-ratio.split("-")
    assert(
      parts.len() == 2,
      message: "Invalid aspect ratio \""
        + aspect-ratio
        + "\". Expected format: \"W-H\" with positive numbers, e.g. \"16-10\".",
    )
    let w-ratio = float(parts.at(0))
    let h-ratio = float(parts.at(1))
    assert(
      w-ratio > 0 and h-ratio > 0,
      message: "Invalid aspect ratio \""
        + aspect-ratio
        + "\": width and height must be positive numbers.",
    )
    let base-width = 841.89pt
    (width: base-width, height: base-width * h-ratio / w-ratio)
  }
}


/// Get the page width and height from the slide configuration.
///
/// Returns a tuple `(width, height)`. If the page has explicit `width`/`height`
/// keys those are used directly; otherwise dimensions are derived from the
/// `paper` key. The built-in Typst presentation paper sizes
/// (`"presentation-16-9"` and `"presentation-4-3"`) are recognised; for any
/// other paper name the 16-9 default dimensions (841.89pt × 473.56pt) are used
/// as a fallback.
///
/// - self (dictionary): The current slide self dictionary.
///
/// -> array
#let get-page-dimensions(self) = {
  let page = self.page
  let paper = page.at("paper", default: "presentation-16-9")
  let (pw, ph) = if paper == "presentation-16-9" {
    (841.89pt, 473.56pt)
  } else if paper == "presentation-4-3" {
    (793.7pt, 595.28pt)
  } else {
    // For explicit width/height pages the paper key may still be the default;
    // the actual dimensions are read from the page dict below.
    (841.89pt, 473.56pt)
  }
  let width = page.at("width", default: pw)
  let height = page.at("height", default: ph)
  (width, height)
}


/// Internationalized outline/table-of-contents title. Returns the appropriate word for the current document language (supports Arabic, Catalan, Czech, Danish, German, English, Spanish, Estonian, Finnish, Japanese, Russian, Traditional Chinese, and Simplified Chinese).
///
/// -> content
#let i18n-outline-title = context {
  let mapping = (
    ar: "المحتويات",
    ca: "Índex",
    cs: "Obsah",
    da: "Indhold",
    de: "Inhalte",
    en: "Outline",
    es: "Índice",
    et: "Sisukord",
    fi: "Sisällys",
    ja: "目次",
    ru: "Содержание",
    zh-TW: "目錄",
    zh: "目录",
  )
  mapping.at(text.lang, default: mapping.en)
}
