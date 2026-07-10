#import "../utils.typ"
#import "../extern.typ"

/// ------------------------------------------------
/// Slide block functions via metadata markers
/// (speaker notes, alerts, animated equations/code/reducers)
/// ------------------------------------------------

// A raw version of `touying-fn-wrapper` that does not support `last-subslide` and `repetitions`.
// It is for wrapping functions that should be affected by the repetition counter surrounding them.
// e.g. `utils.alert`
//
// - fn (function): The function that will be called like `(self: none, ..args) => { .. }`.
//
// - args: The arguments to pass to the function. E.g. content
//
// -> content
#let touying-fn-wrapper-raw(
  fn,
  ..args,
) = [#metadata((
  kind: "touying-fn-wrapper-raw",
  fn: fn,
  args: args,
))<touying-temporary-mark>]


/// Speaker notes are a way to add additional information to your slides that is not visible to the audience. This can be useful for providing additional context or reminders to yourself.
///
/// Multiple calls on the same slide are combined (accumulated), so all notes are shown together.
///
/// Example:
///
/// ```typ
/// #speaker-note[This is a speaker note]
/// ```
///
/// - mode (str): The mode of the markup text, either `typ` or `md`. Default is `typ`.
///
/// - setting (function): A function that takes the note as input and returns a processed note.
///
/// - subslide (none, auto, int, array, str): Restricts the note to specific subslides, similar to `only`.
///   - `auto` (default): automatically determined from the current pause position. A note placed after `#pause` will automatically appear only from that subslide onward.
///   - `none`: shown on all subslides regardless of position.
///   - int, array, or string: shown only on the specified subslides.
///
/// - note (content): The content of the speaker note. May contain `#pause` to reveal parts progressively.
///
/// -> content
#let speaker-note(
  mode: "typ",
  setting: it => it,
  subslide: auto,
  note,
) = [#metadata((
  kind: "touying-speaker-note",
  mode: mode,
  setting: setting,
  subslide: subslide,
  note: note,
))<touying-temporary-mark>]


/// Alert is a way to display a message to the audience. It can be used to draw attention to important information or to provide instructions.
///
/// -> content
#let alert(body) = touying-fn-wrapper-raw(utils.alert, body)


/// Animated math equation. Use `pause` and `meanwhile` inside the equation body to reveal terms step by step.
///
/// Write the equation as a raw block (backtick string) or a plain string. Use `pause` (without backslash or `#`) as a pseudo-command inside the equation to insert a pause marker.
///
/// - block (bool): Whether the equation is a block element. Default is `true`.
///
/// - numbering (none, str): The numbering of the equation. Default is `none`.
///
/// - supplement (auto, str): The supplement of the equation. Default is `auto`.
///
/// - scope (dictionary): Extra bindings passed to `eval()` when the body is a string or raw block.
///
/// - body (str, content, function): The equation content. Accepts a raw block (e.g. `` `f(x) = pause x^2` ``), a plain string, or a callback `self => str`.
///
/// -> content
#let touying-equation(
  block: true,
  numbering: none,
  supplement: auto,
  scope: (:),
  body,
) = [#metadata((
  kind: "touying-equation",
  block: block,
  numbering: numbering,
  supplement: supplement,
  scope: scope,
  body: {
    if type(body) == function {
      body
    } else if type(body) == str {
      body
    } else if type(body) == content and body.has("text") {
      body.text
    } else {
      panic("Unsupported type: " + str(type(body)))
    }
  },
))<touying-temporary-mark>]


