---
sidebar_position: 5
---

# Codly

When using Codly, we should initialize it using the `config-common(preamble: {..})` method.

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/codly:1.0.0": *

#show: codly-init.with()

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(preamble: {
    codly(languages: (
      rust: (
        name: "Rust",
        icon: text(font: "tabler-icons", "\u{fa53}"),
        color: rgb("#CE412B"),
      ),
    ))
  }),
)

== First slide

#raw(lang: "rust", block: true,
`pub fn main() {
  println!("Hello, world!");
}`.text)
```
