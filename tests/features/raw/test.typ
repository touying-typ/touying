#import "/lib.typ": *
#import themes.simple: *

#show raw.where(block: true): body => block(
  width: 100%,
  fill: luma(240),
  outset: (x: 0pt, y: 8pt),
  inset: (x: 16pt, y: 8pt),
  radius: 8pt,
  {
    set par(justify: false)
    body
  },
)
#show: simple-theme

== Normal Mode with pause and meanwhile

#touying-raw(```rust
fn main() {
    // pause
    println!("Hello, world!");
    // meanwhile
}
```)

== fill-empty-lines disabled

#touying-raw(fill-empty-lines: false, ```js
function foo() {
    // pause
    return 42;
}
```)

== Simple mode

#touying-raw(simple: true, ```rust
fn main() { #pause;println!("Hello!");#meanwhile; }
```)

== Unset Language Follows set raw

// `touying-raw` passes `lang` on only when it was given, so `set raw(lang: ..)`
// applies to a body without a language of its own. `lang: none` still turns
// highlighting off.

#set raw(lang: "rust")

#touying-raw("fn main() {\n    // pause\n    println!(\"Hello!\");\n}")

#touying-raw(lang: none, "fn main() {}")
