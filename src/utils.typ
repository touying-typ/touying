#import "bundle.typ"
#import "pdfpc.typ"
#import "extern.typ": warning
#import "core/tree.typ"
#import "core/waypoints.typ": resolve-waypoints
#import "core/subslides.typ": (
  _is-placement, _is-swap, _parse-subslide-indices, check-visible,
)


/// Add page margin dictionary to another page margin dictionary.
///
/// Example: `add-page-margin-dicts((top: 1cm, x: 2cm), (y: 3em))` returns `(x: 2cm, y: 3em)`
///
/// - dict-a (dictionary): The base dictionary.
///
/// - dict-b (dictionary): The dictionary to merge into `dict-a`.
///
/// -> dictionary
#let add-page-margin-dicts(dict-a, dict-b) = {
  // Possible keys: top, right, bottom, left, inside, outside, x, y, rest.
  // Source: https://github.com/typst/typst/blob/e7256a6361f3181bac6d61cfd31935a443109bfb/crates/typst-library/src/layout/page.rs#L128-L139
  let res = dict-a
  let sides = ("top", "right", "bottom", "left")
  let res-has-sides = res.keys().any(k => k in sides)
  // `rest` only works as expected with its context, i.e., `dict-b`.
  if "rest" in dict-b { return dict-b }
  if not res-has-sides { return res + dict-b }
  // Assuming `inside`/`outside` just takes precedence over `x`/`left`/`right`.
  if "x" in dict-b {
    if "left" in res { _ = res.remove("left") }
    if "right" in res { _ = res.remove("right") }
  }
  if "y" in dict-b {
    if "top" in res { _ = res.remove("top") }
    if "bottom" in res { _ = res.remove("bottom") }
  }
  return res + dict-b
}

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
      if key == "margin" {
        // Assuming `margin` can only be in the `config-page`.
        res.insert(key, add-page-margin-dicts(res.at(key), dict-b.at(key)))
      } else {
        res.insert(key, add-dicts(res.at(key), dict-b.at(key)))
      }
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


/// recursively checks if `it` has a text in it
///
/// - it (content): the content to check
/// - transparentize-table (bool): Whether to assume tables contain text. If `false` tables will get searched completely for available text.
/// - text-blocks (bool): Whether so search through block level elements for text.
/// -> bool
#let _contains-text(it, transparentize-table) = {
  let is-text = node => (
    type(node) == content
      and (
        node.func() in (text, math.equation)
          // `raw` keeps its content in `text`, not in a body.
          or node.has("text")
          or (transparentize-table and node.func() == table)
      )
  )
  tree.find-in-tree(it, is-text) != none
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

/// The default `cover` method (wraps Typst's own `hide`) and touying's default value
/// for `config-methods(cover: ..)`. Exposed as a stable, comparable value (rather than
/// only living as a private default in `configs.typ`) so other code can check
/// `self.methods.cover == utils.hiding-cover` as a best-effort way to tell whether
/// covering is genuinely invisible, as opposed to a visual-only style like
/// `color-changing-cover`/`alpha-changing-cover`.
///
/// This is only identity comparison, so it cannot recognize a hand-written cover
/// function that happens to also just call `hide` - use the `cover-hides-footnote`
/// config to override the result explicitly where that distinction matters.
///
/// -> function
#let hiding-cover = method-wrapper(hide)

/// Resolve the `cover-hides-footnote` config: whether the presentation's configured
/// `cover` method genuinely hides content (as opposed to a visual-only style like
/// `color-changing-cover`/`alpha-changing-cover`). Explicit `true`/`false` is
/// returned as-is; `auto` (the default) falls back to comparing `self.methods.cover`
/// against `hiding-cover` by identity - see `hiding-cover` for that check's limits.
///
/// - self (dictionary): The presentation context.
///
/// -> bool
#let cover-hides-footnote(self) = {
  let configured = self.at("cover-hides-footnote", default: auto)
  if configured == auto {
    self.methods.cover == hiding-cover
  } else {
    configured
  }
}


