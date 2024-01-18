# [Touying](https://github.com/touying-typ/touying) ![logo](https://github.com/touying-typ/touying/assets/34951714/2aa394d3-2319-4572-aef7-ed3c14b09846)

[Touying](https://github.com/touying-typ/touying) (投影 in chinese, /tóuyǐng/, meaning projection) is an object-oriented and efficient package for creating presentation slides in Typst. Touying is a package derived from [Polylux](https://github.com/andreasKroepelin/polylux). Therefore, many concepts and APIs remain consistent with Polylux.

Touying provides an object-oriented programming (OOP) style syntax, allowing the simulation of "global variables" through a global singleton. This makes it easy to write themes. Touying does not rely on `counter` and `locate` to implement `#pause`, resulting in better performance.

If you like it, consider [giving a star on GitHub](https://github.com/touying-typ/touying). Touying is a community-driven project, feel free to suggest any ideas and contribute.

[![Book badge](https://img.shields.io/badge/docs-book-green)](https://touying-typ.github.io/touying/)
![GitHub](https://img.shields.io/github/license/touying-typ/touying)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/touying-typ/touying)
![GitHub Repo stars](https://img.shields.io/github/stars/touying-typ/touying)
![Themes badge](https://img.shields.io/badge/themes-3-aqua)

## Document

Read [the document](https://touying-typ.github.io/touying/) to learn all about Touying.

This documentation is powered by [Docusaurus](https://docusaurus.io/). We will maintain **English** and **Chinese** versions of the documentation for Touying, and for each major version, we will maintain a documentation copy. This allows you to easily refer to old versions of the Touying documentation and migrate to new versions.

## Quick start

Before you begin, make sure you have installed the Typst environment. If not, you can use the [Web App](https://typst.app/) or the Typst LSP and Typst Preview plugins for VS Code.

To use Touying, you only need to include the following code in your document:

```typst
#import "@preview/touying:0.2.0": *

#let (init, slide, slides) = utils.methods(s)
#show: init

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

It's simple. Congratulations on creating your first Touying slide! 🎉


## More Complex Examples

In fact, Touying provides various styles for writing slides. For example, the above example uses first-level and second-level titles to create new slides. However, you can also use the `#slide[..]` format to access more powerful features provided by Touying.

```typst
#import "@preview/touying:0.2.0": *

#let s = themes.metropolis.register(s, aspect-ratio: "16-9")
#let s = (s.methods.enable-transparent-cover)(self: s)
#let (init, slide) = utils.methods(s)
#show: init

// simple animations
#slide[
  a simple #pause *dynamic*

  #pause
  
  slide.

  #meanwhile

  meanwhile #pause with pause.
][
  second #pause pause.
]

// complex animations
#slide(setting: body => {
  set text(fill: blue)
  body
}, repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  in subslide #self.subslide

  test #uncover("2-")[uncover] function

  test #only("2-")[only] function

  #pause

  and paused text.
])

// math equation animations
#slide[
  == Touying Equation

  #touying-equation(`
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  `)

  #meanwhile

  Touying equation is very simple.
]

// multiple pages for one slide
#slide[
  == Multiple Pages for One Slide

  #lorem(200)
]

// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide[
  == Appendix
]
```


## Acknowledgements

Thanks to...

- [@andreasKroepelin](https://github.com/andreasKroepelin) for the `polylux` package
- [@Enivex](https://github.com/Enivex) for the `metropolis` theme
- [@ntjess](https://github.com/ntjess) for contributing to `fit-to-height`, `fit-to-width` and `cover-with-rect`
