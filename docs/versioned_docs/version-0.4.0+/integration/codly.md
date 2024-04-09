---
sidebar_position: 5
---

# Codly

When using Codly, we should initialize it using the `s.methods.append-preamble` method.

```typst
#import "@preview/touying:0.4.0": *
#import "@preview/codly:0.2.0": *

#let s = themes.simple.register(aspect-ratio: "16-9")
#let s = (s.methods.append-preamble)(self: s)[
  #codly(languages: (
    rust: (name: "Rust", icon: "\u{fa53}", color: rgb("#CE412B")),
  ))
]
#let (init, slides) = utils.methods(s)
#show heading.where(level: 2): set block(below: 1em)
#show: init
#show: codly-init.with()

#let (slide, empty-slide) = utils.slides(s)
#show: slides

#slide[
  == First slide

  #raw(lang: "rust", block: true,
`pub fn main() {
  println!("Hello, world!");
}`.text)
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/0be2fbaf-cc03-4776-932f-259503d5e23a)
