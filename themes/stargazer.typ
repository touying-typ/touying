// Stargazer theme.
// Authors: Coekjan, QuadnucYard, OrangeX4
// Inspired by https://github.com/Coekjan/touying-buaa and https://github.com/QuadnucYard/touying-theme-seu

#import "../src/exports.typ": *

#let _typst-builtin-align = align

#let _tblock(self: none, title: none, it) = {
  grid(
    columns: 1,
    row-gutter: 0pt,
    block(
      fill: self.colors.primary-dark,
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),

    rect(
      fill: gradient.linear(self.colors.primary-dark, self.colors.primary.lighten(90%), angle: 90deg),
      width: 100%,
      height: 4pt,
    ),

    block(
      fill: self.colors.primary.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}


/// Theorem block for the presentation.
///
/// - `title` is the title of the theorem. Default is `none`.
///
/// - `it` is the content of the theorem.
#let tblock(title: none, it) = touying-fn-wrapper(_tblock.with(title: title, it))


/// Default slide function for the presentation.
///
/// - `title` is the title of the slide. Default is `auto`.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  // restore typst builtin align function
  let align = _typst-builtin-align
  if title != auto {
    self.store.title = title
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  let new-setting = body => {
    show: align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: stargazer-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
#let title-slide(..args) = touying-slide-wrapper(self => {
  self.store.title = none
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    show: align.with(center + horizon)
    block(
      fill: self.colors.primary,
      inset: 1.5em,
      radius: 0.5em,
      breakable: false,
      {
        text(size: 1.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
        if info.subtitle != none {
          parbreak()
          text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
        }
      },
    )
    // authors
    grid(
      columns: (1fr,) * calc.min(info.authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
      ..info.authors.map(author => text(fill: black, author)),
    )
    v(0.5em)
    // institution
    if info.institution != none {
      parbreak()
      text(size: 0.7em, info.institution)
    }
    // date
    if info.date != none {
      parbreak()
      text(size: 1.0em, utils.display-info-date(self))
    }
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, body)
})



/// Outline slide for the presentation.
///
/// - `title` is the title of the outline. Default is `utils.i18n-outline-title`.
///
/// - `level` is the level of the outline. Default is `none`.
///
/// - `numbered` is whether the outline is numbered. Default is `true`.
#let outline-slide(
  title: utils.i18n-outline-title,
  numbered: true,
  level: none,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.title = title
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(
    self: self,
    align(
      self.store.align,
      components.adaptive-columns(
        text(
          fill: self.colors.primary,
          weight: "bold",
          components.custom-progressive-outline(
            level: level,
            alpha: self.store.alpha,
            indent: (0em, 1em),
            vspace: (.4em,),
            numbered: (numbered,),
            depth: 1,
            ..args,
          ),
        ),
      ),
    ),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `title` is the title of the section. The default is `utils.i18n-outline-title`.
///
/// - `level` is the level of the heading. The default is `1`.
///
/// - `numbered` is whether the heading is numbered. The default is `true`.
///
/// - `body` is the title of the section. It will be pass by touying automatically.
#let new-section-slide(
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
  body,
) = outline-slide(title: title, level: level, numbered: numbered, ..args)



/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, _typst-builtin-align(align, body))
})


/// End slide for the presentation.
///
/// - `title` is the title of the slide. Default is `none`.
///
/// - `body` is the content of the slide.
#let ending-slide(title: none, body) = touying-slide-wrapper(self => {
  let content = {
    set align(center + horizon)
    if title != none {
      block(
        fill: self.colors.tertiary,
        inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
        radius: 0.5em,
        text(size: 1.5em, fill: self.colors.neutral-lightest, title),
      )
    }
    body
  }
  touying-slide(self: self, content)
})


/// Touying stargazer theme.
///
/// Example:
///
/// ```typst
/// #show: stargazer-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `align` is the alignment of the content. Default is `horizon`.
///
/// - `title` is the title in header of the slide. Default is `self => utils.display-current-heading(depth: self.slide-level)`.
///
/// - `header-right` is the right part of the header. Default is `self => self.info.logo`.
///
/// - `footer` is the footer of the slide. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `progress-bar` is whether to show the progress bar in the footer. Default is `true`.
///
/// - `footer-columns` is the columns of the footer. Default is `(25%, 25%, 1fr, 5em)`.
///
/// - `footer-a` is the left part of the footer. Default is `self => self.info.author`.
///
/// - `footer-b` is the second left part of the footer. Default is `self => utils.display-info-date(self)`.
///
/// - `footer-c` is the second right part of the footer. Default is `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
///
/// - `footer-d` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#005bac"),
///   primary-dark: rgb("#004078"),
///   secondary: rgb("#ffffff"),
///   tertiary: rgb("#005bac"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
#let stargazer-theme(
  aspect-ratio: "16-9",
  align: horizon,
  alpha: 20%,
  title: self => utils.display-current-heading(depth: self.slide-level),
  header-right: self => self.info.logo,
  progress-bar: true,
  footer-columns: (25%, 25%, 1fr, 5em),
  footer-a: self => self.info.author,
  footer-b: self => utils.display-info-date(self),
  footer-c: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-d: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  ..args,
  body,
) = {
  let header(self) = {
    set _typst-builtin-align(top)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.store.navigation),
      utils.call-or-display(self, self.store.header),
    )
  }
  let footer(self) = {
    set text(size: .5em)
    set _typst-builtin-align(center + bottom)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.store.footer),
      if self.store.progress-bar {
        utils.call-or-display(
          self,
          components.progress-bar(height: 2pt, self.colors.primary, self.colors.neutral-lightest),
        )
      },
    )
  }

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: header,
      footer: footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.5em, bottom: 2.5em, x: 2.5em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        set list(marker: components.knob-marker(primary: self.colors.primary))
        show strong: self.methods.alert.with(self: self)
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        show figure.where(kind: table): set figure.caption(position: top)

        body
      },
      alert: utils.alert-with-primary-color,
      tblock: _tblock,
    ),
    config-colors(
      primary: rgb("#005bac"),
      primary-dark: rgb("#004078"),
      secondary: rgb("#ffffff"),
      tertiary: rgb("#005bac"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      alpha: alpha,
      title: title,
      header-right: header-right,
      progress-bar: progress-bar,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,
      navigation: self => components.simple-navigation(self: self, primary: white, secondary: gray, background: self.colors.neutral-darkest, logo: utils.call-or-display(self, self.store.header-right)),
      header: self => if self.store.title != none {
        block(
          width: 100%,
          height: 1.8em,
          fill: gradient.linear(self.colors.primary, self.colors.neutral-darkest),
          place(left + horizon, text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.3em, utils.call-or-display(self, self.store.title)), dx: 1.5em),
        )
      },
      footer: self => {
        let cell(fill: none, it) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          _typst-builtin-align(horizon, text(fill: self.colors.neutral-lightest, it)),
        )
        grid(
          columns: self.store.footer-columns,
          rows: (1.5em, auto),
          cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-a)),
          cell(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-b)),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-c)),
          cell(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-d)),
        )
      }
    ),
    ..args,
  )

  body
}
