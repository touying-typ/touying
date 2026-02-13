#import "/lib.typ": *
#import themes.simple: *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#show: codly-init.with()

#show: simple-theme.with(
  aspect-ratio: "16-9",
  // Enable Codly with common preamble
  config-common(preamble: {
    codly(languages: codly-languages)
  }),
)

== First slide

```rust
pub fn main() {
  println!("Hello, world!");
}
```
