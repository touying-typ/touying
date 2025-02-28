# ![logo](https://github.com/user-attachments/assets/58a91b14-ae1a-49e2-a3e7-5e3a148e2ba5)

[Touying](https://github.com/touying-typ/touying) (投影 in chinese, /tóuyǐng/, meaning projection) is a user-friendly, powerful and efficient package for creating presentation slides in Typst. Partial code is inherited from [Polylux](https://github.com/andreasKroepelin/polylux) like `#only()` and `#uncover()`.

Touying provides automatically injected global configurations, which is convenient for configuring themes. Besides, Touying does not rely on `counter` and `context` to implement `#pause`, resulting in better performance.

If you like it, consider [giving a star on GitHub](https://github.com/touying-typ/touying). Touying is a community-driven project, feel free to suggest any ideas and contribute.

[![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Ftouying&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=universe&color=%2339cccc)](https://typst.app/universe/package/touying)
[![Book badge](https://img.shields.io/badge/docs-book-green)](https://touying-typ.github.io/)
[![Gallery badge](https://img.shields.io/badge/docs-gallery-orange)](https://github.com/touying-typ/touying/wiki)
![GitHub](https://img.shields.io/github/license/touying-typ/touying)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/touying-typ/touying)
![GitHub Repo stars](https://img.shields.io/github/stars/touying-typ/touying)
![Themes badge](https://img.shields.io/badge/themes-6-aqua)

## Document

Read [the document](https://touying-typ.github.io/) to learn all about Touying.

We will maintain **English** and **Chinese** versions of the documentation for Touying, and for each major version, we will maintain a documentation copy. This allows you to easily refer to old versions of the Touying documentation and migrate to new versions.

**Note that the documentation may be outdated, and you can also use Tinymist to view Touying's annotated documentation by hovering over the code.**

## Gallery

Touying offers [a gallery page](https://github.com/touying-typ/touying/wiki) via wiki, where you can browse elegant slides created by Touying users. You're also encouraged to contribute your own beautiful slides here!

## Special Features

1. Split slides by headings [document](https://touying-typ.github.io/docs/sections)

```typst
= Section

== Subsection

=== First Slide

Hello, Touying!

=== Second Slide

Hello, Typst!
```

2. `#pause` and `#meanwhile` animations [document](https://touying-typ.github.io/docs/dynamic/simple)

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

3. Math Equation Animation [document](https://touying-typ.github.io/docs/dynamic/equation)

![image](https://github.com/touying-typ/touying/assets/34951714/8640fe0a-95e4-46ac-b570-c8c79f993de4)

4. `touying-reducer` Cetz and Fletcher Animations [document](https://touying-typ.github.io/docs/dynamic/other)

![image](https://github.com/touying-typ/touying/assets/34951714/9ba71f54-2a5d-4144-996c-4a42833cc5cc)

5. Correct outline and bookmark (no duplicate and correct page number)

![image](https://github.com/touying-typ/touying/assets/34951714/7b62fcaf-6342-4dba-901b-818c16682529)

6. Dewdrop Theme Navigation Bar [document](https://touying-typ.github.io/docs/themes/dewdrop)

![image](https://github.com/touying-typ/touying/assets/34951714/0426516d-aa3c-4b7a-b7b6-2d5d276fb971)

7. Semi-transparent cover mode [document](https://touying-typ.github.io/docs/dynamic/cover)

![image](https://github.com/touying-typ/touying/assets/34951714/22a9ea66-c8b5-431e-a52c-2c8ca3f18e49)

8. Speaker notes for dual-screen [document](https://touying-typ.github.io/docs/external/pympress)

![image](https://github.com/touying-typ/touying/assets/34951714/afbe17cb-46d4-4507-90e8-959c53de95d5)

9. Export slides to PPTX and HTML formats and show presentation online. [touying-exporter](https://github.com/touying-typ/touying-exporter) [touying-template](https://github.com/touying-typ/touying-template) [online](https://touying-typ.github.io/touying-template/)

![image](https://github.com/touying-typ/touying-exporter/assets/34951714/207ddffc-87c8-4976-9bf4-4c6c5e2573ea)


## Quick start

Before you begin, make sure you have installed the Typst environment. If not, you can use the [Web App](https://typst.app/) or the [Tinymist LSP](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extensions for VS Code.

To use Touying, you only need to include the following code in your document:

```typst
#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

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
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
  aspect-ratio: "16-9",
  // align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Animation

== Simple Animation

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]


== Complex Animation

At subslide #touying-fn-wrapper((self: none) => str(self.subslide)), we can

use #uncover("2-")[`#uncover` function] for reserving space,

use #only("2-")[`#only` function] for not reserving space,

#alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.


== Callback Style Animation

#slide(
  repeat: 3,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    At subslide #self.subslide, we can

    use #uncover("2-")[`#uncover` function] for reserving space,

    use #only("2-")[`#only` function] for not reserving space,

    #alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
  ],
)


== Math Equation Animation

Equation with `pause`:

$
  f(x) &= pause x^2 + 2x + 1 \
  &= pause (x + 1)^2 \
$

#meanwhile

Here, #pause we have the expression of $f(x)$.

#pause

By factorizing, we can obtain this result.


== CeTZ Animation

CeTZ Animation in Touying:

#cetz-canvas({
  import cetz.draw: *

  rect((0, 0), (5, 5))

  (pause,)

  rect((0, 0), (1, 1))
  rect((1, 1), (2, 2))
  rect((2, 2), (3, 3))

  (pause,)

  line((0, 0), (2.5, 2.5), name: "line")
})


== Fletcher Animation

Fletcher Animation in Touying:

#fletcher-diagram(
  node-stroke: .1em,
  node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
  spacing: 4em,
  edge((-1, 0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
  node((0, 0), `reading`, radius: 2em),
  edge((0, 0), (0, 0), `read()`, "--|>", bend: 130deg),
  pause,
  edge(`read()`, "-|>"),
  node((1, 0), `eof`, radius: 2em),
  pause,
  edge(`close()`, "-|>"),
  node((2, 0), `closed`, radius: 2em, extrude: (-2.5, 0)),
  edge((0, 0), (2, 0), `close()`, "-|>", bend: -40deg),
)


= Theorems

== Prime numbers

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]
#example[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#theorem(title: "Euclid")[
  There are infinitely many primes.
]
#pagebreak(weak: true)
#proof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$. Since
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
    n! + 2, quad n! + 3, quad ..., quad n! + n
  $
]


= Others

== Side-by-side

#slide(composer: (1fr, 1fr))[
  First column.
][
  Second column.
]


== Multiple Pages

#lorem(200)


#show: appendix

= Appendix

== Appendix

Please pay attention to the current slide number.
```

![image](https://github.com/user-attachments/assets/b1dfc4d9-e263-46ff-8588-a0635870e370)


## Acknowledgements

Thanks to...

- [@andreasKroepelin](https://github.com/andreasKroepelin) for the `polylux` package
- [@enklht](https://github.com/enklht) for many fixes and improvements
- [@Enivex](https://github.com/Enivex) for the `metropolis` theme
- [@drupol](https://github.com/drupol) for the `university` theme
- [@pride7](https://github.com/pride7) for the `aqua` theme
- [@Coekjan](https://github.com/Coekjan) and [@QuadnucYard](https://github.com/QuadnucYard) for the `stargazer` theme
- [@ntjess](https://github.com/ntjess) for contributing to `fit-to-height`, `fit-to-width` and `cover-with-rect`

## Poster

![poster](https://github.com/user-attachments/assets/e1ddb672-8e8f-472d-b364-b8caed1da16b)


[View Code](https://github.com/touying-typ/touying-poster)

## Star History

<a href="https://star-history.com/#touying-typ/touying&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=touying-typ/touying&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=touying-typ/touying&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=touying-typ/touying&type=Date" />
 </picture>
</a>