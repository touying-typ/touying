---
sidebar_position: 2
---

# MiTeX

During the process of creating slides, we often already have a LaTeX math equation that we simply want to paste into the slides without transcribing it into a Typst math equation. In such cases, we can use [MiTeX](https://github.com/mitex-rs/mitex).

Example:

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

Touying also provides a `touying-mitex` function, which can be used for example

```example
#import "@preview/touying:0.6.3": *
#import "@preview/mitex:0.2.6": *
#import themes.simple: *
#show: simple-theme

#touying-mitex(mitex, `
  f(x) &= \pause x^2 + 2x + 1  \\
      &= \pause (x + 1)^2  \\
`)
```