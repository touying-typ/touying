---
sidebar_position: 3
---

# Math Equation Animations

Touying also provides a unique and highly useful feature—math equation animations, allowing you to conveniently use `pause` and `meanwhile` within math equations.

## Simple Animation

Let's start with an example:

```typst
#slide[
  Touying equation with pause:

  #touying-equation(`
    f(x) &= pause x^2 + 2x + 1  \
         &= pause (x + 1)^2  \
  `)

  #meanwhile

  Touying equation is very simple.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/d176e61f-c0da-4c2a-a1bf-52621be5adb2)

We use the `touying-equation` function to incorporate `pause` and `meanwhile` within the text of math equations (in fact, you can also use `#pause` or `#pause;`).

As you would expect, the math equation is displayed step by step, making it suitable for presenters to demonstrate their math reasoning.

:::warning[Warning]

While the `touying-equation` function is convenient, you should always be aware that it doesn't perform complex syntax analysis. It simply splits the string using regular expressions. Therefore, you should not use `pause` or `meanwhile` within functions like `display(..)`!

:::

## Complex Animation

In fact, we can also use `only`, `uncover`, and `alternatives` within `touying-equation` with a little trick:

```typst
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

    #touying-equation(scope: (uncover: uncover), `
    f(x) &= pause x^2 + 2x + uncover("3-", 1)  \
         &= pause (x + 1)^2  \
  `)
])
```

![image](https://github.com/touying-typ/touying/assets/34951714/f2df14a2-6424-4c53-81f7-1595aa330660)

We can pass the functions we need into the `touying-equation` through the `scope` parameter, such as `uncover` in this example.

## Parameters

The function definition of `touying-equation` is:

```typst
#let touying-equation(block: true, numbering: none, supplement: auto, scope: (:), body) = { .. }
```

Therefore, you can pass parameters like `block`, `numbering`, and `supplement` to `touying-equation` just like using normal math equations.