#import "../utils.typ"

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
/// #let cetz-canvas = touying-reducer.with(
///   reduce: cetz.canvas,
///   cover: cetz.draw.hide.with(bounds: true),
/// )
///
/// // Fletcher
/// #let fletcher-diagram = touying-reducer.with(
///   reduce: fletcher.diagram,
///   cover: fletcher.hide,
/// )
/// ```
///
/// - reduce (function): The external drawing function. It should accept an array of drawing commands and return rendered content (e.g. `cetz.canvas` or `fletcher.diagram`).
///
/// - cover (function): Called with a drawing command when that command should be hidden on the current subslide. Should produce invisible but space-preserving content (e.g. `cetz.draw.hide.with(bounds: true)` or `fletcher.hide`).
///
/// - label (none, str, label): An optional label to identify the graphic in document mode via `touying-block-recall`.
///
/// - args (arguments): The positional and named arguments passed to the `reduce` function.
///
/// -> content
#let touying-reducer(
  reduce: arr => arr.sum(),
  cover: arr => none,
  label: none,
  ..args,
) = [#metadata((
  kind: "touying-reducer",
  reduce: reduce,
  cover: cover,
  kwargs: args.named(),
  args: args.pos(),
  label: label,
))<touying-temporary-mark>]
