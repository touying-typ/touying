#import "utils.typ"
#import "configs.typ"
#import "core.typ"
#import "magic.typ"

/// Focus slide.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide.
///
/// - background (color): Background color. `auto` uses `default-background(self)`.
///
/// - background-color (color): Alias for `background` if explicitly set.
///
/// - background-img (content): Background image content (typically `image(...)` or path string).
///
/// - default-background (function): Returns background color when `background` and `background-color` are both `auto`/`none`.
///
/// - default-foreground (function): Returns text color when `foreground` is `none`.
///
/// - align (alignment): The alignment of the content. Defaults to `horizon + center`.
#let focus-slide(
  config: (:),
  background: auto,
  background-color: none,
  background-img: none,
  align: horizon + center,
  margin: 1em,
  foreground: none,
  text-size: 1.5em,
  text-weight: none,
  page: (:),
  default-background: self => self.colors.primary,
  default-foreground: self => self.colors.neutral-lightest,
  body,
) = core.touying-slide-wrapper(self => {
  let background-color = if background != auto {
    background
  } else if background-color != none {
    background-color
  } else {
    default-background(self)
  }
  let args = (: ..page)
  args.margin = margin
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "cover", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    configs.config-common(freeze-slide-counter: true),
    configs.config-page(..args),
  )
  set text(
    fill: if foreground == none {
      default-foreground(self)
    } else {
      foreground
    },
    size: text-size,
  )
  if text-weight != none {
    set text(weight: text-weight)
  }
  core.touying-slide(self: self, config: config, std.align(align, body))
})

/// Touying slides function.
///
/// Example:
///
/// ```typst
/// #show: touying-slides.with(
///   config-page(paper: "presentation-" + aspect-ratio),
///   config-common(
///     slide-fn: slide,
///   ),
///   ..args,
/// )
/// ```
///
/// - args (arguments): The configurations of the slides. For example, you can use `config-page(paper: "presentation-16-9")` to set the aspect ratio of the slides.
///
/// - body (content): The contents of the slides.
///
/// -> content
#let touying-slides(..args, body) = {
  // get the default config
  let args = (configs.default-config,) + args.pos()
  let self = utils.merge-dicts(..args)

  // set the document
  set document(
    ..(
      if type(self.info.title) in (str, content) {
        (title: self.info.title)
      } else {}
    ),
    ..(
      if type(self.info.author) in (str, array) {
        (author: self.info.author)
      } else if (
        type(self.info.author) == content
      ) { (author: utils.markup-text(self.info.author)) } else {}
    ),
    ..(
      if type(self.info.date) in (datetime,) { (date: self.info.date) } else {}
    ),
  )

  // get the init function
  let init = if "init" in self.methods and type(self.methods.init) == function {
    self.methods.init.with(self: self)
  } else {
    body => body
  }

  show: body => {
    if self.at("scale-list-items", default: none) != none {
      magic.scale-list-items(
        scale: self.at("scale-list-items", default: none),
        body,
      )
    } else {
      body
    }
  }

  show: body => {
    if self.at("nontight-list-enum-and-terms", default: true) {
      magic.nontight-list-enum-and-terms(body)
    } else {
      body
    }
  }

  show: body => {
    if self.at("align-enum-marker-with-baseline", default: false) {
      magic.align-enum-marker-with-baseline(body)
    } else {
      body
    }
  }

  show: body => {
    if self.at("align-list-marker-with-baseline", default: false) {
      magic.align-list-marker-with-baseline(body)
    } else {
      body
    }
  }

  show: body => {
    if self.at("show-hide-set-list-marker-none", default: true) {
      magic.show-hide-set-list-marker-none(body)
    } else {
      body
    }
  }

  show: body => {
    if self.at("show-bibliography-as-footnote", default: none) != none {
      let args = self.at("show-bibliography-as-footnote", default: none)
      if type(args) == dictionary {
        let bibliography = args.at("bibliography")
        args.remove("bibliography")
        magic.show-bibliography-as-footnote.with(
          ..args,
          bibliography,
          body,
        )
      } else {
        // args is a bibliography like `bibliography(title: none, "ref.bib")`
        magic.bibliography-as-footnote(args, body)
      }
    } else {
      body
    }
  }

  show: init

  show: core.split-content-into-slides.with(
    self: self,
    is-first-slide: true,
    is-outer-call: true,
  )

  body
}
