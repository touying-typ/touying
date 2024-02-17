---
sidebar_position: 2
---

# Getting Started

Before you begin, make sure you have installed the Typst environment. If not, you can use the [Web App](https://typst.app/) or the Typst LSP and Typst Preview plugins for VS Code.

To use Touying, you only need to include the following code in your document:

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, slides) = utils.methods(s)
#show: init

#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/6f15b500-b825-4db1-88ff-34212f43723e)

It's simple. Congratulations on creating your first Touying slide! 🎉

## More Complex Examples

In fact, Touying provides various styles for writing slides. For example, the above example uses first-level and second-level titles to create new slides. However, you can also use the `#slide[..]` format to access more powerful features provided by Touying.

```typst
#import "@preview/touying:0.2.1": *

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

![image](https://github.com/touying-typ/touying/assets/34951714/192b13f9-e3fb-4327-864b-fd9084a8ca24)

In addition, Touying provides many built-in themes to easily create beautiful slides. Basically, you just need to add a line at the top of your document:

```
#let s = themes.metropolis.register(s, aspect-ratio: "16-9")
```

This will allow you to use the Metropolis theme. For more detailed tutorials, you can refer to the following chapters.