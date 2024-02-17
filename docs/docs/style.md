---
sidebar_position: 4
---

# Code Styles

## show-slides Style

If we only need simplicity, we can use `#show: slides` for a cleaner syntax.

However, this approach has corresponding drawbacks: firstly, this method may significantly impact document rendering performance. Secondly, subsequent `#slide(..)` cannot be added directly. Instead, you need to manually mark `#slides-end`. The most significant drawback is that complex functionalities cannot be achieved.

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

#slides-end

#slide[
  A new slide.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/db2a1b60-bc56-4fa9-a317-ee9ecc6f3895)

And you can create a new page with the empty header `==`.


## slide-block Style

For better performance and more powerful capabilities, in most cases, we still need to use the code style like:

```typst
#slide[
  A new slide.
]
```