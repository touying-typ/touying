#import "/lib.typ": *
#import themes.simple: *

#show: simple-theme

= Complex Animations

== Mark-Style Functions

At subslide #touying-fn-wrapper((self: none) => str(self.subslide)), we can

use #uncover("2-")[`#uncover` function] for reserving space,

use #only("2-")[`#only` function] for not reserving space,

#alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.

== Callback-Style Functions

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  At subslide #self.subslide, we can

  use #uncover("2-")[`#uncover` function] for reserving space,

  use #only("2-")[`#only` function] for not reserving space,

  #alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
])

== only Function

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #only("1", [First content])
  #only("2", [Second content])
  #only("3", [Third content])
])

== uncover Function

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #uncover("1", [First content])
  #uncover("2-", [Second content])
])

== alternatives Function

#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #alternatives[Ann][Bob][Christopher]
  likes
  #alternatives[chocolate][strawberry][vanilla]
  ice cream.
])