/// Touying can integrate with `mitex` to display math equations.
/// You can use `#touying-mitex` to display math equations with pause and meanwhile.
///
/// Example:
///
/// ```typst
/// #touying-mitex(mitex, `
///   f(x) &= \pause x^2 + 2x + 1  \\
///       &= \pause (x + 1)^2  \\
/// `)
/// ```
///
/// - mitex (function): The mitex function. You can import it by code like `#import "@preview/mitex:0.2.6": mitex`.
///
/// - block (bool): Whether the equation is a block element. Default is `true`.
///
/// - numbering (none, str): The numbering of the equation. Default is `none`.
///
/// - supplement (auto, str): The supplement of the equation. Default is `auto`.
///
/// - body (string, content, function): The content of the equation. It should be a string, a raw text, or a function that receives `self` as an argument and returns a string.
///
/// -> content
#let touying-mitex(
  block: true,
  numbering: none,
  supplement: auto,
  mitex,
  body,
) = [#metadata((
  kind: "touying-mitex",
  block: block,
  numbering: numbering,
  supplement: supplement,
  mitex: mitex,
  body: {
    if type(body) == function {
      body
    } else if type(body) == str {
      body
    } else if type(body) == content and body.has("text") {
      body.text
    } else {
      panic("Unsupported type: " + str(type(body)))
    }
  },
))<touying-temporary-mark>]


/// Animated code block. Use a comment-style `pause` or `meanwhile` on its own line to insert animation markers.
///
/// A line is treated as a `pause` or `meanwhile` marker when its only
/// meaningful characters (letters, digits, CJK) exactly spell "pause" or
/// "meanwhile". For example, `// pause`, `# pause`, and `#pause` are all
/// valid markers, while `pause = 1` or `def pause():` are not.
///
/// - block (bool): Whether the raw block is a block element. Default is `true`.
///
/// - lang (none, str): The language for syntax highlighting. When `none`, the language is inferred from the raw block body if possible. Default is `none`.
///
/// - fill-empty-lines (bool): Whether to replace hidden lines with empty lines to preserve the layout of visible lines. Default is `true`.
///
/// - simple (bool): When `true`, use `#pause;` and `#meanwhile;` as direct split markers (similar to how `touying-mitex` uses `\pause`). Default is `false`.
///
/// - body (str, content, function): The raw code content. Can be a raw block, a string, or a function receiving `self` as an argument.
///
/// -> content
#let touying-raw(
  block: true,
  lang: none,
  fill-empty-lines: true,
  simple: false,
  body,
) = [#metadata((
  kind: "touying-raw",
  block: if type(body) == content and body.has("block") { body.block } else {
    block
  },
  lang: if lang == none and type(body) == content and body.has("lang") {
    body.lang
  } else {
    lang
  },
  fill-empty-lines: fill-empty-lines,
  simple: simple,
  body: {
    if type(body) == function {
      body
    } else if type(body) == str {
      body
    } else if type(body) == content and body.has("text") {
      body.text
    } else {
      panic("Unsupported type: " + str(type(body)))
    }
  },
))<touying-temporary-mark>]


/// Extend external packages with `pause` and `meanwhile` animation support.
///
/// Wraps an external drawing/diagram function (like `cetz.canvas` or `fletcher.diagram`) so that Touying can intercept `pause`/`meanwhile` markers inside its content array and hide/cover items across subslides.
///
/// Define package-specific wrappers once at the top of your document:
///
/// ```typst
/// // CeTZ
/// #let cetz-canvas = touying-reduce.with(cetz)
///
/// // Fletcher
/// #let fletcher-diagram = touying-reduce.with(fletcher)
/// ```
///
/// - reduce (function): The external drawing function. It should accept an array of drawing commands and return rendered content (e.g. `cetz.canvas` or `fletcher.diagram`).
///
/// - cover (function): Called with a drawing command when that command should be hidden on the current subslide. Should produce invisible but space-preserving content (e.g. `cetz.draw.hide.with(bounds: true)` or `fletcher.hide`).
///
/// - label (none, str, label): An optional label to identify the graphic for later recall via `touying-recall`. A string is converted to a label automatically.
///
/// - args (arguments): The positional and named arguments passed to the `reduce` function.
///
/// -> content
#let touying-reducer(
  reduce: arr => arr.sum(),
  cover: arr => none,
  label: none,
  ..args,
) = {
  // std.label: the `label` parameter shadows Typst's own `label()` constructor.
  //
  // Note: this must stay a single metadata node, not a sequence of two — a
  // sequence here would nest one level deeper than the parser's dispatch
  // loop flattens, so neither node would ever be individually recognized.
  // The label-only-on-last-subslide breadcrumb for touying-recall is
  // instead emitted by the parser's own "touying-reducer" dispatch case
  // (src/core/parser.typ), alongside the rendered content, at the point
  // where a single "child" is already being pushed to the result array.
  let real-label = if type(label) == str { std.label(label) } else { label }
  [#metadata((
    kind: "touying-reducer",
    reduce: reduce,
    cover: cover,
    kwargs: args.named(),
    args: args.pos(),
    label: real-label,
  ))<touying-temporary-mark>]
}

