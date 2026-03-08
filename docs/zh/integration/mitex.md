---
sidebar_position: 2
---

# MiTeX

在创建 slides 的过程中，往往我们已经有了一个 LaTeX 数学公式，只是想贴到 slides 的里面，而不想把它转写成 Typst 数学公式，这时候我们就可以用 [MiTeX](https://github.com/mitex-rs/mitex) 了。

示例：

```example
#import "@preview/mitex:0.2.6": *

Write inline equations like #mi("x") or #mi[y].

Also block equations (this case is from #text(blue.lighten(20%), link("https://katex.org/")[katex.org])):

#mitex(`
  \newcommand{\f}[2]{#1f(#2)}
  \f\relax{x} = \int_{-\infty}^\infty
    \f\hat\xi\,e^{2 \pi i \xi x}
    \,d\xi
`)
```

Touying 也提供了一个 `touying-mitex` 函数，用法如

```example
#import "@preview/touying:0.6.2": *
#import "@preview/mitex:0.2.6": *
#import themes.simple: *
#show: simple-theme

#touying-mitex(mitex, `
  f(x) &= \pause x^2 + 2x + 1  \\
      &= \pause (x + 1)^2  \\
`)
```