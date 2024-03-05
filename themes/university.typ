// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"

#let slide(
  self: none,
  title: none,
  subtitle: none,
  header: none,
  footer: auto,
  ..args,
) = {
  if title != auto {
    self.uni-title = title
  }
  self.uni-header = self => {
    if header != none {
      header
    } else if title != none {
      block(inset: (x: .5em), 
        grid(
          columns: 1,
          gutter: .3em,
          grid(
            columns: (auto, 1fr, auto),
            align(top + left, heading(level: 2, text(fill: self.colors.primary, title))),
            [],
            align(top + right, text(fill: self.colors.primary.lighten(65%), states.current-section-title))
          ),
          text(fill: self.colors.primary.lighten(65%), size: .8em, subtitle)
        )
      )
    }
  }
  if footer != auto {
    self.uni-footer = footer
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    setting: body => {
      show: args.named().at("setting", default: body => body)
      body
    },
    ..args.pos(),
  )
}

#let title-slide(
  self: none,
  logo: none,
  ..args,
) = {
  self = utils.empty-page(self)
  let info = self.info + args.named()
  info.authors = {
    let authors =  if "authors" in info { info.authors } else { info.author }
    if type(authors) == array { authors } else { (authors,) }
  }
  let content = {
    if logo != none {
      align(right, logo)
    }
    align(center + horizon, {
      block(
        inset: 0em,
        breakable: false,
        {
          text(size: 2em, fill: self.colors.primary, strong(info.title))
          if info.subtitle != none {
            parbreak()
            text(size: 1.2em, fill: self.colors.primary, info.subtitle)
          }
        }
      )
      set text(size: .8em)
      grid(
        columns: (1fr,) * calc.min(info.authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..info.authors.map(author => text(fill: black, author))
      )
      v(1em)
      if info.institution != none {
        parbreak()
        text(size: .9em, info.institution)
      }
      if info.date != none {
        parbreak()
        text(size: .8em, if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
      }
    })
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let focus-slide(self: none, background-color: none, background-img: none, body) = {
  let background-color = if background-img == none and background-color ==  none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  self = utils.empty-page(self)
  self.page-args = self.page-args + (
    fill: self.colors.primary-dark,
    margin: 1em,
    ..(if background-color != none { (fill: background-color) }),
    ..(if background-img != none { (background: {
        set image(fit: "stretch", width: 100%, height: 100%)
        background-img
      })
    }),
  )
  set text(fill: white, size: 2em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon, body))
}

#let matrix-slide(self: none, columns: none, rows: none, ..bodies) = {
  self = utils.empty-page(self)
  (self.methods.touying-slide)(self: self, composer: (..bodies) => {
    let bodies = bodies.pos()
    let columns = if type(columns) == int {
      (1fr,) * columns
    } else if columns == none {
      (1fr,) * bodies.len()
    } else {
      columns
    }
    let num-cols = columns.len()
    let rows = if type(rows) == int {
      (1fr,) * rows
    } else if rows == none {
      let quotient = calc.quo(bodies.len(), num-cols)
      let correction = if calc.rem(bodies.len(), num-cols) == 0 { 0 } else { 1 }
      (1fr,) * (quotient + correction)
    } else {
      rows
    }
    let num-rows = rows.len()
    if num-rows * num-cols < bodies.len() {
      panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(bodies.len()) + ")")
    }
    let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
    let color-body(idx-body) = {
      let (idx, body) = idx-body
      let (row, col) = cart-idx(idx)
      let color = if calc.even(row + col) { white } else { silver }
      set align(center + horizon)
      rect(inset: .5em, width: 100%, height: 100%, fill: color, body)
    }
    let content = grid(
      columns: columns, rows: rows,
      gutter: 0pt,
      ..bodies.enumerate().map(color-body)
    )
    content
  }, ..bodies)
}

#let slides(self: none, title-slide: true, slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  aspect-ratio: "16-9",
  progress-bar: true,
  self,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#04364A"),
    secondary: rgb("#176B87"),
    tertiary: rgb("#448C95"),
  )
  // save the variables for later use
  self.uni-enable-progress-bar = progress-bar
  self.uni-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: self.colors.primary),
      components.cell(fill: self.colors.secondary)
    )
  })
  self.uni-header = none
  self.uni-footer = self => {
    let cell(fill: none, it) = rect(
      width: 100%, height: 100%, inset: 1mm, outset: 0mm, fill: fill, stroke: none,
      align(horizon, text(fill: white, it))
    )
    show: block.with(width: 100%, height: auto, fill: self.colors.secondary)
    grid(
      columns: (25%, 1fr, 15%, 10%),
      rows: (1.5em, auto),
      cell(fill: self.colors.primary, self.info.author),
      cell(fill: self.colors.secondary, if self.info.short-title == auto {
        self.info.title
      } else {
        self.info.short-title
      }),
      cell(fill: self.colors.tertiary, if type(self.info.date) == datetime { self.info.date.display(self.datetime-format) } else { self.info.date }),
      cell(fill: self.colors.tertiary, states.slide-counter.display() + [~/~] + states.last-slide-number)
    )
  }
  // set page
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      row-gutter: 3mm,
      if self.uni-enable-progress-bar {
        utils.call-or-display(self, self.uni-progress-bar)
      },
      utils.call-or-display(self, self.uni-header),
    )
  }
  let footer(self) = {
    set text(size: .4em)
    set align(center + bottom)
    utils.call-or-display(self, self.uni-footer)
  }

  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 2.5em, bottom: 1em, x: 0em),
  )
  self.padding = (x: 2em, y: 0em)
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.focus-slide = focus-slide
  self.methods.matrix-slide = matrix-slide
  self.methods.slides = slides
  self.methods.touying-outline = (self: none, enum-args: (:), ..args) => {
    states.touying-outline(enum-args: (tight: false,) + enum-args, ..args)
  }
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 25pt)
    show footnote.entry: set text(size: .6em)
    body
  }
  self
}
