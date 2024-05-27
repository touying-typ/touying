---
sidebar_position: 2
---

# MiTeX

During the process of creating slides, we often already have a LaTeX math equation that we simply want to paste into the slides without transcribing it into a Typst math equation. In such cases, we can use [MiTeX](https://github.com/mitex-rs/mitex).

Example:

```typst
#import "@preview/mitex:0.2.3": *

Write inline equations like #mi("x") or #mi[y].

Also block equations (this case is from #text(blue.lighten(20%), link("https://katex.org/")[katex.org])):

#mitex(`
  \newcommand{\f}[2]{#1f(#2)}
  \f\relax{x} = \int_{-\infty}^\infty
    \f\hat\xi\,e^{2 \pi i \xi x}
    \,d\xi
`)
```

![image](https://github.com/mitex-rs/mitex/assets/34951714/c425b2ae-b50b-46a8-a451-4d9e8e70626b)

Touying also provides a `touying-mitex` function, which can be used for example

```typst
#touying-mitex(mitex, `
  f(x) &= \pause x^2 + 2x + 1  \\
      &= \pause (x + 1)^2  \\
`)
```