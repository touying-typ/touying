/// A clean document theme for continuous A4 output.
///
/// This is a plain document theme with no presentation framework dependency.
/// It can be used standalone for papers, reports, etc., or paired with a
/// slide theme via `dual-theme` for single-source presentation + document output.
/// 
/// It serves as an example, you may pass any document theme to the dual theme.
///
/// Example (standalone):
///
/// ```typst
/// #show: document-theme.with(
///   numbering: "1.1",
/// )
///
/// = Introduction
/// Some content here.
/// ```
///
/// - text-size (length): Base text size. Default is `12pt`.
/// - font (str, auto): Font family. Default is `auto` (system default).
/// - numbering (str, none): Heading numbering format. Default is `none`.
/// - paper (str): Paper size. Default is `"a4"`.
/// - margin (length, dictionary): Page margins. Default is `(x: 2.5cm, y: 2.5cm)`.
/// - justify (bool): Whether to justify paragraphs. Default is `true`.
/// - body (content): The document content.
#let document-theme(
  title: "Title",
  subtitle: none,
  author: "Author Name",
  date: datetime.today(),
  date-format: "[day].[month].[year]",
  institution: none,
  logo: none,
  text-size: 12pt,
  font: auto,
  numbering: none,
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  justify: true,
  ..args,
  body,
) = {
  set text(size: text-size)
  set text(font: font) if font != auto
  set par(justify: justify)
  set heading(numbering: numbering) if numbering != none
  set page(paper: paper, margin: margin)
  show figure.where(kind: table): set figure.caption(position: top)

  // write header
  align(center, block({
    if logo != none {
      image(logo, width: 1.5cm, height: 1.5cm)
    }
    block([
      #std.title(title)

      #let subtitle = if subtitle != none {text(subtitle, weight: "bold")} else {none}
      #subtitle

      #author

      #institution 

      #date.display(date-format)
      ],
      spacing: 0.2em
    )},
    spacing: 0.5em,
  ))

  body
}