/// Extract all method functions from `self` and bind `self` as their first named argument.
///
/// Returns a dictionary of ready-to-call functions where the `self` argument has already been applied. Use destructuring to get individual methods.
///
/// Example: `#let (uncover, only) = utils.methods(self)` to get `uncover` and `only` methods.
///
/// This function is primarily intended for callback-style usage inside `context` blocks or style rules, where the top-level
/// `#uncover`/`#only` etc. functions cannot be used. Animation methods resolve waypoint labels
/// via `self.waypoints` (populated before rendering) and check `self.subslide` directly.
///
/// Note: these methods do not register fn-wrappers in the touying parser, so they do not
/// contribute to the subslide count.
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
  // In normal typst documents, `query(heading)` suffices to select all
  // headings. When using bundle export, this would result in the headings
  // of other documents messing up the selection (see #406), so we ask for the
  // headings of our own document only. `within-current-document` explains why
  // that needs a case distinction on the export target.
  let heading-selector = bundle.within-current-document(heading, here())
  let current-page = here().page()
  if not hierachical and level != auto {
    let headings = query(heading-selector).filter(h => (
      h.location().page() <= current-page
        and h.level <= depth
        and h.level == level
    ))
    return headings.at(-1, default: none)
  }
  let headings = query(heading-selector).filter(h => (
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
        return current-heading
      }

      let setting-args-named = setting-args.named()
      let _style = style
      if style == auto {
        _style = (
          setting: body => body,
          numbered: true,
          current-heading,
        ) => setting({
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
        })

        let current-level = current-heading.level
        if current-level == 1 {
          setting-args-named = merge-dicts(setting-args-named, (
            setting: text.with(.715em),
          ))
        } //else do nothing
      }
      _style(..setting-args-named, ..setting-args.pos(), current-heading)
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

/// Get the relationship of the current section a passed in outline entry. For past sections of another top-level section it returns -2, for past section of the current top-level section it returns -1. For the current section and children it returns 0, for future sections of the current top-level section it returns 1, and for future sections of another top-level section it returns 2.
///
/// Usage:
/// ```typc
/// #{// displays all top levels and all levels of the current top-level,
///   // with future siblings and other top levels semi-transparent
///   // and the current entry bold
///   show outline.entry: it => {
///     let relationship = utils.section-relationship(it)
///     let current = utils.current-heading()
///     let alpha = if relationship == -2 or relationship > 0 {40%} else {100%}
///     let weight = if relationship == 0 and current.level == it.level { "bold" } else { "regular" }
///     if it.level > 1 and calc.abs(relationship) > 1 {
///       none
///       // text(fill:red, it) // this will show all non-displayed entries in red.
///     } else {
///       text(fill:utils.update-alpha(text.fill, alpha), weight: weight, it)
///     }
///   }
///   // if title is not none, it will create a new top-level heading which interferes with the computation
///   outline(title:none)
/// }
/// ```
///
/// - current (content, none): The current heading to compare with. Default is `auto`, which uses `utils.current-heading()`.
/// - it (content): The outline entry to compare with.
///
/// -> int
#let section-relationship(current: auto, it) = {
  if current == auto {
    current = current-heading()
  }
  let current-top-heading = current-heading(depth: 1)
  if current-top-heading == none {
    warning(
      "Found no current top-level heading when trying to compute section relationship. Falling back to the current heading. This might cause problems. Problematic heading: "
        + repr(current.body),
    )
    current-top-heading = current
  }
  let next-top-heading = query(
    selector(heading.where(depth: 1)).after(
      inclusive: false,
      current-top-heading.location(),
    ),
  ).at(0, default: none)
  let next-heading = query(
    //the next non-child section heading
    selector(heading.where(depth: current.level)).after(
      inclusive: false,
      current.location(),
    ),
  ).at(0, default: none)
  let this-top-loc = current-top-heading.location().page()
  let this-loc = current.location().page()
  let next-sibling-loc = if next-heading != none {
    next-heading.location().page()
  } else {
    calc.inf
  }
  let next-top-loc = if next-top-heading != none {
    next-top-heading.location().page()
  } else {
    calc.inf
  }

  let it-location = it.element.location().page()

  if it-location < this-top-loc {
    return -2
  } else if it-location < this-loc {
    return -1
  } else if it-location < next-sibling-loc and it-location < next-top-loc {
    return 0
  } else if it-location < next-top-loc {
    return 1
  } else {
    return 2
  }
}


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
    } else if tree.is-styled(it) {
      markup-text(it.child)
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
  if type(size) == fraction {
    let fr = repr(size * 1000000) //avoid capped precision
    to-convert = float(fr.slice(0, fr.len() - 2)) / 1000000
  }
  if type(to-convert) in (int, float, ratio) {
    //nice just a multiplication
    to-convert = container-dimension * to-convert
  } else {
    to-convert = measure(v(to-convert)).height //get in pt if em
  }
  to-convert
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


/// Fit content to specified/remaining height.
///
/// Example: `#utils.fit-to-height[BIG]`
/// - height (length, fraction, relative): The height to fit the content to. For example, `height: 50%` will fit the content to half of the slide height. If given as a fraction, it will be based on the available height after everything else is evaluated, similar to how fractional lengths behave for table column widths. Default is `1fr` which means to fit the content to the full available rest height.
///
/// - width (length, fraction, relative): Will determine the width of the content after scaling. So, if you want the scaled content to fill half of the slide width, you can use `width: 50%`.
///
/// - prescale-width (length, fraction, relative): Allows you to make Typst's layout assume that the given content is to be laid out in a container of a certain width before scaling. For example, you can use `prescale-width: 200%` assuming the slide's width is twice the original.
///
/// - grow (bool): Indicates whether the content should be scaled up if it is smaller than the available height. Default is `true`.
///
/// - shrink (bool): Indicates whether the content should be scaled down if it is larger than the available height. Default is `true`.
///
/// - reflow (bool): Whether to allow text reflow when scaling with auto width. Default is `true`. Only works when `width` is `auto` and the body contains text.
///
/// - force-height (bool): Whether to force the content to occupy the full height and not have it fill the available width. Only matters when `reflow` is `true` and `width` is auto. By default `false`. When text is reflowed, it makes sense to use as much width as possible and not force the content to be as tall as possible. Lines are naturally discrete and thus so are the possible scaling factors to fit the lines to the available height. Forcing the height may lead to the text not occupying the available width.
///
/// - body (content): The content to fit. If two positional arguments are given, this will be height instead.
///
/// - args (arguments): For convenience and compatibility with older versions, passing in height as a positional argument is still supported. If two positional arguments are given, the first one is the width and the second one is the body.
///
/// -> content
#let fit-to-height(
  height: 1fr,
  width: auto,
  prescale-width: none,
  grow: true,
  shrink: true,
  reflow: true,
  force-height: false,
  body,
  ..args,
) = {
  assert(
    args.pos().len() <= 1,
    message: "Only two positional arguments allowed, which will be interpreted as height and body.",
  )
  if args.pos().len() == 1 {
    height = body
    body = args.pos().at(0)
  }
  context {
    let layout-content(
      width: auto,
      prescale-width: none,
      grow: true,
      shrink: true,
      height,
      body,
    ) = layout(container-size => {
      let available-height = 0pt
      if type(height) == fraction {
        available-height = container-size.height
      } else {
        available-height = _size-to-pt(height, container-size.height)
      }
      // Provide a sensible initial width, which will define initial scale parameters.
      // Note this is different from the post-scale width, which is a limiting factor
      // on the allowable scaling ratio
      let boxed-content = _limit-content-width(
        width: prescale-width,
        body,
        container-size,
      )

      //get size of the content when boxed to the prescale width, which is the initial size before scaling, may be different from the container-width
      let size = measure(boxed-content)
      if size.height == 0pt or size.width == 0pt {
        return body
      }
      let h-ratio = available-height / size.height

      // post-scaling width
      let mutable-width = width
      if width == none or width == auto {
        mutable-width = container-size.width
      }
      mutable-width = _size-to-pt(mutable-width, container-size.width)

      let w-ratio = mutable-width / size.width
      let ratio = calc.min(h-ratio, w-ratio) * 100%

      if width == auto and reflow and _contains-text(body, false) {
        //height is good rn, but width may be too small.
        // get the current ratio of used/available width and scale such that we fill it. use sqrt trick to allow good flow.
        // then height may again be slightly too small. repeat that.

        let adjust-width(ratio, body, boxed-content, size) = {
          let w-ratio = (
            measure(scale(
              ratio,
              boxed-content,
              origin: top + left,
              reflow: true,
            )).width
              / size.width
          )

          let _boxed-content = block(
            width: size.width / calc.sqrt(w-ratio), //increase width by sqrt of w-ratio
            body,
          )
          ratio = calc.sqrt(w-ratio) * 100%
          return (ratio, _boxed-content)
        }

        let adjust-height(ratio, body, boxed-content, size) = {
          let h-ratio = (
            measure(scale(
              ratio,
              boxed-content,
              origin: top + left,
              reflow: true,
            )).height
              / size.height
          )

          let _boxed-content = block(
            width: size.width / float(ratio) * calc.sqrt(h-ratio), //reduce width by sqrt of h-ratio
            body,
          )
          ratio *= calc.sqrt(1 / h-ratio)

          h-ratio = (
            measure(scale(
              ratio,
              _boxed-content,
              origin: top + left,
              reflow: true,
            )).height
              / size.height
          )
          ratio /= h-ratio

          return (ratio, _boxed-content)
        }

        //improve iteratively, 2 seems enough.
        for i in range(2) {
          (ratio, boxed-content) = adjust-width(ratio, body, boxed-content, (
            width: mutable-width,
            height: available-height,
          ))
          (ratio, boxed-content) = adjust-height(ratio, body, boxed-content, (
            width: mutable-width,
            height: available-height,
          ))
        }
        if not force-height {
          //fix the width one last time linearly.
          let scaled-width = measure(scale(
            ratio,
            boxed-content,
            origin: top + left,
            reflow: true,
          )).width
          let current-box-width = measure(boxed-content).width
          boxed-content = box(
            width: current-box-width * (mutable-width / scaled-width),
            body,
          )
        }
      }
      if ((shrink and (ratio < 100%)) or (grow and (ratio > 100%))) {
        scale(
          ratio,
          origin: top + left,
          boxed-content,
          reflow: true,
        )
      } else {
        body
      }
    })
    if type(height) == fraction {
      block(
        height: height,
        layout-content(
          width: width,
          prescale-width: prescale-width,
          grow: grow,
          shrink: shrink,
          height,
          body,
        ),
      )
    } else {
      layout-content(
        width: width,
        prescale-width: prescale-width,
        grow: grow,
        shrink: shrink,
        height,
        body,
      )
    }
  }
}


