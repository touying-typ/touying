// This theme is from https://github.com/andreasKroepelin/polylux/blob/main/themes/simple.typ
// Author: Andreas Kröpelin

#import "../slide.typ": s
#import "../utils/utils.typ"
#import "../utils/states.typ"

#let slide(self: none, title: none, footer: auto, ..args) = {
  if footer != auto {
    self.simple-footer = footer
  }
  (self.methods.touying-slide)(self: self, title: title, setting: body => {
    if self.auto-heading == true and title != none {
      heading(level: 2, title)
    }
    body
  }, ..args)
}

#let centered-slide(self: none, ..args) = {
  self = utils.empty-page(self, margin: none)
  (self.methods.touying-slide)(self: self, repeat: none, ..args.named(),
    align(center + horizon, args.pos().sum(default: []))
  )
}

#let title-slide(self: none, body) = {
  centered-slide(self: self, body)
}

#let new-section-slide(self: none, section) = {
  self = utils.empty-page(self, margin: none)
  (self.methods.touying-slide)(self: self, repeat: none, section: section, align(center + horizon, heading(level: 1, states.current-section-with-numbering(self)))
  )
}

#let focus-slide(self: none, background: auto, foreground: white, body) = {
  self = utils.empty-page(self, margin: none)
  self.page-args.fill = if background == auto { self.colors.primary } else { background }
  set text(fill: foreground, size: 1.5em)
  centered-slide(self: self, align(center + horizon, body))
}

#let register(
  self: s,
  aspect-ratio: "16-9",
  footer: [],
  footer-right: states.slide-counter.display() + " / " + states.last-slide-number,
  background: rgb("#ffffff"),
  foreground: rgb("#000000"),
  primary: aqua.darken(50%),
  ..args,
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
  self.auto-heading = true
  // set page
  let header = self => deco-format(states.current-section-with-numbering(self))
  let footer(self) = deco-format(self.simple-footer + h(1fr) + self.simple-footer-right)
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    fill: self.colors.neutral-lightest,
    header: header,
    footer: footer,
    footer-descent: 1em,
    header-ascent: 1em,
  )
  self.full-header = false
  self.full-footer = false
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.centered-slide = centered-slide
  self.methods.focus-slide = focus-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.init = (self: none, body) => {
    set heading(outlined: false)
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