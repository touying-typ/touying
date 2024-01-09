#import "../slide.typ": empty-object, methods, call-or-display, slide-counter, last-slide-number, touying-progress

#let _saved-align = align

#let slide(
  self: empty-object,
  title: auto,
  align: horizon,
  margin: (top: 3em, bottom: 1em, left: 0em, right: 0em),
  padding: 2em,
  body,
  ..args
) = {
  self.page-args = self.page-args + (
    margin: margin,
    fill: self.m-colors.extra-light-gray,
  )
  if title != auto {
    self.m-title = title
  }
  let touying-slide = self.methods.touying-slide
  touying-slide(
    ..args,
    self: self,
    setting: body => {
      show: _saved-align.with(align)
      show: pad.with(padding)
      set text(fill: self.m-colors.dark-teal)
      show: args.named().at("setting", default: body => body)
      body
    },
    body,
  )
}

#let register(aspect-ratio: "16-9", footer: [], self) = {
  // save the variables for later use
  self.m-cell = block.with(
    width: 100%,
    height: 100%,
    above: 0pt,
    below: 0pt,
    breakable: false,
  )
  self.m-colors = (
    dark-teal: rgb("#23373b"),
    light-brown: rgb("#eb811b"),
    lighter-brown: rgb("#d6c6b7"),
    extra-light-gray: white.darken(2%),
  )
  self.m-progress-bar = touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      self.m-cell(fill: m-light-brown),
      self.m-cell(fill: m-lighter-brown)
    )
  })
  self.m-footer = footer
  self.m-title = []
  // set page
  let header(self) = {
    set align(top)
    if self.m-title != none {
      show: self.m-cell.with(fill: self.m-colors.dark-teal, inset: 1em)
      set align(horizon)
      set text(fill: self.m-colors.extra-light-gray, size: 1.2em)
      strong(call-or-display(self, self.m-title))
    } else { [] }
  }
  let footer(self) = {
    set text(size: 0.8em)
    show: pad.with(.5em)
    set align(bottom)
    text(fill: self.m-colors.dark-teal.lighten(40%), call-or-display(self, self.m-footer))
    h(1fr)
    text(fill: self.m-colors.dark-teal, slide-counter.display() + " / " + last-slide-number)
  }
  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    fill: self.m-colors.extra-light-gray,
    header: header,
    footer: footer,
    margin: 0em,
  )
  // register methods
  self.methods.slide = slide
  self
}