/// Fit content to specified width.
///
/// Example: `#utils.fit-to-width(100%)[BIG]`
///
/// - width (length, fraction, relative): The width to fit the content to. For example, `width: 50%` will fit the content to half of the slide width. If given as a fraction, it will be based on the available width after everything else is evaluated, similar to how fractional lengths behave for table column widths. Default is `1fr` which means to fit the content to the full available rest width.
///
/// - grow (bool): Indicates whether the content should be scaled up if it is smaller than the available width. Default is `true`.
///
/// - shrink (bool): Indicates whether the content should be scaled down if it is larger than the available width. Default is `true`.
///
/// - body (content): The content to fit. If two positional arguments are given, this will be width instead.
///
/// - args (arguments): For convenience and compatibility with older versions, passing in width as a positional argument is still supported. If two positional arguments are given, the first one is the width and the second one is the body.
///
/// -> content
#let fit-to-width(width: 1fr, grow: true, shrink: true, body, ..args) = {
  assert(
    args.pos().len() <= 1,
    message: "Only two positional arguments allowed, which will be interpreted as width and body.",
  )
  if args.pos().len() == 1 {
    width = body
    body = args.pos().at(0)
  }

  layout(layout-size => {
    let content-width = measure(body).width
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
        box(body, width: content-width),
        origin: top + left,
        x: ratio,
        y: ratio,
        reflow: true,
      )
    } else {
      body
    }
  })
}
/// true for all typst content that is not inline.
#let is-block(it) = {
  // whenever sth is wrapped in a box it is automatically inlined.
  //first get the variable stuff
  if it.func() in (math.equation, raw, quote) {
    return it.block
  }
  (
    it.func()
      in (
        // model stuff
        figure,
        footnote.entry,
        heading,
        enum,
        list,
        terms,
        par,
        table,
        title,
        // text stuff already checked above, as can be both
        // layout stuff
        align,
        block,
        columns,
        grid,
        move,
        pad,
        place,
        repeat,
        rotate,
        scale,
        skew,
        stack,
        // visual stuff,
        // (path is deprecated)
        circle,
        curve,
        ellipse,
        image,
        line,
        polygon,
        rect,
        square,
      )
  )
}


/// Cover content with a rectangle of a specified color. If you set the fill to the background color of the page, you can use this to create a semi-transparent overlay.
///
/// Example: `#utils.cover-with-rect(fill: "red")[Hidden]`
///
/// - cover-args (args): The arguments to pass to the rectangle.
///
/// - fill (color): The color to fill the rectangle with.
///
/// - inline (bool): Indicates whether the content should be displayed inline. Default is `auto`. It is determined based on content type, not inline for block content and inline for inline content.
///
/// - body (content): The content to cover.
///
/// -> content
#let cover-with-rect(
  self: none,
  ..cover-args,
  fill: auto,
  inline: auto,
  is-first: false,
  body,
) = {
  if fill == auto {
    panic(
      "`auto` fill value is not supported until typst provides utilities to"
        + " retrieve the current page background",
    )
  }
  if type(fill) == str {
    fill = rgb(fill)
  }
  if body == none {
    return []
  }
  //handle all sorts of weird wrappers and space-like content
  if body.func() == tree.typst-builtin-styled {
    // unwrap styled content and re-apply style after covering, to avoid the
    // cover rect being wrapped in the styled element which can cause issues
    // with certain styles (e.g. `set text-color(red)` would make the rect red)
    return tree.reconstruct-styled(
      body,
      cover-with-rect(
        self: self,
        ..cover-args,
        fill: fill,
        inline: inline,
        body.child,
      ),
    )
  }
  //skip space/empty content
  if body.func() in (parbreak, linebreak, tree.typst-builtin-space, h, v) {
    return body
  }
  // split up sequences to find actual content types
  if body.func() == tree.typst-builtin-sequence {
    let bodies = body.children
    return bodies
      .map(b => {
        cover-with-rect(
          self: self,
          ..cover-args,
          fill: fill,
          inline: inline,
          b,
        )
      })
      .sum(default: none)
  }

  if inline == auto {
    inline = not is-block(body)
  }

  //debug colors keep these!!!
  // fill = if body.func() == math.equation {
  //   rgb(0, 0, 255, 50%)
  // } else if inline {
  //   rgb(0, 255, 0, 50%)
  // } else {
  //   rgb(255, 0, 0, 50%)
  // }
  if inline and body.func() != math.equation {
    // For inline content, use strike with a thick stroke to overlay a colored
    // bar per line fragment.  strike is line-break-aware: it renders per
    // fragment during layout, so text wraps naturally (no rigid box).
    // Measure body wrapped in par() to pick up show rules like
    // `show par: set text(2em)` that affect the actual rendered size.
    context {
      // Measure a reference character wrapped in par() to pick up show rules
      // like `show par: set text(2em)` that affect rendered text size.
      let h = measure(par(text(
        top-edge: "bounds",
        bottom-edge: "bounds",
        [Xg],
      ))).height
      strike(
        stroke: 1.6 * h + fill,
        offset: -0.35 * h,
        extent: 0.05 * h,
        body,
      )
      //debug
      // [#metadata(
      //   (func: "cover-with-rect/inline", pos: cover-args.pos(), named: cover-args.named(), body-func: body.func(), body-type: type(body), inline: inline, repr: repr(body), height: h),
      // )<dbg>]
    }
  } else {
    // For block content and inline math, measure and overlay with stack.
    // Blocks don't need to line-wrap, and inline math is short enough that
    // a single box won't cause overflow issues.  strike doesn't work on math.
    let to-display = layout(layout-size => {
      context {
        // new-body-func is called as new-body-func([Xg]) to measure reference text
        // height.  It must accept a content argument — use par as a safe fallback
        // for math.equation and for elements whose constructor requires non-content
        // args (image, raw, …).  For those, measuring the body itself is used.
        let new-body-func = if body.func() == math.equation {
          par
        } else if body.has("body") or body.func() == text {
          (body.func())
        } else {
          none // image, raw, etc. — measure body directly
        }

        let m-body = body
        if body.func() == align {
          m-body = par(body.body)
        }
        let body-size = measure(m-body)
        let bounding-width = calc.min(body-size.width, layout-size.width)
        let wrapped-body-size = measure(box(m-body, width: bounding-width))

        let named = cover-args.named()
        if "width" not in named {
          named.insert("width", wrapped-body-size.width)
        }
        if "height" not in named {
          named.insert("height", wrapped-body-size.height)
        }
        if "outset" not in named {
          // Only text-like content has ascenders/descenders that extend beyond
          // the measured bounding box and need outset to be fully covered.
          // Non-text elements (rect, block, image, …) measure to their true
          // bounding box, so adding outset would make the cover too tall.
          let is-text-like-body = (
            body.func() in (text, math.equation, par, align)
          )
          if is-text-like-body {
            let real-text-size = if new-body-func != none {
              measure(new-body-func([Xg])).height
            } else {
              measure(body).height
            }
            let top-outset = if inline { 0.35 * real-text-size } else {
              0.15 * real-text-size
            }
            let bottom-outset = if inline { 0.65 * real-text-size } else {
              0.45 * real-text-size
            }
            named.insert("outset", (
              top: top-outset,
              bottom: bottom-outset,
              left: 1pt,
              right: 1pt,
            ))
          } else if _contains-text(body, false) {
            named.insert("outset", if inline { 1pt } else {
              (top: 1pt, bottom: 2pt, left: 1pt, right: 1pt)
            })
          } else {
            // Nothing with an ascender or a descender in it, so it measures to
            // its true bounding box and any margin would show as an outline
            // around the very thing being covered.
            named.insert("outset", 0pt)
          }
        }
        if not inline {
          // Use the measured content width when available; fall back to the full
          // layout width when measure returns 0pt (e.g. tiling-fill elements whose
          // relative width can't resolve inside the measurement context).
          named.at("width") = if wrapped-body-size.width > 0pt {
            wrapped-body-size.width
          } else {
            layout-size.width
          }
        }

        //calculate the extra required padding on top and bottom bc the non-covered text gives this to the layout, but wrapping text twice in a box kills it.
        // this is required when you switch between non-text block to text block or the size changes, but somehow the spacing gets eaten when two large text blocks follow each other, then this is wrong. but we cannot detect that.
        let extra = if (
          (body.has("body") and body.body != none and body.body.func() == text)
            or body.func() in (align, math.equation)
        ) {
          ((1.52 * measure(new-body-func([Xg])).height / text.size) - 1)
        } else { 0 }
        let extra-top = (
          extra * if block.above == auto { par.spacing } else { block.above }
        )
        let extra-bottom = (
          extra * if block.below == auto { par.spacing } else { block.below }
        )

        // Prevent the overlay rect from inheriting outer set rect(stroke: …) rules.
        named.insert("stroke", none)
        stack(
          spacing: -wrapped-body-size.height,
          if body.func() in (align, place) {
            pad(top: extra-top, {
              body
              v(0pt)
            }) //somehow the v element allows text to be the true height even when wrapped in pad.
          } else {
            pad(top: extra-top, body)
          },
          {
            pad(
              rect(
                fill: fill,
                ..named,
                ..cover-args.pos(),
              ),
              bottom: extra-bottom,
            )
          },
        )
        //debug
        // [#metadata(
        //   (
        //     func: "cover-with-rect",
        //     pos: cover-args.pos(),
        //     named: cover-args.named(),
        //     body-func: body.func(),
        //     body-type: type(body),
        //     inline: inline,
        //     repr: repr(body),
        //     height: wrapped-body-size.height,
        //     extra: extra,
        //   ),
        // )<dbg>]
      }
    })
    if inline {
      //inline math comes here, as strike doesn't work on math content
      box(to-display)
    } else {
      // Reconstruct the original block element around the covered content
      // so it preserves native spacing (e.g. skew, figure, etc.).
      to-display
    }
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
  color.oklch().opacify(100%).transparentize(100% - alpha)
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
#let semi-transparent-cover(
  self: none,
  alpha: 85%,
  is-fallback: false,
  ..cover-args,
  body,
) = {
  if not is-fallback {
    warning(
      "Using `semi-transparent-cover` as the main cover method is not recommended as it may produce inconsistent results. Use the `alpha-changing-cover` with its auto fallback instead, which should guarantee a consistent look.",
    )
  }
  cover-with-rect(
    ..cover-args,
    fill: update-alpha(
      if self == none { rgb("#ffffff") } else {
        self.page.at("fill", default: rgb("#ffffff"))
      },
      alpha,
    ),
    body,
  )
}

// -------------------------------------
//   Covering content
// -------------------------------------
//
// Both cover methods walk the same tree. They differ in how a colour is
// derived, and in when they give up and hand an element to `fallback-hide`.
// `color-changing-cover` overwrites every colour with one flat value, which it
// can do without ever reading the colour in force, so it makes no `context`
// call; `alpha-changing-cover` reads the colour that is actually in force and
// fades it.

/// Elements that paint themselves, and so have a fill or a stroke to cover.
/// Some of them also carry a body, which is covered in the ordinary way.
#let _cover-shapes = (
  rect,
  square,
  circle,
  ellipse,
  box,
  block,
  highlight,
  underline,
  overline,
  strike,
  table.cell,
  grid.cell,
  table.hline,
  table.vline,
  grid.hline,
  grid.vline,
  line,
  polygon,
  curve,
  math.cancel,
)


