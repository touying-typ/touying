---
sidebar_position: 6
---

# Theorion

Touying can work properly with the [Theorion](https://github.com/OrangeX4/typst-theorion) package, you can directly use the [theorion](https://github.com/OrangeX4/typst-theorion) package. Additionally, you can use `#set heading(numbering: "1.1")` to set numbering for sections and subsections.

**Note: To make animation commands like `#pause` work properly with theorion, you need to use `config-common(frozen-counters: (theorem-counter,))` to bind counters that need to be frozen.**

```example
#import "@preview/touying:0.6.2": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
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