#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"

#let title-slide(self: none) = {
  self = utils.empty-page(self)
  self.page-args = self.page-args + (
    margin: (top: 30%, left:17%, right:17%, bottom:0%),
    background: self.background,
  )
  let info = self.info

  let content = {
    stack(
      spacing: 3em,
      if info.title != none {
        align(
          center,
          text(
            size: 48pt, 
            weight: "bold",
            fill: self.title_color,
            info.title
          )
        )
      },
      if info.author != none {
        align(
          center, 
          text(
            fill: self.author_color,
            size: 28pt, 
            weight: "regular",
            [#info.author]
          )
        )
      },
      if info.date != none {
        align(
          center, 
            text(
              fill: self.date_color,
              size: 20pt, 
              weight: "regular",
              info.date.display()
            )
          )
      }
    )
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let outline-slide(self: none, leading:50pt, body) = {
  self = utils.empty-page(self)
  set text(size: 30pt,fill: self.title_color)
  set par(leading: leading)
  self.page-args = self.page-args + (
    background: self.background,
  )

  let body = {
    grid(
    columns: (1fr,1fr),
    rows: (1fr),
    align(
      center+horizon,
      {
        set par(leading: 20pt)
      text(
        size: 80pt, 
        weight: "bold",
        [#text(size:36pt)[CONTENTS]\ 目录]
      )}
    ),
    align(
      left+horizon,
      body
    )
  )
  }
  (self.methods.touying-slide)(self: self, repeat: none, body)
} 



#let new-section-slide(self: none, section) = {
  self = utils.empty-page(self)
  self.page-args = self.page-args + (
    margin: (left:0%, right:0%, top: 20%, bottom:0%),
    background: self.background,
  )
  let body = {
    self.section_num.step()
    stack(
      dir: ttb,
      spacing: 12%,
      align(
        center,
        text(
          fill: self.title_color,
          size: 166pt, 
          [0#self.section_num.display()]
        )
      ),
      align(
        center,
        text(
          fill: self.title_color,
          size: 60pt, 
          weight: "bold",
          section
        )
      )
    ) 
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: section, body)
}

#let slide(self: none, title:auto, ..args) = {
  self = utils.empty-page(self)

  if title != auto {
    self.slide_title = title
  }
  self.page-args = self.page-args + (
    margin: (x:0em, top:10%),
    header: {
    place(
      center+top,
      dy: 45%,
      rect(width: 100%, height: 100%, fill: self.title_color),
    )
    place(
      left+top,
      line(start: (30%, 30%), end: (27%, 200%), stroke: 7pt+white),
    )
    place(
      left+bottom,
      dx: 4%,
      dy: 15%,
      text(
        fill:white,
        self.slide_title
      ))
    },
    footer: {
    set text(size:0.8em)
    place(
      right,
      dx: -5%, 
      [#counter(page).display("1")]
    )
  }
  )
  self.padding = self.padding + (x: 5%, top:7%)
  (self.methods.touying-slide)(self: self, setting: body=>{
    show heading.where(level:1): body => text(fill: self.author_color)[#body#v(3%)]
    body
  },..args)
}

#let end-slide(self: none) = {
  self.page-args = self.page-args + (
    margin: (x:0em, y:10%),
  )
  self.padding = self.padding + (x: 5%, top:1em)
  (self.methods.slide)(self:self, title:[总结], setting: body =>{
    v(15%)
    stack(
      spacing: 60pt,
      align(
        center,
        text(size:70pt,fill:self.author_color,weight: "bold")[THANKS FOR ALL]
      ),
      align(
        center,
        text(size:60pt,fill:self.author_color,weight: "bold")[敬请指正！]
      )
    )
  })
}

#let register(
  aspect-ratio: "16-9",
  self,
) = {
  self.title_color = rgb(0, 63, 136)
  self.author_color = rgb(33,89,165)
  self.date_color = rgb(33,89,165)
  self.icon_color = rgb(242,244,248)
  self.slide_title = []
  self.section_num = counter("section")
  self.background = {
  place(
    left+top,
    dx: -15pt,
    dy: -26pt,
    circle(
    radius: 40pt,
    fill: self.title_color,
    )
  )
  place(
    left+top,
    dx: 65pt,
    dy: 12pt,
    circle(
    radius: 21pt,
    fill: self.title_color,
    )
  )
  place(
    left+top,
    dx: 3%,
    dy: 15%,
    circle(
    radius: 13pt,
    fill: self.title_color,
    )
  )
  place(
    left+top,
    dx: 2.5%,
    dy: 27%,
    circle(
    radius: 8pt,
    fill: self.title_color,
    )
  )
  place(
    right+bottom,
    dx: 15pt,
    dy: 26pt,
    circle(
    radius: 40pt,
    fill: self.title_color,
    )
  )
  place(
    right+bottom,
    dx: -65pt,
    dy: -12pt,
    circle(
    radius: 21pt,
    fill: self.title_color,
    )
  )
  place(
    right+bottom,
    dx: -3%,
    dy: -15%,
    circle(
    radius: 13pt,
    fill: self.title_color,
    )
  )
  place(
    right+bottom,
    dx: -2.5%,
    dy: -27%,
    circle(
    radius: 8pt,
    fill: self.title_color,
    )
  )
  polygon(
    fill: self.icon_color,
    (35%, -17%),
    (70%, 10%),
    (35%, 30%),
    (0%, 10%),
  )
  place(
    center+horizon,
    dy: 7%,
    ellipse(
      fill: white,
      width: 45%, 
      height: 120pt
    )
  )
  place(
    center+horizon,
    dy: 5%,
    ellipse(
      fill: self.icon_color,
      width: 40%, 
      height: 80pt
    )
  )
  place(
    center+horizon,
    dy: 12%,
    rect(
      fill: self.icon_color,
      width: 40%, 
      height: 60pt
    )
  )
  place(
    center+horizon,
    dy: 20%,
    ellipse(
      fill: white,
      width: 40%, 
      height: 70pt
    )
  )
  place(
    center+horizon,
    dx: 28%,
    dy: -6%,
    circle(
      radius: 13pt,
      fill: white,
    ) 
  )
}

  let footer(self) = {
  set text(size:0.8em)
  place(
    right,
    dx: -5%, 
    [#counter(page).display("1")]
  )
}

  let header(self)={
  place(
    center+top,
    dy: 45%,
    image("./images/header.png", width: 100%)
  )
  states.current-section-title
  set text(fill:white)
  place(
    left+bottom,
    dx: 4%,
    dy: 15%,
    self.slide_title
  )
}

  self.page-args = self.page-args + (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
  )
  self.methods.init = (self: none, body) => {
    set text(
    font: ("Microsoft YaHei"),
    size: 20pt,
    )
    body
  }

  self.methods.title-slide = title-slide
  self.methods.outline-slide = outline-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.slide = slide
  self.methods.end-slide = end-slide
  self
}