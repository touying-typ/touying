---
sidebar_position: 6
---

# Theorion

Touying 能够与 [Theorion](https://github.com/OrangeX4/typst-theorion) 包一起正常工作，你可以直接使用 [Theorion](https://github.com/OrangeX4/typst-theorion) 包。其中，你还可以使用 `#set heading(numbering: "1.1")` 为 sections 和 subsections 设置 numbering。

**注意：为了让 `#pause` 等动画命令与 theorion 一起正常工作，你需要使用 `config-common(frozen-counters: (theorem-counter,))` 来绑定需要冻结的计数器。**

```example
#import "@preview/touying:0.7.0": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.5.0": *
#import cosmos.clouds: *
#show: show-theorion

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(frozen-counters: (theorem-counter,)),  // freeze theorem counter for animation
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

= Theorems

== Prime numbers

#definition[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]
#example[
  The numbers $2$, $3$, and $17$ are prime.
  @cor_largest_prime shows that this list is not exhaustive!
]

#pause

#theorem(title: "Euclid")[
  There are infinitely many primes.
]

#pagebreak(weak: true)

#proof[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$. Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

#corollary[
  There is no largest prime number.
] <cor_largest_prime>
#corollary[
  There are infinitely many composite numbers.
]

#theorem[
  There are arbitrarily long stretches of composite numbers.
]

#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n
  $
]
```

## 为什么需要 `frozen-counters`

Touying 通过重新求值幻灯片内容来渲染每个子幻灯片。若不使用 `frozen-counters`，Theorion 内部的 `theorem-counter` 会在每个子幻灯片上递增，导致定理编号意外跳变。

`config-common(frozen-counters: (theorem-counter,))` 会告知 Touying 在每张幻灯片开始时捕获计数器的值，并在渲染每个子幻灯片前将其恢复，从而保证动画步骤间的定理编号保持一致。

## 冻结多个计数器

如果你还有需要冻结的图表计数器，可以这样配置：

```typst
config-common(frozen-counters: (theorem-counter, figure.where(kind: image)))
```

## Cosmos 样式

Theorion 内置了多种视觉样式。上述示例使用的是 `cosmos.clouds`，此外还有 `cosmos.fancy`、`cosmos.aurora` 等。详情请参阅 [Theorion 文档](https://github.com/OrangeX4/typst-theorion)。
