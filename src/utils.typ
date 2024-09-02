#import "pdfpc.typ"

#let _typst-builtin-numbering = numbering

/// Add a dictionary to another dictionary recursively
///
/// Example: `add-dicts((a: (b: 1), (a: (c: 2))` returns `(a: (b: 1, c: 2)`
#let add-dicts(dict-a, dict-b) = {
  let res = dict-a
  for key in dict-b.keys() {
    if key in res and type(res.at(key)) == dictionary and type(dict-b.at(key)) == dictionary {
      res.insert(key, add-dicts(res.at(key), dict-b.at(key)))
    } else {
      res.insert(key, dict-b.at(key))
    }
  }
  return res
}


/// Merge some dictionaries recursively
///
/// Example: `merge-dicts((a: (b: 1)), (a: (c: 2)))` returns `(a: (b: 1, c: 2))`
#let merge-dicts(init-dict, ..dicts) = {
  assert(dicts.named().len() == 0, message: "You must provide dictionaries as positional arguments")
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
/// - `callback` is the callback function `ratio => { .. }` to get the progress of the current slide. The `ratio` is a float number between 0 and 1.
#let touying-progress(callback) = (
  context {
    if last-slide-counter.final().first() == 0 {
      callback(1.0)
      return
    }
    let ratio = calc.min(1.0, slide-counter.get().first() / last-slide-counter.final().first())
    callback(ratio)
  }
)

// slide note state
#let slide-note-state = state("touying-slide-note-state", none)
#let current-slide-note = context slide-note-state.get()

// -------------------------------------
// Saved states and counters
// -------------------------------------

#let saved-frozen-states = state("touying-saved-frozen-states", ())
#let saved-default-frozen-states = state("touying-saved-default-frozen-states", ())
#let saved-frozen-counters = state("touying-saved-frozen-counters", ())
#let saved-default-frozen-counters = state("touying-saved-default-frozen-counters", ())


/// Remove leading and trailing empty elements from an array of content
///
/// - `empty-contents` is a array of content that is considered empty
///
/// Example: `trim(([], [ ], parbreak(), linebreak(), [a], [ ], [b], [c], linebreak(), parbreak(), [ ], [ ]))` returns `([a], [ ], [b], [c])`
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


/// Add a label to a content
///
/// Example: `label-it("key", [a])` is equivalent to `[a <key>]`
///
/// - `it` is the content to label
///
/// - `label-name` is the name of the label, or a label
#let label-it(it, label-name) = {
  if type(label-name) == label {
    [#it#label-name]
  } else {
    assert(type(label-name) == str, message: repr(label-name))
    [#it#label(label-name)]
  }
}

/// Reconstruct a content with a new body
///
/// - `body-name` is the property name of the body field
///
/// - `labeled` is a boolean indicating whether the fields should be labeled
///
/// - `named` is a boolean indicating whether the fields should be named
///
/// - `it` is the content to reconstruct
///
/// - `new-body` is the new body you want to replace the old body with
#let reconstruct(body-name: "body", labeled: true, named: false, it, ..new-body) = {
  let fields = it.fields()
  let label = fields.remove("label", default: none)
  let _ = fields.remove(body-name, default: none)
  if named {
    if label != none and labeled {
      return label-it((it.func())(..fields, ..new-body), label)
    } else {
      return (it.func())(..fields, ..new-body)
    }
  } else {
    if label != none and labeled {
      return label-it((it.func())(..fields.values(), ..new-body), label)
    } else {
      return (it.func())(..fields.values(), ..new-body)
    }
  }
}


/// Reconstruct a table-like content with new children
///
/// - `named` is a boolean indicating whether the fields should be named
///
/// - `it` is the content to reconstruct
///
/// - `new-children` is the new children you want to replace the old children with
#let reconstruct-table-like(named: true, labeled: true, it, new-children) = {
  reconstruct(body-name: "children", named: named, labeled: labeled, it, ..new-children)
}


