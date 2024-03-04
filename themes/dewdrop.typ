// This theme is inspired by https://github.com/zbowang/BeamerTheme
// The typst version was written by https://github.com/OrangeX4

#import "../utils/utils.typ"
#import "../utils/states.typ"

#let slide(
  self: none,
  subsection: none,
  title: none,
  footer: auto,
  ..args,
) = {
  self.page-args = self.page-args + (
    fill: self.colors.neutral-lightest,
  )
  if footer != auto {
    self.m-footer = footer
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    subsection: subsection,
    title: title,
    setting: body => {
      set text(fill: self.colors.neutral-darkest)
      show heading: set text(fill: self.colors.primary)
      show: args.named().at("setting", default: body => body)
      if self.auto-heading and subsection != none {
        heading(level: 1, subsection)
      }
      if self.auto-heading and title != none {
        heading(level: 2, title)
      }
      body
    },
    ..args.pos(),
  )
}

#let title-slide(
  self: none,
  extra: none,
  ..args,
) = {
  self = utils.empty-page(self)
  let info = self.info + args.named()
  let content = {
    set text(fill: self.colors.neutral-darkest)
    set align(center + horizon)
    block(width: 100%, inset: 3em, {
      block(
        fill: self.colors.neutral-light,
        inset: 1em,
        width: 100%,
        radius: 0.2em,
        text(size: 1.3em, fill: self.colors.primary, text(weight: "medium", info.title))
        + (if info.subtitle != none {
          linebreak()
          text(size: 0.9em, fill: self.colors.primary, info.subtitle)
        })
      )
      set text(size: .8em)
      if info.author != none {
        block(spacing: 1em, info.author)
      }
      v(1em)
      if info.date != none {
        block(spacing: 1em, if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
      }
      set text(size: .8em)
      if info.institution != none {
        block(spacing: 1em, info.institution)
      }
      if extra != none {
        block(spacing: 1em, extra)
      }
    })
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let focus-slide(self: none, body) = {
  self = utils.empty-page(self)
  self.page-args = self.page-args + (
    fill: self.colors.primary,
    margin: 2em,
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let new-section-slide(self: none, section) = {
  (self.methods.slide)(self: self, section: section, heading(level: 2, self.outline-title) + parbreak() + (self.methods.touying-outline)(self: self))
}

#let d-outline(self: none, enum-args: (:), list-args: (:), cover: true) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections.filter(section => section.loc != none)
  final-sections = final-sections.filter(section => section.loc != none)
  let current-index = current-sections.len() - 1
  let d-cover(i, body) = if i != current-index and cover {
    (self.methods.d-cover)(self: self, body)
  } else {
    body
  }
  set enum(..enum-args)
  set list(..enum-args)
  set text(fill: self.colors.primary)
  for (i, section) in final-sections.enumerate() {
    d-cover(i, {
      enum.item(i + 1, [#link(section.loc, section.title)<touying-link>] + if section.children.filter(it => it.kind != "slide").len() > 0 {
        let subsections = section.children.filter(it => it.kind != "slide")
        set text(fill: self.colors.neutral-dark, size: 0.9em)
        list(
          ..subsections.map(subsection => [#link(subsection.loc, subsection.title)<touying-link>])
        )
      })
    })
    parbreak()
  }
})

#let d-sidebar(self: none) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections
    .filter(section => section.loc != none)
    .map(section => (section, section.children))
    .flatten()
    .filter(item => item.kind != "slide")
  final-sections = final-sections
    .filter(section => section.loc != none)
    .map(section => (section, section.children))
    .flatten()
    .filter(item => item.kind != "slide")
  let current-index = current-sections.len() - 1
  show: block.with(width: self.d-sidebar.width, inset: (top: 4em, x: 1em))
  set align(left)
  set par(justify: false)
  set text(size: 0.9em)
  for (i, section) in final-sections.enumerate() {
    if section.kind == "section" {
      set text(fill: if i != current-index { self.colors.primary.lighten(self.d-alpha) } else { self.colors.primary })
      [#link(section.loc, utils.section-short-title(section.title))<touying-link>]
    } else {
      set text(fill: if i != current-index { self.colors.neutral-dark.lighten(self.d-alpha) } else { self.colors.neutral-dark }, size: 0.9em)
      [#link(section.loc, utils.section-short-title(h(.3em) + section.title))<touying-link>]
    }
    parbreak()
  }
})

#let d-mini-slides(self: none) = states.touying-progress-with-sections(dict => {
  let (current-sections, final-sections) = dict
  current-sections = current-sections.filter(section => section.loc != none)
  final-sections = final-sections.filter(section => section.loc != none)
  let current-i = current-sections.len() - 1
  let cols = ()
  let current-count = 0
  for (i, section) in current-sections.enumerate() {
    if self.d-mini-slides.section {
      for slide in section.children.filter(it => it.kind == "slide") {
        current-count += 1
      }
    }
    for subsection in section.children.filter(it => it.kind != "slide") {
      for slide in subsection.children {
        current-count += 1
      }
    }
  }
  let final-count = 0
  for (i, section) in final-sections.enumerate() {
    let primary-color = if i != current-i { self.colors.primary.lighten(self.d-alpha) } else { self.colors.primary }
    cols.push({
      set align(left)
      set text(fill: primary-color)
      [#link(section.loc, utils.section-short-title(section.title))<touying-link>]
      linebreak()
      if self.d-mini-slides.section {
        for slide in section.children.filter(it => it.kind == "slide") {
          final-count += 1
          if i == current-i and final-count == current-count {
            [#link(slide.loc, sym.circle.filled)<touying-link>]
          } else {
            [#link(slide.loc, sym.circle)<touying-link>]
          }
        }
      }
      if self.d-mini-slides.section and self.d-mini-slides.subsection {
        linebreak()
      }
      for subsection in section.children.filter(it => it.kind != "slide") {
        for slide in subsection.children {
          final-count += 1
          if i == current-i and final-count == current-count {
            [#link(slide.loc, sym.circle.filled)<touying-link>]
          } else {
            [#link(slide.loc, sym.circle)<touying-link>]
          }
        }
        if self.d-mini-slides.subsection {
          linebreak()
        }
      }
    })
  }
  set align(top)
  show: block.with(inset: (top: .5em, x: 2em))
  show linebreak: it => it + v(-1em)
  set text(size: .7em)
  grid(columns: cols.map(_ => auto).intersperse(1fr), ..cols.intersperse([]))
})

#let slides(self: none, title-slide: true, outline-slide: true, slide-level: 2, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  if outline-slide {
    (self.methods.slide)(self: self, heading(level: 2, self.outline-title) + parbreak() + (self.methods.touying-outline)(self: self, cover: false))
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  aspect-ratio: "16-9",
  navigation: "sidebar",
  sidebar: (width: 10em),
  mini-slides: (height: 4em, x: 2em, section: false, subsection: true),
  footer: [],
  footer-right: states.slide-counter.display() + " / " + states.last-slide-number,
  primary: rgb("#0c4842"),
  alpha: 70%,
  self,
) = {
  assert(navigation in ("sidebar", "mini-slides", none), message: "navigation must be one of sidebar, mini-slides, none")
  // color theme
  self = (self.methods.colors)(
    self: self,
    neutral-darkest: rgb("#000000"),
    neutral-dark: rgb("#202020"),
    neutral-light: rgb("#f3f3f3"),
    neutral-lightest: rgb("#ffffff"),
    primary: primary,
  )
  // save the variables for later use
  self.d-navigation = navigation
  self.d-sidebar = sidebar
  self.d-mini-slides = mini-slides
  self.d-footer = footer
  self.d-footer-right = footer-right
  self.d-alpha = alpha
  self.auto-heading = true
  self.outline-title = [Outline]
  // set page
  let header(self) = {
    if self.d-navigation == "sidebar" {
      place(right + top, (self.methods.d-sidebar)(self: self))
    } else if self.d-navigation == "mini-slides" {
      (self.methods.d-mini-slides)(self: self)
    }
  }
  let footer(self) = {
    set text(size: 0.8em)
    set align(bottom)
    show: pad.with(.5em)
    text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.d-footer))
    h(1fr)
    text(fill: self.colors.neutral-darkest.lighten(20%), utils.call-or-display(self, self.d-footer-right))
  }
  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    fill: self.colors.neutral-lightest,
    header: header,
    footer: footer,
  ) + if navigation == "sidebar" {(
    margin: (top: 2em, bottom: 1em, x: 0em),
  )} else if navigation == "mini-slides" {(
    margin: (top: mini-slides.height, bottom: 2em, x: 0em),
  )} else {(
    margin: (top: 2em, bottom: 2em, x: 0em),
  )}
  self.padding = (x: if navigation == "sidebar" { sidebar.width } else { mini-slides.x }, y: 0em)
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.focus-slide = focus-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.slides = slides
  self.methods.d-cover = (self: none, body) => {
    utils.cover-with-rect(fill: utils.update-alpha(
      constructor: rgb, self.page-args.fill, self.d-alpha), body)
  }
  self.methods.touying-outline = d-outline
  self.methods.d-outline = d-outline
  self.methods.d-sidebar = d-sidebar
  self.methods.d-mini-slides = d-mini-slides
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    set par(justify: true)
    show heading: set block(below: 1em)
    body
  }
  self
}
