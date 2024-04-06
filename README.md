# [Touying](https://github.com/touying-typ/touying) ![logo](https://github.com/touying-typ/touying/assets/34951714/2aa394d3-2319-4572-aef7-ed3c14b09846)

[Touying](https://github.com/touying-typ/touying) (投影 in chinese, /tóuyǐng/, meaning projection) is a powerful and efficient package for creating presentation slides in Typst. Partial code is inherited from [Polylux](https://github.com/andreasKroepelin/polylux). Therefore, many concepts and APIs remain consistent with Polylux.

Touying provides an object-oriented programming (OOP) style syntax, allowing the simulation of "global variables" through a global singleton. This makes it easy to write themes. Touying does not rely on `counter` and `locate` to implement `#pause`, resulting in better performance.

If you like it, consider [giving a star on GitHub](https://github.com/touying-typ/touying). Touying is a community-driven project, feel free to suggest any ideas and contribute.

[![Book badge](https://img.shields.io/badge/docs-book-green)](https://touying-typ.github.io/touying/)
![GitHub](https://img.shields.io/github/license/touying-typ/touying)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/touying-typ/touying)
![GitHub Repo stars](https://img.shields.io/github/stars/touying-typ/touying)
![Themes badge](https://img.shields.io/badge/themes-5-aqua)

## Document

Read [the document](https://touying-typ.github.io/touying/) to learn all about Touying.

This documentation is powered by [Docusaurus](https://docusaurus.io/). We will maintain **English** and **Chinese** versions of the documentation for Touying, and for each major version, we will maintain a documentation copy. This allows you to easily refer to old versions of the Touying documentation and migrate to new versions.

## Special Features

1. `#pause` and `#meanwhile` Marks [document](https://touying-typ.github.io/touying/docs/dynamic/simple)

```typst
#slide[
  First
  
  #pause
  
  Second

  #meanwhile

  Third

  #pause

  Fourth
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/24ca19a3-b27c-4d31-ab75-09c37911e6ac)

2. Dewdrop Theme Navigation Bar [document](https://touying-typ.github.io/touying/docs/themes/dewdrop)

![image](https://github.com/touying-typ/touying/assets/34951714/0426516d-aa3c-4b7a-b7b6-2d5d276fb971)

3. `touying-equation` Math Equation Animation [document](https://touying-typ.github.io/touying/docs/dynamic/equation)

![image](https://github.com/touying-typ/touying/assets/34951714/8640fe0a-95e4-46ac-b570-c8c79f993de4)

4. `touying-reducer` Cetz and Fletcher Animations [document](https://touying-typ.github.io/touying/docs/dynamic/other)

![image](https://github.com/touying-typ/touying/assets/34951714/9ba71f54-2a5d-4144-996c-4a42833cc5cc)

5. `#show: slides` Style and `#slide[..]` Style

6. Semi-transparent Cover Mode [document](https://touying-typ.github.io/touying/docs/dynamic/cover)

![image](https://github.com/touying-typ/touying/assets/34951714/22a9ea66-c8b5-431e-a52c-2c8ca3f18e49)


## Quick start

Before you begin, make sure you have installed the Typst environment. If not, you can use the [Web App](https://typst.app/) or the Tinymist Typst and Typst Preview extensions for VS Code.

To use Touying, you only need to include the following code in your document:

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.simple.register(aspect-ratio: "16-9")
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides


= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/f5bdbf8f-7bf9-45fd-9923-0fa5d66450b2)

It's simple. Congratulations on creating your first Touying slide! 🎉

**Tip:** You can use Typst syntax like `#import "config.typ": *` or `#include "content.typ"` to implement Touying's multi-file architecture.


## More Complex Examples

In fact, Touying provides various styles for writing slides. For example, the above example uses first-level and second-level titles to create new slides. However, you can also use the `#slide[..]` format to access more powerful features provided by Touying.

```typst
#import "@preview/touying:0.4.0": *
#import "@preview/cetz:0.2.2"
#import "@preview/fletcher:0.4.3" as fletcher: node, edge
#import "@preview/ctheorems:1.1.2": *

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

// Register university theme
// You can remove the theme registration or replace other themes
// it can still work normally
#let s = themes.university.register(aspect-ratio: "16-9")

// Set the numbering of section and subsection
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")

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

// Theroems configuration by ctheorems
#show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))
#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

// Extract methods
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

// Extract slide functions
#let (slide, empty-slide) = utils.slides(s)
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


= Theroems

== Prime numbers

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]
#example[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#theorem("Euclid")[
  There are infinitely many primes.
]
#proof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

#corollary[
  There is no largest prime number.
] <cor_largest_prime>
#corollary[
  There are infinitely many composite numbers.
]

#theorem[
  There are arbitrarily long stretches of composite numbers.
]

#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere
  $
]


= Others

== Side-by-side

#slide[
  First column.
][
  Second column.
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

![image](https://github.com/touying-typ/touying/assets/34951714/5ac2b11c-9e77-4389-ade6-682c9fc3e1fb)


## Acknowledgements

Thanks to...

- [@andreasKroepelin](https://github.com/andreasKroepelin) for the `polylux` package
- [@Enivex](https://github.com/Enivex) for the `metropolis` theme
- [@drupol](https://github.com/drupol) for the `university` theme
- [@pride7](https://github.com/pride7) for the `aqua` theme
- [@ntjess](https://github.com/ntjess) for contributing to `fit-to-height`, `fit-to-width` and `cover-with-rect`
