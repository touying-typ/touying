// This theme is inspired by https://github.com/zbowang/BeamerTheme
// The typst version was written by https://github.com/OrangeX4

#import "../src/exports.typ": *

#let _typst-builtin-repeat = repeat

/// Default slide function for the presentation.
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
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `utils.side-by-side` function.
///
///   The `utils.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    if self.store.navigation == "sidebar" {
      place(
        right + top,
        {
          v(4em)
          show: block.with(width: self.store.sidebar.width, inset: (x: 1em))
          set align(left)
          set par(justify: false)
          set text(size: .9em)
          components.custom-progressive-outline(
            self: self,
            level: auto,
            alpha: self.store.alpha,
            text-fill: (self.colors.primary, self.colors.neutral-darkest),
            text-size: (1em, .9em),
            vspace: (-.2em,),
            indent: (0em, self.store.sidebar.at("indent", default: .5em)),
            fill: (self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),),
            filled: (self.store.sidebar.at("filled", default: false),),
            paged: (self.store.sidebar.at("paged", default: false),),
            short-heading: self.store.sidebar.at("short-heading", default: true),
          )
        },
      )
    } else if self.store.navigation == "mini-slides" {
      // (self.methods.d-mini-slides)(self: self)
    }
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    show: pad.with(.5em)
    components.left-and-right(
      text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
      text(fill: self.colors.neutral-darkest.lighten(20%), utils.call-or-display(self, self.store.footer-right)),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting(body) = {
    set text(fill: self.colors.neutral-darkest)
    setting(body)
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: dewdrop-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - `extra` is the extra information you want to display on the title slide.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set align(center + horizon)
    block(
      width: 100%,
      inset: 3em,
      {
        block(
          fill: self.colors.neutral-light,
          inset: 1em,
          width: 100%,
          radius: 0.2em,
          text(size: 1.3em, fill: self.colors.primary, text(weight: "medium", info.title)) + (
            if info.subtitle != none {
              linebreak()
              text(size: 0.9em, fill: self.colors.primary, info.subtitle)
            }
          ),
        )
        set text(size: .8em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        v(1em)
        if info.date != none {
          block(spacing: 1em, utils.info-date(self))
        }
        set text(size: .8em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `title` is the title of the section. It will be pass by touying automatically.
#let new-section-slide(..args, title) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(
    self: self,
    {
      text(1.2em, fill: self.colors.primary, weight: "bold", utils.call-or-display(self, self.store.outline-title))
      text(
        fill: self.colors.neutral-darkest,
        components.progressive-outline(alpha: self.store.alpha, title: none, indent: 1em, ..args),
      )
    },
  )
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, align(horizon + center, body))
})


/// Touying dewdrop theme.
///
/// Example:
///
/// ```typst
/// #show: dewdrop-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
#let dewdrop-theme(
  aspect-ratio: "16-9",
  navigation: "sidebar",
  sidebar: (width: 10em, filled: false, numbered: false, indent: .5em),
  mini-slides: (height: 4em, x: 2em, section: false, subsection: true),
  footer: none,
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  primary: rgb("#0c4842"),
  alpha: 60%,
  outline-title: [Outline],
  ..args,
  body,
) = {
  set text(size: 20pt)
  set par(justify: true)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: if navigation == "sidebar" {
        (top: 2em, bottom: 1em, x: sidebar.width)
      } else if navigation == "mini-slides" {
        (top: mini-slides.height, bottom: 2em, x: mini-slides.x)
      } else {
        (top: 2em, bottom: 2em, x: mini-slides.x)
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#000000"),
      neutral-dark: rgb("#202020"),
      neutral-light: rgb("#f3f3f3"),
      neutral-lightest: rgb("#ffffff"),
      primary: primary,
    ),
    // save the variables for later use
    config-store(
      navigation: navigation,
      sidebar: sidebar,
      mini-slides: mini-slides,
      footer: footer,
      footer-right: footer-right,
      alpha: alpha,
      outline-title: outline-title,
    ),
    ..args,
  )

  body
}