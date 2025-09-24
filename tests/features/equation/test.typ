#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Math Equation Animations

== Simple Animation

Touying equation with pause:

$
  f(x) &= pause x^2 + 2x + 1  \
       &= pause (x + 1)^2  \
$

#meanwhile

Touying equation is very simple.

== Complex Animation

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  $
    f(x) &= pause x^2 + 2x + uncover("3-", 1)  \
         &= pause (x + 1)^2  \
  $
])