#let typst-builtin-sequence = ([A] + [ ] + [B]).func()

/// Determine if a content is a sequence
///
/// Example: `is-sequence([a])` returns `true`
#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}


#let typst-builtin-styled = [#set text(fill: red)].func()

/// Determine if a content is styled
///
/// Example: `is-styled(text(fill: red)[Red])` returns `true`
#let is-styled(it) = {
  type(it) == content and it.func() == typst-builtin-styled
}


/// Reconstruct a styled content with a new body
///
/// - `it` is the content to reconstruct
///
/// - `new-child` is the new child you want to replace the old body with
#let reconstruct-styled(it, new-child) = {
  typst-builtin-styled(new-child, it.styles)
}


/// Determine if a content is a metadata
///
/// Example: `is-metadata(metadata((a: 1)))` returns `true`
#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}


/// Determine if a content is a metadata with a specific kind
#let is-kind(it, kind) = {
  is-metadata(it) and type(it.value) == dictionary and it.value.at("kind", default: none) == kind
}


/// Determine if a content is a heading in a specific depth
#let is-heading(it, depth: 9999) = {
  type(it) == content and it.func() == heading and it.depth <= depth
}


/// Call a `self => {..}` function and return the result, or just return the content
#let call-or-display(self, it) = {
  if type(it) == function {
    it = it(self)
  }
  return [#it]
}


/// Wrap a function with a `self` parameter to make it a method
///
/// Example: `#let hide = method-wrapper(hide)` to get a `hide` method
#let method-wrapper(fn) = (self: none, ..args) => fn(..args)


/// Assuming all functions in dictionary have a named `self` parameter,
/// `methods` function is used to get all methods in dictionary object
///
/// Example: `#let (uncover, only) = utils.methods(self)` to get `uncover` and `only` methods.
#let methods(self) = {
  assert(type(self) == dictionary, message: "self must be a dictionary")
  assert("methods" in self and type(self.methods) == dictionary, message: "self.methods must be a dictionary")
  let methods = (:)
  for key in self.methods.keys() {
    if type(self.methods.at(key)) == function {
      methods.insert(key, (..args) => self.methods.at(key)(self: self, ..args))
    }
  }
  return methods
}


// -------------------------------------
// Headings
// -------------------------------------


/// Capitalize a string
#let capitalize(s) = {
  assert(type(s) == str, message: "s must be a string")
  if s.len() == 0 {
    return s
  }
  let lowercase = lower(s)
  upper(lowercase.at(0)) + lowercase.slice(1)
}


/// Convert a string into title case
#let titlecase(s) = {
  assert(type(s) == str, message: "s must be a string")
  if s.len() == 0 {
    return s
  }
  s.split(" ").map(capitalize).join(" ")
}


/// Convert a heading with label to short form
///
/// - `it` is the heading
#let short-heading(self: none, it) = {
  if it == none {
    return
  }
  let convert-label-to-short-heading = if (
    type(self) == dictionary and "methods" in self and "convert-label-to-short-heading" in self.methods
  ) {
    self.methods.convert-label-to-short-heading
  } else {
    (self: none, lbl) => titlecase(lbl.replace(regex("^[^:]*:"), "").replace("_", " ").replace("-", " "))
  }
  convert-label-to-short-heading = convert-label-to-short-heading.with(self: self)
  assert(type(it) == content and it.func() == heading, message: "it must be a heading")
  if not it.has("label") {
    return it.body
  }
  let lbl = str(it.label)
  return convert-label-to-short-heading(lbl)
}