/// Automatically reduces the content with the given package and given or predefined bindings. Only works if the package exposes the bindings or its name and touying defines the bindings for the name.
///
/// Usage:
/// ```typst
/// #touying-reduce(cetz, {
///   import cetz.draw: *
///
///   rect((0,0), (5,5))
///   (pause,)
///   rect((0,0), (1,1))
///   rect((1,1), (2,2))
///   rect((2,2), (3,3))
///   (pause,)
///   line((0,0), (2.5, 2.5), name: "line")
/// })
/// ```
///
/// - package (module): The external package to integrate with touying. It should expose its name for auto-binding to work (e.g. `cetz`).
/// - bindings (dictionary): Optional explicit bindings for the reduce and cover functions. Should be a dictionary with keys `reduce` and `cover`, where the values are paths (as arrays of strings) with an optionally last entry being arguments to pass to the function. If any fields are `none`, it checks whether the package has `touying-reducer-bindings` otherwise touying will look up predefined bindings in `extern.auto-reducer-bindings` based on the package name.
/// - args (arguments): The positional and named arguments passed to the reduce function.
/// -> content
#let touying-reduce(package, bindings: (reduce: none, cover: none), ..args) = {
  assert(
    type(package) == module,
    message: "Package for reduce() must be a module. Got: " + repr(package),
  )
  let pckg = dictionary(package)

  let parse-binding(pckg, binding) = {
    //base case without arguments
    if binding.len() == 0 {
      return pckg
    }
    let curr = binding.remove(0)
    if type(curr) == arguments and binding.len() == 0 {
      pckg.with(..curr)
    } else if type(curr) == str {
      parse-binding(dictionary(pckg).at(curr), binding)
    } else {
      panic(
        "Invalid binding for reduce(): expected a path of strings leading to a function, with an optional last argument, got "
          + repr(binding),
      )
    }
  }
  assert(
    type(bindings) == dictionary
      and "reduce" in bindings.keys()
      and "cover" in bindings.keys(),
    message: "Invalid `bindings` passed to `touying-reduce()`: expected a dictionary with keys 'reduce' and 'cover', got "
      + repr(bindings),
  )
  if bindings.reduce == none or bindings.cover == none {
    //two cases to look bindings up:
    // 1. in the package itself
    // 2. in the auto-reducer-bindings based on the package name
    bindings = pckg.at("touying-reducer-bindings", default: none)

    if bindings == none and "name" in pckg.keys() {
      bindings = extern.auto-reducer-bindings.at(pckg.name, default: none)
    }

    //last option: test if it is fletcher, using repr is not necessarily stable, but hey, works
    if bindings == none and (repr(package) == "<module fletcher>") {
      bindings = extern.auto-reducer-bindings.at("fletcher", default: none)
    }

    assert(
      bindings != none,
      message: "Package "
        + repr(package)
        + " is not supported by `touying-reduce()`. Make sure it either exposes `touying-reducer-bindings` or that touying supports the package and it exposes its name. Natively supported packages are: "
        + repr(extern.auto-reducer-bindings.keys()),
    )
  }

  touying-reducer(
    reduce: parse-binding(
      package,
      bindings.at("reduce"),
    ),
    cover: parse-binding(
      package,
      bindings.at("cover"),
    ),
    ..args,
  )
}

