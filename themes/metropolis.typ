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

#let slide(
  self: utils.empty-object,
  title: auto,
  footer: auto,
  align: horizon,
  margin: (top: 3em, bottom: 1em, left: 0em, right: 0em),
  padding: 2em,
  ..args
) = {
  self.page-args = self.page-args + (
    margin: margin,
    fill: self.m-colors.extra-light-gray,
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
      show: pad.with(padding)
      set text(fill: self.m-colors.dark-teal)
      show: args.named().at("setting", default: body => body)
      body
    },
    ..args.pos(),
  )
}

#let title-slide(
  self: utils.empty-object,
  title: auto,
  subtitle: auto,
  author: auto,
  date: auto,
  institution: auto,
  extra: none,
  hide-header: true,
  hide-footer: true,
) = {
  if hide-header {
    self.page-args.header = none
  }
  if hide-footer {
    self.page-args.footer = none
  }
  if title == auto {
    title = self.title
  }
  if subtitle == auto {
    subtitle = self.subtitle
  }
  if author == auto {
    author = self.author
  }
  if date == auto {
    date = self.date
  }
  if institution == auto {
    institution = self.institution
  }
  let content = {
    set text(fill: self.m-colors.dark-teal)
    set align(horizon)
    block(width: 100%, inset: 2em, {
      text(size: 1.3em, strong(title))
      if subtitle != none {
        linebreak()
        text(size: 0.9em, subtitle)
      }
      line(length: 100%, stroke: .05em + self.m-colors.light-brown)
      set text(size: .8em)
      if author != none {
        block(spacing: 1em, author)
      }
      if date != none {
        block(spacing: 1em, date)
      }
      set text(size: .8em)
      if institution != none {
        block(spacing: 1em, institution)
      }
      if extra != none {
        block(spacing: 1em, extra)
      }
    
    })
  }
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, content)
}

#let new-section-slide(self: utils.empty-object, short-title: auto, hide-header: true, hide-footer: true, title) = {
  if hide-header {
    self.page-args.header = none
  }
  if hide-footer {
    self.page-args.footer = none
  }
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

#let focus-slide(self: utils.empty-object, hide-header: true, hide-footer: true, body) = {
  if hide-header {
    self.page-args.header = none
  }
  if hide-footer {
    self.page-args.footer = none
  }
  self.page-args = self.page-args + (
    fill: self.m-colors.dark-teal,
    margin: 2em,
  )
  set text(fill: self.m-colors.extra-light-gray, size: 1.5em)
  let touying-slide = self.methods.touying-slide
  touying-slide(self: self, repeat: none, align(horizon + center, body))
}

#let register(
  aspect-ratio: "16-9",
  header: states.current-section-title,
  footer: [],
  title: [],
  short-title: auto,
  subtitle: none,
  author: none,
  date: none,
  institution: none,
  self,
) = {
  // infos
  self += (
    title: title,
    short-title: short-title,
    subtitle: subtitle,
    author: author,
    date: date,
    institution: institution,
  )
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
    extra-light-gray: rgb("#fafafa"),
  )
  self.m-progress-bar = states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      (self.m-cell)(fill: self.m-colors.light-brown),
      (self.m-cell)(fill: self.m-colors.lighter-brown)
    )
  })
  self.m-footer = footer
  self.m-title = header
  // set page
  let header(self) = {
    set align(top)
    if self.m-title != none {
      show: self.m-cell.with(fill: self.m-colors.dark-teal, inset: 1em)
      set align(horizon)
      set text(fill: self.m-colors.extra-light-gray, size: 1.2em)
      utils.fit-to-width(grow: false, 100%, strong(utils.call-or-display(self, self.m-title)))
    } else { [] }
  }
  let footer(self) = {
    set text(size: 0.8em)
    show: pad.with(.5em)
    set align(bottom)
    text(fill: self.m-colors.dark-teal.lighten(40%), utils.call-or-display(self, self.m-footer))
    h(1fr)
    text(fill: self.m-colors.dark-teal, states.slide-counter.display() + " / " + states.last-slide-number)
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
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.touying-outline = (self: utils.empty-object, enum-args: (:), ..args) => {
    states.touying-outline(enum-args: (tight: false,) + enum-args, ..args)
  }
  self.methods.alert = (self: utils.empty-object, it) => text(fill: self.m-colors.light-brown, it)
  self
}