/// Rebuild a stroke with a new paint, keeping its geometry.
///
/// - map-paint (function): `paint => paint`.
///
/// - s (any): The stroke value.
///
/// -> any
#let _restroke(map-paint, s) = {
  if type(s) == color {
    map-paint(s)
  } else if type(s) == stroke {
    let paint = map-paint(if s.paint == auto { black } else { s.paint })
    if paint == none { return s }
    let args = (paint: paint)
    if s.thickness != auto { args.thickness = s.thickness }
    if s.cap != auto { args.cap = s.cap }
    if s.join != auto { args.join = s.join }
    if s.dash != auto { args.dash = s.dash }
    if s.miter-limit != auto { args.miter-limit = s.miter-limit }
    stroke(..args)
  } else { s }
}


/// The fill a shape inherits when it sets none of its own.
///
/// Only meaningful inside `context`, so only the alpha method asks.
///
/// - f (function): The element function.
///
/// -> any
#let _inherited-fill(f) = {
  if f in (rect, square) {
    rect.fill
  } else if f in (circle, ellipse) {
    circle.fill
  } else if f == box {
    box.fill
  } else if f == block {
    block.fill
  } else if f == highlight {
    highlight.fill
  } else if f == table.cell {
    table.cell.fill
  } else if f == grid.cell {
    grid.cell.fill
  } else if f in (polygon, curve) {
    polygon.fill
  }
}


/// The stroke a shape inherits when it sets none of its own.
///
/// - f (function): The element function.
///
/// -> any
#let _inherited-stroke(f) = {
  if f in (rect, square) {
    rect.stroke
  } else if f in (circle, ellipse) {
    circle.stroke
  } else if f == box {
    box.stroke
  } else if f == block {
    block.stroke
  } else if f == line {
    line.stroke
  } else if f == underline {
    underline.stroke
  } else if f == overline {
    overline.stroke
  } else if f == strike {
    strike.stroke
  } else if f == table.cell {
    table.cell.stroke
  } else if f == grid.cell {
    grid.cell.stroke
  } else if f == table.hline {
    table.hline.stroke
  } else if f == table.vline {
    table.vline.stroke
  } else if f == grid.hline {
    grid.hline.stroke
  } else if f == grid.vline {
    grid.vline.stroke
  } else if f in (polygon, curve) {
    polygon.stroke
  } else if f == math.cancel {
    math.cancel.stroke
  }
}