/// A synonym of `touying-reduce` bc often diagrams are the things integrated via `touying-reducer`. For details see `touying-reduce` instead.
#let touying-diagram(
  package,
  bindings: (reduce: none, cover: none),
  ..args,
) = touying-reduce(package, bindings: bindings, ..args)

/// Create a navigation element with links to previous/next subslide/slide and a center icon. Note that physical pages are considered subslides, thus your content breaking the slide into multiple pages will be considered as 'multiple' subslides.
///
/// Usage:
/// ```typst
/// #lr-navigation(
///   icon: sym.rect.stroked.h,
///   nav: sym.triangle,
///   mode: "both",
///   show-useless: false,
/// )
/// ```
///
/// - self: The slide self. If not provided a `touying-fn-wrapper-raw` is used to retrieve it instead. This means this component does not escape the animation structure like `only`, but behaves like `alert` instead.
/// - icon (symbol, content): The icon to display for the navigation.
/// - nav (symbol, dictionary, content): The navigation symbols. By default we use filled symbols as the links to the subslides and stroked symbols as the links to the slides. You can also pass a dictionary with the structure `(filled:(left:any, right:any), stroked:(left:any, right:any))` and you may omit arbitrary fields. We try the best we can to fill the missing fields based on the values and symbols provided. \ For convenvience we allow 'subslide' as a synonym for 'filled' and 'page' and 'slide' as synonyms for 'stroked', so you can also use `(subslide:(left:any, right:any), page:(left:any, right:any))` instead of the above structure.
/// - mode (str): The mode of the navigation item. Can be "both", "subslide" or "page".
/// - show-useless (bool): Whether to show the navigation links when they are useless (e.g. on the first page, the "previous page" link is useless). Default is `true`.
/// -> content
#let lr-navigation(
  self: none,
  icon: sym.rect.stroked.h,
  nav: sym.triangle,
  mode: "both",
  show-useless: true,
) = {
  let inner(self) = {
    let nav-symbols = utils.create-nav-symbols(nav)

    let current-page = here().page()

    let prev-page = calc.max(1, current-page - self.subslide - 1)
    let next-page = current-page - self.subslide + self.repeat + 1
    let prev-subslide = calc.max(1, current-page - 1)
    let next-subslide = current-page + 1

    let x = page.width / 2
    let y = page.height / 2

    let lom = link((page: prev-page, x: x, y: y), text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      nav-symbols.stroked.left,
    ))
    let lim = link((page: prev-subslide, x: x, y: y), text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      nav-symbols.filled.left,
    ))
    let rim = link((page: next-subslide, x: x, y: y), text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      nav-symbols.filled.right,
    ))
    let rom = link((page: next-page, x: x, y: y), text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      nav-symbols.stroked.right,
    ))
    let icon = text(top-edge: "bounds", bottom-edge: "bounds", icon)

    if not show-useless {
      let last-physical-page = query(<touying-last-page>)
        .last()
        .location()
        .page()
      if current-page <= 1 {
        lom = hide(lom)
      }
      if current-page - self.subslide < 1 {
        lim = hide(lim)
      }
      if current-page >= last-physical-page {
        rim = hide(rim)
      }
      if current-page - self.subslide + self.repeat >= last-physical-page {
        rom = hide(rom)
      }
    }

    if mode == "both" {
      box(stack(
        dir: ltr,
        spacing: 0.05em,
        ..(lom, lim, icon, rim, rom).map(el => align(horizon, el)),
      ))
    } else if mode == "subslide" {
      box(stack(
        dir: ltr,
        spacing: 0.05em,
        ..(lim, icon, rim).map(el => align(horizon, el)),
      ))
    } else if mode == "page" {
      box(stack(
        dir: ltr,
        spacing: 0.05em,
        ..(lom, icon, rom).map(el => align(horizon, el)),
      ))
    } else {
      panic(
        "Invalid mode for lr-navigation: "
          + repr(mode)
          + ". Expected 'both', 'subslide', or 'page'.",
      )
    }
  }

  if self == none {
    touying-fn-wrapper-raw((self: none) => context inner(self))
  } else {
    context inner(self)
  }
}
