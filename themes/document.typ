#import "../src/exports.typ": *

/// Touying slide function for document mode.
///
/// In document mode, slides render their content inline (no page breaks).
/// Animations show the final state. Multiple bodies are linearized sequentially.
///
/// - config (dictionary): Slide-specific configuration overrides.
/// - repeat (int, auto): The number of subslides. Default is `auto`.
/// - setting (function): Additional set/show rules for this slide's content.
/// - composer (function, array, int, auto): Ignored in document mode (bodies are linearized).
/// - bodies (content): The contents of the slide.
#let slide(
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


/// Touying document theme.
///
/// Renders presentation content as a continuous A4 document instead of slides.
/// Headings remain normal headings, `#slide[...]` renders inline, and all
/// animations show their final state.
///
/// Example:
///
/// ```typst
/// #show: document-theme.with()
///
/// = Introduction
///
/// Some content here.
///
/// #slide[
///   More content in a slide.
/// ]
/// ```
///
/// - text-size (length): Base text size. Default is `12pt`.
/// - font (str, auto): Font family. Default is `auto` (system default).
/// - numbering (str, none): Heading numbering format. Default is `none`.
/// - paper (str): Paper size. Default is `"a4"`.
/// - margin (length, dictionary): Page margins. Default is `(x: 2.5cm, y: 2.5cm)`.
/// - wrap-images (bool): Whether to wrap images to the side in multi-body slides. Default is `true`.
/// - justify (bool): Whether to justify paragraphs. Default is `true`.
/// - args: Additional config overrides (e.g. `config-info(title: "My Doc")`).
/// - body (content): The document content.
#let document-theme(
  text-size: 12pt,
  font: auto,
  numbering: none,
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  wrap-images: true,
  justify: true,
  ..args,
  body,
) = {
  set text(size: text-size)
  set text(font: font) if font != auto
  set par(justify: justify)
  set heading(numbering: numbering) if numbering != none

  show: touying-slides.with(
    config-page(
      paper: paper,
      margin: margin,
      header: none,
      footer: none,
    ),
    config-common(
      slide-fn: slide,
      document-mode: true,
      handout: true,
      document-wrap-images: wrap-images,
      horizontal-line-to-pagebreak: false,
      reset-page-counter-to-slide-counter: false,
      reset-footnote-number-per-slide: false,
      enable-pdfpc: false,
      freeze-slide-counter: true,
    ),
    ..args,
  )

  body
}