/// Walk `it`, covering as `policy` says.
///
/// `method` is the recolouring to apply to a text leaf. It is threaded rather
/// than read from the policy because it changes on the way down: inside a
/// `styled` node or a list item, an outer `set text` already handles inherited
/// colours, so only a leaf that sets its own may be touched again.
///
/// The chain is exhaustive and mutually exclusive on purpose. A code block in
/// Typst joins every expression in it, so a missing `else` emits content twice.
///
/// - policy (dictionary): See `color-changing-cover` and
///   `alpha-changing-cover`, which are the only two that build one.
///
/// - method (function): The recolouring for a text leaf.
///
/// - it (any): The content to cover.
///
/// -> content
#let _cover-tree(policy, method, it) = {
  let recurse(m, c) = _cover-tree(policy, m, c)
  let relabel(it, result) = {
    let lbl = it.at("label", default: none)
    if lbl == none { result } else { tree.label-it(result, lbl) }
  }

  if type(it) != content {
    it
  } else if (
    it.func() in (text, math.equation)
      or it.func() == tree.typst-builtin-math-symbol
  ) {
    method(it)
  } else if tree.is-sequence(it) {
    it.children.map(c => recurse(method, c)).sum(default: [])
  } else if tree.is-styled(it) {
    tree.reconstruct-styled(
      it,
      (policy.styled-wrap)(recurse(policy.recolour-explicit, it.child)),
    )
  } else if it.func() in _cover-shapes {
    let fields = it.fields()
    let _ = fields.remove("label", default: none)
    let fill = if "fill" in fields { fields.fill } else {
      (policy.inherited-fill)(it.func())
    }
    let painted = fill != none and fill != auto
    let new-fill = if painted { (policy.map-fill)(fill) }
    // A fill this policy cannot express, or one it would flatten together with
    // the content on top of it, goes to the fallback whole.
    if painted and (new-fill == none or policy.hide-filled) {
      relabel(it, (policy.fallback)(it))
    } else {
      let stroke = if "stroke" in fields { fields.stroke } else {
        (policy.inherited-stroke)(it.func())
      }
      if stroke != none and stroke != auto {
        fields.stroke = (policy.map-stroke)(stroke)
      }
      if new-fill != none { fields.fill = new-fill }
      // The body goes positionally: most built-in constructors reject `body:`.
      let body = fields.remove("body", default: none)
      let result = if body == none {
        tree.call-with-fields(it.func(), fields)
      } else {
        tree.call-with-fields(it.func(), fields, recurse(method, body))
      }
      relabel(it, result)
    }
  } else if it.func() in (table, grid) {
    let fields = it.fields()
    let _ = fields.remove("label", default: none)
    let children = fields.remove("children")
    let fill = fields.at("fill", default: none)
    let new-fill = if fill != none and fill != auto { (policy.map-fill)(fill) }
    if new-fill != none { fields.fill = new-fill }
    let stroke = fields.at("stroke", default: none)
    if stroke != none and stroke != auto {
      fields.stroke = (policy.map-stroke)(stroke)
    }
    let result = (it.func())(
      ..fields,
      ..children.map(c => recurse(method, c)),
    )
    // A fill the policy could not express stays as it is, so the whole table
    // has to be covered by the fallback instead.
    relabel(it, if fill != none and new-fill == none {
      (policy.fallback)(result)
    } else { result })
  } else if it.func() in (list.item, enum.item, terms.item, list, enum, terms) {
    // The markers are generated, not part of the tree, so they are covered by
    // the outer `set text` rather than here; explicit-only avoids covering an
    // explicit colour twice.
    tree.rebuild(
      it,
      tree.children-of(it).map(c => recurse(policy.recolour-explicit, c)),
    )
  } else if it.func() == footnote {
    // A footnote's entry is laid out at the bottom of the page, outside the
    // scope of the `set text` that covers the flow, so the colour has to
    // travel with the body instead of being inherited.
    let body = it.at("body", default: none)
    tree.rebuild(it, (
      if type(body) == content {
        (policy.styled-wrap)(recurse(policy.recolour-explicit, body))
      } else { body },
    ))
  } else if it.func() == figure {
    let result = tree.rebuild(
      it,
      tree.children-of(it).map(c => recurse(method, c)),
    )
    // A figure's supplement and counter are generated during layout and never
    // appear in the tree, so the caption needs a show rule of its own.
    (policy.caption-wrap)(result)
  } else if it.func() in (raw, cite, ref) {
    text(fill: (policy.leaf-fill)(), it)
  } else if (
    it.func() in (parbreak, linebreak)
      or tree.is-space(it)
      or tree.is-metadata(
        it,
      )
  ) {
    it
  } else if tree.children-of(it).len() > 0 {
    tree.rebuild(it, tree.children-of(it).map(c => recurse(method, c)))
  } else {
    (policy.fallback)(it)
  }
}


/// White at the alpha that fades a shape to the same lightness the covered
/// text ends up with, so a shape that cannot be recoloured is dimmed to match
/// rather than left bright or hidden outright.
///
/// Reads `text.fill`, so it must be called inside `context`.
///
/// - color (color): The colour covered text is forced to.
///
/// -> color
#let _flat-overlay-fill(color) = {
  let luma-of(c) = {
    let parts = c.components(alpha: false)
    if parts.len() == 1 { parts.at(0) } else {
      0.299 * parts.at(0) + 0.587 * parts.at(1) + 0.114 * parts.at(2)
    }
  }
  let text-luma = if type(text.fill) == std.color { luma-of(text.fill) } else {
    0%
  }
  update-alpha(rgb("#ffffff"), calc.abs(luma-of(color) - text-luma))
}


/// Cover content by forcing every colour to one flat colour.
///
/// A compiler-light alternative to `alpha-changing-cover`: it overwrites
/// colours rather than reading them, so it makes no `context` call.
///
/// Example: `config-methods(cover: utils.color-changing-cover.with(color: gray))`
///
/// - color (color): The colour to force on covered content. Default is `gray`.
///
/// - hide-filled (bool): Whether an element that paints its own background is
///   handed to `fallback-hide` instead of being recoloured. Flattening such an
///   element and the content on top of it to a single colour would leave the
///   content unreadable, so this defaults to `true`. Set it to `false` to
///   recolour them like everything else. Applies to images, rect, ... so that content is still visible.
///
/// - fallback-hide (func): Applied to what cannot be recoloured, such as
///   images, and to filled elements while `hide-filled` is on. `auto` overlays
///   them so they dim to match the recoloured text instead of disappearing.
///   Pass `none` to leave them untouched.
///
/// - fallback-hide-args (dict): Extra named arguments for `fallback-hide`.
///
/// - it (content): The content to cover.
///
/// -> content
#let color-changing-cover(
  self: none,
  color: gray,
  hide-filled: true,
  fallback-hide: auto,
  fallback-hide-args: (:),
  it,
) = {
  let recolour-fields(fields) = {
    if "fill" in fields and type(fields.fill) in (std.color, gradient) {
      fields.fill = color
    }
    if (
      "stroke" in fields and fields.stroke != none and fields.stroke != auto
    ) {
      fields.stroke = _restroke(_ => color, fields.stroke)
    }
    fields
  }
  let rebuild-text(it) = {
    let fields = it.fields()
    let lbl = fields.remove("label", default: none)
    let body = fields.remove("body", default: none)
    fields = recolour-fields(fields)
    let result = if body == none { text(..fields) } else {
      text(..fields, body)
    }
    if lbl == none { result } else { tree.label-it(result, lbl) }
  }
  let sets-own-colour(it) = {
    let fields = it.fields()
    (
      ("fill" in fields and type(fields.fill) in (std.color, gradient))
        or (
          "stroke" in fields and fields.stroke != none and fields.stroke != auto
        )
    )
  }
  // Leaving a leaf that sets no colour of its own alone matters: wrapping it
  // in a fresh `text(..)` splits it out of the run it was shaped in, which
  // moves smart quotes and kerning.
  let explicit-only(it) = {
    if it.func() == text and sets-own-colour(it) { rebuild-text(it) } else {
      it
    }
  }

  let policy = (
    recolour-explicit: explicit-only,
    styled-wrap: inner => {
      set text(fill: color)
      inner
    },
    map-fill: value => if type(value) in (std.color, gradient) { color },
    map-stroke: value => _restroke(_ => color, value),
    inherited-fill: _ => none,
    inherited-stroke: _ => none,
    leaf-fill: () => color,
    caption-wrap: result => {
      show figure.caption: set text(fill: color)
      result
    },
    hide-filled: hide-filled,
  )

  let run(fallback) = {
    let policy = policy
    policy.fallback = fallback
    set text(fill: color)
    _cover-tree(
      policy,
      // A leaf that sets no colour of its own is left exactly as it is: the
      // `set text` above already reaches it, and wrapping it in anything
      // splits it out of the run it was shaped in, which moves smart quotes
      // and kerning.
      it => if it.func() == text and sets-own-colour(it) {
        rebuild-text(it)
      } else { it },
      it,
    )
  }

  if fallback-hide == none {
    run(it => it)
  } else if fallback-hide == auto {
    // The only `context` this method uses, and the overlay has to be measured
    // out here: inside `run`, `set text(fill: color)` makes `text.fill` report
    // the cover colour and the overlay comes out fully transparent.
    context {
      let overlay = _flat-overlay-fill(color)
      run(it => cover-with-rect(
        fill: overlay,
        inline: type(it) == content and it.func() == box,
        it,
      ))
    }
  } else {
    run(fallback-hide.with(..fallback-hide-args))
  }
}


