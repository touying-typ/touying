#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Math Equation Animations

== Simple Animation

Touying equation with pause:

$
  f(x) & = pause x^2 + 2x + 1 \
       & = pause (x + 1)^2 \
$

#meanwhile

Touying equation is very simple.

== Complex Animation

#slide(repeat: 6, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  Solving the quadratic equation $x^2 + 4x + 3 = 0$:

  $
                x^2 + 4x + 3 & = 0 \
     uncover("2-", x^2 + 4x) & = uncover("2-", -3) \
    only("3-", x^2 + 4x + 4) & = only("3-", -3 + 4) \
    uncover("4-", (x + 2)^2) & = uncover("4-", 1) \
           only("5-", x + 2) & = only("5-", ±1) \
            uncover("6-", x) & = uncover("6-", -2 ± 1) \
  $

  #meanwhile

  #alternatives[
    *Step 1:* Original equation
  ][
    *Step 2:* Move constant to right side
  ][
    *Step 3:* Add 4 to both sides to complete the square
  ][
    *Step 4:* Factor as perfect square
  ][
    *Step 5:* Take square root of both sides
  ][
    *Step 6:* Subtract 2 from both sides: $x = -1$ or $x = -3$
  ]
])
