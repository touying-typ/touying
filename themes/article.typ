/// A clean article theme for continuous A4 output.
///
/// This is a plain article theme with no presentation framework dependency.
/// It can be used standalone for papers, reports, etc., or paired with a
/// slide theme via for single-source presentation + article output.
///
/// It serves as an example, you may in fact use any article-like theme you like for the article output target.
///
/// Example (standalone):
///
/// ```typst
/// #show: article-theme.with(
///   numbering: "1.1",
/// )
///
/// = Introduction
/// Some content here.
/// ```
///
/// Example (paired with a slide theme):
/// ```typst
/// #show: simple-theme.with(
///   config-common(
///    export-mode: "article",
///    article-theme: article-theme.with(numbering: "1.1"),
///   ),
///   config-article(
///     wrap-images: true,
///     wrap-image-figures: true,
///     available-fields: (
///       // specify config fields that should be passed to the article theme.
///       title: "info.title",
///       subtitle: "common.export-mode",
///     ),
///   )
/// )
///
/// = Introduction
/// Some content here. #pause More content which is not paused during article output.
/// ```
///
/// - title (str): Article title.
/// - subtitle (str, none): Article subtitle. Default is `none`.
/// - author (str, array): Article author(s).
/// - date (datetime): Article date.
/// - date-format (str): Date format for displaying the date. Default is `"[day].[month].[year]"`.
/// - institution (str, none): Institution or affiliation. Default is `none`.
/// - logo (str, none): Path to a logo image to show in the title block. Default is `none`.
/// - text-size (length): Base text size. Default is `12pt`.
/// - font (str, auto): Font family. Default is `auto` (system default).
/// - numbering (str, none): Heading numbering format. Default is `none`.
/// - paper (str): Paper size. Default is `"a4"`.
/// - margin (length, dictionary): Page margins. Default is `(x: 2.5cm, y: 2.5cm)`.
/// - justify (bool): Whether to justify paragraphs. Default is `true`.
/// - title-block-fn (function): A function returning the title block to show at the beginning of the rendered article. If your theme has an automatic function for this you don't need it. And you can always use `#article-only` before the first slide to show your custom title block.
/// - body (content): The article content.
///
/// -> content
#let article-theme(
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
  title-block-fn: (..args) => {
    // default title block ignores subtitle and institution, you can customize it by passing a different function
    let kwargs = args.named()
    align(center, block(
      {
        if kwargs.logo != none {
          place(top + right, image(kwargs.logo, width: 1.5cm, height: 1.5cm))
        }
        block(
          [
            #std.title(kwargs.title)

            #let subtitle = if kwargs.subtitle != none {
              text(kwargs.subtitle, weight: "bold")
            } else { none }
            #subtitle

            #kwargs.author

            #kwargs.institution

            #kwargs.date.display(kwargs.date-format)
          ],
          spacing: 0.2em,
        )
      },
      spacing: 0.5em,
    ))
  },
  ..args,
  body,
) = {
  set text(size: text-size)
  set text(font: font) if font != auto
  set par(justify: justify)
  set heading(numbering: numbering) if numbering != none
  set page(paper: paper, margin: margin)
  show figure.where(kind: table): set figure.caption(position: top)

  // write title header
  assert(
    type(title-block-fn) == function,
    message: "title-block-fn must be a function",
  )
  title-block-fn(
    title: title,
    subtitle: subtitle,
    author: author,
    institution: institution,
    date: date,
    date-format: date-format,
    logo: logo,
    ..args,
  )

  body
}
