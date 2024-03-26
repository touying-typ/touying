---
sidebar_position: 1
---

# Pinit

[Pinit](https://github.com/OrangeX4/typst-pinit/) 包其提供了一个基于页面绝对定位与基于「图钉」pins 相对定位的能力，可以很方便地为 slides 实现箭头指示与解释说明的效果。

## 简单示例

```typst
#import "@preview/pinit:0.1.3": *

#set text(size: 24pt)

A simple #pin(1)highlighted text#pin(2).

#pinit-highlight(1, 2)

#pinit-point-from(2)[It is simple.]
```

![image](https://github.com/touying-typ/touying/assets/34951714/b17f9b80-5a8b-4943-a222-bcb0eb38611d)

另一个 [示例](https://github.com/OrangeX4/typst-pinit/blob/main/examples/equation-desc.typ)：

![image](https://github.com/touying-typ/touying/assets/34951714/9b4a6b50-fcfd-497d-9649-ae1f7762ee3f)



## 复杂示例

![image](https://github.com/touying-typ/touying/assets/34951714/7fb0095a-fd86-49ec-af95-15bc81a341c2)


一个与 Touying 共同使用的示例：

```typst
#import "@preview/touying:0.3.3": *
#import "@preview/pinit:0.1.3": *

#(s.page-args.paper = "presentation-4-3")
#let (init, slides) = utils.methods(s)
#show: init

#set text(size: 20pt, font: "Calibri", ligatures: false)
#show heading: set text(weight: "regular")
#show heading: set block(above: 1.4em, below: 1em)
#show heading.where(level: 1): set text(size: 1.5em)

// Useful functions
#let crimson = rgb("#c00000")
#let greybox(..args, body) = rect(fill: luma(95%), stroke: 0.5pt, inset: 0pt, outset: 10pt, ..args, body)
#let redbold(body) = {
  set text(fill: crimson, weight: "bold")
  body
}
#let blueit(body) = {
  set text(fill: blue)
  body
}

#let (slide, empty-slide) = utils.slides(s)
#show: slides

// Main body
#slide(self => [
  #let (uncover, only) = utils.methods(self)

  = Asymptotic Notation: $O$

  Use #pin("h1")asymptotic notations#pin("h2") to describe asymptotic efficiency of algorithms.
  (Ignore constant coefficients and lower-order terms.)

  #pause

  #greybox[
    Given a function $g(n)$, we denote by $O(g(n))$ the following *set of functions*:
    #redbold(${f(n): "exists" c > 0 "and" n_0 > 0, "such that" f(n) <= c dot g(n) "for all" n >= n_0}$)
  ]

  #pinit-highlight("h1", "h2")

  #pause

  $f(n) = O(g(n))$: #pin(1)$f(n)$ is *asymptotically smaller* than $g(n)$.#pin(2)

  // #absolute-place(dx: 550pt, dy: 320pt, image(width: 25%, "asymptotic.png"))

  #pause

  $f(n) redbold(in) O(g(n))$: $f(n)$ is *asymptotically* #redbold[at most] $g(n)$.

  #only("4-", pinit-line(stroke: 3pt + crimson, start-dy: -0.25em, end-dy: -0.25em, 1, 2))

  #pause

  #block[Insertion Sort as an #pin("r1")example#pin("r2"):]

  - Best Case: $T(n) approx c n + c' n - c''$ #pin(3)
  - Worst case: $T(n) approx c n + (c' \/ 2) n^2 - c''$ #pin(4)

  #pinit-rect("r1", "r2")

  #pause

  #pinit-place(3, dx: 15pt, dy: -15pt)[#redbold[$T(n) = O(n)$]]
  #pinit-place(4, dx: 15pt, dy: -15pt)[#redbold[$T(n) = O(n)$]]

  #pause

  #blueit[Q: Is $n^(3) = O(n^2)$#pin("que")? How to prove your answer#pin("ans")?]

  #pause

  #only("8-", pinit-point-to("que", fill: crimson, redbold[No.]))
  #only("8-", pinit-point-from("ans", body-dx: -150pt)[
    Show that the equation $(3/2)^n >= c$ \
    has infinitely many solutions for $n$.
  ])
])
```

![image](https://github.com/touying-typ/touying/assets/34951714/f36a026f-491c-4290-90d5-0aa3c2086567)
