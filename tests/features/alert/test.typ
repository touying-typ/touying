#import "../../../lib.typ": *
#import themes.simple: *

#show: simple-theme

= Touying Fn Wrapper Raw

== Animation with Alert

Normal explanation.

#pause

#alert[This is an important point!]

== Inside Uncover

Normal explanation.

#uncover("2-")[#alert[This is an important point with uncover!]]


== Around Only

Normal explanation.

#alert[This is an important point, #only("2-", text(style: "italic")[easter egg]) don't miss it!]

//covers recursive cases of alert
== Recursive
#alert[
  This is an important point!

  #alert[
    This is a sub-point that is also important!
  ]
]

== Recursive with pause and meanwhile
#alert[
  This is an important point!

  #pause

  #alert[
    This is a sub-point that is also important!

    #meanwhile

    #alert[Even more details in this sub-sub-point!]
  ]
]

== Recursive from within uncover
Normal explanation.
#uncover("2-")[
  #alert[
    This is an important point that appears with uncover!

    #alert[
      This is a sub-point that is also important!

      #alert[Even more details in this sub-sub-point!]
    ]
  ]
]

== Weird Nesting
#alert[
  This is an important point!

  #effect(text.with(red), "2-")[
    This is an important point that changes color via effect.

    #alert[
      This is a sub-point that is also important!

      #touying-fn-wrapper-raw((self: none) => {
        if self.subslide == 2 {
          "This is a sub-point that also changes color, but in a hacky way, could also use utils.effect instead."
        } else {
          text(
            blue,
          )[This is a sub-point that also changes color, but in a hacky way, could also use utils.effect instead.]
        }
      })
    ]
  ]
]
