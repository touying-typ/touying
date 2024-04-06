#import "../slide.typ": s
#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"

#let title-slide(self: none, ..args) = {
  self = utils.empty-page(self)
  self.page-args += (
    margin: (top: 30%, left: 17%, right: 17%, bottom: 0%),
    background: utils.call-or-display(self, self.aqua-background),
  )
  let info = self.info + args.named()

  let content = {
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
          utils.info-date(self),
        )
      }
    )
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let outline-slide(self: none, enum-args: (:), leading: 50pt) = {
  self = utils.empty-page(self)
  self.page-args += (
    background: utils.call-or-display(self, self.aqua-background),
  )
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
          if self.aqua-lang == "zh" {
            text(
              size: 80pt, 
              weight: "bold",
              [#text(size:36pt)[CONTENTS]\ 目录]
            )
          } else if self.aqua-lang == "en" {
            text(
              size: 48pt, 
              weight: "bold",
              [CONTENTS]
            )
          }
        }
      ),
      align(
        left + horizon,
        {
          set par(leading: leading)
          set text(weight: "bold")
          (self.methods.touying-outline)(self: self, enum-args: (numbering: self.numbering, ..enum-args))
        }
      )
    )
  }
  (self.methods.touying-slide)(self: self, repeat: none, body)
}

#let new-section-slide(self: none, section) = {
  self = utils.empty-page(self)
  self.page-args += (
    margin: (left:0%, right:0%, top: 20%, bottom:0%),
    background: utils.call-or-display(self, self.aqua-background),
  )
  let body = {
    stack(
      dir: ttb,
      spacing: 12%,
      align(
        center,
        text(
          fill: self.colors.primary,
          size: 166pt,
          states.current-section-number(numbering: self.numbering)
        )
      ),
      align(
        center,
        text(
          fill: self.colors.primary,
          size: 60pt,
          weight: "bold",
          section
        )
      )
    ) 
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: section, body)
}

#let focus-slide(self: none, body) = {
  self = utils.empty-page(self)
  self.page-args += (fill: self.colors.primary, margin: 2em)
  set text(fill: white, size: 2em, weight: "bold")
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let slide(self: none, title: auto, ..args) = {
  if title != auto {
    self.aqua-title = title
  }
  (self.methods.touying-slide)(
    self: self,
    setting: body => {
      show heading.where(level:1): body => text(fill: self.colors.primary-light)[#body#v(3%)]
      body
    },
    ..args,
  )
}

#let slides(self: none, title-slide: true, outline-slide: true, slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  if outline-slide {
    (self.methods.outline-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  self: s,
  aspect-ratio: "16-9",
  footer: states.slide-counter.display(),
  lang: "en",
) = {
  assert(lang in ("zh", "en"), message: "lang must be 'zh' or 'en'")

  self = (self.methods.colors)(
    self: self,
    primary: rgb("#003F88"),
    primary-light: rgb("#2159A5"),
    primary-lightest: rgb("#F2F4F8"),
  )

  self.aqua-title = states.current-section-with-numbering
  self.aqua-footer = footer
  self.aqua-lang = lang
  self.aqua-background = (self) => {
    place(left + top, dx: -15pt, dy: -26pt,
      circle(radius: 40pt, fill: self.colors.primary))
    place(left + top, dx: 65pt, dy: 12pt,
      circle(radius: 21pt, fill: self.colors.primary))
    place(left + top, dx: 3%, dy: 15%,
      circle(radius: 13pt, fill: self.colors.primary))
    place(left + top, dx: 2.5%, dy: 27%,
      circle(radius: 8pt, fill: self.colors.primary))
    place(right + bottom, dx: 15pt, dy: 26pt,
      circle(radius: 40pt, fill: self.colors.primary))
    place(right + bottom, dx: -65pt, dy: -12pt,
      circle(radius: 21pt, fill: self.colors.primary))
    place(right + bottom, dx: -3%, dy: -15%,
      circle(radius: 13pt, fill: self.colors.primary))
    place(right + bottom, dx: -2.5%, dy: -27%,
      circle(radius: 8pt, fill: self.colors.primary))
    polygon(fill: self.colors.primary-lightest,
      (35%, -17%), (70%, 10%), (35%, 30%), (0%, 10%))
    place(center + horizon, dy: 7%,
      ellipse(fill: white, width: 45%, height: 120pt))
    place(center + horizon, dy: 5%,
      ellipse(fill: self.colors.primary-lightest, width: 40%, height: 80pt))
    place(center + horizon, dy: 12%,
      rect(fill: self.colors.primary-lightest, width: 40%, height: 60pt))
    place(center + horizon, dy: 20%,
      ellipse(fill: white, width: 40%, height: 70pt))
    place(center + horizon, dx: 28%, dy: -6%,
      circle(radius: 13pt, fill: white))
  }
  let header(self) = {
    place(center + top, dy: .5em,
      rect(
        width: 100%,
        height: 1.8em,
        fill: self.colors.primary,
        align(left + horizon, h(1.5em) + text(fill:white, utils.call-or-display(self, self.aqua-title)))
      )
    )
    place(left + top, line(start: (30%, 0%), end: (27%, 100%), stroke: .5em + white))
  }
  let footer(self) = {
    set text(size: 0.8em)
    place(right, dx: -5%, utils.call-or-display(self, utils.call-or-display(self, self.aqua-footer)))
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    margin: (x: 2em, top: 3.5em, bottom: 2em),
    header: header,
    footer: footer,
  )
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self.numbering = "01"
  self.methods.title-slide = title-slide
  self.methods.outline-slide = outline-slide
  self.methods.focus-slide = focus-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.slide = slide
  self.methods.slides = slides
  self
}