/// Cover content by fading every colour towards transparency.
///
/// Reads the colour actually in force and lowers its alpha, so covered content
/// keeps its own hues. That costs `context` calls; `color-changing-cover` is
/// the cheaper option if compile time matters, at the price of a flat look.
///
/// Note: this covers ordinary Typst content. Diagram packages such as cetz
/// paint outside it and are handled by `fallback-hide`.
///
/// Example: `config-methods(cover: utils.alpha-changing-cover.with(alpha: 25%))`
///
/// - alpha (ratio): The opacity to fade covered colours to. Default is `25%`.
///
/// - fallback-hide (func): Applied to what cannot be faded, such as images and
///   tiling fills. `auto` overlays them with `semi-transparent-cover` so they
///   match the surrounding fade. Pass `none` to leave them untouched.
///
/// - fallback-hide-args (dict): Extra named arguments for `fallback-hide`.
///
/// - it (content): The content to cover.
///
/// -> content
#let alpha-changing-cover(
  self: none,
  alpha: 25%,
  fallback-hide: auto,
  fallback-hide-args: (:),
  it,
) = context {
  let fallback = if fallback-hide == none {
    it => it
  } else if fallback-hide == auto {
    semi-transparent-cover.with(
      self: self,
      alpha: 100% - alpha,
      is-fallback: true,
    )
  } else {
    fallback-hide.with(..fallback-hide-args)
  }

  // A gradient has no `fields()`, so it is taken apart and put back together.
  let fade-gradient(g) = {
    let stops = g.stops().map(s => (update-alpha(s.first(), alpha), s.last()))
    let kind = g.kind()
    if kind == gradient.linear {
      gradient.linear(
        ..stops,
        space: g.space(),
        relative: g.relative(),
        angle: g.angle(),
      )
    } else if kind == gradient.radial {
      gradient.radial(
        ..stops,
        space: g.space(),
        relative: g.relative(),
        center: g.center(),
        radius: g.radius(),
        focal-center: g.focal-center(),
        focal-radius: g.focal-radius(),
      )
    } else {
      gradient.conic(
        ..stops,
        space: g.space(),
        relative: g.relative(),
        angle: g.angle(),
        center: g.center(),
      )
    }
  }
  let fade(value) = {
    if type(value) == std.color {
      update-alpha(value, alpha)
    } else if type(value) == gradient {
      fade-gradient(value)
    }
  }

  let sets-own-colour(it) = {
    let fields = it.fields()
    (
      ("fill" in fields and type(fields.fill) in (std.color, gradient))
        or (
          "stroke" in fields and fields.stroke != none and fields.stroke != auto
        )
    )
  }
  let rebuild-text(it) = {
    let fields = it.fields()
    let lbl = fields.remove("label", default: none)
    let body = fields.remove("body", default: none)
    if "fill" in fields and type(fields.fill) in (std.color, gradient) {
      fields.fill = fade(fields.fill)
    }
    if (
      "stroke" in fields and fields.stroke != none and fields.stroke != auto
    ) {
      fields.stroke = _restroke(fade, fields.stroke)
    }
    let result = if body == none { text(..fields) } else {
      text(..fields, body)
    }
    if lbl == none { result } else { tree.label-it(result, lbl) }
  }
  let explicit-only(it) = {
    if it.func() == text and sets-own-colour(it) { rebuild-text(it) } else {
      it
    }
  }

  let policy = (
    recolour-explicit: explicit-only,
    styled-wrap: inner => context {
      // Read the colour after the wrapper's own rules have applied, then fade
      // it as the innermost rule, which is the one that wins.
      set text(
        fill: if type(text.fill) in (std.color, gradient) {
          fade(text.fill)
        } else {
          text.fill
        },
        stroke: if text.stroke == none { text.stroke } else {
          _restroke(fade, text.stroke)
        },
      )
      inner
    },
    map-fill: fade,
    map-stroke: value => _restroke(fade, value),
    inherited-fill: _inherited-fill,
    inherited-stroke: _inherited-stroke,
    leaf-fill: () => fade(text.fill),
    caption-wrap: result => context {
      show figure.caption: set text(fill: fade(text.fill))
      result
    },
    fallback: fallback,
    hide-filled: false,
  )

  set text(fill: fade(text.fill))
  _cover-tree(
    policy,
    it => if it.func() == text and sets-own-colour(it) {
      rebuild-text(it)
    } else { it },
    it,
  )
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


/// Runtime half of `#animate` — see its docstring for the model. Called
/// through `touying-fn-wrapper`, so it receives `self` and can read
/// `self.subslide` and the slide's waypoints.
///
/// - effects (array): Normalized effect entries, each a dictionary with
///   `effect`, `subslides` and `priority` keys.
///
/// - body (content): The content being animated.
///
/// - alignment (alignment): Where `body` itself sits inside the reserved box,
///   when one is needed. Each swap carries its own alignment.

///
/// - resolved-subslides (array, none): Per-effect specs with `"h"` already
///   substituted, supplied by the `last-subslide` callback at placement time.
///
/// -> content
#let animate(
  self: none,
  effects: (),
  alignment: top + left,
  resolved-subslides: none,
  body,
) = {
  // Each effect's spec, resolved once. `resolved-subslides`, when present,
  // runs parallel to `effects` and carries each spec with its "h" already
  // replaced by the placement-time repetitions counter.
  let specs = effects
    .enumerate()
    .map(((i, eff)) => resolve-waypoints(
      self,
      if resolved-subslides != none {
        resolved-subslides.at(i)
      } else { eff.subslides },
    ))

  // What applies at subslide `idx`: the one winning placement, and the styles
  // to nest around it. Both come back tagged with the index of the effect they
  // came from, so that a configuration can be identified without comparing
  // content.
  let resolve-at(idx) = {
    let active = effects
      .enumerate()
      .filter(((i, _)) => check-visible(idx, specs.at(i)))

    // Placements are resolved, never composed: the cover method is `hide`,
    // which is not a style node, and "remove" drops the content outright, so
    // nothing nested inside either could undo it. The implicit default sits at
    // priority 0 and effects default to priority 1, so writing any placement
    // at all replaces it; among the rest the highest priority wins, ties going
    // to the last one written.
    let winner = active
      .filter(((_, eff)) => _is-placement(eff.effect))
      .fold((-1, (effect: "show", priority: 0)), (best, it) => {
        if it.last().priority >= best.last().priority { it } else { best }
      })

    // Styles all apply, nesting innermost-first. Reversed before grouping, so
    // that within one priority the *last* style written ends up innermost and
    // therefore wins any property the two of them both set - matching the way
    // a later placement wins its own tie. Grouped by priority explicitly
    // rather than sorted, so the within-priority order does not depend on
    // `array.sorted` being stable.
    let style-entries = active
      .filter(((_, eff)) => not _is-placement(eff.effect))
      .rev()
    let styles = ()
    for p in style-entries.map(((_, eff)) => eff.priority).dedup().sorted() {
      styles += style-entries.filter(((_, eff)) => eff.priority == p)
    }
    (winner, styles)
  }

  let apply-styles(styles, cont) = {
    for (_, eff) in styles {
      cont = (eff.effect)(cont, self: self)
    }
    cont
  }

  // The content a configuration puts on the page, or `none` where it puts
  // nothing. `reserving-only` additionally drops what does not lay claim to
  // space: a swap only reserves when it asks to stretch.
  let render(config, reserving-only: false) = {
    let ((_, winner), styles) = config
    let eff = winner.effect
    if eff == "remove" {
      none
    } else if _is-swap(eff) {
      if reserving-only and not eff.stretch {
        none
      } else {
        (apply-styles(styles, eff.body), eff.alignment)
      }
    } else if eff == "cover" {
      ((self.methods.cover)(self: self, apply-styles(styles, body)), alignment)
    } else {
      (apply-styles(styles, body), alignment)
    }
  }

  let here = render(resolve-at(self.subslide))

  // Measuring costs a `context` and a pass over the slide's subslides, so it
  // only happens once some swap actually asks to stretch. Everything else —
  // show, cover, remove, and swaps that let the layout reflow — needs no
  // reserved size at all: the cover method already preserves layout by itself.
  if not effects.any(eff => _is-swap(eff.effect) and eff.effect.stretch) {
    if here != none { here.first() }
  } else if here == none {
    // Removed here, so nothing to place — the reservation is moot.
  } else {
    context {
      // Walk the slide's subslides and measure what each *distinct*
      // configuration reserves. Distinct is by which effects are in play, not
      // by the content they produce, so a style that is active across five
      // subslides is measured once. Measuring the styled result (rather than
      // the bare body) is the point: a style that changes the size would
      // otherwise be left out of the reservation it belongs in.
      let seen = ()
      let sizes = ()
      for idx in range(1, calc.max(self.at("repeat", default: 1), 1) + 1) {
        let config = resolve-at(idx)
        let ((wi, _), styles) = config
        let key = (wi,) + styles.map(((i, _)) => i)
        if key in seen {
          continue
        }
        seen.push(key)
        let reserved = render(config, reserving-only: true)
        if reserved != none {
          sizes.push(measure(reserved.first()))
        }
      }
      if sizes.len() == 0 {
        here.first()
      } else {
        box(
          width: calc.max(..sizes.map(sz => sz.width)),
          height: calc.max(..sizes.map(sz => sz.height)),
          align(here.last(), here.first()),
        )
      }
    }
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

/// Display list, enum, or terms items one by one with animation and styling.
/// For more details see `utils.item-by-item`.
///
/// - start (int, label, str, dictionary): The starting subslide number or waypoint.
/// - fn (function): A function that gets `(idx, it)` and returns the styled item content for the item at the relative index `idx` (may be negative if it was revealed already)
/// - cont (content): The content containing the items to display.
/// -> content
#let item-by-item-fn(self: none, start: 1, fn, cont) = {
  if fn == none {
    fn = (idx, it) => it
  }
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

  if tree.is-styled(cont) {
    return tree.reconstruct-styled(
      cont,
      item-by-item-fn(self: self, start: start, fn, cont.child),
    )
  }

  if tree.is-sequence(cont) {
    let meaningful = cont.children.filter(c => c not in tree.empty-contents)
    if (
      meaningful.len() == 1
        and (
          tree.is-styled(meaningful.first())
            or tree.is-sequence(
              meaningful.first(),
            )
        )
    ) {
      // A `#set` at the top of the body leaves the items inside a lone
      // `styled` child; animate that instead of treating it as one item.
      let inner = item-by-item-fn(
        self: self,
        start: start,
        fn,
        meaningful.first(),
      )
      let at = cont.children.position(c => c not in tree.empty-contents)
      return cont
        .children
        .enumerate()
        .map(((i, c)) => if i == at { inner } else { c })
        .sum(default: [])
    }
    // Markup list/enum/terms: items appear as list.item/enum.item/terms.item in a sequence
    let item-count = 0
    let result = ()
    for child in cont.children {
      if type(child) == content and child.func() in item-funcs {
        if check-visible(self.subslide, (beginning: start + item-count)) {
          result.push(fn(start + item-count - self.subslide, child))
        } else {
          result.push(fn(start + item-count - self.subslide, cover(child)))
        }
        item-count += 1
      } else {
        result.push(fn(start + item-count - self.subslide, child))
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
          fn(start + idx - self.subslide, item)
        } else {
          tree.rebuild(item, (
            fn(start + idx - self.subslide, cover(
              item.body,
            )),
          ))
        }
      })
    tree.reconstruct-table-like(cont, new-items)
  } else if cont.func() == terms {
    // Programmatic terms container
    let new-items = cont
      .children
      .enumerate()
      .map(((idx, item)) => {
        if check-visible(self.subslide, (beginning: start + idx)) {
          fn(start + idx - self.subslide, item)
        } else {
          tree.rebuild(item, (
            fn(start + idx - self.subslide, cover(item.term)),
            fn(start + idx - self.subslide, cover(item.description)),
          ))
        }
      })
    tree.reconstruct-table-like(cont, new-items)
  } else {
    // Fallback: show content as-is
    cont
  }
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
  item-by-item-fn(self: self, start: start, (idx, it) => it, cont)
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
    show-notes-on-second-screen in (none, top, bottom, left, right),
    message: "`show-notes-on-second-screen` should be `none`, `top`, `bottom`, "
      + "`left` or `right`",
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
    fr: "Plan",
    ja: "目次",
    pl: "Agenda",
    ru: "Содержание",
    zh-TW: "目錄",
    zh: "目录",
  )
  mapping.at(text.lang, default: mapping.en)
}

