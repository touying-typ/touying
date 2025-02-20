#import "utils.typ"
#import "configs.typ"
#import "core.typ"
#import "magic.typ"

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
    ..(if type(self.info.title) in (str, content) { (title: self.info.title) } else { }),
    ..(
      if type(self.info.author) in (str, array) { (author: self.info.author) } else if (
        type(self.info.author) == content
      ) { (author: utils.markup-text(self.info.author)) } else { }
    ),
    ..(if type(self.info.date) in (datetime,) { (date: self.info.date) } else { }),
  )

  // get the init function
  let init = if "init" in self.methods and type(self.methods.init) == function {
    self.methods.init.with(self: self)
  } else {
    body => body
  }

  show: body => {
    if self.at("scale-list-items", default: none) != none {
      magic.scale-list-items(scale: self.at("scale-list-items", default: none), body)
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
        magic.show-bibliography-as-footnote.with(..args, record: false, bibliography, body)
      } else {
        // args is a bibliography like `bibliography(title: none, "ref.bib")`
        magic.bibliography-as-footnote(args, record: false, body)
      }
    } else {
      body
    }
  }

  show: init

  show: core.split-content-into-slides.with(self: self, is-first-slide: true)

  body
}
