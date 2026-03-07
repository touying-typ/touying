#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Raw Code Block Animations

== Normal Mode with pause

#touying-raw(```rust
fn main() {
    // pause
    println!("Hello, world!");
    // pause
    println!("Goodbye!");
}
```)

== Normal Mode with meanwhile

#touying-raw(```python
def greet():
    // meanwhile
    print("hi")
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
fn main() {
#pause;
    println!("Hello!");
#pause;
    println!("World!");
}
```)

== Explicit lang parameter

#touying-raw(lang: "python", fill-empty-lines: true, ```python
x = 1
# pause
y = 2
# pause
z = 3
```)