/// Every name Typst knows is parsed; a single word it does not know becomes a
/// string, so shell-friendly input needs no quoting.
///
/// "Knows" means a `std` binding (`red`, `left`, `calc`, ..), one of the keywords
/// that are not bindings (`true`, `false`, `none`, `auto`), or a number, with or
/// without a unit. Everything else that is a single bare word - letters, digits,
/// `_` and `-` - is returned verbatim; anything else at all goes through `eval`.
#let _std-names = dictionary(std).keys()

#let _parse-input(value) = {
  if value == none {
    return none
  }
  let known = (
    value in _std-names
      or value in ("true", "false", "none", "auto")
      or value.match(
        regex("^-?\\d+(\\.\\d+)?(e-?\\d+)?(pt|mm|cm|in|em|deg|rad|fr|%)?$"),
      )
        != none
  )
  if not known and value.match(regex("^[\\p{L}\\p{N}_\\-]+$")) != none {
    return value
  }
  eval(value)
}

/// *Returns input given to the compiler.*
///
/// Anything Typst knows is parsed as Typst: `red` is a colour, `left` an alignment,
/// `3` and `2em` numbers, `true`/`false`/`none`/`auto` keywords, and dictionaries,
/// arrays and function calls all work. A single word Typst does *not* know becomes
/// a string, so `--input export-mode=handout` needs no shell quoting.
///
/// Example:
/// `typst compile --input export-mode=handout myslide.typ` \
/// Then in the code you can do:
/// `#let export-mode = utils.get-input(key: "export-mode")`
///
/// Example 2:
/// `typst compile FILE --input config='("foo": 1, "bar": [1, 2, 3], "baz": ("nested": 4))'`
///
/// You may also provide no key to get the entire inputs dictionary with parsed values:
/// `#let inputs = utils.get-input()`
///
/// - key (str, none): The input key to retrieve. If `none`, returns the entire inputs dictionary with parsed values.
///
/// -> any
#let get-input(key: none) = {
  if key == none {
    let values = (:)
    for key in sys.inputs.keys() {
      if key == "x-preview" { continue } // skip tinymist preview input
      values.insert(key, _parse-input(sys.inputs.at(key, default: none)))
    }
    values
  } else {
    _parse-input(sys.inputs.at(key, default: none))
  }
}