/// Get the current heading On or before the current page.
///
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
#let current-heading(level: auto, hierachical: true, depth: 9999) = {
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = query(heading).filter(h => (
      h.location().page() <= current-page and h.level <= depth and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = query(heading).filter(h => h.location().page() <= current-page and h.level <= depth)
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
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `numbered` is a boolean value to indicate whether to display the numbering of the heading. Default is `true`.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - `setting` is the setting of the heading. Default is `body => body`.
///
/// - `sty` is the style of the heading. If `sty` is a function, it will use the function to style the heading. For example, `sty: current-heading => current-heading.body`.
#let display-current-heading(
  self: none,
  level: auto,
  numbered: true,
  hierachical: true,
  depth: 9999,
  setting: body => body,
  ..sty,
) = (
  context {
    let sty = if sty.pos().len() > 1 {
      sty.pos().at(0)
    } else {
      current-heading => {
        if numbered and current-heading.numbering != none {
          _typst-builtin-numbering(
            current-heading.numbering,
            ..counter(heading).at(current-heading.location()),
          ) + h(.3em)
        }
        current-heading.body
      }
    }
    let current-heading = current-heading(level: level, hierachical: hierachical, depth: depth)
    if current-heading != none {
      setting(sty(current-heading))
    }
  }
)


/// Display the current heading number on the page.
///
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `numbering` is the numbering of the heading. If `numbering` is `auto`, it will use the numbering of the heading. If `numbering` is a string, it will use the string as the numbering.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
#let display-current-heading-number(level: auto, numbering: auto, hierachical: true, depth: 9999) = (
  context {
    let current-heading = current-heading(level: level, hierachical: hierachical, depth: depth)
    if current-heading != none and numbering == auto and current-heading.numbering != none {
      _typst-builtin-numbering(current-heading.numbering, ..counter(heading).at(current-heading.location()))
    } else if current-heading != none and numbering != auto {
      _typst-builtin-numbering(numbering, ..counter(heading).at(current-heading.location()))
    }
  }
)


/// Display the current short heading on the page.
///
/// - `level` is the level of the heading. If `level` is `auto`, it will return the last heading on or before the current page. If `level` is a number, it will return the last heading on or before the current page with the same level.
///
/// - `hierachical` is a boolean value to indicate whether to return the heading hierachically. If `hierachical` is `true`, it will return the last heading according to the hierachical structure. If `hierachical` is `false`, it will return the last heading on or before the current page with the same level.
///
/// - `depth` is the maximum depth of the heading to search. Usually, it should be set as slide-level.
///
/// - `sty` is the style of the heading. If `sty` is a function, it will use the function to style the heading. For example, `sty: current-heading => current-heading.body`.
#let display-current-short-heading(
  self: none,
  level: auto,
  hierachical: true,
  depth: 9999,
  setting: body => body,
  ..sty,
) = (
  context {
    let sty = if sty.pos().len() > 1 {
      sty.pos().at(0)
    } else {
      current-heading => {
        short-heading(self: self, current-heading)
      }
    }
    let current-heading = current-heading(level: level, hierachical: hierachical, depth: depth)
    if current-heading != none {
      setting(sty(current-heading))
    }
  }
)


