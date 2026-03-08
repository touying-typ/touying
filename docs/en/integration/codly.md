---
sidebar_position: 5
---

# Codly

When using Codly, we should initialize it using the `config-common(preamble: {..})` method.

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(preamble: {
    codly(languages: codly-languages)
  }),
)

== First slide

#raw(lang: "rust", block: true,
`pub fn main() {
  println!("Hello, world!");
}`.text)
```
