#import "../src/exports.typ": *
#import "document.typ": document-theme as _default-document-theme

/// Internal slide function for document mode.
///
/// In document mode, slides render their content inline (no page breaks).
/// Animations show the final state. Multiple bodies are linearized sequentially.
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


/// Dual theme — one source file, multiple output formats.
///
/// Wraps a slide theme and a document theme, switching between them based
/// on the `export-mode` key in `config-common`. General configs are forwarded
/// to both themes; the slide theme's own arguments take precedence in
/// presentation/handout mode.
///
/// Example:
///
/// ```typst
/// #import themes.dual: *
/// #import themes.simple: simple-theme
///
/// #show: dual-theme.with(
///   slide-theme: simple-theme,
///   config-common(export-mode: "document"),
///   config-info(title: [My Talk]),
///   config-document(wrap-images: true, wrap-figures: true),
/// )
///
/// = Introduction
/// Some content here.
/// ```
///
/// - slide-theme (function): The presentation theme function (e.g., `simple-theme`).
/// - document-theme (function, auto): The document theme function. Default is
///   the built-in `document-theme`. Any function `(body) => content` works.
/// - args: Config overrides forwarded to both themes. Use `config-common(export-mode: ...)`
///   to set the output mode (`"presentation"`, `"handout"`, or `"document"`).
///   Also accepts `config-info(...)`, `config-document(...)`, etc.
/// - body (content): The document content.
#let dual-theme(
  slide-theme: none,
  document-theme: auto,
  ..args,
  body,
) = {
  assert(
    slide-theme != none,
    message: "dual-theme requires a slide-theme (e.g., simple-theme)",
  )

  let doc-theme = if document-theme == auto { _default-document-theme } else { document-theme }

  // Resolve export-mode from the merged configs
  let merged = utils.merge-dicts(default-config, ..args.pos())
  let export-mode = merged.at("export-mode", default: "presentation")

  assert(
    export-mode in ("presentation", "handout", "document"),
    message: "export-mode must be \"presentation\", \"handout\", or \"document\"",
  )

  if export-mode == "document" {
    // Apply the document theme for styling (page, text, etc.)
    show: doc-theme

    // Extract document config from merged configs
    let doc-cfg = merged.at("document", default: (:))

    // Wrap with touying-slides for slide/animation processing in document mode
    show: touying-slides.with(
      config-page(
        header: none,
        footer: none,
      ),
      config-common(
        slide-fn: _document-slide,
        document-mode: true,
        handout: true,
        horizontal-line-to-pagebreak: false,
        reset-page-counter-to-slide-counter: false,
        reset-footnote-number-per-slide: false,
        enable-pdfpc: false,
        freeze-slide-counter: true,
      ),
      // Forward document wrapping config
      (document: doc-cfg),
      // Forward all other user configs (config-info, config-common overrides, etc.)
      ..args,
    )

    body
  } else if export-mode == "handout" {
    // Forward all configs to slide theme, adding handout: true
    show: slide-theme.with(..args, config-common(handout: true))
    body
  } else {
    // Forward all configs to slide theme as-is
    show: slide-theme.with(..args)
    body
  }
}
