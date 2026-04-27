// Touyings fully customizable, user-friendly theme

#import "../src/exports.typ": *
// ── Content-tree helpers ────────────────────────────────────────────────────

// Find the first element labeled <content> (must be box/block/place/align),
// replace its body with `actual`, and return (found: bool, result: content).
// The element's own properties (size, fill, alignment …) are preserved.
#let _inject-content(template, actual) = {
  if type(template) != content { return (false, template) }
  let f = template.func()

  // ── Placeholder found ───────────────────────────────────────────────────
  if (
    f in (box, block, place, align)
      and template.has("label")
      and template.label == <content>
  ) {
    if f == place {
      // place takes its alignment as the first *positional* argument
      let fields = template.fields()
      let _ = fields.remove("label", default: none)
      let _ = fields.remove("body", default: none)
      let alignment = fields.remove("alignment", default: start)
      return (true, place(alignment, ..fields, actual))
    } else {
      // box / block / align: all constructor args are named
      return (
        true,
        utils.reconstruct(named: true, labeled: false, template, actual),
      )
    }
  }

  // ── Sequence ─────────────────────────────────────────────────────────────
  if f == utils.typst-builtin-sequence {
    let children = template.fields().at("children", default: ())
    let out = ()
    let found = false
    for child in children {
      if found {
        out.push(child)
      } else {
        let (ok, new-child) = _inject-content(child, actual)
        found = ok
        out.push(new-child)
      }
    }
    return (found, out.sum(default: []))
  }

  // ── Styled wrapper (produced by set/show rules) ───────────────────────────
  if f == utils.typst-builtin-styled {
    let (ok, new-child) = _inject-content(template.child, actual)
    if ok { return (true, utils.reconstruct-styled(template, new-child)) }
    return (false, template)
  }

  // ── Any other element that carries a body ────────────────────────────────
  if template.has("body") {
    let (ok, new-body) = _inject-content(template.body, actual)
    if ok {
      return (
        true,
        utils.reconstruct(named: true, labeled: true, template, new-body),
      )
    }
  }

  (false, template)
}

// Convert a user-supplied template into a unified wrapper function
// with signature  (self, body) => content.
//
// Accepted template forms:
//   • none                             → identity (body passes through)
//   • function                         → called as template(body)
//   • dict (fn:, requires-self: true)  → called as fn(self, body)
//   • content with <content> label     → placeholder replaced by body
#let _resolve-wrapper(template) = {
  if template == none {
    return (self, body, ..args) => body
  }
  if type(template) == function {
    return (self, body, ..args) => template(body, ..args)
  }
  if type(template) == dictionary and "fn" in template {
    let fn = template.fn
    if template.at("requires-self", default: false) {
      return (self, body, ..args) => fn(self, body, ..args)
    } else {
      return (self, body, ..args) => fn(body, ..args)
    }
  }
  // Content template: walk the tree and replace the <content> placeholder
  (self, body, ..args) => {
    let (found, result) = _inject-content(template, body)
    if found { result } else { body }
  }
}

// Wrap a user template so it can be used as a touying new-*-slide-fn.
// Returns none when template is none.
#let _make-heading-slide-fn(template) = {
  if template == none { return none }
  let wrapper = _resolve-wrapper(template)
  (config: (:), body) => touying-slide-wrapper(self => {
    touying-slide(
      self: self,
      config: config,
      (wrapper)(self, body),
    )
  })
}

// ── User-facing slide function ──────────────────────────────────────────────

#let _slide-fn = none

/// The base slide function for the custom theme.
///
/// - config (dictionary): Slide configuration via `config-xxx` helpers.
/// - repeat (int, auto): Number of subslides. `auto` = detect automatically.
/// - setting (function): Additional show/set rules applied to slide bodies.
/// - composer (function, auto): Layout composer for multiple bodies.
/// - args (arguments): Body content (positional) passed to the slide. Named args are forwarded to your template slide function.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..args,
) = touying-slide-wrapper(self => {
  //merge config into self.
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }
  let template = self.store.at("slide-template", default: none)
  let wrapper = _resolve-wrapper(template)
  touying-slide(
    self: self,
    config: (:),
    repeat: repeat,
    setting: body => (wrapper)(self, setting(body), args.named()),
    composer: composer,
    ..args.pos(),
  )
})

#(_slide-fn = slide)

// ── Theme entry point ───────────────────────────────────────────────────────

/// Touying custom theme.
///
/// Build your slide layout with ordinary Typst content and mark exactly one
/// `box`, `block`, `place`, or `align` element with the label `<content>`.
/// That element's body will be replaced with the actual slide content at
/// render time; its other properties (size, fill, alignment …) are kept.
///
/// Alternatively pass a plain function or a self-aware dict:
///
/// ```typst
/// // Content with placeholder
/// #show: custom-theme.with(slide: {
///   place(top + left, rect(width: 100%, height: 2em, fill: teal)[Header])
///   block(width: 100%, height: 1fr)<content>
///   place(bottom + left, rect(width: 100%, height: 2em, fill: teal)[Footer])
/// })
///
/// // Plain function
/// #show: custom-theme.with(
///   slide: content => align(center + horizon, content),
/// )
///
/// // Self-aware function (receives `self` for access to colors etc.)
/// #show: custom-theme.with(slide: (
///   fn: (self, content) => block(fill: self.colors.primary, content),
///   requires-self: true,
/// ))
/// ```
///
/// The same three forms are accepted for `new-section-slide` and the other
/// heading-level slide parameters.
///
/// - aspect-ratio (string): Page aspect ratio. Default `"16-9"`.
/// - slide (content, function, dictionary, none): Slide layout template.
/// - new-section-slide (content, function, dictionary, none): Section slide.
/// - new-subsection-slide (content, function, dictionary, none): Subsection slide.
/// - new-subsubsection-slide (content, function, dictionary, none): Subsubsection slide.
/// - new-subsubsubsection-slide (content, function, dictionary, none): Subsubsubsection slide.
/// - args (arguments): Extra configuration forwarded to `touying-slides`.
#let custom-theme(
  aspect-ratio: "16-9",
  slide: none,
  new-section-slide: none,
  new-subsection-slide: none,
  new-subsubsection-slide: none,
  new-subsubsubsection-slide: none,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: 2em,
      footer-descent: 0em,
    ),
    config-common(
      slide-fn: _slide-fn,
      new-section-slide-fn: _make-heading-slide-fn(new-section-slide),
      new-subsection-slide-fn: _make-heading-slide-fn(new-subsection-slide),
      new-subsubsection-slide-fn: _make-heading-slide-fn(
        new-subsubsection-slide,
      ),
      new-subsubsubsection-slide-fn: _make-heading-slide-fn(
        new-subsubsubsection-slide,
      ),
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-store(
      slide-template: slide,
    ),
    ..args,
  )

  body
}
