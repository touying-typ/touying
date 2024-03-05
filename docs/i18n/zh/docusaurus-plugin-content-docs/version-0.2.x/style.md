---
sidebar_position: 4
---

# 代码风格

## show-slides 风格

如果我们只是需要简单使用，我们可以通过 `#show: slides` 实现更简洁的语法。

但是这样做也有对应的弊端：第一个弊端是这种方式可能会极大地影响文档渲染性能，第二个弊端是后续不能直接加入 `#slide(..)`，而是需要手动标记 `#slides-end`，以及最大的弊端是实现不了复杂的功能。

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

并且你可以使用空标题 `==` 创建一个新页。


## slide-block 风格

为了更优秀的性能和更强大的能力，大部分情况我们还是需要使用

```typst
#slide[
  A new slide.
]
```

这样的代码风格。