/// Display the date of `self.info.date` with `self.datetime-format` format.
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
/// - `it` is the content to convert.
///
/// - `mode` is the mode of the markup text, either `typ` or `md`.
///
/// - `indent` is the number of spaces to indent, default is `0`.
#let markup-text(it, mode: "typ", indent: 0) = {
  assert(mode == "typ" or mode == "md", message: "mode must be 'typ' or 'md'")
  let indent-markup-text = markup-text.with(mode: mode, indent: indent + 2)
  let markup-text = markup-text.with(mode: mode, indent: indent)
  if type(it) == str {
    it
  } else if type(it) == content {
    if it.func() == raw {
      if it.block {
        "\n" + indent * " " + "```" + it.lang + it
          .text
          .split("\n")
          .map(l => "\n" + indent * " " + l)
          .sum(default: "") + "\n" + indent * " " + "```"
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
      "\n" + indent * " " + "/ " + markup-text(it.term) + ": " + indent-markup-text(it.description)
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
/// Example: `#utils.fit-to-height(1fr)[BIG]`
///
/// - `width` will determine the width of the content after scaling. So, if you want the scaled content to fill half of the slide width, you can use width: 50%.
///
/// - `prescale-width` allows you to make typst's layout assume that the given content is to be laid out in a container of a certain width before scaling. For example, you can use `prescale-width: 200%` assuming the slide's width is twice the original.
///
/// - `grow` is a boolean indicating whether the content should be scaled up if it is smaller than the available height. Default is `true`.
///
/// - `shrink` is a boolean indicating whether the content should be scaled down if it is larger than the available height. Default is `true`.
///
/// - `height` is the height to fit the content to.
///
/// - `body` is the content to fit.
#let fit-to-height(
  width: none,
  prescale-width: none,
  grow: true,
  shrink: true,
  height,
  body,
) = {
  // Place two labels with the requested vertical separation to be able to
  // measure their vertical distance in pt.
  // Using this approach instead of using `measure` allows us to accept fractions
  // like `1fr` as well.
  // The label must be attached to content, so we use a show rule that doesn't
  // display anything as the anchor.
  let before-label = label("touying-fit-height-before")
  let after-label = label("touying-fit-height-after")
  [
    #show before-label: none
    #show after-label: none
    #v(1em)
    hidden#before-label
    #v(height)
    hidden#after-label
  ]

  context {
    let before = query(selector(before-label).before(here()))
    let before-pos = before.last().location().position()
    let after = query(selector(after-label).before(here()))
    let after-pos = after.last().location().position()

    let available-height = after-pos.y - before-pos.y

    layout(container-size => {
      // Helper function to more easily grab absolute units
      let get-pts(body, w-or-h) = {
        let dim = if w-or-h == "w" {
          container-size.width
        } else {
          container-size.height
        }
        _size-to-pt(body, dim)
      }

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
      mutable-width = get-pts(mutable-width, "w")

      let size = measure(boxed-content)
      if size.height == 0pt or size.width == 0pt {
        return body
      }
      let h-ratio = available-height / size.height
      let w-ratio = mutable-width / size.width
      let ratio = calc.min(h-ratio, w-ratio) * 100%

      if ((shrink and (ratio < 100%)) or (grow and (ratio > 100%))) {
        let new-width = size.width * ratio
        v(-available-height)
        // If not boxed, the content can overflow to the next page even though it will
        // fit. This is because scale doesn't update the layout information.
        // Boxing in a container without clipping will inform typst that content
        // will indeed fit in the remaining space
        box(
          width: new-width,
          height: available-height,
          scale(x: ratio, y: ratio, origin: top + left, boxed-content),
        )
      } else {
        body
      }
    })
  }
}


/// Fit content to specified width.
///
/// Example: `#utils.fit-to-width(1fr)[BIG]`
///
/// - `grow` is a boolean indicating whether the content should be scaled up if it is smaller than the available width. Default is `true`.
///
/// - `shrink` is a boolean indicating whether the content should be scaled down if it is larger than the available width. Default is `true`.
///
/// - `width` is the width to fit the content to.
///
/// - `body` is the content to fit.
#let fit-to-width(grow: true, shrink: true, width, content) = {
  layout(layout-size => {
    let content-size = measure(content)
    let content-width = content-size.width
    let width = _size-to-pt(width, layout-size.width)
    if (content-width != 0pt and ((shrink and (width < content-width)) or (grow and (width > content-width)))) {
      let ratio = width / content-width * 100%
      // The first box keeps content from prematurely wrapping
      let scaled = scale(
        box(content, width: content-width),
        origin: top + left,
        x: ratio,
        y: ratio,
      )
      // The second box lets typst know the post-scaled dimensions, since `scale`
      // doesn't update layout information
      box(scaled, width: width, height: content-size.height * ratio)
    } else {
      content
    }
  })
}


/// Cover content with a rectangle of a specified color. If you set the fill to the background color of the page, you can use this to create a semi-transparent overlay.
///
/// Example: `#utils.cover-with-rect(fill: "red")[Hidden]`
///
/// - `cover-args` are the arguments to pass to the rectangle.
///
/// - `fill` is the color to fill the rectangle with.
///
/// - `inline` is a boolean indicating whether the content should be displayed inline. Default is `true`.
///
/// - `body` is the content to cover.
#let cover-with-rect(..cover-args, fill: auto, inline: true, body) = {
  if fill == auto {
    panic("`auto` fill value is not supported until typst provides utilities to" + " retrieve the current page background")
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
/// Example: `update-alpha(rgb("#ff0000"), 0.5)` returns `rgb(255, 0, 0, 0.5)`
///
/// - `constructor` is the color constructor to use. Default is `rgb`.
///
/// - `color` is the color to update.
///
/// - `alpha` is the new alpha value.
#let update-alpha(constructor: rgb, color, alpha) = constructor(..color.components(alpha: true).slice(0, -1), alpha)


/// Cover content with a transparent rectangle.
///
/// Example: `config-methods(cover: utils.semi-transparent-cover)`
#let semi-transparent-cover(self: none, constructor: rgb, alpha: 85%, body) = {
  cover-with-rect(
    fill: update-alpha(
      constructor: constructor,
      self.page.fill,
      alpha,
    ),
    body,
  )
}


/// Alert content with a primary color.
///
/// Example: `config-methods(alert: utils.alert-with-primary-color)`
#let alert-with-primary-color(self: none, body) = text(fill: self.colors.primary, body)


/// Alert content.
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


/// Check if a slide is visible
///
/// Example: `check-visible(3, "2-")` returns `true`
///
/// - `idx` is the index of the slide
///
/// - `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read [polylux book](https://polylux.dev/book/dynamic/complex.html)
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
#let check-visible(idx, visible-subslides) = {
  if type(visible-subslides) == int {
    idx == visible-subslides
  } else if type(visible-subslides) == array {
    visible-subslides.any(s => check-visible(idx, s))
  } else if type(visible-subslides) == str {
    let parts = _parse-subslide-indices(visible-subslides)
    check-visible(idx, parts)
  } else if type(visible-subslides) == content and visible-subslides.has("text") {
    let parts = _parse-subslide-indices(visible-subslides.text)
    check-visible(idx, parts)
  } else if type(visible-subslides) == dictionary {
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
  } else {
    panic("you may only provide a single integer, an array of integers, or a string")
  }
}


