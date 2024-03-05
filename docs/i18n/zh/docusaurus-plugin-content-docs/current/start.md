---
sidebar_position: 2
---

# 开始

在开始之前，请确保您已经安装了 Typst 环境，如果没有，可以使用 [Web App](https://typst.app/) 或 VS Code 的 [Typst LSP](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp) 和 [Typst Preview](https://marketplace.visualstudio.com/items?itemName=mgt19937.typst-preview) 插件。

要使用 Touying，您只需要在文档里加入

```typst
#import "@preview/touying:0.3.0": *

#let s = themes.simple.register(s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/f5bdbf8f-7bf9-45fd-9923-0fa5d66450b2)

这很简单，您创建了您的第一个 Touying slides，恭喜！🎉

## 更复杂的例子

事实上，Touying 提供了多种 slides 编写风格，实际上您也可以使用 `#slide[..]` 的写法，以获得 Touying 提供的更多更强大的功能。

```typst
#import "@preview/touying:0.3.0": *
#import "@preview/cetz:0.2.1"
#import "@preview/fletcher:0.4.2" as fletcher: node, edge

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: (arr, ..args) => fletcher.diagram(..args, ..arr))

// Register university theme
// You can remove the theme registration or replace other themes
// it can still work normally
#let s = themes.university.register(s, aspect-ratio: "16-9")

// Global information configuration
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)

// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let s = (s.methods.append-preamble)(self: s, pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
  default-transition: (
    type: "push",
    duration-seconds: 2,
    angle: ltr,
    alignment: "vertical",
    direction: "inward",
  ),
))

// Extract methods
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

// Extract slide functions
#let (slide,) = utils.slides(s)
#show: slides

= Animation

== Simple Animation

#slide[
  We can use `#pause` to #pause display something later.

  #pause
  
  Just like this.

  #meanwhile
  
  Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.
]

== Complex Animation

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  At subslide #self.subslide, we can

  use #uncover("2-")[`#uncover` function] for reserving space,

  use #only("2-")[`#only` function] for not reserving space,

  #alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
])

== Math Equation Animation

#slide[
  Touying equation with `pause`:

  #touying-equation(`
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  `)

  #meanwhile

  Here, #pause we have the expression of $f(x)$.
  
  #pause

  By factorizing, we can obtain this result.
]

== CeTZ Animation

#slide[
  CeTZ Animation in Touying:

  #cetz-canvas({
    import cetz.draw: *
    
    rect((0,0), (5,5))

    (pause,)

    rect((0,0), (1,1))
    rect((1,1), (2,2))
    rect((2,2), (3,3))

    (pause,)

    line((0,0), (2.5, 2.5), name: "line")
  })
]

== Fletcher Animation

#slide[
  Fletcher Animation in Touying:

  #fletcher-diagram(
    node-stroke: .1em,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,
    edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
    node((0,0), `reading`, radius: 2em),
    edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),
    pause,
    edge(`read()`, "-|>"),
    node((1,0), `eof`, radius: 2em),
    pause,
    edge(`close()`, "-|>"),
    node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
    edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
  )
]


= Others

== Side-by-side

#slide[
  First column.
][
  Second column.
]

== Setting

#slide(setting: body => {
  set text(fill: blue)
  body
})[
  This slide has blue text.
]

== Multiple Pages

#slide[
  #lorem(200)
]


// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.slides(s)

== Appendix

#slide[
  Please pay attention to the current slide number.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/fcecb505-d2d1-4e36-945a-225f4661a694)

Touying 提供了很多内置的主题，能够简单地编写精美的 slides，例如此处的

```
#let s = themes.university.register(s, aspect-ratio: "16-9")
```

可以使用 university 主题。关于主题更详细的教程，您可以参阅后面的章节。
