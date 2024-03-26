---
sidebar_position: 5
---

# Codly

在使用 codly 的时候，我们应该使用 `s.methods.append-preamble` 方法进行初始化。

```typst
#import "@preview/touying:0.3.3": *
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
