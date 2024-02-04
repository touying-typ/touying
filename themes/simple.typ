// This theme is from https://github.com/andreasKroepelin/polylux/blob/main/themes/simple.typ
// Author: Andreas Kröpelin

#import "../utils/utils.typ"
#import "../utils/states.typ"

#let slide(self: utils.empty-object, footer: auto, ..args) = {
  if footer != auto {
    self.simple-footer = footer
  }
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, ..args)
}

#let centered-slide(self: utils.empty-object, section: none, ..bodis) = {
  self.page-args.header = none
  self.page-args.footer = none
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, section: section,
    align(center + horizon, if section != none { heading(level: 1, utils.unify-section(section).title) } + bodis.pos().sum(default: []))
  )
}

#let title-slide(self: utils.empty-object, body) = {
  self.page-args.header = none
  self.page-args.footer = none
  let touying-slide = self.methods.touying-slide
  centered-slide(self: self, body)
}

#let focus-slide(self: utils.empty-object, background: auto, foreground: white, body) = {
  self.page-args.header = none
  self.page-args.footer = none
  self.page-args.fill = if background == auto { self.colors.primary } else { background }
  let touying-slide = self.methods.touying-slide
  set text(fill: foreground, size: 1.5em)
  centered-slide(self: self, align(center + horizon, body))
}

#let slide-in-slides(self: utils.empty-object, section: none, subsection: none, body, ..args) = {
  if section != none {
    (self.methods.centered-slide)(self: self, section: section)
  } else if subsection != none {
    (self.methods.slide)(self: self, ..args, heading(level: 2, subsection) + parbreak() + body)
  } else {
    (self.methods.slide)(self: self, ..args, body)
  }
}

#let register(
  aspect-ratio: "16-9",
  footer: [],
  footer-right: states.slide-counter.display() + " / " + states.last-slide-number,
  background: rgb("#ffffff"),
  foreground: rgb("#000000"),
  primary: aqua.darken(50%),
  self,
) = {
  let deco-format(it) = text(size: .6em, fill: gray, it)
  // color theme
  self = (self.methods.colors)(
    self: self,
    neutral-light: gray,
    neutral-lightest: background,
    neutral-darkest: foreground,
    primary: primary,
  )
  // save the variables for later use
  self.simple-footer = footer
  self.simple-footer-right = footer-right
  // set page
  let header = locate(loc => {
    let sections = states.sections-state.at(loc)
    deco-format(sections.last().title)
  })
  let footer(self) = deco-format(self.simple-footer + h(1fr) + self.simple-footer-right)
  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    fill: self.colors.neutral-lightest,
    header: header,
    footer: footer,
    footer-descent: 1em,
    header-ascent: 1em,
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.centered-slide = centered-slide
  self.methods.focus-slide = focus-slide
  self.methods.slide-in-slides = slide-in-slides
  self.methods.init = (self: utils.empty-object, body) => {
    set text(fill: foreground, size: 25pt)
    show footnote.entry: set text(size: .6em)
    show heading.where(level: 2): set block(below: 1.5em)
    set outline(target: heading.where(level: 1), title: none, fill: none)
    show outline.entry: it => it.body
    show outline: it => block(inset: (x: 1em), it)
    body
  }
  self
}