---
sidebar_position: 3
---

# 数学公式动画

Touying 还提供了一个独特且十分有用的功能，即数学公式动画，它让你可以方便地在数学公式里使用 `pause` 和 `meanwhile`。

## 简单动画

让我们先来看一个例子：

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


我们使用 `touying-equation` 函数来实现在数学公式文本内部使用 `pause` 和 `meanwhile`（事实上，你也能用 `#pause` 或者 `#pause;`）。

正如你料想的一样，数学公式会分步显示，这很适合给让演讲者演示自己的数学公式推理思路。

:::warning[警告]

虽然 `touying-equation` 函数很便利，但是您需要时刻注意，`touying-equation` 并不会做复杂的语法分析，只是单纯地正则表达式分割字符串，因此您不应在 `display(..)` 这类函数内部使用 `pause` 或 `meanwhile`！

:::


## 复杂动画

事实上，我们也可以在 `touying-equation` 内部使用 `only`、`uncover` 和 `alternatives`，只是需要一点技巧：

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


我们可以在 `touying-equation` 的 `scope` 参数中将我们需要用到的函数传递进去，例如这里的 `uncover`。


## 参数

`touying-equation` 的函数定义为

```typst
#let touying-equation(block: true, numbering: none, supplement: auto, scope: (:), body) = { .. }
```

因此，我们可以像使用普通数学公式一样，为 `touying-equation` 传入 `block`、`numbering` 和 `supplement` 参数。