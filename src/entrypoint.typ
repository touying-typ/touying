#import "utils.typ"
#import "configs.typ"
#import "core/docmode.typ": render-content-as-document
#import "core/slides.typ": split-content-into-slides, touying-slide
#import "core/animation.typ": touying-slide-wrapper
#import "magic.typ"

#import "../themes/document.typ": document-theme as _default-document-theme

/// Internal slide function for document mode.
///
/// In document mode, slides render their content inline (no page breaks).
/// Animations show the final state. Multiple bodies are linearized sequentially.
/// Use a raw slide wrapper to avoid theme stuff.
#let _document-slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

#let _get-available-fields(config, requested_fields) = {
  let _recursive-has(dict, path) = {
    if path == none {
      true
    } else {
      let parts = path.split(".")
      let key = parts.remove(0)
      if key in dict {
        _recursive-has(dict.at(key), parts.join("."))
      } else {
        false
      }
    }
  }

  let _recursive-get(dict, path) = {
    if path == none {
      dict
    } else {
      let parts = path.split(".")
      let key = parts.remove(0)
      _recursive-get(dict.at(key), parts.join("."))
    }
  }

  let avail_fields = (:)
  for (k, v) in requested_fields {
    if v.starts-with("common.") {
      v = v.slice(7) // remove "common." prefix
    }
    assert(
      _recursive-has(config, v),
      message: "Requested field \"" + v + "\" not found in config.",
    )
    avail_fields.insert(k, _recursive-get(config, v))
  }

  avail_fields
}

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

  // get compiler args
  let comp_args = utils.get-input()
  self = utils.merge-dicts(self, comp_args)

  // resolve export-mode and apply handout flag
  let export-mode = self.at("export-mode", default: "slides")
  assert(
    export-mode in ("presentation", "handout", "slides", "document"),
    message: "export-mode must be \"presentation\", \"handout\", \"slides\", or \"document\"",
  )
  if export-mode == "handout" {
    self.handout = true
  } else if export-mode == "presentation" {
    self.handout = false
  }

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

  // apply document-mode overrides to self before any other processing
  if export-mode == "document" or self.at("document-mode", default: false) {
    self = utils.merge-dicts(self, (
      page: utils.merge-dicts(self.at("page", default: (:)), (
        header: none,
        footer: none,
      )),
      slide-fn: _document-slide,
      document-mode: true,
      handout: true,
      horizontal-line-to-pagebreak: false,
      reset-page-counter-to-slide-counter: false,
      reset-footnote-number-per-slide: false,
      enable-pdfpc: false,
      freeze-slide-counter: true,
      // Neutralize theme's init (25pt text, heading styles, etc.)
      methods: utils.merge-dicts(self.at("methods", default: (:)), (
        init: (self: none, body) => body,
      )),
    ))
  } 
  else { // apply magic stuff when rendering slides
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
  }

  // get the init function and show.
  let init = if "init" in self.methods and type(self.methods.init) == function {
    self.methods.init.with(self: self)
  } else {
    body => body
  }
  show: init

  //final show rules either presentation or document mode.
  if self.at("document-mode", default: false) {
    let auto-title-block() = context {
      let title = document.title
      let authors = document.author
      if type(authors) == array {
        authors = authors.reduce((a, b) => a + " and " + b)
      }
      let date = document.date
      let description = document.description
      let keywords = document.keywords
      if type(keywords) == array {
        keywords = keywords.reduce((a, b) => a + ", " + b)
      }
      align(center, block[
        #std.title(title)

        *#authors*

        #date.display()

        #v(1em)

        #block(width: page.width * 0.6, text(style: "italic", description))

        #text(weight: "semibold", style: "italic", tracking: 0.5pt, keywords)
      ])
    }

    // show the theme and then render the content into it.
    let doc-theme-fn = self.at("document-theme", default: auto)
    let doc-theme = if doc-theme-fn == auto { _default-document-theme } else {
      doc-theme-fn
    }
    let avail-fields = self.at("document").at("available-fields", default: ())
    let doc-fields = _get-available-fields(self, avail-fields)
    show: doc-theme.with(..doc-fields)

    //show the title block
    let title-block-fn = self.at("document").at("title-block-fn", default: none)
    if title-block-fn == none {
      //do nothing
    } else if title-block-fn == auto {
      auto-title-block()
    } else if type(title-block-fn) == function {
      title-block-fn.with(self: self)
    } else {
      panic(
        "title-block-fn must be a function or auto or none. Got: "
          + repr(title-block-fn),
      )
    }

    show: render-content-as-document.with(self: self)

    body
  } else {
    show: split-content-into-slides.with(self: self, is-first-slide: true)
    body
  }
}
