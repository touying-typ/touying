#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Math Equation Numbering Tests

== Basic Equation Numbering

#set math.equation(numbering: "(1)")

Here's a numbered equation:

$ x^2 + y^2 = z^2 $ <pythagorean>

And another one:

$ E = m c^2 $ <einstein>

== Different Numbering Styles

#set math.equation(numbering: "[1]")

Square bracket numbering:

$ a^2 + b^2 = c^2 $

$ integral_0^1 x^2 dif x = 1/3 $

== Roman Numeral Numbering

#set math.equation(numbering: "(I)")

Roman numeral style:

$ sum_(i=1)^n i = (n(n+1))/2 $

$ lim_(x -> 0) (sin x)/x = 1 $

== Custom Numbering Format

#set math.equation(numbering: "Eq. 1")

Custom prefix style:

$ f(x) = x^3 - 2x^2 + x - 1 $

$ g(x) = e^x + ln(x) $

== Referencing Numbered Equations

We can reference equations like @pythagorean and @einstein from earlier slides.

$ h(x) = sin(x) + cos(x) $ <trig>

Now we can reference this new equation @trig as well.

== Unnumbered Equations

#set math.equation(numbering: none)

These equations won't have numbers:

$ x + y = z $

$ alpha + beta = gamma $