#let last-required-subslide(visible-subslides) = {
  if type(visible-subslides) == int {
    visible-subslides
  } else if type(visible-subslides) == array {
    calc.max(..visible-subslides.map(s => last-required-subslide(s)))
  } else if type(visible-subslides) == str {
    let parts = _parse-subslide-indices(visible-subslides)
    last-required-subslide(parts)
  } else if type(visible-subslides) == dictionary {
    let last = 0
    if "beginning" in visible-subslides {
      last = calc.max(last, visible-subslides.beginning)
    }
    if "until" in visible-subslides {
      last = calc.max(last, visible-subslides.until)
    }
    last
  } else {
    panic("you may only provide a single integer, an array of integers, or a string")
  }
}

/// Uncover content in some subslides. Reserved space when hidden (like `#hide()`).
///
/// Example: `uncover("2-")[abc]` will display `[abc]` if the current slide is 2 or later
///
/// - `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read [polylux book](https://polylux.dev/book/dynamic/complex.html)
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - `uncover-cont` is the content to display when the content is visible in the subslide.
#let uncover(self: none, visible-subslides, uncover-cont) = {
  let cover = self.methods.cover.with(self: self)
  if check-visible(self.subslide, visible-subslides) {
    uncover-cont
  } else {
    cover(uncover-cont)
  }
}


