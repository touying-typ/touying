#import "../src/exports.typ": *

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function, array): The composer of the slide. You can use it to set the layout of the slide.
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
/// - bodies (content): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    place(
      center + top,
      dy: .5em,
      rect(
        width: 100%,
        height: 1.8em,
        fill: self.colors.primary,
        align(left + horizon, h(1.5em) + text(fill: white, utils.call-or-display(self, self.store.header))),
      ),
    )
    place(left + top, line(start: (30%, 0%), end: (27%, 100%), stroke: .5em + white))
  }
  let footer(self) = {
    set text(size: 0.8em)
    place(right, dx: -5%, utils.call-or-display(self, utils.call-or-display(self, self.store.footer)))
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: aqua-theme.with(
///   config-info(
///     title: [Title],
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      background: utils.call-or-display(self, self.store.background),
      margin: (x: 0em, top: 30%, bottom: 0%),
    ),
  )
  let info = self.info + args.named()
  let body = {
    set align(center)
    stack(
      spacing: 3em,
      if info.title != none {
        text(size: 48pt, weight: "bold", fill: self.colors.primary, info.title)
      },
      if info.author != none {
        text(fill: self.colors.primary-light, size: 28pt, weight: "regular", info.author)
      },
      if info.date != none {
        text(
          fill: self.colors.primary-light,
          size: 20pt,
          weight: "regular",
          utils.display-info-date(self),
        )
      },
    )
  }
  touying-slide(self: self, body)
})


/// Outline slide for the presentation.
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
///
/// - leading (length): The leading of paragraphs in the outline. Default is `50pt`.
#let outline-slide(config: (:), leading: 50pt) = touying-slide-wrapper(self => {
  set text(size: 30pt, fill: self.colors.primary)
  set par(leading: leading)

  let body = {
    grid(
      columns: (1fr, 1fr),
      rows: (1fr),
      align(
        center + horizon,
        {
          set par(leading: 20pt)
          context {
            if text.lang == "zh" {
              text(
                size: 80pt,
                weight: "bold",
                [#text(size:36pt)[CONTENTS]\ 目录],
              )
            } else {
              text(
                size: 48pt,
                weight: "bold",
                [CONTENTS],
              )
            }
          }
        },
      ),
      align(
        left + horizon,
        {
          set par(leading: leading)
          set text(weight: "bold")
          components.custom-progressive-outline(
            level: none,
            depth: 1,
            numbered: (true,),
          )
        },
      ),
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      background: utils.call-or-display(self, self.store.background),
      margin: 0em,
    ),
  )
  touying-slide(self: self, config: config, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
/// 
/// - level (int): The level of the heading.
///
/// - body (content): The body of the section. It will be passed by touying automatically.
#let new-section-slide(config: (:), level: 1, body) = touying-slide-wrapper(self => {
  let slide-body = {
    stack(
      dir: ttb,
      spacing: 12%,
      align(
        center,
        text(
          fill: self.colors.primary,
          size: 166pt,
          utils.display-current-heading-number(level: level),
        ),
      ),
      align(
        center,
        text(
          fill: self.colors.primary,
          size: 60pt,
          weight: "bold",
          utils.display-current-heading(level: level, numbered: false),
        ),
      ),
    )
    body
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (left: 0%, right: 0%, top: 20%, bottom: 0%),
      background: utils.call-or-display(self, self.store.background),
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
/// 
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more configurations, you can use `utils.merge-dicts` to merge them.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em, weight: "bold")
  touying-slide(self: self, config: config, align(horizon + center, body))
})


/// Touying aqua theme.
///
/// Example:
///
/// ```typst
/// #show: aqua-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
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
/// The default colors:
///
/// ```typst
/// config-colors(
///   primary: rgb("#003F88"),
///   primary-light: rgb("#2159A5"),
///   primary-lightest: rgb("#F2F4F8"),
///   neutral-lightest: rgb("#FFFFFF")
/// )
/// ```
///
/// - aspect-ratio (ratio): The aspect ratio of the slides. Default is `16-9`.
///
/// - header (content): The header of the slides. Default is `self => utils.display-current-heading(depth: self.slide-level)`.
///
/// - footer (content): The footer of the slides. Default is `context utils.slide-counter.display()`.
#let aqua-theme(
  aspect-ratio: "16-9",
  header: self => utils.display-current-heading(depth: self.slide-level),
  footer: context utils.slide-counter.display(),
  ..args,
  body,
) = {
  set text(size: 20pt)
  set heading(numbering: "1.1")
  show heading.where(level: 1): set heading(numbering: "01")

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: 2em, top: 3.5em, bottom: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        show heading: set text(fill: self.colors.primary-light)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#003F88"),
      primary-light: rgb("#2159A5"),
      primary-lightest: rgb("#F2F4F8"),
      neutral-lightest: rgb("#FFFFFF")
    ),
    // save the variables for later use
    config-store(
      align: align,
      header: header,
      footer: footer,
      background: self => {
        let page-width = if self.page.paper == "presentation-16-9" { 841.89pt } else { 793.7pt }
        let r = if self.at("show-notes-on-second-screen", default: none) == none { 1.0 } else { 0.5 }
        let bias1 = - page-width * (1-r)
        let bias2 = - page-width * 2 * (1-r)
        place(left + top, dx: -15pt, dy: -26pt,
          circle(radius: 40pt, fill: self.colors.primary))
        place(left + top, dx: 65pt, dy: 12pt,
          circle(radius: 21pt, fill: self.colors.primary))
        place(left + top, dx: r * 3%, dy: 15%,
          circle(radius: 13pt, fill: self.colors.primary))
        place(left + top, dx: r * 2.5%, dy: 27%,
          circle(radius: 8pt, fill: self.colors.primary))
        place(right + bottom, dx: 15pt + bias2, dy: 26pt,
          circle(radius: 40pt, fill: self.colors.primary))
        place(right + bottom, dx: -65pt + bias2, dy: -12pt,
          circle(radius: 21pt, fill: self.colors.primary))
        place(right + bottom, dx: r * -3% + bias2, dy: -15%,
          circle(radius: 13pt, fill: self.colors.primary))
        place(right + bottom, dx: r * -2.5% + bias2, dy: -27%,
          circle(radius: 8pt, fill: self.colors.primary))
        place(center + horizon, dx: bias1, polygon(fill: self.colors.primary-lightest,
          (35% * page-width, -17%), (70% * page-width, 10%), (35% * page-width, 30%), (0% * page-width, 10%)))
        place(center + horizon, dy: 7%, dx: bias1,
          ellipse(fill: white, width: r * 45%, height: 120pt))
        place(center + horizon, dy: 5%, dx: bias1,
          ellipse(fill: self.colors.primary-lightest, width: r * 40%, height: 80pt))
        place(center + horizon, dy: 12%, dx: bias1,
          rect(fill: self.colors.primary-lightest, width: r * 40%, height: 60pt))
        place(center + horizon, dy: 20%, dx: bias1,
          ellipse(fill: white, width: r * 40%, height: 70pt))
        place(center + horizon, dx: r * 28% + bias1, dy: -6%,
          circle(radius: 13pt, fill: white))
      }
    ),
    ..args,
  )

  body
}
