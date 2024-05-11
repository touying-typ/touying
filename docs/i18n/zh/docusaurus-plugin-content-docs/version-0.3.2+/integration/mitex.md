---
sidebar_position: 2
---

# MiTeX

在创建 slides 的过程中，往往我们已经有了一个 LaTeX 数学公式，只是想贴到 slides 的里面，而不想把它转写成 Typst 数学公式，这时候我们就可以用 [MiTeX](https://github.com/mitex-rs/mitex) 了。

示例：

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