/// Display content in some subslides only.
/// Don't reserve space when hidden, content is completely not existing there.
///
/// - `visible-subslides` is a single integer, an array of integers,
///    or a string that specifies the visible subslides
///
///    Read [polylux book](https://polylux.dev/book/dynamic/complex.html)
///
///    The simplest extension is to use an array, such as `(1, 2, 4)` indicating that
///    slides 1, 2, and 4 are visible. This is equivalent to the string `"1, 2, 4"`.
///
///    You can also use more convenient and complex strings to specify visible slides.
///
///    For example, "-2, 4, 6-8, 10-" means slides 1, 2, 4, 6, 7, 8, 10, and slides after 10 are visible.
///
/// - `only-cont` is the content to display when the content is visible in the subslide.
#let only(self: none, visible-subslides, only-cont) = {
  if check-visible(self.subslide, visible-subslides) {
    only-cont
  }
}


/// `#alternatives` has a couple of "cousins" that might be more convenient in some situations. The first one is `#alternatives-match` that has a name inspired by match-statements in many functional programming languages. The idea is that you give it a dictionary mapping from subslides to content:
///
/// #example(```
/// #alternatives-match((
///   "1, 3-5": [this text has the majority],
///   "2, 6": [this is shown less often]
/// ))
/// ```)
///
/// - `subslides-contents` is a dictionary mapping from subslides to content.
///
/// - `position` is the position of the content. Default is `bottom + left`.
#let alternatives-match(self: none, subslides-contents, position: bottom + left) = {
  let subslides-contents = if type(subslides-contents) == dictionary {
    subslides-contents.pairs()
  } else {
    subslides-contents
  }

  let subslides = subslides-contents.map(it => it.first())
  let contents = subslides-contents.map(it => it.last())
  context {
    let sizes = contents.map(c => measure(c))
    let max-width = calc.max(..sizes.map(sz => sz.width))
    let max-height = calc.max(..sizes.map(sz => sz.height))
    for (subslides, content) in subslides-contents {
      only(
        self: self,
        subslides,
        box(
          width: max-width,
          height: max-height,
          align(position, content),
        ),
      )
    }
  }
}


/// `#alternatives` is able to show contents sequentially in subslides.
///
/// Example: `#alternatives[Ann][Bob][Christopher]` will show "Ann" in the first subslide, "Bob" in the second subslide, and "Christopher" in the third subslide.
///
/// - `start` is the starting subslide number. Default is `1`.
///
/// - `repeat-last` is a boolean indicating whether the last subslide should be repeated. Default is `true`.
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
/// - `start` is the starting subslide number. Default is `1`.
///
/// - `end` is the ending subslide number. Default is `none`.
///
/// - `count` is the number of subslides. Default is `none`.
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
/// #example(```
/// #alternatives-cases(("1, 3", "2"), case => [
///   #set text(fill: teal) if case == 1
///   Some text
/// ])
/// ```)
///
/// - `cases` is an array of strings that specify the subslides for each case.
///
/// - `fn` is a function that maps the case to content. The argument `case` is the index of the cases array you input.
#let alternatives-cases(self: none, cases, fn, ..kwargs) = {
  let idcs = range(cases.len())
  let contents = idcs.map(fn)
  alternatives-match(self: self, cases.zip(contents), ..kwargs.named())
}


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Example: `#speaker-note[This is a speaker note]`
///
/// - `self` is the current context.
///
/// - `mode` is the mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - `setting` is a function that takes the note as input and returns a processed note.
///
/// - `note` is the content of the speaker note.
#let speaker-note(self: none, mode: "typ", setting: it => it, note) = {
  if self.at("enable-pdfpc", default: true) {
    let raw-text = if type(note) == content and note.has("text") {
      note.text
    } else {
      markup-text(note, mode: mode).trim()
    }
    pdfpc.speaker-note(raw-text)
  }
  let show-notes-on-second-screen = self.at("show-notes-on-second-screen", default: none)
  assert(
    show-notes-on-second-screen in (none, bottom, right),
    message: "`show-notes-on-second-screen` should be `none`, `bottom` or `right`",
  )
  if show-notes-on-second-screen != none {
    slide-note-state.update(setting(note))
  }
}


/// i18n Outline Title
#let i18n-outline-title = context {
  let mapping = (
    ar: "المحتويات",
    ca: "Índex",
    cs: "Obsah",
    da: "Indhold",
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