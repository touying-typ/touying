#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Math Equation Numbering Tests

== Basic Equation Numbering

#set math.equation(numbering: "(1)")

Here's a numbered equation:

$ x^2 + y^2 = z^2 $ <pythagorean>

#pause

And another one:

$ E = m c^2 $ <einstein>
