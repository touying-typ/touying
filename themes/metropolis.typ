// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex

// Consider using:
// #set text(font: "Fira Sans", weight: "light", size: 20pt)
// #show math.equation: set text(font: "Fira Math")
// #set strong(delta: 100)
// #set par(justify: true)

#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"

#let _saved-align = align

#let slide(
  self: none,
  title: auto,
  footer: auto,
  align: horizon,
  ..args,
) = {
  self.page-args = self.page-args + (
    fill: self.colors.neutral-lightest,
  )
  if title != auto {
    self.m-title = title
  }
  if footer != auto {
    self.m-footer = footer
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    setting: body => {
      show: _saved-align.with(align)
      set text(fill: self.colors.primary-dark)
      show: args.named().at("setting", default: body => body)
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
    set text(fill: self.colors.primary-dark)
    set align(horizon)
    block(width: 100%, inset: 2em, {
      text(size: 1.3em, text(weight: "medium", info.title))
      if info.subtitle != none {
        linebreak()
        text(size: 0.9em, info.subtitle)
      }
      line(length: 100%, stroke: .05em + self.colors.secondary-light)
      set text(size: .8em)
      if info.author != none {
        block(spacing: 1em, info.author)
      }
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

#let new-section-slide(self: none, short-title: auto, title) = {
  self = utils.empty-page(self)
  let content = {
    set align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em)
    title
    block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.m-progress-bar))
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: (title: title, short-title: short-title), content)
}

#let focus-slide(self: none, body) = {
  self = utils.empty-page(self)
  self.page-args = self.page-args + (
    fill: self.colors.primary-dark,
    margin: 2em,
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let slides(self: none, title-slide: true, outline-slide: true, outline-title: [Table of contents], slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  if outline-slide {
    (self.methods.slide)(self: self, title: outline-title, (self.methods.touying-outline)())
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  aspect-ratio: "16-9",
  header: states.current-section-title,
  footer: [],
  footer-right: states.slide-counter.display() + " / " + states.last-slide-number,
  footer-progress: true,
  self,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    neutral-lightest: rgb("#fafafa"),
    primary-dark: rgb("#23373b"),
    secondary-light: rgb("#eb811b"),
    secondary-lighter: rgb("#d6c6b7"),
  )
  // save the variables for later use
  self.m-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      components.cell(fill: self.colors.secondary-light),
      components.cell(fill: self.colors.secondary-lighter)
    )
  })
  self.m-footer-progress = footer-progress
  self.m-title = header
  self.m-footer = footer
  self.m-footer-right = footer-right
  // set page
  let header(self) = {
    set align(top)
    if self.m-title != none {
      show: components.cell.with(fill: self.colors.primary-dark, inset: 1em)
      set align(horizon)
      set text(fill: self.colors.neutral-lightest, size: 1.2em)
      utils.fit-to-width(grow: false, 100%, text(weight: "medium", utils.call-or-display(self, self.m-title)))
    } else { [] }
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    pad(.5em, {
      text(fill: self.colors.primary-dark.lighten(40%), utils.call-or-display(self, self.m-footer))
      h(1fr)
      text(fill: self.colors.primary-dark, utils.call-or-display(self, self.m-footer-right))
    })
    if self.m-footer-progress {
      place(bottom, block(height: 2pt, width: 100%, spacing: 0pt, utils.call-or-display(self, self.m-progress-bar)))
    }
  }
  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 3em, bottom: 1.5em, x: 0em),
  )
  self.padding = (x: 2em, y: 0em)
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.slides = slides
  self.methods.touying-outline = (self: none, enum-args: (:), ..args) => {
    states.touying-outline(enum-args: (tight: false,) + enum-args, ..args)
  }
  self.methods.alert = (self: none, it) => text(fill: self.colors.secondary-light, it)
  self
}
