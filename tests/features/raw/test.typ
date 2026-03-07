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

= Raw Code Block Animations

== Normal Mode with pause and meanwhile

#touying-raw(```rust
fn main() {
    // pause
    println!("Hello, world!");
    // pause
    println!("Goodbye!");
    // meanwhile
}
```)

== fill-empty-lines disabled

#touying-raw(fill-empty-lines: false, ```js
function foo() {
    // pause
    return 42;
    // pause
    return 0;
}
```)

== Simple mode

#touying-raw(simple: true, ```rust
fn main() { #pause;println!("Hello!");#meanwhile; }
```)
