#import "/lib.typ": *
#import themes.simple: *
#import "@preview/mitex:0.2.6": *

#show: simple-theme

= Math Equation Animations

== Simple Animation

Touying equation with pause:

// TODO: fix touying mitex bug
$
  f(x) & = pause x^2 + 2x + 1 \
       & = pause (x + 1)^2 \
$

#meanwhile

Touying equation is very simple.

== touying-mitex Follows set math.equation

// `touying-mitex` passes `numbering` and `supplement` on only when they were
// given, so `set math.equation(..)` applies.

#set math.equation(numbering: "(1)", supplement: [Eq.])

#touying-mitex(mitex, `f(x) = \pause x^2`)
