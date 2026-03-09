---
sidebar_position: 3
---

# Math Equation Animations

Touying also provides a unique and highly useful feature—math equation animations, allowing you to conveniently use `pause` and `meanwhile` within math equations.

## Simple Animation

Let's start with an example:

```example
>>> #import "@preview/touying:0.6.3": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Touying equation with pause:

  $
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  $

  #meanwhile

  Touying equation is very simple.
]
```

We use the `touying-equation` function to incorporate `pause` and `meanwhile` within the text of math equations (in fact, you can also use `#pause` or `#pause;`).

As you would expect, the math equation is displayed step by step, making it suitable for presenters to demonstrate their math reasoning.

## Complex Animation

In fact, we can also use `only`, `uncover`, and `alternatives`:

```example
>>> #import "@preview/touying:0.6.3": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  $
    f(x) &= pause x^2 + 2x + uncover("3-", 1)  \
         &= pause (x + 1)^2  \
  $
])
```