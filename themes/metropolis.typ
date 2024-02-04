// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex

// Consider using:
// #set text(font: "Fira Sans", weight: "light", size: 20pt)
// #show math.equation: set text(font: "Fira Math")
// #set strong(delta: 100)
// #set par(justify: true)

#import "../utils/utils.typ"
#import "../utils/states.typ"

#let _saved-align = align
#let m-cell = block.with(
  width: 100%,
  height: 100%,
  above: 0pt,
  below: 0pt,
  breakable: false,
)

#let slide(
  self: utils.empty-object,
  title: auto,
  footer: auto,
  align: horizon,
  margin: (top: 3em, bottom: 1em, left: 0em, right: 0em),
  padding: 2em,
  ..args,
) = {
  self.page-args = self.page-args + (
    margin: margin,
    fill: self.colors.neutral-lightest,
  )
  if title != auto {
    self.m-title = title
  }
  if footer != auto {
    self.m-footer = footer
  }
  let touying-slide = self.methods.touying-slide
  touying-slide(
    ..args.named(),
    self: self,
    setting: body => {
      show: _saved-align.with(align)
      show: pad.with(..(if type(padding) == dictionary { padding } else { (padding,) }))
      set text(fill: self.colors.primary-dark)
      show: args.named().at("setting", default: body => body)
      body
    },
    ..args.pos(),
  )
}

#let title-slide(
  self: utils.empty-object,
  extra: none,
  ..args,
) = {
  self.page-args.header = none
  self.page-args.footer = none
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
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, content)
}

#let new-section-slide(self: utils.empty-object, short-title: auto, title) = {
  self.page-args.header = none
  self.page-args.footer = none
  let content = {
    set align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em)
    title
    block(height: 2pt, width: 100%, spacing: 0pt, self.m-progress-bar)
  }
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, section: (title: title, short-title: short-title), content)
}

#let focus-slide(self: utils.empty-object, body) = {
  self.page-args.header = none
  self.page-args.footer = none
  self.page-args = self.page-args + (
    fill: self.colors.primary-dark,
    margin: 2em,
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, align(horizon + center, body))
}

#let slide-in-slides(self: utils.empty-object, section: none, subsection: none, body, ..args) = {
  if section != none {
    (self.methods.new-section-slide)(self: self, section)
  } else if subsection != none {
    (self.methods.slide)(self: self, ..args, title: subsection, body)
  } else {
    (self.methods.slide)(self: self, ..args, body)
  }
}

#let slides(self: utils.empty-object, title-slide: true, outline-slide: true, outline-title: [Table of contents], ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  if outline-slide {
    (self.methods.slide)(self: self, title: outline-title, (self.methods.touying-outline)())
  }
  (self.methods.touying-slides)(self: self, ..args)
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
  self.m-progress-bar = states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      m-cell(fill: self.colors.secondary-light),
      m-cell(fill: self.colors.secondary-lighter)
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
      show: m-cell.with(fill: self.colors.primary-dark, inset: 1em)
      set align(horizon)
      set text(fill: self.colors.neutral-lightest, size: 1.2em)
      utils.fit-to-width(grow: false, 100%, text(weight: "medium", utils.call-or-display(self, self.m-title)))
    } else { [] }
  }
  let footer(self) = {
    set text(size: 0.8em)
    set align(bottom)
    pad(.5em, {
      text(fill: self.colors.primary-dark.lighten(40%), utils.call-or-display(self, self.m-footer))
      h(1fr)
      text(fill: self.colors.primary-dark, utils.call-or-display(self, self.m-footer-right))
    })
    if self.m-footer-progress {
      place(bottom, block(height: 2pt, width: 100%, spacing: 0pt, self.m-progress-bar))
    }
  }
  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    fill: self.colors.neutral-lightest,
    header: header,
    footer: footer,
    margin: 0em,
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.slides = slides
  self.methods.slide-in-slides = slide-in-slides
  self.methods.touying-outline = (self: utils.empty-object, enum-args: (:), ..args) => {
    states.touying-outline(enum-args: (tight: false,) + enum-args, ..args)
  }
  self.methods.alert = (self: utils.empty-object, it) => text(fill: self.colors.secondary-light, it)
  self
}