/// Rescale an image element to fit within a column-fraction of the available content width.
///
/// - img-el (content): The raw image element — used only for measuring its declared `width`.
/// - display-el (content): The element that is actually rendered (may be `img-el` itself, or a figure containing it).
/// - col-fraction (ratio): Fraction of `container-width` this image should occupy (e.g. `40%` → `0.4`).
/// - container-width (none, length): The available content-area width in points. When `none` (default), it is measured automatically via `layout()`.
/// - align-direction (alignment): `left` or `right` — which side the image is placed on.
///
/// -> content
#let rescale-image(
  img-el,
  display-el,
  col-fraction,
  align-direction,
  container-width: none,
) = {
  let _render(cw) = {
    let obstacle-width = (col-fraction * 1pt).pt() * cw

    let img-width = img-el.fields().at("width", default: none)
    let p = if img-width != none and type(img-width) == relative {
      (img-width.ratio * 1pt).pt()
    } else if img-width != none and type(img-width) == ratio {
      (img-width * 1pt).pt()
    } else {
      1.0
    }
    let inv = if p > 0 { 1.0 / p } else { 1.0 }

    let overlay(..args) = {
      box(place(
        top + (if align-direction == right { left } else { right }),
        ..args,
      ))
      sym.wj
      h(0pt, weak: true)
    }

    let visible-width = obstacle-width * inv * 0.95
    let dx-offset = obstacle-width * inv * 0.025
    let img-size = measure(display-el, width: visible-width)
    let other-direction = if align-direction == right { 1 } else { -1 }

    stack(
      spacing: -par.leading,
      overlay(
        box(width: visible-width, display-el),
        dy: -par.leading,
        dx: dx-offset * other-direction,
      ),
      hide(box(width: obstacle-width, height: img-size.height)),
    )
  }

  if container-width != none {
    _render(container-width)
  } else {
    layout(size => _render(size.width))
  }
}

#let dbg(val) = [#metadata(repr(val))<dbg>]

#let _parse-nav-symbol(s, target, other) = {
  if type(s) == dictionary {
    let d = s
    if target in d {
      let td = d.at(target)
      let res = _parse-nav-symbol(td, target, other)
      if res.left != none or res.right != none { return res }
    }
    if other in d {
      let od = d.at(other)
      let res = _parse-nav-symbol(od, target, other)
      if res.left != none or res.right != none { return res }
    }
    let res = (left: none, right: none)
    if "left" in d { res.left = d.left }
    if "right" in d { res.right = d.right }
    if res.left == none and res.right != none {
      res.left = scale(x: -100%, res.right)
    }
    if res.right == none and res.left != none {
      res.right = scale(x: -100%, res.left)
    }
    return res
  }

  if type(s) != symbol {
    return (left: s, right: scale(x: -100%, s))
  }

  let r = repr(s)
  let has(m) = "\"" + m + "\"" in r or "(\"" + m + "\"" in r

  if target == "filled" {
    if has("filled.l") and has("filled.r") {
      return (left: s.filled.l, right: s.filled.r)
    }
    if has("l.filled") and has("r.filled") {
      return (left: s.l.filled, right: s.r.filled)
    }
    if has("filled") {
      return (left: scale(x: -100%, s.filled), right: s.filled)
    }

    if has("stroked.l") and has("stroked.r") {
      return (left: s.stroked.l, right: s.stroked.r)
    }
    if has("l.stroked") and has("r.stroked") {
      return (left: s.l.stroked, right: s.r.stroked)
    }
    if has("stroked") {
      return (left: scale(x: -100%, s.stroked), right: s.stroked)
    }
  } else {
    if has("stroked.l") and has("stroked.r") {
      return (left: s.stroked.l, right: s.stroked.r)
    }
    if has("l.stroked") and has("r.stroked") {
      return (left: s.l.stroked, right: s.r.stroked)
    }
    if has("stroked") {
      return (left: scale(x: -100%, s.stroked), right: s.stroked)
    }

    if has("filled.l") and has("filled.r") {
      return (left: s.filled.l, right: s.filled.r)
    }
    if has("l.filled") and has("r.filled") {
      return (left: s.l.filled, right: s.r.filled)
    }
    if has("filled") {
      return (left: scale(x: -100%, s.filled), right: s.filled)
    }
  }

  if has("l") and has("r") { return (left: s.l, right: s.r) }

  return (left: s, right: scale(x: -100%, s))
}

/// Takes in a symbol or a dictionary of symbols and
/// emits a 2d dict for filled|stroked-styled x left|right-orientated symbols,
/// usable as a set of navigation symbols.
///
/// The dict may compose multiple different symbols and
/// the function will try to fill in the gaps as best as possible.
///
/// - symbol (symbol|dictionary): the symbol to build the variants for.
/// -> dictionary
#let create-nav-symbols(symbol) = {
  if type(symbol) == dictionary {
    let allowed = ("filled", "stroked", "left", "right")
    for k in symbol.keys() {
      if k not in allowed {
        panic(
          "Invalid key in nav symbols dictionary: "
            + k
            + ". Expected 'filled', 'stroked', 'left', or 'right'.",
        )
      }
    }
  }

  let nav-symbols = (
    filled: _parse-nav-symbol(symbol, "filled", "stroked"),
    stroked: _parse-nav-symbol(symbol, "stroked", "filled"),
  )

  return nav-symbols
}


// -------------------------------------
// Moved to core/tree.typ in 0.8.0
// -------------------------------------
//
// A deprecation warning is content, and Typst only reports it once that
// content is laid out, so only the functions that return content can carry
// one. The rest have to say so by refusing to run.

#let _moved(name) = panic(
  "`utils." + name + "` moved to `core.tree` in 0.8.0.",
)

#let typst-builtin-sequence = tree.typst-builtin-sequence
#let typst-builtin-styled = tree.typst-builtin-styled
#let typst-builtin-space = tree.typst-builtin-space
#let typst-builtin-math-symbol = tree.typst-builtin-math-symbol

#let is-sequence(..) = _moved("is-sequence")
#let is-styled(..) = _moved("is-styled")
#let is-space(..) = _moved("is-space")
#let is-math-symbol(..) = _moved("is-math-symbol")
#let is-metadata(..) = _moved("is-metadata")
#let is-kind(..) = _moved("is-kind")
#let is-heading(..) = _moved("is-heading")
#let trim(..) = _moved("trim")
#let sequence-to-array(..) = _moved("sequence-to-array")
#let positional-fields(..) = _moved("positional-fields")

// -------------------------------------
// Moved to core/subslides.typ and core/waypoints.typ in 0.8.0
// -------------------------------------

#let _moved-to(name, module) = panic(
  "`utils." + name + "` moved to touying's `core." + module + " in 0.8.0.",
)

#let check-visible(..) = _moved-to("check-visible", "subslides")
#let last-required-subslide(..) = _moved-to(
  "last-required-subslide",
  "subslides",
)
#let resolve-waypoints(..) = _moved-to("resolve-waypoints", "waypoints")

#let _deprecated(name, fn, extra: "") = (..args) => {
  tree._deprecation-warning("utils." + name, "0.9.0", extra: extra)
  fn(..args)
}

#let label-it = _deprecated(
  "label-it",
  tree.label-it,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
#let call-with-fields = _deprecated(
  "call-with-fields",
  tree.call-with-fields,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
#let reconstruct = _deprecated(
  "reconstruct",
  tree.reconstruct,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
#let reconstruct-table-like = _deprecated(
  "reconstruct-table-like",
  tree.reconstruct-table-like,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
#let reconstruct-styled = _deprecated(
  "reconstruct-styled",
  tree.reconstruct-styled,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
#let reconstruct-heading = _deprecated(
  "reconstruct-heading",
  tree.reconstruct-heading,
  extra: "The function moved to `core.tree` in v0.8.0.",
)
