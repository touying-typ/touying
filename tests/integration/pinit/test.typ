#import "/lib.typ": *
#import themes.default: *
#import "@preview/pinit:0.2.2": *

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

#show: default-theme.with(aspect-ratio: "4-3")

// Main body
#slide[
  #set heading(offset: 0)

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

  #pinit-point-to("que", fill: crimson, redbold[No.])
  #pinit-point-from("ans", body-dx: -150pt)[
    Show that the equation $(3/2)^n >= c$ \
    has infinitely many solutions for $n$.
  ]
]